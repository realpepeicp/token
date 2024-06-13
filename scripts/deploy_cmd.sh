    dfx deploy icrc1 --argument "( record {               
        name = \"Insane Clown Protocol\";                         
        symbol = \"CLOWN\";                           
        decimals = 8;                               
        fee = 0.0005; 
        max_supply = 1_000_000_000_0000_0000;
        logo = \"data:image/jpeg;base64,$(base64 -w 0 clown-logo.jpg)\";                                        
        initial_balances = vec {                                
            record {                                            
                record {
                    owner = principal \"d5jbw-krtiv-v5xi4-jj6cf-53euc-vlcbd-u73lb-wlwdj-a5ijb-evlu4-qqe\";   
                    subaccount = null;                          
                };                                              
                1_000_000_000_0000_0000
            };                                                   
        };                                                             
        min_burn_amount = 10_000;
        minting_account = (
            opt record {
                owner=principal \"t5kgr-44ker-fn3gq-uqqzo-mskle-2oqhl-dmxlo-25p4u-dbxdx-2c332-dae\"; 
                subaccount=null
            }
        );
        advanced_settings = null;
    })" --network ic  --mode reinstall

