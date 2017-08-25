#!/usr/bin/env bash

# reference http://xgboost.readthedocs.io/en/latest/build.html

# Prep the environment

yum install -y git gcc gcc-c++ wget

# Download and build

git clone --recursive https://github.com/dmlc/xgboost
cd xgboost; make -j4

## Build JVM Packages

yum install -y java-1.8.0-openjdk java-1.8.0-openjdk-devel
java -version
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-3.b12.el7_3.x86_64/jre/

wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
yum install -y apache-maven
mvn --version

yum install -y epel-release cmake3
ln -s -f /usr/bin/cmake3 /usr/bin/cmake

cd jvm-packages; mvn clean -DskipTests install package