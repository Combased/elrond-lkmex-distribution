#!/bin/sh
PYTHON_BINARY=python3.8
GAS_LIMIT=500000

### Need to modify #####
# Identifier of the collection. Check the collection row in the example: https://explorer.elrond.com/collections/COMBEYS-bc640d
NFT_COLLECTION_IDENTIFIER=COMBEYS-bc640d
# Leave it `null` if the Smart Contract does not hold NFTs for distribution. Provide an address if it holds.
SMART_CONTRACT_ADDRESS=erd1qqqqqqqqqqqqqpgqxesrq4yltexyy29ejwj8qrc9cz8p08evmkdqqxl7e4
# Select `mainnet`, `testnet` or `devnet`
PROXY="mainnet"
# Owner address or could be the holder address of the most NFTs, which should not be counted :)
OWNER_ADDRESS=erd1gkn5eppdkrkpyaq852vkgkqudg62qmsfy4nvdyj9w07eed2nmkdq9rgrk5
# Specify how many consecutive days the holder address should keep NFT without performing transactions
DAYS_OF_HOLDING_NFT=10
#######################

# See https://docs.elrond.com/sdk-and-tools/erdpy/configuring-erdpy/
# if proxy is mainnet, testnet or devnet, set proxy and chainId to different values
if [ "$PROXY" = "mainnet" ]; then
    PROXY_PREFIX=" "
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

set -ex
DATA=$($PYTHON_BINARY ./owners-list.py get_duration_of_holding $NFT_COLLECTION_IDENTIFIER $SMART_CONTRACT_ADDRESS $OWNER_ADDRESS $PROXY_PREFIX $DAYS_OF_HOLDING_NFT)