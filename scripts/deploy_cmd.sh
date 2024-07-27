    dfx deploy icrc1 --argument "( record {               
        name = \"PEPE\";                         
        symbol = \"PEPE\";                           
        decimals = 8;                               
        fee = 42069; 
        max_supply = 420_436_954_965;
        logo = \"data:image/jpeg;base64,$(base64 -w 0 clown-logo.jpg)\";                                        
        initial_balances = vec {                                
            record {                                            
                record {
                    owner = principal \"qhw6f-yij7k-sctbp-fwu7v-4lm72-efdwp-7qizz-cuxd3-tn3qb-53hxn-iae\";   
                    subaccount = null;                          
                };                                              
                420_436_954_965
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

