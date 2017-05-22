#!/usr/bin/env bash

. ./setenv.sh

# Make a script

cat > do-install-exhibitor.sh << FIN
#!/usr/bin/env bash
docker run -d --net=host --restart always -e PORT0=8181 -e PORT1=2181 -e PORT2=2888 -e PORT3=3888 mesosphere/exhibitor-dcos /exhibitor-wrapper -c zookeeper --zkconfigconnect $ZK_MASTER --zkconfigzpath /exhibitor/config --zkconfigexhibitorport 8181 --hostname=\$(ip addr show eth1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
FIN


cat > do-install-spark-master.sh << FIN
#!/usr/bin/env bash
docker run -d --net=host --restart always -e SPARK_PROCESS_NAME=master -e SPARK_MASTER_WEBUI_PORT=8090 -e SPARK_USE_PRIVATE_NETWORK=false -e SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER  -Dspark.deploy.zookeeper.url=${ZK_MASTER} -Dspark.deploy.zookeeper.dir=/sparkha" yanglei99/spark_mesosphere_mesos 
FIN


cat > do-install-spark-worker.sh << FIN
#!/usr/bin/env bash
docker run -d --net=host --restart always -e SPARK_PROCESS_NAME=slave -e SPARK_WORKER_WEBUI_PORT=8091 -e SPARK_USE_PRIVATE_NETWORK=false -e SPARK_MASTER=$SPARK_MASTER yanglei99/spark_mesosphere_mesos 
FIN

cat > do-install-kafka.sh << FIN
#!/usr/bin/env bash
echo KAFKA_BROKER_ID=\$1
docker run -d --net=host -e KAFKA_ZOOKEEPER_CONNECT=$ZK_MASTER -e KAFKA_BROKER_ID=\$1 -e KAFKA_DELETE_TOPIC_ENABLE=true -e KAFKA_ADVERTISED_PORT=9092 -e KAFKA_ADVERTISED_HOST_NAME=\$(ip addr show eth1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1) confluent/kafka 
FIN
