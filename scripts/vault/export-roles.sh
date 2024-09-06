#!/bin/bash

# List all roles
roles=$(vault list -format=json auth/kubernetes/role | jq -r '.[]')

# Loop through each role and export its configuration
for role in $roles; do
    echo "Exporting role: $role"
    vault read -format=json auth/kubernetes/role/$role > "${role}_backup.json"
done
