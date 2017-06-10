#!/bin/bash

echo initialize local environment from $1 with proxy at: $2

echo used by node to join cluster

yes | scp -i do-key -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$1:/tmp/do-join-node.sh .

echo used by: kubectl --kubeconfig ./admin.conf get nodes
echo used by: kubectl --kubeconfig ./admin.conf proxy. for local access of the cluster at: http://localhost:8001/api/v1

yes | scp -i do-key -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$1:/etc/kubernetes/admin.conf .

echo enable local proxy

export KUBECONFIG=./admin.conf

kubectl get nodes
kubectl version
kubectl cluster-info

nohup kubectl proxy --port=$2 &

echo start proxy at background
ps aux | grep proxy





