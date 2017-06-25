## Spark XGBoost Example

This example is converted from [Data Science Experience Lab in Python](https://apsportal.ibm.com/analytics/notebooks/78be018b-021c-431a-8408-c8c5b1b355b3/view?access_token=64b7542b28abfe6c60dc3c690fbf14095c47f0bd7b205afd2ffb65fdf21b7358) to integrate with XGBoost in a Spark Scala application. It uses the same [cleansed version of data](./lending/input/loan_sub_new.csv) originated from [Lending Club](https://www.lendingclub.com/info/download-data.action)

You can reference a similar Scala version of the Lab in [Zeppelin Notebook](./notebook/Lending_ML.json) and [Data Science Experience Jupyter Notebook](./notebook/Lending_ML.ipynb)

Note: all activities on master node meed to follow [Prepare the Spark Submission Environment on a Master Node](../README.md)


### Build 

The project need to use [sbt](http://www.scala-sbt.org/0.13/docs/Setup.html) to build, which is already installed on the Cluster node.


#### Build Preparation

If building locally, make XGBoost Spark Jar available : 

    cd examples
	scp -i do-key root@$MASTER_IP:/root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar ./lib/
	
If building on master node, upload the examples project and make XGBoost Spark Jar available: 

    scp -i do-key -r examples root@$MASTER_IP:/root/
    
    // logon to master node
 
    cd examples/
    mkdir -p /root/examples/lib/
	ln -s /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar $(pwd)/lib/xgboost4j-spark-0.7-jar-with-dependencies.jar
	
	
#### To Build

	sbt package assembly
 	
To enable eclipse IDE environment

	sbt eclipse

### Run on Master Node

####  Upload library if built locally

	scp -i do-key XGBoost/target/scala-2.11/spark-xgboost-test-assembly.jar root@$MASTER_IP:/root/examples/target/scala-2.11/
	
#### Upload test data to Object Storage (s3)

[Follow instruction](https://knowledgelayer.softlayer.com/procedure/connecting-cos-s3-using-s3cmd) to enable s3cmd to access Softlayer Object Storage(s3). Then upload test data

	s3cmd put ./lending/input/loan_sub_new.csv s3://lending/input/loan_sub_new.csv

#### Run

	cd /root/examples
	
	spark-submit --class "mytest.spark.LendingXGBoost" --master $SPARK_MASTER --conf spark.driver.memory=6g  --conf spark.driver.cores=3 --conf spark.executor.memory=6g --conf spark.executor.cores=4 --packages org.apache.hadoop:hadoop-aws:2.7.3 --properties-file /root/myspark.properties --jars /root/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar  ./target/scala-2.11/spark-xgboost-test-assembly.jar 100 6 s3a://lending

	