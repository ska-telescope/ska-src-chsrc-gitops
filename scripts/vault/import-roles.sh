#!/bin/bash

# Loop through all the JSON backup files
for file in *_backup.json; do
    # Extract the role name from the filename
    role_name=$(basename "$file" _backup.json)

    echo "Importing role: $role_name"
    
    # Import the role into Vault
    vault write auth/kubernetes/role/$role_name @$file

    if [ $? -eq 0 ]; then
        echo "Role $role_name successfully imported."
    else
        echo "Failed to import role $role_name."
    fi
done
