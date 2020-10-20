#!/bin/bash

die()
{
	echo "$*" 1>&2 ; exit 1;
 }

test_exists()
{
	command -v "$1" >/dev/null 2>&1 || { echo >&2 "Command "$1" not installed.  Aborting."; exit 1; }
}

test_goe()
{
	printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

test_exists git
git_version=`git --version | awk '{print $3}' - | tr ',' '\0'`
test_goe $git_version 2.00 || die "Need git version 2.25 or above"
echo Git version $git_version OK

test_exists docker
docker_version=`docker --version | awk '{print $3}' - | tr ',' '\0'`
test_goe $docker_version 19.00 || die "Need docker version 19.03 or above"
echo Docker version $docker_version OK

test_exists minikube
minikube_version=`minikube version | head -1 | awk '{print $3}' - | tr 'v' '\0'`
test_goe $minikube_version 1.7.3 || die "Need minikube version 1.7.3 or above"
echo Minikube version $minikube_version OK

test_exists kubectl
kubectl_major_version=`kubectl version | head -1 | \
	awk '{ for(i=1; i<=NF; i++) { tmp=match($i, /Major:"[0-9]+"/); if(tmp) { print $i } } }' - | \
	tr '"' " " | \
	awk '{print $2}' -`
kubectl_minor_version=`kubectl version | head -1 | \
	awk '{ for(i=1; i<=NF; i++) { tmp=match($i, /Minor:"[0-9]+"/); if(tmp) { print $i } } }' - | \
	tr '"' " " | \
	awk '{print $2}' -`
kubectl_version=$kubectl_major_version.$kubectl_minor_version
test_goe $kubectl_version 1.17 || die "Need kubectl version 1.17 or above"
echo Kubectl version $kubectl_version OK

test_exists helm
helm_version=`helm version 2> /dev/null | head -1 | \
	awk '{ for(i=1; i<=NF; i++) { tmp=match($i, /SemVer:".+"/); if(tmp) { print $i } } }' - | \
	tr '"' " " | \
	tr 'v' " " | \
	awk '{print $3}' -`
test_goe $helm_version 2.16.3 || die "Need helm version 2.16 or above"
echo Helm version $helm_version OK

is_minikube_registry_enabled=`minikube addons list | grep "registry " | grep enabled`
if [[ -z $is_minikube_registry_enabled ]]; then
	die "Minikube registry addon is not enabled"
fi

#is_minikube_helm_tiller_enabled=`minikube addons list | grep "helm-tiller " | grep enabled`
#if [[ -z $is_minikube_helm_tiller_enabled ]]; then
##	die "Minikube helm-tiller addon is not enabled"
#fi

test_exists jq
test_exists openssl
test_exists sha256sum

echo
echo "Looks like all the tools are in place..."
echo
