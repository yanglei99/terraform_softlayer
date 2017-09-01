#!/bin/bash

echo reference https://unskilledcoder.github.io/hadoop/2016/12/10/hadoop-cluster-installation-basic-version.html

sudo yum upgrade --assumeyes --tolerant
sudo yum update --assumeyes
uname -r

sudo yum install -y net-tools
sudo yum install -y openssh-server
sudo yum install -y wget

echo setup hostname for all nodes

sudo hostnamectl set-hostname $(hostname -s)

echo setup jdk for all nodes

yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
java -version

echo set environment variable

cat > /etc/profile.d/java.sh << FIN
export JAVA_HOME=\$(cd /usr/lib/jvm/java-1.8.0-openjdk-1.8.0*; pwd)
export JRE_HOME=\$JAVA_HOME/jre
export CLASSPATH=\$JAVA_HOME/lib:.
export PATH=\$PATH:\$JAVA_HOME/bin
FIN

source /etc/profile.d/java.sh

java -version
ls $JAVA_HOME
echo $PATH

echo setup user and user group on all nodes

sudo groupadd hadoop
sudo useradd -d /home/hadoop -g hadoop hadoop
echo $1 | passwd --stdin hadoop

echo stop and disable firewall

sudo systemctl stop firewalld.service
sudo systemctl disable firewalld.service

echo enable sshpass

wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-10.noarch.rpm
rpm -ivh epel-release-7-10.noarch.rpm
yum repolist
yum --enablerepo=epel -y install sshpass
