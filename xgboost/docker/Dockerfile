FROM       mesosphere/mesos:1.3.0
MAINTAINER Yang Lei <yanglei@us.ibm.com>

# The generic Spark Mesos Docker image with contains XGBoost
#
# Folder structure:
#        Dockerfile
#        run.sh
#		 		the script that can start Spark Standalone Master/Slave, and also can submit spark job against all kinds of Spark Master
#
# To build image once:
#
#        docker build -t spark_xgboost_mesosphere . 
#
#


# Installation Prereq

RUN apt-get update && apt-get install -y wget curl

# Download prebuild Spark 2.1.0 with Hadoop 2.7+

RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-2.1.0-bin-hadoop2.7.tgz
RUN mkdir -p /usr/local
RUN tar -xvzf spark-2.1.0-bin-hadoop2.7.tgz -C /usr/local
ENV SPARK_HOME /usr/local/spark-2.1.0-bin-hadoop2.7
ENV PATH $SPARK_HOME/bin:$PATH

# Install JQ for processing JSON when needed

RUN apt-get install -y jq

# Install pip

RUN apt-get -y install python-pip
RUN pip -V

# Install the latest OpenJDK.
RUN \
    apt-get install -y software-properties-common;\
    add-apt-repository ppa:openjdk-r/ppa;\
    apt-get update;\
    apt-get install -y openjdk-8-jdk
    
ENV MESOS_NATIVE_JAVA_LIBRARY /usr/local/lib/libmesos.so
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Install XGBoost

WORKDIR /xgboost

RUN git clone --recursive https://github.com/dmlc/xgboost
RUN cd xgboost; make -j4

RUN apt-get install -y maven
RUN mvn --version

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:george-edison55/cmake-3.x
RUN apt-get update
RUN apt-get install -y cmake

RUN cd xgboost/jvm-packages; mvn clean -DskipTests install package 
RUN pwd && ls xgboost/jvm-packages/xgboost4j-spark/target/

# Add run script

WORKDIR /spark

ADD run.sh /spark/
RUN chmod +x run.sh

RUN cp /xgboost/xgboost/jvm-packages/xgboost4j-example/target/xgboost4j-example-0.7.jar /spark
RUN cp /xgboost/xgboost/jvm-packages/xgboost4j-spark/target/xgboost4j-spark-0.7-jar-with-dependencies.jar /spark

RUN ls /spark

VOLUME /spark/job

WORKDIR /spark/job

ENV MARATHON_HOST http://marathon.mesos:8080
ENV SPARK_PROCESS_NAME application

#ENV SPARK_MASTER mesos://zk://leader.mesos:2181/mesos
ENV SPARK_MESOS_COARSE true

#ENV SPARK_JOB_CONFIG --conf spark.mesos.executor.docker.image=yanglei99/spark_xgboost_mesosphere 
#ENV SPARK_JOB_PACKAGES --packages org.apache.hadoop:hadoop-aws:2.7.3 
#ENV SPARK_JOB_JARS --jars /spark/xgboost4j-spark-0.7-jar-with-dependencies.jar 
#ENV SPARK_JOB  --class ml.dmlc.xgboost4j.scala.example.spark.SparkWithDataFrame /spark/xgboost4j-example-0.7.jar 100 3 s3a://xgboost/xgb-demo/train s3a://xgboost/xgb-demo/test

#ENV SPARK_MASTER_ID spark-master
#ENV SPARK_MASTER_HOST spark-master.marathon.mesos

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_WEBUI_PORT 8081
ENV SPARK_USE_PRIVATE_NETWORK true

ENV DMLC_TRACKER_PORT 9091

RUN rm -rf /root/.m2 && rm -rf /root/.ivy2/cache

CMD ["/spark/run.sh"]

