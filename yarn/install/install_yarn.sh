#!/bin/bash

echo reference https://unskilledcoder.github.io/hadoop/2016/12/10/hadoop-cluster-installation-basic-version.html

echo install $1 node of $2

echo Install Yarn

export VER=$2

cd /home/hadoop

wget http://mirrors.sonic.net/apache/hadoop/common/hadoop-$VER/hadoop-$VER.tar.gz
tar -xvf hadoop-$VER.tar.gz
rm hadoop-$VER.tar.gz
chmod 775 hadoop-$VER

cat >> /home/hadoop/.bashrc << FIN
export HADOOP_HOME=/home/hadoop/hadoop-$VER
export HADOOP_INSTALL=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin
FIN

source /home/hadoop/.bashrc
  
head -1 /tmp/hadoop.slaves > $HADOOP_HOME/etc/hadoop/masters
cp /tmp/hadoop.slaves $HADOOP_HOME/etc/hadoop/slaves
cp /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
cp /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
cp /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
cp /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml
  
sudo -u hadoop bash << EOF
whoami

mkdir -p $HADOOP_HOME/tmp
mkdir -p $HADOOP_HOME/hdfs/name
mkdir -p $HADOOP_HOME/hdfs/data

EOF
