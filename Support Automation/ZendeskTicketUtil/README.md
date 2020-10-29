This utility will delete directories pertaining to ZenDesk tickets that are no longer open.

Use `python3 zd_util.py -h` for usage instructions.

This script expects that ticket directory you specify contains top-level directory names that are ticket numbers.
For example: /users/me/tickets/
			       |-> 12345
			       |-> 23456
			       |-> 19863

Prerequisites:

	1. Generate an API token in ZenDesk to use for authentication purposes. This can be found under Admin > API >
	   Add API Token in the ZenDesk support portal.
	2. You must create a `creds.json` file in the directory you plan to execute this from. The file should contain a
	   JSON block with the following structure:
		{ "email": "<your-email-address>", "token": "<zendesk-api-token>", "subdomain": "streamsets" }
	3. Install the Zenpy dependency for your version of Python:
		pip install Zenpy
