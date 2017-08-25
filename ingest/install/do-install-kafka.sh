#!/usr/bin/env bash
echo KAFKA_BROKER_ID=$1
docker run -d --net=host -e KAFKA_ZOOKEEPER_CONNECT=169.57.64.86:2181,169.57.64.92:2181,169.57.64.84:2181 -e KAFKA_BROKER_ID=$1 -e KAFKA_DELETE_TOPIC_ENABLE=true -e KAFKA_ADVERTISED_PORT=9092 -e KAFKA_ADVERTISED_HOST_NAME=$(ip addr show eth1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1) confluent/kafka 
