#!/bin/bash

# List all policies and export each into a separate file
for policy in $(vault policy list); do
  echo "Exporting policy: $policy"

  # Export each policy to a separate file named <policy-name>_backup.hcl
  vault policy read $policy > "${policy}_backup.hcl"

  if [ $? -eq 0 ]; then
      echo "Policy $policy successfully exported to ${policy}_backup.hcl."
  else
      echo "Failed to export policy $policy."
  fi
done
