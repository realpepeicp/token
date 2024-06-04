    dfx deploy icrc1 --argument "( record {               
        name = \"ALIEN\";                         
        symbol = \"ALIEN\";                           
        decimals = 8;                               
        fee = 420; 
        max_supply = 42_000_000_000_0000_0000;
        logo = \"data:image/jpeg;base64,$(base64 -w 0 alien-logo.jpg)\";                                        
        initial_balances = vec {                                
            record {                                            
                record {
                    owner = principal \"peg2s-47dqj-7dnez-bznad-kclyo-rxbc7-oor7s-wc3kx-e5k23-ziivp-oqe\";   
                    subaccount = null;                          
                };                                              
                2_100_000_000_0000_0000
            };                                                   
            record {                                            
                record {
                    owner = principal \"rdqvh-7d7ja-mt3xe-mxeqh-ejo26-piyo7-s2ap2-klyfw-ljixo-gehot-pae\";   
                    subaccount = null;                          
                };                                              
                18_900_000_000_0000_0000 
            };
            record {                                            
                record {
                    owner = principal \"fi3zi-fyaaa-aaaaq-aachq-cai\";   
                    subaccount = opt vec {139 : nat8;8 : nat8;5 : nat8;148 : nat8;44 : nat8;72 : nat8;179 : nat8;66 : nat8;13 : nat8;110 : nat8;223 : nat8;254 : nat8;203 : nat8;182 : nat8;133 : nat8;232 : nat8;195 : nat8;158 : nat8;245 : nat8;116 : nat8;97 : nat8;42 : nat8;93 : nat8;138 : nat8;145 : nat8;31 : nat8;176 : nat8;104 : nat8;191 : nat8;102 : nat8;72 : nat8;222 : nat8};
                };                                              
                21_000_000_000_0000_0000
            };
        };                                                             
        min_burn_amount = 10_000;
        minting_account = (
            opt record {
                owner=principal \"wprcj-xlqbs-h2qiy-7kh56-ghbl7-kt3hd-ojqgz-cvjrj-robhr-5jlhf-aae\"; 
                subaccount=null
            }
        );
        advanced_settings = null;
    })" --network ic  --mode reinstall

