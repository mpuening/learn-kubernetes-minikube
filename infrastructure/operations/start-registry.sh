#!/bin/bash

echo
echo "Starting local docker registry... use ctrl-c to quit..."
echo

docker run --rm -it --network=host alpine ash -c "apk add socat && socat TCP-LISTEN:5000,reuseaddr,fork TCP:$(minikube ip):5000"

