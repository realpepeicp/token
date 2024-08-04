#!/bin/bash

dfx canister call  icrc1 icrc1_transfer '(record{
  to = record{
    owner = principal "qhw6f-yij7k-sctbp-fwu7v-4lm72-efdwp-7qizz-cuxd3-tn3qb-53hxn-iae";
    subaccount = null;
  };
  amount = 40_200_000_000_000;
})' --network=local
