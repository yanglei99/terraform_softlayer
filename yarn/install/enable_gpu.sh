#!/bin/bash


echo follow instructions http://www.dedoimedo.com/computers/centos-7-nvidia.html

yum -y update

yum -y install kernel-devel kernel-headers gcc make
yum -y upgrade kernel kernel-devel

echo Blacklist Nouveau

lsmod | grep nouv

mv /etc/default/grub /etc/default/grub.org

sed -e 's/GRUB_CMDLINE_LINUX="\([^"]*\)"/GRUB_CMDLINE_LINUX="\1 rd.driver.blacklist=nouveau nouveau.modeset=0"/g' /etc/default/grub.org > /etc/default/grub

cat /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg

echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf
cat /etc/modprobe.d/blacklist.conf

echo Install Nvidia proprietary driver

wget http://us.download.nvidia.com/XFree86/Linux-x86_64/375.66/NVIDIA-Linux-x86_64-375.66.run

chmod +x NVIDIA-Linux-x86_64-375.66.run
./NVIDIA-Linux-x86_64-375.66.run -silent

sudo bash -c "cat > /etc/ld.so.conf.d/cuda-lib64.conf << EOF
/usr/local/cuda/lib64
EOF"

sudo ldconfig

echo enable cuda

yum install -y epel-release
yum install -y dkms

wget https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda-repo-rhel7-8-0-local-ga2-8.0.61-1.x86_64-rpm

sudo rpm -i cuda-repo-rhel7-8-0-local-ga2-8.0.61-1.x86_64-rpm
sudo yum clean all
sudo yum install -y cuda
