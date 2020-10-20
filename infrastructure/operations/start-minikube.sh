#!/bin/bash

memory=8192

echo
echo "Starting minikube with $memory MB of memory..."
echo

minikube start --memory $memory --insecure-registry "10.0.0.0/24"

minikube status

