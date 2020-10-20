#!/bin/bash

die()
{
	echo
	echo "$*" 1>&2 ; echo ; exit 1;
 }

helm del --purge vault
helm del --purge consul

echo
echo "Waiting a bit for pods to stop...."
echo
sleep 10

is_vault_pods_found=`kubectl get pods | grep "vault-" | grep Running`
if [[ ! -z $is_vault_pods_found ]]; then
	die "Vault pods were found and are still running."
fi

is_consul_pods_found=`kubectl get pods | grep "consul-" | grep Running`
if [[ ! -z $is_consul_pods_found ]]; then
	die "Consul pods were found and are still running."
fi

mv cluster-keys.json cluster-keys-$(date +%Y-%m-%d_%H-%M-%S).json

kubectl delete persistentvolumeclaims data-default-consul-consul-server-0
[ $? -eq 0 ] || die "Unable to delete persistent volume claim for consul (Already deleted?)..."

