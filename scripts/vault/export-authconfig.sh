#!/bin/bash
vault read -format=json auth/kubernetes/config | jq -r '.data' > kubernetes_auth_config.json
