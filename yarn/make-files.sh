#!/usr/bin/env bash

echo version: $2 , enable iptables: $1 , install spark: $3, install gpu: $4, install xgboost: $5

# Make some config files

. ./setenv.txt
mv hosts.txt etc.hosts
mv slaves.txt hadoop.slaves

if [ -f "bm-slaves.txt" ]; then
  cat bm-slaves.txt >> hadoop.slaves
fi

cat >> etc.hosts << FIN

127.0.0.1 localhost
FIN


cat > core-site.xml << FIN
<configuration>
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://$MASTER_00:9000/</value>
    <description>namenode settings</description>
</property>
<property>
    <name>hadoop.tmp.dir</name>
    <value>/home/hadoop/hadoop-$2/tmp/hadoop-\${user.name}</value>
    <description> temp folder </description>
</property>  
<property>
    <name>hadoop.proxyuser.hadoop.hosts</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.hadoop.groups</name>
    <value>*</value>
</property>
</configuration>
FIN


cat > hdfs-site.xml << FIN
<configuration>  
    <property>  
        <name>dfs.namenode.http-address</name>  
        <value>$MASTER_00:50070</value>  
        <description> fetch NameNode images and edits </description>  
    </property>
    <property>  
        <name>dfs.namenode.secondary.http-address</name>  
        <value>$SLAVE_00:50090</value>  
        <description> fetch SecondNameNode fsimage </description>  
    </property> 
    <property>
        <name>dfs.replication</name>
        <value>2</value>
        <description> replica count </description>
    </property>
    <property>  
        <name>dfs.namenode.name.dir</name>  
        <value>file:///home/hadoop/hadoop-$2/hdfs/name</value>  
        <description> namenode </description>  
    </property>  
    <property>  
        <name>dfs.datanode.data.dir</name>
        <value>file:///home/hadoop/hadoop-$2/hdfs/data</value>  
        <description> DataNode </description>  
    </property>  
    <property>  
        <name>dfs.namenode.checkpoint.dir</name>  
        <value>file:///home/hadoop/hadoop-$2/hdfs/namesecondary</value>  
        <description>  check point </description>  
    </property> 
    <property>
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>dfs.stream-buffer-size</name>
        <value>131072</value>
        <description> buffer </description>
    </property> 
    <property>  
        <name>dfs.namenode.checkpoint.period</name>  
        <value>3600</value>  
        <description> duration </description>  
    </property> 
</configuration>
FIN

cat > mapred-site.xml << FIN
<configuration>  
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
        </property>
    <property>
        <name>mapreduce.jobtracker.address</name>
        <value>hdfs://trucy:9001</value>
    </property>
    <property>
        <name>mapreduce.jobhistory.address</name>
        <value>$MASTER_00:10020</value>
        <description>MapReduce JobHistory Server host:port, default port is 10020.</description>
    </property>
    <property>
        <name>mapreduce.jobhistory.webapp.address</name>
        <value>$MASTER_00:19888</value>
        <description>MapReduce JobHistory Server Web UI host:port, default port is 19888.</description>
    </property>
</configuration>
FIN

cat > yarn-site.xml << FIN

<configuration>
    <property>
       <name>yarn.nodemanager.vmem-pmem-ratio</name>
       <value>4</value>
       <description>Ratio between virtual memory to physical memory when setting memory limits for containers</description>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>$MASTER_00</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>$MASTER_00:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>$MASTER_00:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>$MASTER_00:8031</value>
    </property>
    <property>
        <name>yarn.resourcemanager.admin.address</name>
        <value>$MASTER_00:8033</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>$MASTER_00:8088</value>
    </property>
    <property>
        <name>yarn.node-labels.fs-store.root-dir</name>
        <value>hdfs://$MASTER_00:9000/yarn/node-labels/</value>
    </property>
    <property>
        <name>yarn.node-labels.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>$VM_MEMORY</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>$VM_CORES</value>
    </property>
</configuration>
FIN

cat > yarn-site-bm.xml << FIN

<configuration>
    <property>
       <name>yarn.nodemanager.vmem-pmem-ratio</name>
       <value>4</value>
       <description>Ratio between virtual memory to physical memory when setting memory limits for containers</description>
    </property>
    <property>
        <name>yarn.resourcemanager.hostname</name>
        <value>$MASTER_00</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>
    <property>
        <name>yarn.resourcemanager.address</name>
        <value>$MASTER_00:8032</value>
    </property>
    <property>
        <name>yarn.resourcemanager.scheduler.address</name>
        <value>$MASTER_00:8030</value>
    </property>
    <property>
        <name>yarn.resourcemanager.resource-tracker.address</name>
        <value>$MASTER_00:8031</value>
    </property>
    <property>
        <name>yarn.resourcemanager.admin.address</name>
        <value>$MASTER_00:8033</value>
    </property>
    <property>
        <name>yarn.resourcemanager.webapp.address</name>
        <value>$MASTER_00:8088</value>
    </property>
    <property>
        <name>yarn.node-labels.fs-store.root-dir</name>
        <value>hdfs://$MASTER_00:9000/yarn/node-labels/</value>
    </property>
    <property>
        <name>yarn.node-labels.enabled</name>
        <value>true</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.memory-mb</name>
        <value>$BM_MEMORY</value>
    </property>
    <property>
        <name>yarn.nodemanager.resource.cpu-vcores</name>
        <value>$BM_CORES</value>
    </property>
</configuration>
FIN

# Make some scripts

cat > do-start-yarn.sh << FIN
#!/usr/bin/env bash

echo copy Hadoop to Slaves

yes | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa

sshpass -p \$1 ssh-copy-id -o StrictHostKeyChecking=no hadoop@$MASTER_00
ssh-keyscan $MASTER_00 >> ~/.ssh/known_hosts

for line in \$(cat \$HADOOP_HOME/etc/hadoop/slaves)
do
    echo \$line
    sshpass -p \$1 ssh-copy-id -o StrictHostKeyChecking=no hadoop@\$line
    ssh-keyscan \$line >> ~/.ssh/known_hosts
    scp -r -o StrictHostKeyChecking=no ~/hadoop-$2 hadoop@\$line:~/
    scp -r -o StrictHostKeyChecking=no ~/.bashrc hadoop@\$line:~/.bashrc
done

FIN

if [ "$4" != "0" ]; then

for line in $(cat bm-slaves.txt )
do
    echo "scp -r -o StrictHostKeyChecking=no /tmp/yarn-site-bm.xml hadoop@$line:~/hadoop-$2/etc/hadoop/yarn-site.xml" >> do-start-yarn.sh
done

fi

cat >> do-start-yarn.sh << FIN

echo start HDFS

hdfs namenode -format
start-dfs.sh

echo create hdfs directory for node label

hdfs dfs -mkdir -p /yarn/node-labels
hdfs dfs -chown hadoop:hadoop /yarn
hadoop fs -ls /yarn

FIN

if [ ! -z "$3" ]; then

cat >> do-start-yarn.sh << FIN

echo create hdfs directory for Spark

hdfs dfs -mkdir -p /user/root
hdfs dfs -chown root:hadoop /user/root
hadoop fs -ls /user

FIN

fi

if [ "$5" == "1" ]; then

cat >> do-start-yarn.sh << FIN

echo create hdfs directory for xgboost

hdfs dfs -mkdir -p /tmp
hdfs dfs -chown root:hadoop /tmp
hadoop fs -ls /tmp

FIN
fi

cat >> do-start-yarn.sh << FIN

echo start Yarn

start-yarn.sh
jps

FIN

if [ "$4" == "1" ]; then

cat >> do-start-yarn.sh << FIN

echo add gpu label
yarn rmadmin -addToClusterNodeLabels "gpu"
yarn cluster --list-node-labels

sed -i.bak '/<\/configuration>/d'  \$YARN_HOME/etc/hadoop/capacity-scheduler.xml

cat >> \$YARN_HOME/etc/hadoop/capacity-scheduler.xml << EOF

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels</name>
    <value>gpu</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.accessible-node-labels.gpu.capacity</name>
    <value>100</value>
  </property>

  <property>
    <name>yarn.scheduler.capacity.root.default.accessible-node-labels.gpu.capacity</name>
    <value>100</value>
  </property>

</configuration>
EOF

yarn rmadmin -refreshQueues

FIN

fi

for line in $(cat bm-slaves.txt )
do
    echo "yarn rmadmin -replaceLabelsOnNode \"$line=gpu\" " >> do-start-yarn.sh
done

cat > do-install-iptables.sh << FIN
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
if [ -d /sys/class/net/bond0 ]; then
  iptables -A INPUT -i bond0 -j ACCEPT
else
  iptables -A INPUT -i eth0 -j ACCEPT
fi
# accept anything that's related to connections already established
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# accept some cluster needed ports
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL
FIN

if [ "$1" != "1" ]; then
	echo service iptables stop >> do-install-iptables.sh 
fi

rm bm-slaves.txt
rm setenv.txt

