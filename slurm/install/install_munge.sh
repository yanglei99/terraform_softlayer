#!/bin/bash

echo reference https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/
echo install $1 node, shared directory: $2

sudo yum upgrade --assumeyes --tolerant
sudo yum update --assumeyes
uname -r

if [ "$1" == "master" ]; then
  yum install mariadb-server mariadb-devel -y
fi

echo create global user

export MUNGEUSER=991
groupadd -g $MUNGEUSER munge
useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge

export SLURMUSER=992
groupadd -g $SLURMUSER slurm
useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm

echo install munge

yum install -y epel-release
yum install -y munge munge-libs munge-devel

echo create secret key

if [ "$1" == "master" ]; then
  yum install rng-tools -y
  rngd -r /dev/urandom
  /usr/sbin/create-munge-key -r
  dd if=/dev/urandom bs=1 count=1024 > /etc/munge/munge.key
  chown munge: /etc/munge/munge.key
  chmod 400 /etc/munge/munge.key
  
  echo share /etc/munge/munge.key at $2/slurm 
  
  mkdir -p $2/slurm
  cp /etc/munge/munge.key $2/slurm/munge.key
  
else

  cp $2/slurm/munge.key /etc/munge/munge.key
  chown -R munge: /etc/munge/ /var/log/munge/
  chmod 0700 /etc/munge/ /var/log/munge/ 
   
fi

systemctl enable munge
systemctl start munge


echo verify munge
munge -n
munge -n | unmunge
remunge



