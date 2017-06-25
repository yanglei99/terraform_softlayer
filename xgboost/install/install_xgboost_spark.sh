#!/usr/bin/env bash

# reference http://xgboost.readthedocs.io/en/latest/build.html

# Prep the environment

yum upgrade -y
yum install -y git gcc gcc-c++ wget

# Download and build XGBoost

git clone --recursive https://github.com/dmlc/xgboost
cd xgboost; make -j4

## Build JVM Packages

yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
java -version

wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
yum install -y apache-maven
mvn --version

yum install -y epel-release 
yum install -y cmake3
ln -s -f /usr/bin/cmake3 /usr/bin/cmake

cd jvm-packages; mvn clean -DskipTests install package

# Download and install spark

wget http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz
mkdir -p /usr/local
tar -xvzf spark-2.1.0-bin-hadoop2.7.tgz -C /usr/local

# Download and install sbt (for sample)

curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo
yum install -y sbt

# set environment variable
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-3.b12.el7_3.x86_64/jre/' >> ~/.bashrc
echo 'export SPARK_HOME=/usr/local/spark-2.1.0-bin-hadoop2.7' >> ~/.bashrc
echo 'export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin' >> ~/.bashrc
source ~/.bashrc

env | grep HOME
