#!/bin/bash

# Path to import to (change if needed)
path="app/"

# Enable the KV secrets engine at the path if not already enabled
if ! vault secrets list | grep -q "^${path}"; then
  echo "Enabling KV secrets engine at path: ${path}"
  vault secrets enable -path=${path} kv-v2
else
  echo "KV secrets engine already enabled at path: ${path}"
fi

# Loop through each JSON file in the backup directory
for secret_file in *_secret.json; do
    # Extract the secret name from the filename
    secret_name=$(basename "$secret_file" _secret.json)
    
    echo "Importing secret: ${secret_name}"
    
    # Import the secret back into Vault
    vault kv put ${path}${secret_name} @${secret_file}
    
    if [ $? -eq 0 ]; then
        echo "Secret ${secret_name} successfully imported."
    else
        echo "Failed to import secret ${secret_name}."
    fi
done
