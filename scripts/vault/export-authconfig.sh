#!/bin/bash
vault read -format=json auth/kubernetes/config > kubernetes_auth_config.json
