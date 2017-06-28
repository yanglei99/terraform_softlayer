#!/bin/bash

echo setup NFS: https://knowledgelayer.softlayer.com/procedure/accessing-file-storage-linux

yum -y install nfs-utils nfs-utils-lib

mkdir -p $2

mount -t nfs4 -o hard,intr $1 $2