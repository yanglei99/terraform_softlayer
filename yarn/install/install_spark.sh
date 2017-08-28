#!/usr/bin/env bash

echo Spark : $1 , Hadoop: $2

# Download and install spark

wget https://d3kbcqa49mib13.cloudfront.net/$1.tgz
mkdir -p /usr/local
tar -xvzf $1.tgz -C /usr/local

# set environment variable

cat >> ~/.bashrc << FIN
export SPARK_HOME=/usr/local/$1
export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin
FIN

source ~/.bashrc

cat >> $SPARK_HOME/conf/spark-env.sh << FIN
export HADOOP_CONF_DIR=/home/hadoop/hadoop-$2/etc/hadoop
FIN

env | grep HOME
env | grep PATH
