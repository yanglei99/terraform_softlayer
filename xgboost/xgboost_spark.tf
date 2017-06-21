provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_xgboost" {
    label = "terraform_xg"
    notes = "terraform key for xgboost"
    public_key = "${file(var.ssh_public_key_path)}"
}

resource "softlayer_virtual_guest" "xgboost_master" {

    count  = "${var.master_count}"

    hostname = "${format("${var.cluster_name}-master-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_xgboost.id}"]
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

resource "null_resource" "xgboost_master_env" {
    
    depends_on = ["softlayer_virtual_guest.xgboost_master"]

	provisioner "local-exec" {
	    command = "echo export ZK_MASTER=\"${join(",",formatlist("%s:2181",softlayer_virtual_guest.xgboost_master.*.ipv4_address))}\" > setenv.sh"
	}

	provisioner "local-exec" {
	    command = "echo SPARK_MASTER=\"spark://${var.master_public_ip ? join(",",formatlist("%s:7077",softlayer_virtual_guest.xgboost_master.*.ipv4_address)) : join(",",formatlist("%s:7077",softlayer_virtual_guest.xgboost_master.*.ipv4_address_private))}\" >> setenv.sh"
	}
	
	provisioner "local-exec" {
	    command = "echo SPARK_MASTER_CLUSTER=\"spark://${var.master_public_ip ? join(",",formatlist("%s:6066",softlayer_virtual_guest.xgboost_master.*.ipv4_address)) : join(",",formatlist("%s:6066",softlayer_virtual_guest.xgboost_master.*.ipv4_address_private))}\" >> setenv.sh"
	}
	
	provisioner "local-exec" {
	    command = "./make-files.sh"
	}

}

resource "null_resource" "xgboost_master_docker" {
    
    count = "${var.install_docker * var.master_count}"
    depends_on = ["softlayer_virtual_guest.xgboost_master"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_master.*.ipv4_address, count.index)}"
    }

    provisioner "file" {
      source = "./install/install_docker.sh"
      destination = "/tmp/install_docker.sh"
    }
 
    provisioner "remote-exec" {
	  inline = "bash /tmp/install_docker.sh > /tmp/installDocker.log"
	}

}

resource "null_resource" "xgboost_master_install_zk" {

    count = "${var.master_count}"
    depends_on = ["null_resource.xgboost_master_docker","null_resource.xgboost_master_env"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./do-install-exhibitor.sh"
      destination = "/tmp/do-install-exhibitor.sh"
    }
   
	provisioner "remote-exec" {
	    inline = [
	       "echo install exhibitor && bash /tmp/do-install-exhibitor.sh ${element(softlayer_virtual_guest.xgboost_master.*.ipv4_address, count.index)} > /tmp/installExhibitor.log"
	    ]
	}
	
}

resource "null_resource" "xgboost_master_install" {

    count = "${var.master_count}"
    depends_on = ["null_resource.xgboost_master_install_zk"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/install_xgboost_spark.sh"
      destination = "/tmp/install_xgboost_spark.sh"
    }
   
	provisioner "remote-exec" {
	    inline = "echo install spark and xgboost && bash /tmp/install_xgboost_spark.sh > /tmp/installXgboostSpark.log"
	}

}

resource "null_resource" "xgboost_master_start" {

    count = "${var.master_count}"
    depends_on = ["null_resource.xgboost_master_install"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_master.*.ipv4_address, count.index)}"
    }
    
	provisioner "local-exec" {
	    command = "sleep ${var.provision_zk_wait_time} && echo done waiting master ZK ready"
    }
      
    provisioner "file" {
      source = "./do-start-spark-master.sh"
      destination = "/tmp/do-start-spark-master.sh"
    }

	provisioner "remote-exec" {
	    inline = "echo start spark master && bash /tmp/do-start-spark-master.sh ${ var.master_public_ip ? element(softlayer_virtual_guest.xgboost_master.*.ipv4_address, count.index) : element(softlayer_virtual_guest.xgboost_master.*.ipv4_address_private, count.index)} > /tmp/startSparkMaster.log"
	}
	
}


resource "softlayer_virtual_guest" "xgboost_worker" {
  
    count         = "${var.worker_count}"

    hostname = "${format("${var.cluster_name}-worker-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_xgboost.id}"]
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
  
resource "null_resource" "xgboost_worker_docker" {
    
    count = "${var.install_docker * var.worker_count}"
    depends_on = ["softlayer_virtual_guest.xgboost_worker"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_worker.*.ipv4_address, count.index)}"
    }

    provisioner "file" {
      source = "./install/install_docker.sh"
      destination = "/tmp/install_docker.sh"
    }
 
    provisioner "remote-exec" {
	  inline = "bash /tmp/install_docker.sh > /tmp/installDocker.log"
	}
}

resource "null_resource" "xgboost_worker_install" {

    count = "${var.worker_count}"
    depends_on = ["null_resource.xgboost_worker_docker"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/install_xgboost_spark.sh"
      destination = "/tmp/install_xgboost_spark.sh"
    }
   
	provisioner "remote-exec" {
	    inline = "echo install spark and xgboost && bash /tmp/install_xgboost_spark.sh > /tmp/installXgboostSpark.log"
	}

}

resource "null_resource" "xgboost_worker_start" {

    count = "${var.worker_count}"
    depends_on = ["null_resource.xgboost_worker_install","null_resource.xgboost_master_start"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.xgboost_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./do-start-spark-worker.sh"
      destination = "/tmp/do-start-spark-worker.sh"
    }
    
	provisioner "remote-exec" {
	    inline = "echo start spark worker && bash /tmp/do-start-spark-worker.sh ${element(softlayer_virtual_guest.xgboost_worker.*.ipv4_address_private, count.index)} > /tmp/startSparkWorker.log"
	}
}
