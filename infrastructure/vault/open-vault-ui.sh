#!/bin/sh

root_token=`cat cluster-keys.json | jq -r ".root_token"`

echo
echo "Log into Vault with this token: $root_token"
echo
echo "Opening browser now...."
echo
minikube service vault-ui

