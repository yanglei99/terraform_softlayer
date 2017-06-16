#!/bin/bash
 
echo Installing a pod network addon: https://www.weave.works/docs/net/latest/kube-addon/. 
 
export KUBECONFIG=$HOME/admin.conf

# To avoid Network 10.32.0.0/12 overlaps with existing route 10.0.0.0/8 on host
 
if [ -z "$1"  ]; then
  kubectl apply -f https://git.io/weave-kube-1.6
else
  echo use revised IPALLOC_RANGE $1
  cp /tmp/weave-daemonset-k8s-1.6-fix.yaml /tmp/weave-daemonset-k8s-1.6-fix.yaml.bak
  sed 's/10.32.0.0\/12/'$1'/g' /tmp/weave-daemonset-k8s-1.6-fix.yaml.bak > /tmp/weave-daemonset-k8s-1.6-fix.yaml
  cat /tmp/weave-daemonset-k8s-1.6-fix.yaml
  kubectl apply -f /tmp/weave-daemonset-k8s-1.6-fix.yaml
fi

if [ -n "$2" ]; then
  echo use token 
  kubectl apply -f https://cloud.weave.works/k8s.yaml?t=$2
fi

kubectl get pods --all-namespaces
