#!/usr/bin/env bash
. ./ips.txt
# Make some config files
cat > config.yaml << FIN
bootstrap_url: http://$BOOTSTRAP:4040
cluster_name: $CLUSTER_NAME
exhibitor_storage_backend: zookeeper
exhibitor_zk_hosts: $BOOTSTRAP:2181
exhibitor_zk_path: /$CLUSTER_NAME
log_directory: /genconf/logs
master_discovery: static
master_list:
- $MASTER_00
- $MASTER_01
- $MASTER_02
- $MASTER_03
- $MASTER_04
resolvers: 
- 8.8.4.4
- 8.8.8.8
FIN

cat > ip-detect << FIN
#!/usr/bin/env bash
set -o nounset -o errexit
export PATH=/usr/sbin:/usr/bin:\$PATH
echo \$(ip addr show eth0 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
FIN

# Make some scripts

cat > do-install.sh << FIN
#!/usr/bin/env bash
mkdir /tmp/dcos && cd /tmp/dcos
printf "Waiting for installer to appear at Bootstrap URL"
until \$(curl -m 2 --connect-timeout 2 --output /dev/null --silent --head --fail http://$BOOTSTRAP:4040/dcos_install.sh); do
    sleep 1
done           
curl -O http://$BOOTSTRAP:4040/dcos_install.sh
sudo bash dcos_install.sh \$1 

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
iptables -A INPUT -p tcp -m tcp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8123 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2181 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 2888 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 3888 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 5050 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 5051 -j ACCEPT
# port for default Spark Cluster
iptables -A INPUT -p tcp -m tcp --dport 4040 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 8081 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 6066 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 7077 -j ACCEPT
# port for default XGBoost tracker
iptables -A INPUT -p tcp -m tcp --dport 9091 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL
FIN

if [ "$1" != "true"]; then
	echo service iptables stop >> do-install.sh 
fi


cat > do-install-bootstrap-iptables.sh << FIN
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
iptables -A INPUT -p tcp -m tcp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 --src 10.0.0.0/8 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
# drop every other inbound packet
iptables -P INPUT DROP

service iptables save
iptables -nvL
FIN

if [ "$1" != "true"]; then
	echo service iptables stop >> do-install-bootstrap-iptables.sh 
fi

rm -rf ./ips.txt
