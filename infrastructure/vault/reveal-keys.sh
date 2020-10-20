#!/bin/sh

root_token=`cat cluster-keys.json | jq -r ".root_token"`
cat << EOF | kubectl exec -it vault-0 -- /bin/sh
vault login $root_token
echo
echo "=============== Example Web App Key ==============="
echo
vault kv get secret/webapp/config
EOF

