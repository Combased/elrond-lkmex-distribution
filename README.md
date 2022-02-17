### elrond-lkmex-distribution

**The script for distributing LKMEX (or any other [ESDT](https://docs.elrond.com/developers/esdt-tokens/) token!) to all Your NFTs collection holders 😎!**

Inspired by the [Elrond script utils](https://github.com/ElrondNetwork/script-utils) (we'll unify our scripts in near future).

#### How it works
The script gets the addresses from all collection holders, it excludes **marketplaces** and the owner address/SC address.

Then it distributes your **total** provided LKMEX (ESDT token) for all NFTs holders. The more NFTs the wallet address has - the more LKMEX it gets 🤑.

#### Known limitations & improvements

Right now LKMEX is divided evenly by all addresses. For instance, if the wallet address holds 10 NFTS, he will get **10 transactions** with an equal LKMEX amount.

The gas fee is **cheap** indeed, but it is the most important priority right now to stack the LKMEX and send only a **single transaction per wallet** 🧐.

#### Getting started

You need to interact only with the **distribute.sh** file.

To make this distribution work for your NFTs collection you can configure it like this:

##### 1. Configuring Python
You need to have Python installed on your machine or in the virtual environment 🤓.

Check your Python version by running:

```shell
$ python3 --version
```

Then you should modify the **distribute.sh** script to match your Python version: 

**PYTHON_BINARY=python3.8**

After that run

```shell
$ pip install -r requirements.txt
```

##### 2. Provide the wallet.pem file
You need to generate a wallet.pem file from your secret seed phrase. You can read [here](https://docs.elrond.com/sdk-and-tools/erdpy/deriving-the-wallet-pem-file/) (**check the warning**).

##### 3. Modifying the constants

You need to modify the following constants:

```shell
# Identifier of the collection. Check the collection row https://explorer.elrond.com/collections/COMBEYS-bc640d
NFT_COLLECTION_IDENTIFIER=Your collection identifier
# Null if Smart Contract does not hold NFTs for distribution. Provide an address if it holds.
SMART_CONTRACT_ADDRESS=null
# The collection identifier of the tokens that will be distributed. Check the collection row in the example: https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef
TOKEN_COLLECTION_IDENTIFIER=LKMEX-aab910
# Check the identifier row and extract the nonce. As an example: LKMEX-aab910-22e4ef has the nonce 22e4ef 
TOKEN_NONCE=22e4ef
# The amount of decimals of the token. Check the decimals row in the example: https://explorer.elrond.com/nfts/LKMEX-aab910-22e4ef For LKMEX it is 18
TOKEN_DECIMALS=18
# The total amount which will be divided and distributed to all NFTs owners.
TOKEN_TOTAL=500000
# Select `mainnet`, `testnet` or `devnet`
PROXY="mainnet"
```
##### 4. Run the script!
Congrats, open the terminal and run **./distribute.sh**. Check the **output** folder for information, which can be displayed in the Discord or your website 🥳! 
#### Contact me
- [Twitter](https://twitter.com/wellbranding)
