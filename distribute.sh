#!/bin/sh
PYTHON_BINARY=python3.8
GAS_LIMIT=500000
OWNER_WALLET=wallet.pem

### Need to modify #####
# Identifier of the collection. Check the collection row in the example: https://explorer.elrond.com/collections/COMBEYS-bc640d
NFT_COLLECTION_IDENTIFIER=SHIRE-e6ab2d
# Leave it `null` if the Smart Contract does not hold NFTs for distribution. Provide an address if it holds.
SMART_CONTRACT_ADDRESS=null
# The collection identifier of the tokens that will be distributed. Check the collection row in the example: https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef
TOKEN_COLLECTION_IDENTIFIER_IN_HEX=LEMBAS-b25809
# Check the identifier row and extract the nonce. As an example: LKMEX-aab910-22e4ef has the nonce 22e4ef 
TOKEN_NONCE=01
# The amount of decimals of the token. Check the decimals row in the example: https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef
TOKEN_DECIMALS=18
# The total amount to will be divided and distributed to all NFTs owners.
TOKEN_TOTAL=500
# Select `mainnet`, `testnet` or `devnet`
PROXY="devnet"
#######################

# See https://docs.elrond.com/sdk-and-tools/erdpy/configuring-erdpy/
# if proxy is mainnet, testnet or devnet, set proxy and chainId to different values
if [ "$PROXY" = "mainnet" ]; then
    PROXY_PREFIX=""
    PROXY="https://gateway.elrond.com"
    CHAIN="1"
elif [ "$PROXY" = "testnet" ]; then
    PROXY_PREFIX="testnet"
    PROXY="https://testnet-api.elrond.com"
    CHAIN="T"
elif [ "$PROXY" = "devnet" ]; then
    PROXY_PREFIX="devnet"
    PROXY="https://devnet-gateway.elrond.com"
    CHAIN="D"
fi

OWNER_ADDRESS=$(erdpy wallet pem-address $OWNER_WALLET)
set -ex
DATA=$($PYTHON_BINARY ./prepare-args.py get-addresses $NFT_COLLECTION_IDENTIFIER $SMART_CONTRACT_ADDRESS $OWNER_ADDRESS $TOKEN_COLLECTION_IDENTIFIER_IN_HEX $TOKEN_NONCE $TOKEN_DECIMALS $TOKEN_TOTAL $PROXY_PREFIX)
set -f
all_addresses=($(echo "$DATA" | tr ' ' '\n'))

quantity_in_hex=${all_addresses[0]}
token_in_hex="0x${all_addresses[1]}"
lkmex_nonce_in_hex="0x$TOKEN_NONCE"
for address in "${all_addresses[@]:2}"
do
   destination_address=`erdpy wallet bech32 --decode $address| sed 's/^.*= //'`
   destination_address="0x$destination_address"
   erdpy contract call $OWNER_ADDRESS --function ESDTNFTTransfer --arguments $token_in_hex $lkmex_nonce_in_hex $quantity_in_hex $destination_address --proxy $PROXY --recall-nonce --gas-limit $GAS_LIMIT --chain $CHAIN --pem wallet.pem --send
   sleep 15
done