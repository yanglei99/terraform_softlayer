## Spark XGBoost in Docker on Mesos

Docker image which can be used to

* Submit XGBoost Spark job against local cluster, Standalone cluster, Mesos (using the image as executor)
* Start Spark Standalone cluster which enabled XGBoost on Mesos

[Reference Mesosphere DC/OS cluster creation on Sofltayer through Terraform)(../../../dcos/README.md)

### Build Docker Image

Reference [Dockerfile](Dockerfile) for build instructions.

Here is the [pre-built images](https://hub.docker.com/r/yanglei99/spark_xgboost_mesosphere/tags/)

#### Latest

* Base image: mesosphere/mesos:1.3.0
* Spark 2.1.0 with Hadoop 2.7
* Java 8
* XGBoost 0.7


### Start Spark Standalone Cluster in Docker with Marathon

#### Start Master in Docker

[Spark Master job description](spark-cluster/marathon-in-docker-master.json)

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-in-docker-master.json $marathonIp:8080/v2/apps

Note:

* The master will use DC/OS Zookeeper for HA

#### Start Slave in Docker

[Spark Slave job description](spark-cluster/marathon-in-docker-slave.json)

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-in-docker-slave.json $marathonIp:8080/v2/apps

Note:

* The slave can use Spark-Master's Marathon task name to calculate the Spark master IP address, `SPARK_MASTER_ID=spark-master`. You can also set IP directly by  `SPARK_MASTER_HOST=xxx.xxx.xxx.xxx` or `SPARK_MASTER=spark://xxx.xxx.xxx.xxx:7077`

#### The console

* Spark Master at: `spark://$SPARK_MASTER_HOST:$SPARK_MASTER_PORT`
* Spark Master console start at: `$SPARK_MASTER_HOST:$SPARK_MASTER_WEBUI_PORT`
* Spark Slave console start at: `$SPARK_SLAVE_HOST:$SPARK_WORKER_WEBUI_PORT`

Note:

* As private IP is used, you will need to enable VPN to see the console.


### Submit Spark Job using Marathon

#### Run XGBoost Example on a local Spark Master

[Job description](marathon-local.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-local.json $marathonIp:8080/v2/apps

#### using Spark Standalone Cluster

[Against Spark Cluster of known IP Job description](marathon-standalone.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-standalone.json $marathonIp:8080/v2/apps

[Agaist Spark Cluster in Docker](spark-cluster/marathon-in-docker-standalone.json)

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-in-docker-standalone.json $marathonIp:8080/v2/apps

Note:

* The spark job can use Spark-Master's Marathon task name to calculate the Spark master IP address, `SPARK_MASTER_ID=spark-master`. You can also use the IP directly by setting `SPARK_MASTER_HOST=xxx.xxx.xxx.xxx` or `SPARK_MASTER=spark://xxx.xxx.xxx.xxx:7077`


#### using Mesos as Cluster Manager with docker executor

[Job description](marathon-mesos-docker.json) 

	curl -i -H 'Content-Type: application/json' -d@spark-cluster/marathon-mesos-docker.json $marathonIp:8080/v2/apps

### Known issue and constraints

* both against local master test and standalone in docker master test fails post training dataframe show. Investigating.
* Only support one Standalone Master in Docker at this time.
