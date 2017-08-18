#!/bin/bash

echo reference https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/ and https://wiki.fysik.dtu.dk/niflheim/Slurm_installation

echo install $1 node, shared directory: $2, master is also compute: $3, worker with gpu: $4

yum install -y rpm-build gcc openssl openssl-devel pam-devel numactl numactl-devel hwloc hwloc-devel lua lua-devel readline-devel rrdtool-devel ncurses-devel gtk2-devel man2html libibmad libibumad perl-Switch perl-ExtUtils-MakeMaker

export VER=17.02.6

if [ "$1" == "master" ]; then

  yum install -y mariadb-server mariadb-devel
  yum install -y rpm-build
  
  cd /tmp
  rpmbuild -ta slurm-$VER.tar.bz2
  
  mkdir -p $2/slurm/slurm-rpms
  cd $2/slurm/slurm-rpms
  cp /root/rpmbuild/RPMS/x86_64/*.rpm .
  
  yum install -y slurm-$VER*rpm slurm-devel-$VER*rpm slurm-munge-$VER*rpm slurm-perlapi-$VER*rpm slurm-plugins-$VER*rpm slurm-torque-$VER*rpm slurm-seff-$VER*rpm
  yum install -y slurm-slurmdbd-$VER*rpm slurm-sql-$VER*rpm slurm-plugins-$VER*rpm
else

  cd $2/slurm/slurm-rpms
  yum install -y slurm-$VER*rpm slurm-devel-$VER*rpm slurm-munge-$VER*rpm slurm-perlapi-$VER*rpm slurm-plugins-$VER*rpm slurm-torque-$VER*rpm slurm-seff-$VER*rpm
  yum install -y slurm-pam_slurm-$VER*rpm

fi

echo enable ntp


yum install ntp -y
chkconfig ntpd on
ntpdate pool.ntp.org
systemctl start ntpd

echo remove old slurm

chkconfig --del slurm
rm -f /etc/init.d/slurm


echo enable log rotate

yum -y install logrotate

cat > /etc/logrotate.d/slurmctld << FIN
/var/log/slurmctld.log {
weekly
missingok
notifempty
sharedscripts
create 0600 slurm slurm
rotate 8
compress
postrotate
      /bin/systemctl reload slurmctld.service > /dev/null 2>/dev/null || true
endscript
}

/var/log/slurmd.log {
weekly
missingok
notifempty
sharedscripts
create 0600 slurm slurm
rotate 8
compress
postrotate
      /bin/systemctl reload slurmctld.service > /dev/null 2>/dev/null || true
endscript
}

FIN

echo slurm.conf is calculated and uploaded before the installation at $2/slurm.conf
echo start the service

cp $2/*.conf /etc/slurm

if [ "$4" == "1" ]; then

   yes | cp $2/gres.conf.gpu /etc/slurm/gres.conf
   nvidia-smi --persistence-mode=1 
   
   echo 'TODO change to use persistenced http://docs.nvidia.com/deploy/driver-persistence/index.html#persistence-daemon'

fi

if [ "$1" == "master" ]; then

  mkdir /var/spool/slurmctld
  chown slurm: /var/spool/slurmctld
  chmod 755 /var/spool/slurmctld
  touch /var/log/slurmctld.log
  chown slurm: /var/log/slurmctld.log
  touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
  chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

  systemctl enable slurmctld.service
  systemctl start slurmctld.service
  systemctl status slurmctld.service

fi

if [ "$1" != "master" ] || [ "$3" == "1" ]; then

  mkdir /var/spool/slurmd
  chown slurm: /var/spool/slurmd
  chmod 755 /var/spool/slurmd
  touch /var/log/slurmd.log
  chown slurm: /var/log/slurmd.log

  systemctl enable slurmd.service
  systemctl start slurmd.service
  systemctl status slurmd.service
  
fi
