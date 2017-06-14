#!/bin/bash
 
echo reference https://kubernetes.io/docs/setup/independent/install-kubeadm/

echo Install docker v1.12.6: http://www.installvirtual.com/how-to-install-docker-1-12-on-centos-7/

sudo yum update -y

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

#yum install -y docker-1.12.6

yum install -y docker-engine-1.12.6
systemctl start docker
systemctl enable docker

docker -v
docker run hello-world
docker ps

echo Install kubectl binary via curl

version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
echo k8s version: $version

curl -LO "https://storage.googleapis.com/kubernetes-release/release/$version/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

echo Installing kubelet and kubeadm on CENTOS

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

setenforce 0
yum install -y kubelet kubeadm kubernetes-cni
systemctl enable kubelet && systemctl start kubelet

# https://github.com/moby/moby/issues/24809
# https://github.com/kubernetes/kubernetes/issues/43815
# https://github.com/kubernetes/kubernetes.github.io/issues/3159
# https://github.com/kubernetes/kubernetes/issues/44665
# https://github.com/kubernetes/kubeadm/issues/193
# https://github.com/kubernetes/kubernetes/issues/34101

echo fix v1.6.4 issue

sysctl net.bridge.bridge-nf-call-iptables=1
sysctl net.bridge.bridge-nf-call-ip6tables=1

sysctl net.ipv4.conf.all.forwarding=1

kubeadm reset

mv /etc/systemd/system/kubelet.service.d/10-kubeadm.conf  /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bak
sed 's/\$KUBELET_NETWORK_ARGS//g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.bak > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.1
sed 's/systemd/cgroupfs/g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf.1 > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload
systemctl restart kubelet.service
