#!/bin/bash

# Command from https://github.com/kubernetes/kubernetes/issues/17512

kubectl get nodes --no-headers | awk '{print $1}' | \
	xargs -I {} sh -c 'echo {} ; kubectl describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo'
