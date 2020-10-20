#!/bin/bash

# Commands derived from https://learn.hashicorp.com/vault/getting-started-k8s/minikube

die()
{
	echo
	echo "$*" 1>&2 ; echo ; exit 1;
}

helm init
[ $? -eq 0 ] || die "Unable to helm init..."

is_tiller_pod_found=`kubectl get pods --namespace kube-system | grep tiller-deploy | grep Running`
if [[ -z $is_tiller_pod_found ]]; then
	die "Tiller-deploy pod was not found or is not running."
fi

helm install --name consul \
	--values ./helm-consul-values.yml \
	https://github.com/hashicorp/consul-helm/archive/v0.15.0.tar.gz

echo
echo "Waiting a bit for consul pods to start..."
echo
sleep 15

is_consul_pods_found=`kubectl get pods | grep consul-consul | grep Running`
if [[ -z $is_consul_pods_found ]]; then
	# Or run: helm del --purge consul; to delete it
	die "Consul pods were not found or are not running."
fi

helm install --name vault \
    --values ./helm-vault-values.yml \
    https://github.com/hashicorp/vault-helm/archive/v0.3.0.tar.gz

echo
echo "Waiting a bit for vault pods to start..."
echo
sleep 15

is_vault_pods_found=`kubectl get pods | grep "vault-" | grep Running`
if [[ -z $is_vault_pods_found ]]; then
	# Or run: helm del --purge vault; to delete it
	die "Vault pods were not found or are not running."
fi

./unseal-vault.sh

