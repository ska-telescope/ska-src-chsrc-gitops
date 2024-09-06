#!/bin/bash

# Loop through all the *_backup.hcl files
for policy_file in *_backup.hcl; do
    # Extract the policy name from the filename
    policy_name=$(basename "$policy_file" _backup.hcl)

    echo "Importing policy: $policy_name"
    
    # Write the policy back into Vault
    vault policy write "$policy_name" "$policy_file"
    
    if [ $? -eq 0 ]; then
        echo "Policy $policy_name successfully imported."
    else
        echo "Failed to import policy $policy_name."
    fi
done
