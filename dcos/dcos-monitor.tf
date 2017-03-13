
resource "null_resource" "dcos_bootstrap_monitoring" {

  count = "${var.dcos_install_monitoring}"
  depends_on = ["null_resource.dcos_public_agent_install","null_resource.dcos_master_install"]
  connection {
    user = "${var.softlayer_vm_user}"
    private_key = "${file(var.dcos_ssh_key_path)}"
    host = "${element(softlayer_virtual_guest.dcos_master.*.ipv4_address,0)}"
    agent = true
    timeout = "3m"
  }

  provisioner "file" {
	    source = "./monitoring/marathon/cadvisor.json"
	    destination = "/tmp/cadvisor.json"
  }

  provisioner "file" {
	    source = "./monitoring/marathon/influxdb.json"
	    destination = "/tmp/influxdb.json"
  }

  provisioner "file" {
	    source = "./monitoring/marathon/grafana.json"
	    destination = "/tmp/grafana.json"
  }

  provisioner "remote-exec" {
       inline = [
              "curl -i -H 'Content-Type: application/json' -d@/tmp/cadvisor.json localhost:8080/v2/apps",
              "curl -i -H 'Content-Type: application/json' -d@/tmp/influxdb.json localhost:8080/v2/apps",
              "curl -i -H 'Content-Type: application/json' -d@/tmp/grafana.json localhost:8080/v2/apps"
              ]
  }

  provisioner "local-exec" {
	    command = "sleep 30 && echo done waiting influxdb"
  }
  
  provisioner "remote-exec" {
       inline = "curl -i -H -XPUT http://influxdb.marathon.mesos:8086/query --data-urlencode \"q=CREATE DATABASE cadvisor\""
  }
  
  
  
}
