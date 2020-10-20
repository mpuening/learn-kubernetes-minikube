#!/bin/bash

# Commands derived from https://learn.hashicorp.com/vault/getting-started-k8s/minikube

die()
{
	echo
	echo "$*" 1>&2 ; echo ; exit 1;
}

is_vault_pods_found=`kubectl get pods | grep "vault-" | grep Running`
if [[ -z $is_vault_pods_found ]]; then
	die "Vault pods were not found or are not running."
fi

if [ ! -f cluster-keys.json ]; then
	kubectl exec -it vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
else
	echo
	echo "It appears as though vault-0 has already been initialized..."
	echo
	echo "If not the case, then run the command below and try again..."
	echo
	echo "    mv cluster-keys.json cluster-keys-$(date +%Y-%m-%d_%H-%M-%S).json"
	echo
	exit 1
fi

root_token=`cat cluster-keys.json | jq -r ".root_token"`
if [[ -z $root-token ]]; then
	die "Root token was not found."
fi

kubectl exec -it vault-0 -- vault operator unseal `cat cluster-keys.json | jq -r ".unseal_keys_b64[]"`
[ $? -eq 0 ] || die "Unable to unseal vault=0..."

kubectl exec -it vault-1 -- vault operator unseal `cat cluster-keys.json | jq -r ".unseal_keys_b64[]"`
[ $? -eq 0 ] || die "Unable to unseal vault=1..."

kubectl exec -it vault-2 -- vault operator unseal `cat cluster-keys.json | jq -r ".unseal_keys_b64[]"`
[ $? -eq 0 ] || die "Unable to unseal vault=2..."

is_vault_pods_found2=`kubectl get pods | grep "vault-" | grep Running`
if [[ -z $is_vault_pods_found2 ]]; then
	# Or run: helm del --purge vault; to delete it
	die "Vault pods were not found or are not running."
fi

cat << EOF | kubectl exec -it vault-0 -- /bin/sh
vault login $root_token
vault secrets enable -path=secret kv-v2
vault kv put secret/webapp/config username="static-user" password="static-password"
vault kv get secret/webapp/config
vault auth enable kubernetes
vault write auth/kubernetes/config \
        token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
        kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
        kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
vault policy write webapp - <<EOH
path "secret/data/webapp/config" {
  capabilities = ["read"]
}
EOH
vault write auth/kubernetes/role/webapp \
        bound_service_account_names=vault \
        bound_service_account_namespaces=default \
        policies=webapp \
        ttl=24h
exit
EOF
