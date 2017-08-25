#!/usr/bin/env bash
docker run -d --net=host --restart always -e SPARK_PROCESS_NAME=slave -e SPARK_WORKER_WEBUI_PORT=8091 -e SPARK_USE_PRIVATE_NETWORK=false -e SPARK_MASTER=spark://169.57.64.86:7077,169.57.64.92:7077,169.57.64.84:7077 yanglei99/spark_mesosphere_mesos 
