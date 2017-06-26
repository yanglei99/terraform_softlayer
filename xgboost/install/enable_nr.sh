#!/bin/bash

echo enable New Relic

cat >  /etc/newrelic-infra.yml  << FIN
license_key: $1
custom_attributes:
  clusterName: $2
  nodeType: $3
FIN

echo install New Relic

sudo curl -o /etc/yum.repos.d/newrelic-infra.repo https://download.newrelic.com/infrastructure_agent/linux/yum/el/7/x86_64/newrelic-infra.repo

sudo yum -q makecache -y --disablerepo='*' --enablerepo='newrelic-infra'

sudo yum install newrelic-infra -y

echo start newrelic

sudo systemctl stop newrelic-infra
sudo systemctl start newrelic-infra

echo download application Agent

wget https://oss.sonatype.org/content/repositories/releases/com/newrelic/agent/java/newrelic-java/3.34.0/newrelic-java-3.34.0.zip
wget http://download.newrelic.com/python_agent/release/newrelic-2.86.3.70.tar.gz

