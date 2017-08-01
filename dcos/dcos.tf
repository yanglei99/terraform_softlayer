provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_dcos" {
    label = "${var.softlayer_ssh_key_label}"
    notes = "terraform key for dcos"
    public_key = "${file(var.dcos_ssh_public_key_path)}"
}

resource "softlayer_virtual_guest" "dcos_bootstrap" {

    hostname = "${format("${var.dcos_cluster_name}-bootstrap-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.boot_cores}"
    memory = "${var.boot_memory}"
    network_speed = "${var.boot_network}"
    local_disk = "true"
    disks = "${var.boot_disk}"

	provisioner "local-exec" {
	    command = "echo BOOTSTRAP=\"${softlayer_virtual_guest.dcos_bootstrap.ipv4_address_private}\" >> ips.txt"
	}
	  
    provisioner "local-exec" {
      command = "echo CLUSTER_NAME=\"${var.dcos_cluster_name}\" >> ips.txt"
    }  
    
    provisioner "local-exec" {
       command = "rm -rf ./do-install.sh"
    }
    
    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting bootstrap VM ready"
    }
    
}

resource "null_resource" "dcos_bootstrap_docker" {
    
    count = "${var.dcos_install_docker}"
    depends_on = ["softlayer_virtual_guest.dcos_bootstrap"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${softlayer_virtual_guest.dcos_bootstrap.ipv4_address}"
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


resource "null_resource" "dcos_bootstrap_install" {
    
    depends_on = ["null_resource.dcos_bootstrap_docker", "softlayer_virtual_guest.dcos_master"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${softlayer_virtual_guest.dcos_bootstrap.ipv4_address}"
    }
    
    provisioner "local-exec" {
      command = "./make-files.sh {var.enable_iptables}"
    }

    provisioner "local-exec" {
      command = "sed -i -e '/^- *$/d' ./config.yaml"
    }
  
    provisioner "remote-exec" {
      inline = [
        "wget -q -O dcos_generate_config.sh -P $HOME ${var.dcos_installer_url}",
        "mkdir $HOME/genconf"
      ]
    }

    provisioner "file" {
      source = "./ip-detect"
      destination = "$HOME/genconf/ip-detect"
    }
  
    provisioner "file" {
      source = "./config.yaml"
      destination = "$HOME/genconf/config.yaml"
    }
    
    provisioner "file" {
      source = "./do-install-bootstrap-iptables.sh"
      destination = "/tmp/do-install-bootstrap-iptables.sh"
    }

     provisioner "remote-exec" {
       inline = ["sudo bash $HOME/dcos_generate_config.sh",
              "docker run -d -p 4040:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null",
              "docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=dcos_int_zk jplock/zookeeper 2>/dev/null"
              ]
    }

	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install-bootstrap-iptables.sh> /tmp/enable-iptables.log"
	  }
    
}

resource "softlayer_virtual_guest" "dcos_master" {

    count  = "${var.dcos_master_count}"

    hostname = "${format("${var.dcos_cluster_name}-master-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.master_cores}"
    memory = "${var.master_memory}"
    network_speed = "${var.master_network}"
    local_disk = "true"
    disks = "${var.master_disk}"
  
  	provisioner "local-exec" {
	    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.ipv4_address_private}\" >> ips.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting master VM ready"
    }
  
}

resource "null_resource" "dcos_master_docker" {
    
    count = "${var.dcos_install_docker * var.dcos_master_count}"
    depends_on = ["softlayer_virtual_guest.dcos_master"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_master.*.ipv4_address, count.index)}"
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

resource "null_resource" "dcos_master_install" {

    count = "${var.dcos_master_count}"
    depends_on = ["null_resource.dcos_bootstrap_install", "null_resource.dcos_master_docker"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_master.*.ipv4_address, count.index)}"
    }

	  provisioner "file" {
	    source = "./do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }

	  provisioner "file" {
	    source = "./install/enable_nr.sh"
	    destination = "/tmp/enable_nr.sh"
	  }

	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh master  > /tmp/install-master.log"
	  }

	provisioner "remote-exec" {
	    inline = "if [ ! -z \"${var.nr_license}\" ]; then bash /tmp/enable_nr.sh ${var.nr_license} ${var.dcos_cluster_name} master > /tmp/enableNR.log ; fi"
	}
	  
}


resource "softlayer_file_storage" "storage" {

		count = "${var.enable_file_storage}"
		
	    depends_on = ["softlayer_virtual_guest.dcos_agent","softlayer_virtual_guest.dcos_public_agent", "softlayer_bare_metal.dcos_bm_agent"]

        type = "${var.storage_type}"
        datacenter = "${var.softlayer_datacenter}"
        capacity = "${var.storage_capacity}"
        iops = "${var.storage_iops}"
        
        # Optional fields
        allowed_virtual_guest_ids =  ["${concat(softlayer_virtual_guest.dcos_agent.*.id,softlayer_virtual_guest.dcos_public_agent.*.id)}"]
		allowed_hardware_ids = ["${softlayer_bare_metal.dcos_bm_agent.*.id}"]
		
        snapshot_capacity = "${var.storage_snapshot_capacity}"
}

resource "softlayer_virtual_guest" "dcos_agent" {
  
    count         = "${var.dcos_agent_count}"

    hostname = "${format("${var.dcos_cluster_name}-agent-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.agent_cores}"
    memory = "${var.agent_memory}"
    local_disk = "true"
    network_speed = "${var.agent_network}"
    disks = "${var.agent_disk}"

      provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting agent VM ready"
      }
     
}
  

resource "null_resource" "nfs_agent" {
    
    count = "${var.enable_file_storage * var.dcos_agent_count}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_agent.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}
}

resource "null_resource" "dcos_agent_docker" {
    
    count = "${var.dcos_install_docker * var.dcos_agent_count}"
    depends_on = ["null_resource.nfs_agent"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_agent.*.ipv4_address, count.index)}"
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

resource "null_resource" "dcos_agent_install" {

    count = "${var.dcos_agent_count}"
    
    depends_on = ["null_resource.dcos_bootstrap_install","null_resource.dcos_agent_docker"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_agent.*.ipv4_address, count.index)}"
    }

  	  provisioner "file" {
	    source = "do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }
	  
	  provisioner "file" {
	    source = "./install/enable_nr.sh"
	    destination = "/tmp/enable_nr.sh"
	  }

	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh slave  > /tmp/install-slave.log"
	  }
	  
	  provisioner "remote-exec" {
		    inline = "if [ ! -z \"${var.nr_license}\" ]; then bash /tmp/enable_nr.sh ${var.nr_license} ${var.dcos_cluster_name} agent > /tmp/enableNR.log ; fi"
	 }

}


resource "softlayer_virtual_guest" "dcos_public_agent" {

    count         = "${var.dcos_public_agent_count}"

    hostname = "${format("${var.dcos_cluster_name}-public-agent-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"
    cores = "${var.agent_cores}"
    memory = "${var.agent_memory}"
    network_speed = "${var.agent_network}"
    local_disk = "true"
    disks = "${var.agent_disk}"

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_vm} && echo done waiting public agent VM ready"
    }
}
  
 resource "null_resource" "nfs_public_agent" {
    
    count = "${var.enable_file_storage * var.dcos_public_agent_count}"
    depends_on = ["softlayer_file_storage.storage"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_public_agent.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}

}
resource "null_resource" "dcos_public_agent_docker" {
    
    count = "${var.dcos_install_docker * var.dcos_public_agent_count}"
    depends_on = ["null_resource.nfs_public_agent"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_public_agent.*.ipv4_address, count.index)}"
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

resource "null_resource" "dcos_public_agent_install" {

    count = "${var.dcos_public_agent_count}"
    
    depends_on = ["null_resource.dcos_bootstrap_install","null_resource.dcos_public_agent_docker"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.dcos_public_agent.*.ipv4_address, count.index)}"
    }

	provisioner "file" {
      source = "do-install.sh"
      destination = "/tmp/do-install.sh"
    }

	  provisioner "file" {
	    source = "./install/enable_nr.sh"
	    destination = "/tmp/enable_nr.sh"
	  }

  
    provisioner "remote-exec" {
      inline = "bash /tmp/do-install.sh slave_public > /tmp/install-slave-public.log"
    }
    
	provisioner "remote-exec" {
		    inline = "if [ ! -z \"${var.nr_license}\" ]; then bash /tmp/enable_nr.sh ${var.nr_license} ${var.dcos_cluster_name} agent_public > /tmp/enableNR.log ; fi"
	}
}
