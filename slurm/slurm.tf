provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_slurm" {
    label = "key_${var.cluster_name}"
    notes = "terraform key for ${var.cluster_name}"
    public_key = "${file(var.ssh_public_key_path)}"
}

resource "softlayer_file_storage" "storage" {

		count = "${var.enable_file_storage}"
		
	    depends_on = ["softlayer_virtual_guest.slurm_master", "softlayer_virtual_guest.slurm_worker","softlayer_bare_metal.slurm_bm_worker"]

        type = "${var.storage_type}"
        datacenter = "${var.softlayer_datacenter}"
        capacity = "${var.storage_capacity}"
        iops = "${var.storage_iops}"
        
        # Optional fields
        allowed_virtual_guest_ids =  ["${concat(softlayer_virtual_guest.slurm_master.*.id,softlayer_virtual_guest.slurm_worker.*.id)}"]
		allowed_hardware_ids = ["${softlayer_bare_metal.slurm_bm_worker.*.id}"]
		
        snapshot_capacity = "${var.storage_snapshot_capacity}"
}


resource "softlayer_virtual_guest" "slurm_master" {

    count  = "${var.master_count}"

    hostname = "${format("${var.cluster_name}-master-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_slurm.id}"]
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
	    command = "echo \"ControlAddr=${self.ipv4_address_private}\" >> cluster_info.txt"
	}
	  
    provisioner "local-exec" {
      command = "echo \"ControlMachine=${self.hostname}\" >> cluster_info.txt"
    }  

    provisioner "local-exec" {
      command = "echo \"ClusterName=${var.cluster_name}\" >> cluster_info.txt"
    }  

  	provisioner "local-exec" {
	    command = "if [ \"${var.master_iscompute}\" == \"1\" ] ; then echo \"NodeName=${self.hostname} NodeAddr=${self.ipv4_address_private} CPUs=${var.worker_cores} State=UNKNOWN \" >> cluster_info.txt; fi"
	}

    provisioner "local-exec" {
       command = "rm -rf ./slurm.conf"
    }
    
    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting master VM ready"
    }
  
}

resource "null_resource" "nfs_master" {
    
    count = "${var.enable_file_storage * var.master_count}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.slurm_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}
}

resource "null_resource" "slurm_config" {
    
	depends_on = ["null_resource.nfs_master", "softlayer_virtual_guest.slurm_worker","softlayer_bare_metal.slurm_bm_worker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.slurm_master.*.ipv4_address, 0)}"
    }
	
    provisioner "local-exec" {
      command = "./make-files.sh {var.enable_iptables}"
    }
    
    provisioner "file" {
      source = "slurm.conf"
      destination = "${var.nfs_dir}/slurm.conf"
    }
    
    provisioner "file" {
      source = "install/cgroup.conf"
      destination = "${var.nfs_dir}/cgroup.conf"
    }
    
    provisioner "file" {
      source = "install/cgroup_allowed_devices_file.conf"
      destination = "${var.nfs_dir}/cgroup_allowed_devices_file.conf"
    }
}


resource "null_resource" "master_install" {
    
    count = "${var.master_count}"
    depends_on = ["null_resource.slurm_config" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.slurm_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_munge.sh"
      destination = "/tmp/install_munge.sh"
    }

    provisioner "file" {
      source = "install/install_slurm.sh"
      destination = "/tmp/install_slurm.sh"
    }

    provisioner "file" {
      source = "slurm-17.02.6.tar.bz2"
      destination = "/tmp/slurm-17.02.6.tar.bz2"
    }

    provisioner "file" {
      source = "do-install-iptables.sh"
      destination = "/tmp/do-install-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_munge.sh master ${var.nfs_dir} > /tmp/installMunge.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_slurm.sh master ${var.nfs_dir} ${var.master_iscompute} > /tmp/installSlurm.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-iptables.sh > /tmp/installIptables.log"
	}

}


resource "softlayer_virtual_guest" "slurm_worker" {

    count  = "${var.worker_count}"

    hostname = "${format("${var.cluster_name}-worker-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_slurm.id}"]
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
	    command = "echo \"NodeName=${self.hostname} NodeAddr=${self.ipv4_address_private} CPUs=${var.worker_cores} State=UNKNOWN \" >> cluster_info.txt"
	}
	  
    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting worker VM ready"
    }
  
}


resource "null_resource" "nfs_worker" {
    
    count = "${var.enable_file_storage * var.worker_count}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.slurm_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}
}

resource "null_resource" "worker_install" {
    
    count = "${var.worker_count}"
    depends_on = ["null_resource.nfs_worker", "null_resource.master_install" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.slurm_worker.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_munge.sh"
      destination = "/tmp/install_munge.sh"
    }

    provisioner "file" {
      source = "install/install_slurm.sh"
      destination = "/tmp/install_slurm.sh"
    }

    provisioner "file" {
      source = "do-install-iptables.sh"
      destination = "/tmp/do-install-iptables.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_munge.sh worker ${var.nfs_dir} > /tmp/installMunge.log"
	}
		
   provisioner "remote-exec" {
	  inline = "bash /tmp/install_slurm.sh worker ${var.nfs_dir} > /tmp/installSlurm.log"
	}

    provisioner "remote-exec" {
	  inline = "bash /tmp/do-install-iptables.sh > /tmp/installIptables.log"
	}

}

