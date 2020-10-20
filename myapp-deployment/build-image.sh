#!/bin/sh

#
# Note! This is intended to be run with Minikube's docker
#
# Run: eval $(minikube docker-env)
#
docker build -t myapp .
