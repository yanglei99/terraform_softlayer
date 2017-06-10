#!/bin/bash

 
kubeadm init --apiserver-advertise-address=$1 | tee /tmp/k8s_init.out

echo get the join command

join_cmd=$(cat /tmp/k8s_init.out | grep "kubeadm join")
cat > /tmp/do-join-node.sh << FIN
#!/bin/bash
${join_cmd}
FIN

cat /tmp/do-join-node.sh 
  
echo Configuring kubectl

echo "source <(kubectl completion bash)" >> ~/.bashrc

echo create sample environment

kubectl config set-cluster demo-cluster --server=http://$1:8080
kubectl config set-context demo-system --cluster=demo-cluster
kubectl config use-context demo-system

sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

kubectl get nodes
kubectl version
kubectl cluster-info

echo "source <(kubectl completion bash)" >> ~/.bashrc

