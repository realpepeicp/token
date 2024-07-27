import Prim "mo:prim";

import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Debug "mo:base/Debug";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Hash "mo:base/Hash";
import Result "mo:base/Result";

import ExperimentalCycles "mo:base/ExperimentalCycles";
import ExperimentalStableMemory "mo:base/ExperimentalStableMemory";
import Principal "mo:base/Principal";

import Itertools "mo:itertools/Iter";
import StableTrieMap "mo:StableTrieMap";
import U "../Utils";
import T "../Types";

shared ({ caller = ledger_canister_id }) actor class Archive() : async T.ArchiveInterface {

    type Transaction = T.Transaction;
    type MemoryBlock = {
        offset : Nat64;
        size : Nat;
    };

    let original_canister_id = Principal.fromText("4n7ms-zqaaa-aaaal-qjmnq-cai");
    stable let KiB = 1024;
    stable let GiB = KiB ** 3;
    stable let MEMORY_PER_PAGE : Nat64 = Nat64.fromNat(64 * KiB);
    stable let MIN_PAGES : Nat64 = 32; // 2MiB == 32 * 64KiB
    stable var PAGES_TO_GROW : Nat64 = 2048; // 64MiB
    stable let MAX_MEMORY = 32 * GiB;

    stable let BUCKET_SIZE = 1000;
    stable let MAX_TRANSACTIONS_PER_REQUEST = 5000;

    stable let MAX_TXS_LENGTH = 1000;

    stable var memory_pages : Nat64 = ExperimentalStableMemory.size();
    stable var total_memory_used : Nat64 = 0;

    stable var filled_buckets = 0;
    stable var trailing_txs = 0;

    stable let txStore = StableTrieMap.new<Nat, [MemoryBlock]>();
    stable var backupTxStore = StableTrieMap.new<Nat, [MemoryBlock]>();

    stable var prevArchive : T.ArchiveInterface = actor ("aaaaa-aa");
    stable var nextArchive : T.ArchiveInterface = actor ("aaaaa-aa");
    stable var first_tx : Nat = 0;
    stable var last_tx : Nat = 0;

    public shared query func get_prev_archive() : async T.ArchiveInterface {
        prevArchive;
    };

    public shared query func get_next_archive() : async T.ArchiveInterface {
        nextArchive;
    };

    public shared query func get_first_tx() : async Nat {
        first_tx;
    };

    public shared query func get_last_tx() : async Nat {
        last_tx;
    };

    public shared ({ caller }) func set_prev_archive(prev_archive : T.ArchiveInterface) : async Result.Result<(), Text> {

        if (caller != ledger_canister_id) {
            return #err("Unauthorized Access: Only the ledger canister can access this archive canister");
        };

        prevArchive := prev_archive;

        #ok();
    };

    public shared ({ caller }) func set_next_archive(next_archive : T.ArchiveInterface) : async Result.Result<(), Text> {

        if (caller != ledger_canister_id) {
            return #err("Unauthorized Access: Only the ledger canister can access this archive canister");
        };

        nextArchive := next_archive;

        #ok();
    };

    public shared ({ caller }) func set_first_tx(tx : Nat) : async Result.Result<(), Text> {

        if (caller != ledger_canister_id) {
            return #err("Unauthorized Access: Only the ledger canister can access this archive canister");
        };

        first_tx := tx;

        #ok();
    };

    public shared ({ caller }) func set_last_tx(tx : Nat) : async Result.Result<(), Text> {

        if (caller != ledger_canister_id) {
            return #err("Unauthorized Access: Only the ledger canister can access this archive canister");
        };

        last_tx := tx;

        #ok();
    };

    public shared ({ caller }) func append_transactions(txs : [Transaction]) : async Result.Result<(), Text> {
        if (caller != ledger_canister_id and caller != original_canister_id) {
            return #err("Unauthorized Access: Only the ledger canister can access this archive canister");
        };

        // Ensure no pre-registered transaction is stored
        let last_tx_index = get_last_tx_index();
        let filtered_txs = Array.filter<T.Transaction>(txs, func tx = tx.index > last_tx_index);
        var txs_iter = filtered_txs.vals();

        if (trailing_txs > 0) {
            let last_bucket = StableTrieMap.get(
                txStore,
                Nat.equal,
                U.hash,
                filled_buckets,
            );

            switch (last_bucket) {
                case (?last_bucket) {
                    let new_bucket = Iter.toArray(
                        Itertools.take(
                            Itertools.chain(
                                last_bucket.vals(),
                                Iter.map(filtered_txs.vals(), store_tx),
                            ),
                            BUCKET_SIZE,
                        )
                    );

                    if (new_bucket.size() == BUCKET_SIZE) {
                        let offset = (BUCKET_SIZE - last_bucket.size()) : Nat;

                        txs_iter := Itertools.fromArraySlice(filtered_txs, offset, txs.size());
                    } else {
                        txs_iter := Itertools.empty();
                    };

                    store_bucket(new_bucket);
                };
                case (_) {};
            };
        };

        for (chunk in Itertools.chunks(txs_iter, BUCKET_SIZE)) {
            store_bucket(Array.map(chunk, store_tx));
        };

        #ok();
    };

    func get_last_tx_index() : Int {
        if (total_txs() == 0) return -1;

        let bucket_index = if (trailing_txs > 0) filled_buckets else Nat.max(filled_buckets - 1, 0);
        let last_bucket_opt = StableTrieMap.get(
            txStore,
            Nat.equal,
            U.hash,
            bucket_index,
        );

        let last_bucket = switch (last_bucket_opt) {
            case (?last_bucket) last_bucket;
            case (null) Debug.trap("Unexpected Error: Last Bucket not found");
        };

        if (last_bucket.size() == 0) Debug.trap("Unexpected Error: Last Bucket is not filled");

        get_tx(last_bucket[last_bucket.size() - 1]).index;
    };

    func total_txs() : Nat {
        (filled_buckets * BUCKET_SIZE) + trailing_txs;
    };

    public shared query func total_transactions() : async Nat {
        total_txs();
    };

    public shared query func get_transaction(tx_index : T.TxIndex) : async ?Transaction {
        let tx_max = Nat.max(tx_index, first_tx);
        let tx_off : Nat = tx_max - first_tx;
        let bucket_key = tx_off / BUCKET_SIZE;

        let opt_bucket = StableTrieMap.get(
            txStore,
            Nat.equal,
            U.hash,
            bucket_key,
        );

        switch (opt_bucket) {
            case (?bucket) {
                let i = tx_off % BUCKET_SIZE;
                if (i < bucket.size()) {
                    ?get_tx(bucket[tx_off % BUCKET_SIZE]);
                } else {
                    null;
                };
            };
            case (_) {
                null;
            };
        };
    };

    public shared query func get_transactions(req : T.GetTransactionsRequest) : async T.TransactionRange {
        let { start; length } = req;

        let length_max = Nat.max(0, length);
        let length_min = Nat.min(MAX_TXS_LENGTH, length_max);

        let start_max = Nat.max(start, first_tx);
        let start_off : Nat = start_max - first_tx;
        let end = start_off + length_min;
        let start_bucket = start_off / BUCKET_SIZE;
        let end_bucket = (Nat.min(end, total_txs()) / BUCKET_SIZE) + 1;

        get_transactions_from_buckets(start_off, end, start_bucket, end_bucket);
    };

    public shared query func remaining_capacity() : async Nat {
        MAX_MEMORY - Nat64.toNat(total_memory_used);
    };

    public shared query func max_memory() : async Nat {
        MAX_MEMORY;
    };

    public shared query func total_used() : async Nat {
        Nat64.toNat(total_memory_used);
    };

    /// Deposit cycles into this archive canister.
    public shared func deposit_cycles() : async () {
        let amount = ExperimentalCycles.available();
        let accepted = ExperimentalCycles.accept(amount);
        assert (accepted == amount);
    };

    func get_transactions_from_buckets(start_off : Nat, end : Nat, start_bucket : Nat, end_bucket : Nat) : T.TransactionRange {
        var iter = Itertools.empty<MemoryBlock>();
        label _loop for (i in Itertools.range(start_bucket, end_bucket)) {
            let opt_bucket = StableTrieMap.get(
                txStore,
                Nat.equal,
                U.hash,
                i,
            );

            switch (opt_bucket) {
                case (?bucket) {
                    if (i == start_bucket) {
                        iter := Itertools.fromArraySlice(bucket, start_off % BUCKET_SIZE, Nat.min(bucket.size(), end));
                    } else if (i + 1 == end_bucket) {
                        let bucket_iter = Itertools.fromArraySlice(bucket, 0, end % BUCKET_SIZE);
                        iter := Itertools.chain(iter, bucket_iter);
                    } else {
                        iter := Itertools.chain(iter, bucket.vals());
                    };
                };
                case (_) { break _loop };
            };
        };

        let transactions = Iter.toArray(
            Iter.map(
                Itertools.take(iter, MAX_TRANSACTIONS_PER_REQUEST),
                get_tx,
            )
        );

        { transactions };
    };

    func to_blob(tx : Transaction) : Blob {
        to_candid (tx);
    };

    func from_blob(tx : Blob) : Transaction {
        switch (from_candid (tx) : ?Transaction) {
            case (?tx) tx;
            case (_) Debug.trap("Could not decode tx blob");
        };
    };

    func store_tx(tx : Transaction) : MemoryBlock {
        let blob = to_blob(tx);

        if ((memory_pages * MEMORY_PER_PAGE) - total_memory_used < (MIN_PAGES * MEMORY_PER_PAGE)) {
            ignore ExperimentalStableMemory.grow(PAGES_TO_GROW);
            memory_pages += PAGES_TO_GROW;
        };

        let offset = total_memory_used;

        ExperimentalStableMemory.storeBlob(
            offset,
            blob,
        );

        let mem_block = {
            offset;
            size = blob.size();
        };

        total_memory_used += Nat64.fromNat(blob.size());
        mem_block;
    };

    func get_tx({ offset; size } : MemoryBlock) : Transaction {
        let blob = ExperimentalStableMemory.loadBlob(offset, size);

        let tx = from_blob(blob);
    };

    func store_bucket(bucket : [MemoryBlock]) {

        StableTrieMap.put(
            txStore,
            Nat.equal,
            U.hash,
            filled_buckets,
            bucket,
        );

        if (bucket.size() == BUCKET_SIZE) {
            filled_buckets += 1;
            trailing_txs := 0;
        } else {
            trailing_txs := bucket.size();
        };
    };
};
