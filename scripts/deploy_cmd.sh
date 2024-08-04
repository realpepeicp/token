#!/bin/bash
NETWORK=${1:-local}
OPTIONS=$2

echo "Deploying the contract on network '$NETWORK' with additional options '$OPTIONS'..."

dfx deploy icrc1 --argument "( record {               
    name = \"PEPE\";                         
    symbol = \"PEPE\";                           
    decimals = 8;                               
    fee = 4_200_0000_0000; 
    max_supply = 420_436_954_965_0000_0000;
    logo = \"data:image/jpeg;base64,$(base64 -w 0 pepe.jpg)\";                                        
    initial_balances = vec {                                
        record {                                            
            record {
                owner = principal \"qhw6f-yij7k-sctbp-fwu7v-4lm72-efdwp-7qizz-cuxd3-tn3qb-53hxn-iae\";   
                subaccount = null;                          
            };                                              
            420_436_954_965_0000_0000
        };                                                   
    };                                                             
    min_burn_amount = 400_0000_0000;
    minting_account = (
        opt record {
            owner=principal \"qhw6f-yij7k-sctbp-fwu7v-4lm72-efdwp-7qizz-cuxd3-tn3qb-53hxn-iae\"; 
            subaccount=null
        }
    );
    advanced_settings = null;
})" --network=$NETWORK $OPTIONS

