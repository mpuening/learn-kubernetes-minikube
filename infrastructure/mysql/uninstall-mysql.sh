#!/bin/bash

die()
{
        echo
        echo "$*" 1>&2 ; echo ; exit 1;
}

kubectl delete -f ./mysql-deployment.yml
[ $? -eq 0 ] || die "Unable to uninstall mysql..."

kubectl delete -f ./mysql-pv.yml
[ $? -eq 0 ] || die "Unable to uninstall mysql volumes..."
