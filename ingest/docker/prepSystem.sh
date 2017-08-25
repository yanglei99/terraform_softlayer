 #!/bin/bash
 
echo reference "https://dcos.io/docs/1.9/administration/installing/custom/system-requirements/"
 
echo Upgrade CentOS

sudo yum upgrade -y
sudo systemctl stop firewalld && sudo systemctl disable firewalld

echo Enable OverlayFS

sudo tee /etc/modules-load.d/overlay.conf <<-'EOF'
overlay
EOF

echo Enable NTP

sudo yum install -y ntp ntpdate ntp-doc

service ntpd stop
ntpdate 0.rhel.pool.ntp.org
service ntpd start
ntptime

echo Advance setup

sudo yum install -y tar xz unzip curl ipset

sudo sed -i s/SELINUX=enforcing/SELINUX=permissive/g /etc/selinux/config 
sudo groupadd nogroup
  
sudo reboot