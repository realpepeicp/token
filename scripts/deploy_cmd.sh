    dfx deploy icrc1 --argument "( record {               
        name = \"PEPE\";                         
        symbol = \"PEPE\";                           
        decimals = 8;                               
        fee = 42069; 
        max_supply = 420_436_954_965;
        logo = \"data:image/jpeg;base64,$(base64 -w 0 pepe.jpg)\";                                        
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
                owner=principal \"klp6a-qwls4-atsmj-3letr-sehl5-4qynl-a3una-l376r-gear2-pbmst-eqe\"; 
                subaccount=null
            }
        );
        advanced_settings = null;
    })" --network ic  --mode reinstall

