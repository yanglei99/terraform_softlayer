#!/bin/bash

echo setup NFS: https://knowledgelayer.softlayer.com/procedure/accessing-file-storage-linux

echo mount point: $1, directory: $2

yum -y install nfs-utils nfs-utils-lib

mkdir -p $2

mount -t nfs4 -o hard,intr $1 $2

echo $1 $2 nfs4 defaults,hard,intr 0 0 >> /etc/fstab

mount -fav