import argparse
import csv
import time
from datetime import datetime, timedelta
from pathlib import Path
from typing import Any

import requests

EMOON_ADDRESS = "erd1w9mmxz6533m7cf08gehs8phkun2x4e8689ecfk3makk3dgzsgurszhsxk4"
DEAD_RARE_ADDRESS = "erd1qqqqqqqqqqqqqpgqd9rvv2n378e27jcts8vfwynpx0gfl5ufz6hqhfy0u0"
TRUST_WALLET_ADDRESS = "erd1qqqqqqqqqqqqqpgq6wegs2xkypfpync8mn2sa5cmpqjlvrhwz5nqgepyg8"


class AddressNftData:
    def __init__(self, address, nfts_total, nfts_available):
        self.address = address
        self.nfts_total = nfts_total
        self.nfts_available = nfts_available

    def __str__(self):
        return self.address + "-" + str(self.nfts_total) + "-" + str(self.nfts_available)


def get_duration_of_holding(args: Any):
    nft_collection_name = args["collection"]
    sc_address = args["sc_address"]
    proxy_prefix = args["proxy_prefix"]
    days_of_holding = int(args["days_of_holding"])

    api_url = f"https://{proxy_prefix}api.elrond.com/nfts/{nft_collection_name}/owners/?size=10000"
    r = requests.get(api_url)
    values = r.json()

    # creating a black listed array so that these addresses won't get the token
    black_listed_addresses = [EMOON_ADDRESS,
                              DEAD_RARE_ADDRESS,
                              TRUST_WALLET_ADDRESS,
                              args["owner_address"]]
    if sc_address != "null":
        black_listed_addresses.append(sc_address)

    addresses_return_to_sh = ""
    unique_addresses_list = []
    count = 0
    for value in values:
        address = value["address"]
        if address not in black_listed_addresses:
            addresses_return_to_sh += address + " "
            count = count + 1

            # unique addresses for html
            if address not in unique_addresses_list:
                unique_addresses_list.append(address)

    current_date = datetime.now()
    end_date = current_date + timedelta(days=-days_of_holding)
    timestamp = end_date.timestamp()
    timestamp = int(timestamp)

    nft_collection_name = args["collection"]
    proxy_prefix = args["proxy_prefix"]
    address_nft_data = []
    txt_file = current_date.strftime(f"%b-%d-%Y-with-duration-{nft_collection_name}.txt")
    name_of_file = "output/{}".format(txt_file)

    p = Path('output')
    p.mkdir(parents=True, exist_ok=True)
    func_txt = open(name_of_file, "w")
    for address in unique_addresses_list:
        api_url = f"https://{proxy_prefix}api.elrond.com/accounts/{address}/nfts?size=10000&search={nft_collection_name}"
        r = requests.get(api_url)
        nfts = r.json()
        all_nfts = len(nfts)
        eligible_nfts = all_nfts
        # sleeping to not hit the API calls limits
        time.sleep(0.3)
        for nft in nfts:
            time.sleep(0.3)
            nft_identifier = nft["identifier"]
            # checking if buy transactions occurred, cause airdrops don't appear on it
            transactions_with_nfts_url = f"https://api.elrond.com/transactions?status=success&token={nft_identifier}&after={timestamp}"
            r = requests.get(transactions_with_nfts_url)
            txs = r.json()
            if len(txs) != 0:
                # found transactions, subtracting from eligible nfts
                eligible_nfts = eligible_nfts - 1

        # creating an entry
        address_nft_data_entry = AddressNftData(address, all_nfts, eligible_nfts)
        print(address_nft_data_entry)
        address_nft_data.append(address_nft_data_entry)

    # sort nfts
    address_nft_data = sorted(address_nft_data, key=lambda x: (x.nfts_available, x.nfts_total), reverse=True)
    result_csv = current_date.strftime(f"output/%b-%d-%Y-with-duration-{nft_collection_name}")
    # write results
    with open(current_date.strftime(f"{result_csv}.csv"), "wt") as fp:
        writer = csv.writer(fp, delimiter=",")
        writer.writerow(["Wallet address", "total nfts", f"nfts in wallet for {days_of_holding} days"])  # write header
        func_txt.write("Wallet address" + " " + "Total nfts" + "  " + f"nfts in wallet for {days_of_holding} days" "\n")
        for output in address_nft_data:
            func_txt.write(output.__str__() + "\n")
            writer.writerow([output.address, output.nfts_total, output.nfts_available])

        func_txt.close()


def prepare_args(args: Any):
    get_duration_of_holding(args)


parser = argparse.ArgumentParser(description='Prepare the data field for a given command from a JSON.')
parser.add_argument('command', help='Command to prepare', nargs='?',
                    choices=('get-addresses', 'hex_encode', 'get_duration_of_holding'))
parser.add_argument('collection', type=str, help='NFT collection name')
parser.add_argument('sc_address', type=str, help='Smart contract wallet address', default=None)
parser.add_argument('owner_address', type=str, help='Owner wallet address')
parser.add_argument('proxy_prefix', type=str, help='Proxy prefix for urls')
parser.add_argument('days_of_holding', type=str, help='Days of holding NFT in wallet')
cli_args = parser.parse_args()
tx_args = {"collection": cli_args.collection,
           "sc_address": cli_args.sc_address,
           "owner_address": cli_args.owner_address,
           "proxy_prefix": cli_args.proxy_prefix.strip(),
           "days_of_holding": cli_args.days_of_holding}
tx_data = prepare_args(tx_args)

# if __name__ == '__main__':
#     get_duration_of_holding(
#         {"sc_address": "erd1kkpqqm9ekycugn6zkchsgralcepx8uxzeefldpwua7wwkj5p9fuse7j7ed", "collection": "CQLCRN-e6e99d",
#          "proxy_prefix": "", "owner_address": "erd17frjmjj93klz0w9gh0xj76atp8lk7h2k4uhawe8yp5g0rusprn0qm7n49c",
#          "days_of_holding": "2"})
