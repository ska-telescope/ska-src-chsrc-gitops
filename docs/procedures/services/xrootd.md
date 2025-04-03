# XRootD Procedures

The procedures below are useful for verifying the correct functioning of our RSE, as well as for verifying that the tokens are properly configured.


## Upload data using the rucio client

Using the rucio client is a straightforward way to upload data. You will need docker to run the [client](https://gitlab.com/ska-telescope/src/src-dm/ska-src-dm-da-rucio-client). Please note that these instructions use a specific client version, but a [newer container version may be available](https://gitlab.com/ska-telescope/src/src-dm/ska-src-dm-da-rucio-client/container_registry/6685306).

On our xrootd-based RSE, you need special token scopes to **create**, **read**, or **modify** data files.
These permissions correspond to `storage.create:/`, `storage.read:/`, and `storage.modify:/` respectively, where the path after the `:` represents where those permissions apply.

Therefore, you will need to ask for these scopes explicitly when requesting a token.
This does not necessarily apply to all RSEs.

### Running the Rucio Client

Running the client, make sure you use an account username that corresponds to your SKA-IAM username (i.e. substituting `$USER` accordingly).

```bash
docker run -it --rm \
    -e RUCIO_CFG_CLIENT_ACCOUNT=$USER
    -e RUCIO_CFG_CLIENT_OIDC_SCOPE="openid profile offline_access wlcg.groups storage.create:/" \
    registry.gitlab.com/ska-telescope/src/src-dm/ska-src-dm-da-rucio-client:release-35.6.0
```

If you need to mount a local file, you can add a volume mount, e.g.: `-v /Users/llopis/Downloads/PSZ2_G052.35-31.98-mosaic.fits:/mnt/PSZ2_G052.35-31.98-mosaic.fits`

To get a valid authentication token, run:

```bash
rucio whoami
```

Then follow the auth flow as requested.

### Data Upload

Finally, you can upload data to a target RSE and namespace.
The data files will be deleted after the specified lifetime (in seconds) expires.
For example:

```bash
rucio -vvv upload --rse CHSRC_XRD_DEV --lifetime 3600 --scope chocolate --register-after-upload test.txt
```

## Upload data using cURL

!!! Tip
    While using cURL can be useful for debugging, it is easier to upload files using the rucio client.

### Token verification

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

### Upload data

To upload a file to the dev RSE, first obtain a valid token (see above):

```bash
curl -T test.txt -H "Authorization: Bearer $BEARER_TOKEN" https://xrootd.dev.skach.org/data/test.txt
:-)
```

### Read data

To read a file from the dev RSE, use:

```bash
curl -H "Authorization: Bearer $BEARER_TOKEN" https://xrootd.dev.skach.org/data/test.txt
Hello SKACH
```
