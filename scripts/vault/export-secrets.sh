#!/bin/bash

# Path to export from (change if needed)
path="app/"

# List all secrets under the given path
secrets=$(vault kv list -format=json ${path} | jq -r '.[]')

# Export each secret
for secret in $secrets; do
    echo "Exporting secret: ${secret}"

    # Extract only the inner "data" field, that's what the import expects
    vault kv get -format=json ${path}${secret} | jq '.data.data' > ${secret}_secret.json
    
    if [ $? -eq 0 ]; then
        echo "Secret ${secret} successfully exported."
    else
        echo "Failed to export secret ${secret}."
    fi
done
