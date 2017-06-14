#!/bin/bash
 
echo kubeadm init with $1, $2

echo ignore use apiserver-advertise-address, as it can cause weave-net not started

#kubeadm init --apiserver-advertise-address=$1 --pod-network-cidr=$2 | tee /tmp/k8s_init.out


if [ "$2" = "" ]; then
  kubeadm init  | tee /tmp/k8s_init.out
else
  kubeadm init --pod-network-cidr=$2 | tee /tmp/k8s_init.out
fi

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

