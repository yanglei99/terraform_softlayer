
resource "null_resource" "dcos_bootstrap_logging" {

  count = "${var.dcos_install_logging}"
  depends_on = ["null_resource.dcos_public_agent_install","null_resource.dcos_master_install"]
  connection {
    user = "${var.softlayer_vm_user}"
    private_key = "${file(var.dcos_ssh_key_path)}"
    host = "${element(softlayer_virtual_guest.dcos_master.*.ipv4_address,0)}"
    agent = true
    timeout = "3m"
  }

  provisioner "file" {
	    source = "./logging/marathon/es-monitor.json"
	    destination = "/tmp/es-monitor.json"
  }

  provisioner "file" {
	    source = "./logging/marathon/kibana-es.json"
	    destination = "/tmp/kibana-es.json"
  }

  provisioner "remote-exec" {
       inline = [
              "curl -i -H 'Content-Type: application/json' -d@/tmp/es-monitor.json localhost:8080/v2/apps",
              "curl -i -H 'Content-Type: application/json' -d@/tmp/kibana-es.json localhost:8080/v2/apps"
              ]
  }
}

resource "null_resource" "dcos_master_logging" {

  count = "${var.dcos_master_count * var.dcos_install_logging}"
  depends_on = ["null_resource.dcos_master_install"]
  connection {
    user = "${var.softlayer_vm_user}"
    private_key = "${file(var.dcos_ssh_key_path)}"
    host = "${element(softlayer_virtual_guest.dcos_master.*.ipv4_address, count.index)}"
    agent = true
    timeout = "3m"
  }

  provisioner "file" {
	    source = "./logging/install-filebeat.sh"
	    destination = "/tmp/install-filebeat.sh"
  }

  provisioner "remote-exec" {
	 inline = "bash /tmp/install-filebeat.sh master > /tmp/install-master-logging.log"
  }
}

resource "null_resource" "dcos_agent_logging" {

  count = "${var.dcos_agent_count * var.dcos_install_logging }"
  depends_on = ["null_resource.dcos_agent_install"]
  connection {
    user = "${var.softlayer_vm_user}"
    private_key = "${file(var.dcos_ssh_key_path)}"
    host = "${element(softlayer_virtual_guest.dcos_agent.*.ipv4_address, count.index)}"
    agent = true
    timeout = "3m"
  }

  provisioner "file" {
	    source = "./logging/install-filebeat.sh"
	    destination = "/tmp/install-filebeat.sh"
  }

  provisioner "remote-exec" {
	 inline = "bash /tmp/install-filebeat.sh agent > /tmp/install-agent-logging.log"
  }
}

resource "null_resource" "dcos_public_agent_logging" {
  count = "${var.dcos_public_agent_count * var.dcos_install_logging}"
  depends_on = ["null_resource.dcos_public_agent_install"]
  connection {
    user = "${var.softlayer_vm_user}"
    private_key = "${file(var.dcos_ssh_key_path)}"
    host = "${element(softlayer_virtual_guest.dcos_public_agent.*.ipv4_address, count.index)}"
    agent = true
    timeout = "3m"
  }

  provisioner "file" {
	    source = "./logging/install-filebeat.sh"
	    destination = "/tmp/install-filebeat.sh"
  }

  provisioner "remote-exec" {
	 inline = "bash /tmp/install-filebeat.sh agent > /tmp/install-agent-logging.log"
  }
}


