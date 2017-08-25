
#!/usr/bin/env bash
docker run -d --net=host -e KAFKA_ZOOKEEPER_CONNECT=$ZK_MASTER -e KAFKA_DELETE_TOPIC_ENABLE=true -e KAFKA_ADVERTISED_PORT=9092 -e KAFKA_ADVERTISED_HOST_NAME=\$(ip addr show eth1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1) confluent/kafka 
