#!/bin/bash

# Loop through all the JSON backup files
for file in *_backup.json; do
    # Extract the role name from the filename
    role_name=$(basename "$file" _backup.json)

    echo "Importing role: $role_name"
    
    # Import the role into Vault

    # Extract necessary fields from JSON using jq, providing default values for missing or null fields
    alias_name_source=$(jq -r '.data.alias_name_source' "$file")
    bound_service_account_names=$(jq -r '.data.bound_service_account_names | select(. != null) | join(",")' "$file")
    bound_service_account_namespaces=$(jq -r '.data.bound_service_account_namespaces | select(. != null) | join(",")' "$file")
    bound_service_account_namespace_selector=$(jq -r '.data.bound_service_account_namespace_selector // ""' "$file")
    policies=$(jq -r '.data.policies | select(. != null) | join(",")' "$file")
    token_ttl=$(jq -r '.data.token_ttl // empty' "$file")
    ttl=$(jq -r '.data.ttl // empty' "$file")

    # Build the vault write command, skipping fields if they're empty
    vault_cmd="vault write auth/kubernetes/role/$role_name alias_name_source=\"$alias_name_source\" bound_service_account_names=\"$bound_service_account_names\" bound_service_account_namespaces=\"$bound_service_account_namespaces\" bound_service_account_namespace_selector=\"$bound_service_account_namespace_selector\" policies=\"$policies\""

    # Append TTL fields only if they are non-empty
    if [ -n "$token_ttl" ]; then
        vault_cmd+=" token_ttl=\"$token_ttl\""
    fi

    if [ -n "$ttl" ]; then
        vault_cmd+=" ttl=\"$ttl\""
    fi

    # Execute the command
    eval $vault_cmd

    if [ $? -eq 0 ]; then
        echo "Role $role_name successfully imported."
    else
        echo "Failed to import role $role_name."
    fi
done
