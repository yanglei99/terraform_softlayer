#!/usr/bin/env bash

# reference http://xgboost.readthedocs.io/en/latest/build.html

echo hadoop: $1, xgboost/dmlc-core patch: $2

# Prep the environment

yum install -y git gcc gcc-c++

yum install -y curl-devel
yum install -y openssl-devel

echo enable hadoop environment to root user

cat >> /root/.bashrc << FIN

export HADOOP_HOME=/home/hadoop/hadoop-$1
export HADOOP_INSTALL=\$HADOOP_HOME
export HADOOP_MAPRED_HOME=\$HADOOP_HOME
export HADOOP_COMMON_HOME=\$HADOOP_HOME
export HADOOP_HDFS_HOME=\$HADOOP_HOME
export YARN_HOME=\$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native
export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin

FIN

. /root/.bashrc 

# Download and build XGBoost

git clone --recursive https://github.com/dmlc/xgboost
cd xgboost
cp make/config.mk config.mk

sed -i.bak 's/^\(USE_S3 =\).*/\1 1/' config.mk
sed -i.bak 's/^\(USE_HDFS =\).*/\1 1/' config.mk

if [ "$2" != "" ]; then
   

   cd dmlc-core
   wget $2
   git apply --stat $(basename $2)
   git apply --check $(basename $2) --apply

   cd ..
   
fi

make -j4

yum install -y python-setuptools
cd python-package; sudo python setup.py install; cd ..

echo "export PYTHONPATH=~/xgboost/python-package" >> ~/.bashrc

## Build JVM Packages

java -version

wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
yum install -y apache-maven
mvn --version

yum install -y epel-release 
yum install -y cmake3
ln -s -f /usr/bin/cmake3 /usr/bin/cmake

cd jvm-packages

sed -i.bak 's/^\(\ *"USE_S3\": \).*/\1 \"ON\",/' create_jni.py
sed -i.bak 's/^\(\ *"USE_HDFS\": \).*/\1 \"ON\",/' create_jni.py

mvn clean -DskipTests install package

cd ..

echo install s3cmd 

yum install -y s3cmd

wget -O $HOME/.s3cfg https://gist.githubusercontent.com/greyhoundforty/a4a9d80a942d22a8a7bf838f7abbcab2/raw/05ad584edee4370f4c252e4f747abb118d0075cb/example.s3cfg

echo make sure to change /root/.s3cfg

cat /root/.s3cfg | grep _key




