#!/bin/bash
 
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

