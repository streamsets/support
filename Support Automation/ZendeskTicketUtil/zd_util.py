import zenpy
import json
import os
import argparse
import shutil

from zenpy import Zenpy

# noinspection PyTypeChecker
parser = argparse.ArgumentParser(formatter_class=argparse.RawDescriptionHelpFormatter, description='''\
Handles removal of old ZenDesk ticket directories automatically. 
This script expects that you have a 'conf.json' file in the current directory, which stores
a JSON block with the following format: 
{ \"email\": \"<your-email-address>\", \"token\": \"<zendesk-api-token>\", \"subdomain\": \"streamsets\" }''')
parser.add_argument("-f", "--force", action="store_true",
                    help="Ignore all prompts and forcibly delete any directories without a corresponding"
                         " ticket. Default: false.")
parser.add_argument("-d", "--directory", default='.',
                    help="String. Specify the path to your tickets directory, on which you want the script to run. "
                         "Default: The current directory.")

args = parser.parse_args()

try:
    with open('./creds.json', 'r') as f:
        creds = json.load(f)
except FileNotFoundError:
    raise FileNotFoundError("No creds.json found in current directory. Please make sure one exists before running this"
                            " script.")

ticketNums, rmDirs = [], []
count = 0
caseDir = args.directory
zenpy_client = Zenpy(**creds)

print("Getting list of open Zendesk tickets...")
for ticket in zenpy_client.search("type:ticket status:open status:new status:hold status:pending assignee:"
                                  + creds.get("email")):
    ticketNums.append(str(ticket.id))

# next(os.walk())[1] gets a list of all top-level directories in the path specified, and will avoid any literal files
# and/or subdirectories
for directory in next(os.walk(caseDir))[1]:
    if directory not in ticketNums:
        rmDirs.append(directory)

rmDirs.sort()

if not args.force:
    for item in rmDirs:
        valid = False

        while not valid:
            confirm = input(">Delete directory: " + item + "? (Y/N) ")
            if confirm.upper() == "Y" or confirm.upper() == "YES":
                print("*Deleted* " + item)
                shutil.rmtree(caseDir + "/" + item)
                count += 1
                valid = True
            elif confirm.upper() == "N" or confirm.upper() == "NO":
                print("-Skipping- " + item)
                valid = True
            else:
                print("Invalid input, please specify Y or N...")
else:
    for item in rmDirs:
        print("*Deleted* " + item)
        shutil.rmtree(caseDir + "/" + item)
        count += 1

print("Removal complete. " + str(count) + " directories deleted.")
