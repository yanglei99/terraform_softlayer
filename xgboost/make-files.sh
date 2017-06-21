#!/usr/bin/env bash

. ./setenv.sh

# Make a script

cat > do-install-exhibitor.sh << FIN
#!/usr/bin/env bash
docker run -d --net=host --restart always -e PORT0=8181 -e PORT1=2181 -e PORT2=2888 -e PORT3=3888 mesosphere/exhibitor-dcos /exhibitor-wrapper -c zookeeper --zkconfigconnect $ZK_MASTER --zkconfigzpath /exhibitor/config --zkconfigexhibitorport 8181 --hostname=\$1
FIN


cat > do-start-spark-master.sh << FIN
#!/usr/bin/env bash

echo "enable iptables"

yum install -y iptables-services
service iptables restart
service iptables status
chkconfig --level 345 iptables on

iptables -nvL

iptables -F
# accept everything on loopback
iptables -A INPUT -i lo -j ACCEPT
# accept everything on private interface
iptables -A INPUT -i eth0 -j ACCEPT
# accept anything thats releated to connections already established
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# accept some cluster needed ports
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 4040 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 6066 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7077 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 9091 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2888 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3888 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL

echo "Start spark master on the node \$1"

export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=$ZK_MASTER -Dspark.deploy.zookeeper.dir=/sparkha" 
start-master.sh -h \$1 
FIN

cat > do-start-spark-worker.sh << FIN
#!/usr/bin/env bash

echo "enable iptables"

yum install -y iptables-services
service iptables restart
service iptables status
chkconfig --level 345 iptables on

iptables -nvL

iptables -F
# accept everything on loopback
iptables -A INPUT -i lo -j ACCEPT
# accept everything on private interface
iptables -A INPUT -i eth0 -j ACCEPT
# accept anything thats releated to connections already established
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# accept some cluster needed ports
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8081 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL

echo "Start spark worker on the node \$1"
start-slave.sh $SPARK_MASTER -h \$1
FIN


cat > setenv-spark-driver.sh << FIN
#!/usr/bin/env bash

export SPARK_MASTER=$SPARK_MASTER
export SPARK_MASTER_CLUSTER=$SPARK_MASTER_CLUSTER

echo calculate Spark Driver Host to private IP

export SPARK_DRIVER_HOST=\$(ip addr show eth0 | awk '/inet / {print \$2}' | cut -d/ -f1)
export LIBPROCESS_IP=\$SPARK_DRIVER_HOST
export SPARK_PUBLIC_DNS=\$SPARK_DRIVER_HOST
export SPARK_LOCAL_IP=\$SPARK_DRIVER_HOST

env | grep SPARK

echo force XGBoost Traker URI to private IP

export DMLC_TRACKER_URI=\$SPARK_DRIVER_HOST
export DMLC_TRACKER_PORT=9091

env | grep DMLC

FIN

