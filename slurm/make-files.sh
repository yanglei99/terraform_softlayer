#!/usr/bin/env bash


echo enable iptables: $1, gpu: $2, $3

# Make some config files

cat cluster_info.txt
cp install/slurm.conf.template slurm.conf
cat cluster_info.txt >> slurm.conf

rm -rf cluster_info.txt

# Make some scripts

cat > gres.conf << FIN
# Configure support for GPUs
Name=gpu File=/dev/nvidia[0-$(($2 * $3 -1))]
FIN


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

