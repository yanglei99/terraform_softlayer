
resource "softlayer_bare_metal" "yarn_bm_worker" {

    count         = "${var.bm_worker_count}"

    hostname = "${format("${var.cluster_name}-bm-worker-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_yarn.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"

    network_speed = "${var.worker_network}"

    fixed_config_preset = "${var.softlayer_bm_fixed_config}" 

  	provisioner "local-exec" {
	    command = "echo \"${self.private_ipv4_address} ${self.hostname}\" >> hosts.txt"
	}
	  
  	provisioner "local-exec" {
	    command = "echo ${format("SLAVE_BM_%02d", count.index)}=\"${self.hostname}\" >> setenv.txt"
	}
	
  	provisioner "local-exec" {
	    command = "echo \"${self.hostname}\" >> bm-slaves.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_bm} && echo done waiting agent BM ready"
    }
    
}

resource "null_resource" "prep_bm_worker" {
    
    count = "${var.bm_worker_count}"
    depends_on = ["softlayer_bare_metal.yarn_bm_worker" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_bare_metal.yarn_bm_worker.*.public_ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/prep_yarn.sh"
      destination = "/tmp/prep_yarn.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prep_yarn.sh ${var.hadoop_password} > /tmp/prepYarn.log"
	}
}



resource "null_resource" "gpu_bm_worker" {
    
    count = "${var.enable_gpu * var.bm_worker_count}"
    depends_on = ["null_resource.prep_bm_worker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_bare_metal.yarn_bm_worker.*.public_ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/enable_gpu.sh"
      destination = "/tmp/enable_gpu.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/enable_gpu.sh  > /tmp/enableGPU.log"
	}
}


resource "null_resource" "bm_worker_install" {
    
    count = "${var.bm_worker_count}"
    depends_on = ["null_resource.gpu_bm_worker", "null_resource.yarn_config"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_bare_metal.yarn_bm_worker.*.public_ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "etc.hosts"
      destination = "/etc/hosts"
    }

    provisioner "file" {
      source = "do-install-iptables.sh"
      destination = "/tmp/do-install-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-iptables.sh > /tmp/installIptables.log"
	}

	provisioner "file" {
      source = "install/install_spark.sh"
      destination = "/tmp/install_spark.sh"
    }
    
    provisioner "remote-exec" {
	  inline = "if [ ! -z \"${var.spark_version}\" ]; then bash /tmp/install_spark.sh ${var.spark_version} ${var.hadoop_version} > /tmp/installSpark.log; fi"
	}
	
}

