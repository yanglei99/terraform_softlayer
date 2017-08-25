#!/usr/bin/env bash
docker run -d --net=host --restart always -e PORT0=8181 -e PORT1=2181 -e PORT2=2888 -e PORT3=3888 mesosphere/exhibitor-dcos /exhibitor-wrapper -c zookeeper --zkconfigconnect 169.57.64.86:2181,169.57.64.92:2181,169.57.64.84:2181 --zkconfigzpath /exhibitor/config --zkconfigexhibitorport 8181 --hostname=$(ip addr show eth1 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)
