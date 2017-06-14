#!/bin/bash
 
echo Installing a pod network addon: https://www.weave.works/docs/net/latest/kube-addon/
 
export KUBECONFIG=$HOME/admin.conf

# To avoid Network 10.32.0.0/12 overlaps with existing route 10.0.0.0/8 on host
 
if [ "$#" -ne 1 ]; then
  kubectl apply -f https://git.io/weave-kube-1.6
else
   kubectl apply -f $1
fi

kubectl get pods --all-namespaces