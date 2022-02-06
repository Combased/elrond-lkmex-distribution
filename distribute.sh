#!/bin/sh

PYTHON_BINARY=python3.8
LKMEX_COLLECTION_IDENTIFIER_IN_HEX=0x4c4b4d45582d616162393130
GAS_LIMIT=500000
OWNER_WALLET=wallet.pem

###Needs to modify#####
# Identifier of the collection. Check the collection row https://explorer.elrond.com/collections/COMBEYS-bc640d
NFT_COLLECTION_IDENTIFIER=COMBEYS-bc640d
# Null if Smart Contract does not hold NFTs for distribution. Provide an address if it holds.
SMART_CONTRACT_ADDRESS=null
# Found in Elrond Explorer. Check the identifier row and extract the nonce https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef
LKMEX_NONCE=22e4ef
# The total amount to distribute to the NFTs owners
LKMEX_TOTAL=150000

# Configuration https://docs.elrond.com/sdk-and-tools/erdpy/configuring-erdpy/
PROXY="https://gateway.elrond.com"
CHAIN="1"

OWNER_ADDRESS=$(erdpy wallet pem-address $OWNER_WALLET)
set -ex
DATA=$($PYTHON_BINARY ./prepare-args.py get-addresses $NFT_COLLECTION_IDENTIFIER $SMART_CONTRACT_ADDRESS $OWNER_ADDRESS $LKMEX_NONCE $LKMEX_TOTAL)
set -f
all_addresses=($(echo "$DATA" | tr ' ' '\n'))

quantity_in_hex=$all_addresses[1]
lkmex_nonce_in_hex="0x$LKMEX_NONCE"
for address in "${all_addresses[@]:1}"
do
   destination_address=`erdpy wallet bech32 --decode $address| sed 's/^.*= //'`
   destination_address="0x$destination_address"
   erdpy contract call $OWNER_ADDRESS --function ESDTNFTTransfer --arguments $LKMEX_COLLECTION_IDENTIFIER_IN_HEX $lkmex_nonce_in_hex $quantity_in_hex $destination_address --proxy $PROXY --recall-nonce --gas-limit $GAS_LIMIT --chain $CHAIN --pem wallet.pem --send
   sleep 15
done