### Enable Monitoring with cAdvisor, InfluxDB and Grafana on DC/OS

Instruction [reference](https://github.com/dcos/examples/tree/master/1.8/cadvisor-influxdb-grafana)

#### To use:

* Set `dcos_install_monitoring` to true. 

* Revise [ElasticSearch definition](marathon/cadvistor.json) ,  [InfluxDB definition](marathon/influxdb.json) and  [Grafana definition](marathon/grafana.json). Which are used to start the service.

* After cluster is provisioned:

	cAdvisor for each agent is at 'http//agent_public_ip:8080'

	Grafana is at `http://grafana_public_ip:3000`. 
	Config influxdb http url with `http://influxdb.marathon.mesos:8086`.
	Upload Dashboard as in the instruction above.
