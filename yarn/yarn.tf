provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_yarn" {
    label = "key_${var.cluster_name}"
    notes = "terraform key for ${var.cluster_name}"
    public_key = "${file(var.ssh_public_key_path)}"
}

resource "softlayer_virtual_guest" "yarn_master" {

    hostname = "${var.cluster_name}-master-00"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_yarn.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.master_cores}"
    memory = "${var.master_memory}"
    network_speed = "${var.master_network}"
    local_disk = "true"
    disks = "${var.master_disk}"
    
	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private} ${self.hostname}\" >> hosts.txt"
	}
	  
	provisioner "local-exec" {
	    command = "echo MASTER_00=\"${self.hostname}\" >> setenv.txt"
	}
	  
    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting master VM ready"
    }
}

resource "softlayer_virtual_guest" "yarn_worker" {

    count  = "${var.worker_count}"

    hostname = "${format("${var.cluster_name}-worker-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_yarn.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.worker_cores}"
    memory = "${var.worker_memory}"
    network_speed = "${var.worker_network}"
    local_disk = "true"
    disks = "${var.worker_disk}"
  
  	provisioner "local-exec" {
	    command = "echo \"${self.ipv4_address_private} ${self.hostname}\" >> hosts.txt"
	}
	  
  	provisioner "local-exec" {
	    command = "echo ${format("SLAVE_%02d", count.index)}=\"${self.hostname}\" >> setenv.txt"
	}
	
  	provisioner "local-exec" {
	    command = "echo \"${self.hostname}\" >> slaves.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting worker VM ready"
    }
}

resource "null_resource" "prep_master" {
    
    depends_on = ["softlayer_virtual_guest.yarn_master" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }
    
    provisioner "file" {
      source = "install/prep_yarn.sh"
      destination = "/tmp/prep_yarn.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prep_yarn.sh ${var.hadoop_password} > /tmp/prepYarn.log"
	}
}

resource "null_resource" "prep_worker" {
    
    count = "${var.worker_count}"
    depends_on = ["softlayer_virtual_guest.yarn_worker" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.yarn_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/prep_yarn.sh"
      destination = "/tmp/prep_yarn.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prep_yarn.sh ${var.hadoop_password} > /tmp/prepYarn.log"
	}
}

resource "null_resource" "yarn_config" {
    
	depends_on = ["softlayer_virtual_guest.yarn_master", "softlayer_virtual_guest.yarn_worker", "softlayer_bare_metal.yarn_bm_worker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }
	
  	provisioner "local-exec" {
	    command = "echo VM_CORES=${var.worker_cores} >> setenv.txt"
	}
	
  	provisioner "local-exec" {
	    command = "echo VM_MEMORY=${var.worker_memory * 1024} >> setenv.txt"
	}

  	provisioner "local-exec" {
	    command = "echo BM_CORES=${var.softlayer_bm_fixed_config_cores} >> setenv.txt"
	}
	
  	provisioner "local-exec" {
	    command = "echo BM_MEMORY=${var.softlayer_bm_fixed_config_memory * 1024} >> setenv.txt"
	}

    provisioner "local-exec" {
      command = "./make-files.sh ${var.enable_iptables} ${var.hadoop_version} ${var.spark_version} ${var.enable_gpu * var.bm_worker_count} ${var.enable_xgboost}"
    }
    
}

resource "null_resource" "master_install" {
    
    depends_on = ["null_resource.yarn_config" , "null_resource.prep_master"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
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



resource "null_resource" "worker_install" {
    
    count = "${var.worker_count}"
    depends_on = ["null_resource.yarn_config" , "null_resource.prep_worker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.yarn_worker.*.ipv4_address, count.index)}"
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

resource "null_resource" "cluster-start" {
    
    depends_on = ["null_resource.master_install","null_resource.worker_install", "null_resource.bm_worker_install"]
    connection {
	  user = "hadoop"
      password = "${var.hadoop_password}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }

    provisioner "file" {
      source = "hadoop.slaves"
      destination = "/tmp/hadoop.slaves"
    }

    provisioner "file" {
      source = "core-site.xml"
      destination = "/tmp/core-site.xml"
    }
    
    provisioner "file" {
      source = "hdfs-site.xml"
      destination = "/tmp/hdfs-site.xml"
    }

    provisioner "file" {
      source = "mapred-site.xml"
      destination = "/tmp/mapred-site.xml"
    }

    provisioner "file" {
      source = "yarn-site.xml"
      destination = "/tmp/yarn-site.xml"
    }

    provisioner "file" {
      source = "yarn-site-bm.xml"
      destination = "/tmp/yarn-site-bm.xml"
    }

    provisioner "file" {
      source = "install/install_yarn.sh"
      destination = "/tmp/install_yarn.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_yarn.sh master ${var.hadoop_version} > /tmp/installYarn.log"
	}

    provisioner "file" {
      source = "do-start-yarn.sh"
      destination = "/tmp/do-start-yarn.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-start-yarn.sh ${var.hadoop_password} > /tmp/startYarn.log"
	}

}

resource "null_resource" "master_install_xgboost" {
    
    depends_on = ["null_resource.cluster-start" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }

	provisioner "file" {
      source = "install/install_xgboost.sh"
      destination = "/tmp/install_xgboost.sh"
    }

    provisioner "remote-exec" {
	  inline = "if [ \"${var.enable_xgboost}\" == \"1\" ]; then bash /tmp/install_xgboost.sh ${var.hadoop_version} ${var.xgboost_patch} > /tmp/installXGBoost.log; fi"
	}

}


