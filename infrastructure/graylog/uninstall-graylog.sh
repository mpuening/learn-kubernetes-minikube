#!/bin/bash

die()
{
        echo
        echo "$*" 1>&2 ; echo ; exit 1;
}

kubectl delete -f ./graylog-service.yml
[ $? -eq 0 ] || die "Unable to uninstall graylog service..."

kubectl delete -f ./graylog-application.yml
[ $? -eq 0 ] || die "Unable to uninstall graylog application..."

kubectl delete -f ./graylog-elasticsearch.yml
[ $? -eq 0 ] || die "Unable to uninstall elastic search..."

kubectl delete -f ./graylog-mongodb.yml
[ $? -eq 0 ] || die "Unable to uninstall mongodb..."
