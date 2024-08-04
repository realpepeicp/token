#!/bin/bash
NETWORK=${1:-local}
OPTIONS=$2

echo "Updating token logo on network '$NETWORK' with additional options '$OPTIONS'..."                                     
dfx canister call icrc1 set_logo "(\"data:image/png;base64,$(base64 -w 0 pepe.png)\")" --network=$NETWORK $OPTIONS