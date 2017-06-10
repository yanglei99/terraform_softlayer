 #!/bin/bash
 
 echo Installing a pod network addon: https://www.weave.works/docs/net/latest/kube-addon/
 
 export KUBECONFIG=$HOME/admin.conf
 
 kubectl apply -f https://git.io/weave-kube-1.6 
 kubectl get pods --all-namespaces