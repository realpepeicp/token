    dfx deploy icrc1 --argument "( record {               
        name = \"PEPE\";                         
        symbol = \"PEPE\";                           
        decimals = 8;                               
        fee = 420; 
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
        min_burn_amount = 400;
        minting_account = (
            opt record {
                owner=principal \"4mdxv-6ua6c-okz4e-3kau3-texi2-hvmuk-ll7jy-hzbr3-fr2bc-zjx7k-tqe\"; 
                subaccount=null
            }
        );
        advanced_settings = null;
    })" --network ic  --mode reinstall

