#!/bin/bash

echo reference https://unskilledcoder.github.io/hadoop/2016/12/10/hadoop-cluster-installation-basic-version.html

hdfs namenode -format
start-dfs.sh
start-yarn.sh
jps