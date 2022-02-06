#!/usr/bin/env python3

import argparse
from datetime import date
from typing import Any, List, Union

import requests

EMOON_ADDRESS = "erd1w9mmxz6533m7cf08gehs8phkun2x4e8689ecfk3makk3dgzsgurszhsxk4"
DEAD_RARE_ADDRESS = "erd1qqqqqqqqqqqqqpgqd9rvv2n378e27jcts8vfwynpx0gfl5ufz6hqhfy0u0"
TRUST_WALLET_ADDRESS = "erd1qqqqqqqqqqqqqpgq6wegs2xkypfpync8mn2sa5cmpqjlvrhwz5nqgepyg8"


def get_addresses_for_lkmex(args: Any) -> str:
    '''
    Gets addresses to send LKMEX
    :param args: Contains a collection identifier, owner address and smart-contract address
    :return: A string with empty spaces to form an array in sh script
    '''

    nft_collection_address = args["collection"]
    sc_address = args["sc_address"]

    r = requests.get('https://api.elrond.com/nfts/{}/owners/?size=10000'.format(nft_collection_address))
    values = r.json()

    # creating a black listed array so that these addresses won't get a LKMEX
    black_listed_addresses = [EMOON_ADDRESS,
                              DEAD_RARE_ADDRESS,
                              TRUST_WALLET_ADDRESS,
                              args["owner_address"]]
    if sc_address != "null":
        black_listed_addresses.append(sc_address)

    today = date.today()
    html_file = today.strftime("%b-%d-%Y.html")
    txt_file = today.strftime("%b-%d-%Y.txt")
    func_html = open("output/unique-{}".format(html_file), "w")
    func_txt = open("output/total-{}".format(txt_file), "w")

    func_html.write("<html>\n<head>\n<title> \nLKMEX Distribution \
               </title>\n</head> <body><h1>All addresses</u></h1>\
               ")
    addresses_return_to_sh = ""
    unique_addresses_list = []
    count = 0
    for value in values:
        address = value["address"]
        if address not in black_listed_addresses:
            addresses_return_to_sh += address + " "
            count = count + 1
            # txt writing
            func_txt.write(address + "\n")

            # unique addresses for html
            if address not in unique_addresses_list:
                unique_addresses_list.append(address)

    # forming HTML file
    for unique_address in unique_addresses_list:
        func_html.write(
            "\n<a href='https://explorer.elrond.com/accounts/{}'>{}\n</a>".format(unique_address, unique_address))
        func_html.write("</br>")

    func_html.write("\n</body></html>")
    func_html.close()
    func_txt.write("Total count is " + str(count) + "\n")
    func_txt.close()

    # calculating LKMEX amount to distribute to each wallet address
    lkmex_total = int(args["lkmex_total"])
    per_wallet = int((lkmex_total / count * 10 ** 18))
    quantity_in_hex = hex(per_wallet)
    # attaching to returned string as first argument
    addresses_return_to_sh = quantity_in_hex + " " + addresses_return_to_sh
    print(addresses_return_to_sh)
    return addresses_return_to_sh


def pad_even(arg: str) -> str:
    '''
    Pads the argument with a zero, if needed, so that the number of hex-digits is even.

>>> pad_even('4d2b3')
'04d2b3'
>>> pad_even('c0ffee')
'c0ffee'
    '''
    new_length = len(arg) + len(arg) % 2
    return arg.rjust(new_length, '0')


def hex_encode_int(arg: int) -> str:
    '''
    Hex-encodes an int.

>>> hex_encode_int(1234)
'04d2'
    '''
    return pad_even(f'{arg:x}')


def hex_encode_string(arg: str) -> str:
    '''
    Hex-encodes a string.

>>> hex_encode_string('\\ntest')
'0a74657374'
    '''
    return ''.join(f'{ord(c):02x}' for c in arg)


def join_arguments(args: List[str]) -> str:
    return '@'.join(args)


def hex_encode(arg: Union[str, int]) -> str:
    '''
    Hex-encodes an argument or a list of arguments.

>>> hex_encode('\\ntest')
'0a74657374'
>>> hex_encode(1234)
'04d2'
>>> hex_encode([1234, 'test'])
'04d2@74657374'
>>> hex_encode([10, 11, [12, 13]])
'0a@0b@0c@0d'
    '''
    if isinstance(arg, int):
        return hex_encode_int(arg)
    elif isinstance(arg, str):
        return hex_encode_string(arg)
    else:
        raise Exception(f'Invalid argument: {arg}')


def prepare_args(args: Any) -> str:
    return get_addresses_for_lkmex(args)


parser = argparse.ArgumentParser(description='Prepare the data field for a given command from a JSON.')
parser.add_argument('command', help='Command to prepare', nargs='?',
                    choices=('get-addresses', 'hex_encode'))
parser.add_argument('collection', type=str, help='Collection identifier')
parser.add_argument('sc_address', type=str, help='Smart contract wallet address', default=None)
parser.add_argument('owner_address', type=str, help='Owner wallet address')
parser.add_argument("lkmex_nonce", type=str, help="LKMEX nonce identifier")
parser.add_argument('lkmex_total', type=str, help='Total LKMEX value in decimal, natural numbers only')
cli_args = parser.parse_args()
tx_args = {"collection": cli_args.collection,
           "sc_address": cli_args.sc_address,
           "owner_address": cli_args.owner_address,
           "lkmex_nonce": cli_args.lkmex_nonce,
           "lkmex_total": cli_args.lkmex_total}
tx_data = prepare_args(tx_args)
