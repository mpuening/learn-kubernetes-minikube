#!/bin/bash

die()
{
        echo
        echo "$*" 1>&2 ; echo ; exit 1;
}

#is_vault_pods_found=`kubectl get pods | grep "vault-" | grep Running`
#if [[ -z $is_vault_pods_found ]]; then
#        die "Vault pods were not found or are not running. We use vault to store passwords."
#fi

# See example at https://k8s.io/examples/application/mysql/mysql-pv.yaml

kubectl apply -f ./mysql-pv.yml
[ $? -eq 0 ] || die "Unable to install mysql persistent volume..."

echo
echo "Waiting for mysql volume..."
echo
sleep 5

MYSQL_ROOT_PASSWORD_VALUE=`openssl rand -base64 18 | tr -d '\n'`
echo $MYSQL_ROOT_PASSWORD_VALUE

# See example at https://k8s.io/examples/application/mysql/mysql-deployment.yaml

# Replace variables with values using sed
cat mysql-deployment.yml | \
	sed "s~MYSQL_ROOT_PASSWORD_VALUE~$MYSQL_ROOT_PASSWORD_VALUE~g" | \
	kubectl apply -f -
