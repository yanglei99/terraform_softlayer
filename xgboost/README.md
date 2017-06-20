## softlayer-terraform-xgboost

[Terraform](https://www.terraform.io/) configuration and scripts for provision Spark Cluster with XGBoost [Softlayer](https://softlayer.com/)

Here is the [provision graph](graph.png)

### Cluster Topology

There are two kinds of nodes, master and worker, which work together to support clusters of:

* ZooKeeper with Exhibitor for HA
* Spark stand-alone cluster with HA using Zookeeper

### Software Components

As Docker container is used for some of the provision, Docker are installed on all nodes.

#### Master node details

* ZooKeeper with Exhibitor in Docker
* Spark stand-alone cluster master with HA using Zookeeper

#### Worker node details

* Spark stand-alone cluster worker


### To provision:

* Clone or download repo.

* Generate a `do-key` keypair (with an empty passphrase):

	ssh-keygen -t rsa -P '' -f ./do-key

* Copy [sample.terraform.tfvars](./sample.terraform.tfvars) to `terraform.tfvars` and revise your variables. Reference [vars.tf](./vars.tf) for variable definitions

* Run Provision `terraform apply`


#### Important ports

[make-files](make-files.sh)

* Exhibitor Web UI start at : 8181
* Spark Master Web UI at: 8080
* Spark Worker Web UI at: 8081
* Spark Master port: 7077, cluster submission port: 6066

Output would calculate SPARK_MASTER and ZK_MASTER, besides the list of master-ip and worker-ip. You can use `terraform show` to see them
	
#### Configuration Details

| Scenario | Configuration | Default Value | Notes|
|----------|---------------|-------|------|
|Docker Installation | provision_install_docker |false| Default behavior is for CoreOS which already includes docker installation. For other OS, set it to true.|
|Wait Time for VM    | provision_vm_wait_time   |15   | You may need to adjust the value to make sure remote provisioner actions only start after VM is ready.|
|Wait Time for ZK    | provision_zk_wait_time   |120  | You may need to adjust the value to make sure zookeeper dependent actions only start after ZK cluster is ready.|

### Run XGBoost Example

XGBoost is download and built at `/root/xgboost` on all nodes

#### Spark Submission from Local

    . ./setenv.sh
    
	spark-submit --class  ml.dmlc.xgboost4j.scala.example.spark.SparkWithDataFrame --master $SPARK_MASTER --driver-class-path /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar --conf spark.executor.extraClassPath=/root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar  --deploy-mode cluster /root/xgboost/jvm-packages/xgboost4j-example/target/xgboost4j-example-0.7.jar 100 2 /root/xgboost/demo/data/agaricus.txt.train /root/xgboost/demo/data/agaricus.txt.test
	

	
#### Spark Job Submission from Master VM with local test data

	ssh -i do-key root@$MASTER_IP
	
	# set the same SPARK_MASTER as in the setenv.sh

	spark-submit --class  ml.dmlc.xgboost4j.scala.example.spark.SparkWithDataFrame --master $SPARK_MASTER --jars /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar /root/xgboost/jvm-packages/xgboost4j-example/target/xgboost4j-example-0.7.jar 100 2 /root/xgboost/demo/data/agaricus.txt.train /root/xgboost/demo/data/agaricus.txt.test
	

#### Spark Submission from Master VM with test data on Softlayer Object Strorage (s3) 
	
	ssh -i do-key root@$MASTER_IP
	
	# set the same SPARK_MASTER as in the setenv.sh
		
* [Follow instruction](https://knowledgelayer.softlayer.com/procedure/connecting-cos-s3-using-s3cmd) to enable s3cmd to access Softlayer Object Storage(s3)

* upload test data

	s3cmd put /root/xgboost/demo/data/agaricus.txt.train s3://xgboost/xgb-demo/train
	s3cmd put /root/xgboost/demo/data/agaricus.txt.test s3://xbboost/xgb-demo/test
	
* Create Spark Hadoop S3 configuration 

[reference myspark.properties](myspark.properties)


* Spark Submit

	spark-submit --class  ml.dmlc.xgboost4j.scala.example.spark.SparkWithDataFrame --master $SPARK_MASTER --jars /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar --packages org.apache.hadoop:hadoop-aws:2.7.3 --properties-file myspark.properties /root/xgboost/jvm-packages/xgboost4j-example/target/xgboost4j-example-0.7.jar 200 2 s3a://xgboost/xgb-demo/train s3a://xgboost/xgb-demo/test


### Known issue, limitation and workaround

* If you hit can not download library during spark submit on master, you may need to remove both `~/.m2` and `~/.ivy2/cache` 

