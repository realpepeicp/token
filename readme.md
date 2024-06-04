# ALIEN ICRC-1 
This repo contains the source code for the ALIEN ICRC1 token, 
a fork of [SNEED](https://github.com/icsneed/sneed) fork of the [NatLabs implementation](https://github.com/NatLabs/icrc1) of the [ICRC-1](https://github.com/dfinity/ICRC-1) token standard. 

Created as a celebration for [ICPCC24](https://www.icp-cc.com/)

# Important Instruction!!

In the file ./src/ICRC1/Canisters/Archive.mo on line 29

Update the canister id to your ledger canister id
The current code looks like this:

    let original_canister_id = Principal.fromText("7tvr6-fqaaa-aaaan-qmira-cai");

## The rest of the readme

NB: A logo field has been added to the construction arguments. Below is the example from NatLabs, modified to include the logo field.
    
  - Replace the values enclosed in `< >` with your desired values and run in the terminal 

  ```motoko
    cd alien-token
    mops install
    dfx start --background --clean

    dfx deploy icrc1 --argument '( record {                     
        name = "ALIEN";                         
        symbol = "ALIEN";                           
        decimals = 8;                                           
        fee = 420;                                        
        logo = "data:image/jpeg;base64,$(base64 -w 0 alien-logo.jpg)";                                        
        max_supply = 42_000_000_000_0000_0000;                         
        initial_balances = vec {                                
            record {                                            
                record {
                    owner = principal "peg2s-47dqj-7dnez-bznad-kclyo-rxbc7-oor7s-wc3kx-e5k23-ziivp-oqe";   
                    subaccount = null;                          
                };                                              
                2_100_000_000_0000_0000
            };                                                   
            record {                                            
                record {
                    owner = principal "rdqvh-7d7ja-mt3xe-mxeqh-ejo26-piyo7-s2ap2-klyfw-ljixo-gehot-pae";   
                    subaccount = null;                          
                };                                              
                18_900_000_000_0000_0000 
            };
            record {                                            
                record {
                    owner = principal "fi3zi-fyaaa-aaaaq-aachq-cai";   
                    subaccount = opt vec {139 : nat8;8 : nat8;5 : nat8;148 : nat8;44 : nat8;72 : nat8;179 : nat8;66 : nat8;13 : nat8;110 : nat8;223 : nat8;254 : nat8;203 : nat8;182 : nat8;133 : nat8;232 : nat8;195 : nat8;158 : nat8;245 : nat8;116 : nat8;97 : nat8;42 : nat8;93 : nat8;138 : nat8;145 : nat8;31 : nat8;176 : nat8;104 : nat8;191 : nat8;102 : nat8;72 : nat8;222 : nat8};
                };                                              
                21_000_000_000_0000_0000
            };
        };                                                             
        min_burn_amount = 10_000;                         
        minting_account = (
            opt record {
                owner=principal "wprcj-xlqbs-h2qiy-7kh56-ghbl7-kt3hd-ojqgz-cvjrj-robhr-5jlhf-aae"; 
                subaccount=null
            }
        );

        advanced_settings = null;                               
    })'
  ```

## Funding

This source code was forked from a library that was initially incentivized by [ICDevs](https://icdevs.org/). You can view more about the bounty on the [forum](https://forum.dfinity.org/t/completed-icdevs-org-bounty-26-icrc-1-motoko-up-to-10k/14868/54) or [website](https://icdevs.org/bounties/2022/08/14/ICRC-1-Motoko.html). The bounty was funded by The ICDevs.org community and the DFINITY Foundation and the award was paid to [@NatLabs](https://github.com/NatLabs). If you use this source code or the library it was forked from and gain value from it, please consider a [donation](https://icdevs.org/donations.html) to ICDevs.
