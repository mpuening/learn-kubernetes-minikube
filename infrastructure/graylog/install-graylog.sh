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

kubectl apply -f ./graylog-mongodb.yml
[ $? -eq 0 ] || die "Unable to install mongodb..."

kubectl apply -f ./graylog-elasticsearch.yml
[ $? -eq 0 ] || die "Unable to install elastic search..."

# We split the service from the application to get an assigned external IP
kubectl apply -f ./graylog-service.yml
[ $? -eq 0 ] || die "Unable to install graylog service..."

echo
echo "Waiting for graylog services to start..."
echo
sleep 5

GRAYLOG_PASSWORD_SECRET_VALUE=`openssl rand -base64 18 | tr -d '\n'`
GRAYLOG_ROOT_PASSWORD_SHA2_VALUE=`echo password | tr -d '\n' | sha256sum | cut -d" " -f1`
GRAYLOG_HTTP_EXTERNAL_URI_VALUE=`minikube service graylog-application --url | head -1`
GRAYLOG_TRAILING_SLASH=/
GRAYLOG_HTTP_EXTERNAL_URI_VALUE_WITH_SLASH=$GRAYLOG_HTTP_EXTERNAL_URI_VALUE$GRAYLOG_TRAILING_SLASH

#echo $GRAYLOG_PASSWORD_SECRET_VALUE
#echo $GRAYLOG_ROOT_PASSWORD_SHA2_VALUE
#echo $GRAYLOG_HTTP_EXTERNAL_URI_VALUE_WITH_SLASH

# Replace variables with values using sed
cat graylog-application.yml | \
	sed "s~GRAYLOG_PASSWORD_SECRET_VALUE~$GRAYLOG_PASSWORD_SECRET_VALUE~g" | \
	sed "s~GRAYLOG_ROOT_PASSWORD_SHA2_VALUE~$GRAYLOG_ROOT_PASSWORD_SHA2_VALUE~g" | \
	sed "s~GRAYLOG_HTTP_EXTERNAL_URI_VALUE~$GRAYLOG_HTTP_EXTERNAL_URI_VALUE_WITH_SLASH~g" | \
	kubectl apply -f -

echo
echo "Waiting a minute or two for graylog application to start..."
echo
sleep 120

./create-streams.sh

# LDAP Integration?
# https://annaken.github.io/using-graylogs-rest-api/

# Alerts?
# https://gist.github.com/mariussturm/0b885812500d91df8c3a
