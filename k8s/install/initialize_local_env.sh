#!/bin/bash

echo initialize local environment from $1

echo used by node to join cluster: do-join-node.sh

yes | scp -r -i do-key -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$1:/tmp/do-join-node.sh .

echo used by: kubectl --kubeconfig ./admin.conf get nodes
echo used by: kubectl --kubeconfig ./admin.conf proxy. for local access of the cluster at: http://localhost:$3/api/v1

yes | scp -r -i do-key -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null root@$1:/etc/kubernetes/admin.conf .

export KUBECONFIG=$(pwd)/admin.conf

kubectl get nodes
kubectl version
kubectl cluster-info

if [ -n "$2" ]; then
   echo enable local proxy at $2
   bash -c "nohup kubectl proxy --port=$2 &"
fi

