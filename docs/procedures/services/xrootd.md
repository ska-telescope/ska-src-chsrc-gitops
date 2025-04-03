# XRootD Procedures

The procedures below are useful for verifying the correct functioning of our RSE, as well as for verifying that the tokens are properly configured.

## Token verification

To upload data, you need an OIDC client that has the `storage.create:/` and `wclg` scopes.
On jwt.io you can paste and decode your token and see which scopes it has.

If you have an existing client but it's missing that scope, you can add it as follows:

* Head over to the [SKA-IAM clients dashboard](https://ska-iam.stfc.ac.uk/dashboard#!/home/clients) and locate your client.
* Go to your client > Scopes tab > make sure that `storage.create:/` and `wlcg` are checked. Save client.
* Back on your machine, you'll have to update the client. If your client was called `ska-iam` you would run: `oidc-gen -m ska-iam`.
* Use all the defaults from oidc-gen, except in the scopes, where you would add `storage.create:/` and `wclg`. Once finished it will ask to re-authenticate.

Now you should be able to generate a token with the scope using `oidc-token ska-iam` (adjust using your client name as need be).

!!! Tip "Read and modify scopes are restricted"
    Please note that with the above instructions you will abe able to upload (create) data.
    You will **not be able to read or modify** any files. Not even the files that you upload.
    For reading and modifying, the `storage.read:/` and `storage.modify:/` scopes are required.
    However, these are restricted scopes, and an **SKA-IAM admin** needs to enable those for your client.

## Upload data

To upload a file to the dev RSE, first obtain a valid token (see above):

```bash
curl -T test.txt -H "Authorization: Bearer $BEARER_TOKEN" https://xrootd.dev.skach.org/data/test.txt
:-)
```

## Read data

To read a file from the dev RSE, use:

```bash
curl -H "Authorization: Bearer $BEARER_TOKEN" https://xrootd.dev.skach.org/data/test.txt
Hello SKACH
```