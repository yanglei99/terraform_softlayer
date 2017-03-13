### Enable Logging Aggregation with ELK on DC/OS

Instruction [reference](https://docs.mesosphere.com/1.9/administration/logging/aggregating/elk/)


#### To use:

* Set `dcos_install_logging` to true. The scripts only tested for CENTOS

* Revise [ElasticSearch definition](marathon/es-monitor.json) and [Kibana definition](marathon/kibana.json) which are used to start the services

* After cluster is provisioned

	Kibana is at `http://kibana_public_ip:5601`
