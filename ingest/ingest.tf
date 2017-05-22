provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_ingest" {
    label = "terraform_ingest_1"
    notes = "terraform key for ingest"
    public_key = "${file(var.ssh_public_key_path)}"
}

resource "softlayer_virtual_guest" "ingest_master" {

    count  = "${var.master_count}"

    hostname = "${format("${var.cluster_name}-master-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_ingest.id}"]
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
	    command = "sleep ${var.provision_vm_wait_time} && echo done waiting master VM ready"
    }

}

resource "null_resource" "ingest_master_env" {
    
    depends_on = ["softlayer_virtual_guest.ingest_master"]

	provisioner "local-exec" {
	    command = "echo ZK_MASTER=\"${join(",",formatlist("%s:2181",softlayer_virtual_guest.ingest_master.*.ipv4_address))}\" > setenv.sh"
	}

	provisioner "local-exec" {
	    command = "echo SPARK_MASTER=\"spark://${join(",",formatlist("%s:7077",softlayer_virtual_guest.ingest_master.*.ipv4_address))}\" >> setenv.sh"
	}
	
	provisioner "local-exec" {
	    command = "./make-files.sh"
	}

}

resource "null_resource" "ingest_master_docker" {
    
    count = "${var.install_docker * var.master_count}"
    depends_on = ["softlayer_virtual_guest.ingest_master"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.ingest_master.*.ipv4_address, count.index)}"
    }

    provisioner "file" {
      source = "./docker/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }
 
    provisioner "file" {
      source = "./docker/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh > /tmp/prepSystem.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
}

resource "null_resource" "ingest_master_install_zk" {

    count = "${var.master_count}"
    depends_on = ["null_resource.ingest_master_docker","null_resource.ingest_master_env"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.ingest_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./do-install-exhibitor.sh"
      destination = "/tmp/do-install-exhibitor.sh"
    }
   
	provisioner "remote-exec" {
	    inline = [
	       "echo install exhibitor && bash /tmp/do-install-exhibitor.sh > /tmp/installExhibitor.log"
	    ]
	}
	
}

resource "null_resource" "ingest_master_install" {

    count = "${var.master_count}"
    depends_on = ["null_resource.ingest_master_install_zk"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.ingest_master.*.ipv4_address, count.index)}"
    }
    
	provisioner "local-exec" {
	    command = "sleep ${var.provision_zk_wait_time} && echo done waiting master ZK ready"
    }
      
    provisioner "file" {
      source = "./do-install-spark-master.sh"
      destination = "/tmp/do-install-spark-master.sh"
    }
   
    provisioner "file" {
      source = "./do-install-spark-worker.sh"
      destination = "/tmp/do-install-spark-worker.sh"
    }

    provisioner "file" {
      source = "./do-install-kafka.sh"
      destination = "/tmp/do-install-kafka.sh"
    }

	provisioner "remote-exec" {
	    inline = [
	    "echo install spark master && bash /tmp/do-install-spark-master.sh > /tmp/installSparkMaster.log",
	    "if [ \"${var.master_install_spark_worker}\" = \"true\" ]; then echo install spark worker && bash /tmp/do-install-spark-worker.sh > /tmp/installSparkWorker.log; fi",
	    "if [ \"${var.master_install_kafka}\" = \"true\" ]; then echo install kafka && bash /tmp/do-install-kafka.sh ${count.index + 1 } > /tmp/installKafka.log; fi"
	    ]
	}
	
}

resource "softlayer_virtual_guest" "ingest_worker" {
  
    count         = "${var.worker_count}"

    hostname = "${format("${var.cluster_name}-worker-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_ingest.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.worker_cores}"
    memory = "${var.worker_memory}"
    local_disk = "true"
    network_speed = "${var.worker_network}"
    disks = "${var.worker_disk}"

    provisioner "local-exec" {
	    command = "sleep ${var.provision_vm_wait_time} && echo done waiting agent VM ready"
    }

}
  
resource "null_resource" "ingest_worker_docker" {
    
    count = "${var.install_docker * var.worker_count}"
    depends_on = ["softlayer_virtual_guest.ingest_worker"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.ingest_worker.*.ipv4_address, count.index)}"
    }
          
    provisioner "file" {
      source = "./docker/prepSystem.sh"
      destination = "/tmp/prepSystem.sh"
    }
 
    provisioner "file" {
      source = "./docker/installDocker.sh"
      destination = "/tmp/installDocker.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/prepSystem.sh > /tmp/prepSystem.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/installDocker.sh > /tmp/installDocker.log"
	}
}

resource "null_resource" "ingest_worker_install" {

    count = "${var.worker_count}"
    depends_on = ["null_resource.ingest_worker_docker","null_resource.ingest_master_install"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.ingest_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./do-install-spark-worker.sh"
      destination = "/tmp/do-install-spark-worker.sh"
    }

    provisioner "file" {
      source = "./do-install-kafka.sh"
      destination = "/tmp/do-install-kafka.sh"
    }
    
	provisioner "remote-exec" {
	    inline = [
	    "if [ \"${var.worker_install_spark_worker}\" = \"true\" ]; then echo install spark worker && bash /tmp/do-install-spark-worker.sh > /tmp/installSparkWorker.log; fi",
	    "if [ \"${var.worker_install_kafka}\" = \"true\" ]; then echo install kafka && bash /tmp/do-install-kafka.sh ${var.master_install_kafka ? var.master_count + count.index + 1: count.index + 1} > /tmp/installKafka.log; fi"
	    ]
	}
}

