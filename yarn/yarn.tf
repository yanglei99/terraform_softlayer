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

resource "softlayer_file_storage" "storage" {

		count = "${var.enable_file_storage}"
		
	    depends_on = ["softlayer_virtual_guest.yarn_master", "softlayer_virtual_guest.yarn_worker"]

        type = "${var.storage_type}"
        datacenter = "${var.softlayer_datacenter}"
        capacity = "${var.storage_capacity}"
        iops = "${var.storage_iops}"
        
        # Optional fields
        allowed_virtual_guest_ids =  ["${concat(softlayer_virtual_guest.yarn_master.*.id,softlayer_virtual_guest.yarn_worker.*.id)}"]
		
        snapshot_capacity = "${var.storage_snapshot_capacity}"
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

resource "null_resource" "nfs_master" {
    
    count = "${var.enable_file_storage}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}
	
}

resource "null_resource" "nfs_worker" {
    
    count = "${var.enable_file_storage * var.worker_count}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.yarn_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}
	
}

resource "null_resource" "prep_master" {
    
    depends_on = ["null_resource.nfs_master" ]
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
    depends_on = ["null_resource.nfs_worker" ]
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
    
	depends_on = ["softlayer_virtual_guest.yarn_master", "softlayer_virtual_guest.yarn_worker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }
	
    provisioner "local-exec" {
      command = "./make-files.sh ${var.enable_iptables} ${var.hadoop_verion}"
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
      source = "install/install_yarn.sh"
      destination = "/tmp/install_yarn.sh"
    }

    provisioner "file" {
      source = "do-install-iptables.sh"
      destination = "/tmp/do-install-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_yarn.sh master ${var.hadoop_verion} > /tmp/installYarn.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-iptables.sh > /tmp/installIptables.log"
	}

}



resource "null_resource" "worker_install" {
    
    count = "${var.worker_count}"
    depends_on = ["null_resource.master_install" , "null_resource.prep_worker"]
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

}

resource "null_resource" "cluster-start" {
    
    depends_on = ["null_resource.worker_install" ]
    connection {
	  user = "hadoop"
      password = "${var.hadoop_password}"
      host = "${softlayer_virtual_guest.yarn_master.ipv4_address}"
    }

    provisioner "file" {
      source = "do-ssh-copy-to-slave.sh"
      destination = "/tmp/do-ssh-copy-to-slave.sh"
    }

    provisioner "file" {
      source = "install/start_yarn.sh"
      destination = "/tmp/start_yarn.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-ssh-copy-to-slave.sh ${var.hadoop_password} > /tmp/installSlaves.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/start_yarn.sh> /tmp/startYarn.log"
	}

}

