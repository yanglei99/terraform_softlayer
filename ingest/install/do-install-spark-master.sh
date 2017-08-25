#!/usr/bin/env bash
docker run -d --net=host --restart always -e SPARK_PROCESS_NAME=master -e SPARK_MASTER_WEBUI_PORT=8090 -e SPARK_USE_PRIVATE_NETWORK=false -e SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER  -Dspark.deploy.zookeeper.url=169.57.64.86:2181,169.57.64.92:2181,169.57.64.84:2181 -Dspark.deploy.zookeeper.dir=/sparkha" yanglei99/spark_mesosphere_mesos 
