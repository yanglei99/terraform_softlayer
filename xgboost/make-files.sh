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
iptables -P INPUT DROP
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 6066 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7077 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2888 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3888 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -j DROP

service iptables save
iptables -nvL

# TODO
service iptables stop

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
iptables -P INPUT DROP
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8081 -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -j ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -j DROP

service iptables save
iptables -nvL

echo "Start spark worker on the node \$1"
start-slave.sh $SPARK_MASTER -h \$1
FIN
