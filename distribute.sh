#!/bin/sh
PYTHON_BINARY=python3.8
GAS_LIMIT=500000
OWNER_WALLET=wallet.pem

### Need to modify #####
# Identifier of the collection. Check the collection row in the example: https://explorer.elrond.com/collections/COMBEYS-bc640d
NFT_COLLECTION_IDENTIFIER=COMBEYS-bc640d
# Leave it `null` if the Smart Contract does not hold NFTs for distribution. Provide an address if it holds.
SMART_CONTRACT_ADDRESS=null
# The collection identifier of the tokens that will be distributed. Check the collection row in the example: https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef
TOKEN_COLLECTION_IDENTIFIER=LKMEX-aab910
# Check the identifier row and extract the nonce. As an example: LKMEX-aab910-22e4ef has the nonce 22e4ef 
TOKEN_NONCE=22e4ef
# The amount of decimals of the token. Check the decimals row in the example: https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef For LKMEX it is 18
TOKEN_DECIMALS=18
# The total amount which will be divided and distributed to all NFTs owners.
TOKEN_TOTAL=50000000
# Select `mainnet`, `testnet` or `devnet`
PROXY="mainnet"
# Specify the required holding NFT duration in days. If not, leave -1;
DURATION_OF_HOLDING=10
# To filter NFTs based on type
FILTER_TRAIT_TYPE=-1
# To filter NFTs based on value
FILTER_TRAIT_VALUE=-1
#######################

# See https://docs.elrond.com/sdk-and-tools/erdpy/configuring-erdpy/
# if proxy is mainnet, testnet or devnet, set proxy and chainId to different values
if [ "$PROXY" = "mainnet" ]; then
    PROXY_PREFIX="&"
    PROXY="https://gateway.elrond.com"
    CHAIN="1"
elif [ "$PROXY" = "testnet" ]; then
    PROXY_PREFIX="testnet-"
    PROXY="https://testnet-api.elrond.com"
    CHAIN="T"
elif [ "$PROXY" = "devnet" ]; then
    PROXY_PREFIX="devnet-"
    PROXY="https://devnet-gateway.elrond.com"
    CHAIN="D"
fi

OWNER_ADDRESS=$(erdpy wallet pem-address $OWNER_WALLET)
set -ex
DATA=$($PYTHON_BINARY ./prepare-args.py get-addresses $NFT_COLLECTION_IDENTIFIER $SMART_CONTRACT_ADDRESS $OWNER_ADDRESS $TOKEN_COLLECTION_IDENTIFIER $TOKEN_NONCE $TOKEN_DECIMALS $TOKEN_TOTAL $PROXY_PREFIX $DURATION_OF_HOLDING $FILTER_TRAIT_TYPE $FILTER_TRAIT_VALUE)
set -f
all_addresses=($(echo "$DATA" | tr ' ' '\n'))
quantity_in_hex=${all_addresses[1]}
token_in_hex="0x${all_addresses[2]}"
token_nonce_in_hex="0x$TOKEN_NONCE"

while IFS="," read -r address_column esdt_value_colum random
do
  echo $address_column
  destination_address=`erdpy wallet bech32 --decode $address_column| sed 's/^.*= //'`
  destination_address="0x$destination_address"

  # Transfers LKMEX or any other NFT based ESDT
  erdpy contract call $OWNER_ADDRESS --function ESDTNFTTransfer --arguments $token_in_hex $token_nonce_in_hex "${esdt_value_colum}" $destination_address --proxy $PROXY --recall-nonce --gas-limit $GAS_LIMIT --chain $CHAIN --pem wallet.pem --send

  # Uncomment to transfer RIDE, UTK or any other ESDT
  # erdpy contract call $address_column --function ESDTTransfer --arguments $token_in_hex "${esdt_value_colum}" --proxy $PROXY --recall-nonce --gas-limit $GAS_LIMIT --chain $CHAIN --pem wallet.pem --send

  # Uncomment to transfer EGLD
  #erdpy --verbose tx new --receiver $address_column --value=${esdt_value_colum} --proxy $PROXY --recall-nonce --gas-limit $GAS_LIMIT --chain $CHAIN --pem wallet.pem --send

  sleep 20
done < <(tail -n +2 "output/${NFT_COLLECTION_IDENTIFIER}-esdt-per-address.csv")