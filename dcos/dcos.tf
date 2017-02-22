provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_dcos" {
    label = "terraform_dcos_17"
    notes = "terraform key for dcos"
    public_key = "${file(var.dcos_ssh_public_key_path)}"
}

resource "softlayer_virtual_guest" "dcos_bootstrap" {
    hostname = "${format("${var.dcos_cluster_name}-bootstrap-%02d", count.index)}"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    connection {
      user = "core"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${self.ipv4_address}"
    }
    
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "COREOS_LATEST_64"
    datacenter = "${var.datacenter}"
    hourly_billing = "true"
    cores = "${var.boot_cores}"
    memory = "${var.boot_memory}"
    network_speed = "${var.boot_network}"
    local_disk = "true"
    disks = "${var.boot_disk}"
    
    provisioner "local-exec" {
       command = "rm -rf ./do-install.sh"
    }
    
	provisioner "local-exec" {
	    command = "echo BOOTSTRAP=\"${softlayer_virtual_guest.dcos_bootstrap.ipv4_address}\" >> ips.txt"
	}
	  
    provisioner "local-exec" {
      command = "echo CLUSTER_NAME=\"${var.dcos_cluster_name}\" >> ips.txt"
    }  
    
 	provisioner "local-exec" {
	    command = "sleep ${var.wait_time_masters} && echo done waiting masters ready"
	}
    
    provisioner "local-exec" {
      command = "./make-files.sh"
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
 
     provisioner "remote-exec" {
       inline = ["sudo bash $HOME/dcos_generate_config.sh",
              "docker run -d -p 4040:80 -v $HOME/genconf/serve:/usr/share/nginx/html:ro nginx 2>/dev/null",
              "docker run -d -p 2181:2181 -p 2888:2888 -p 3888:3888 --name=dcos_int_zk jplock/zookeeper 2>/dev/null"
              ]
    }
    
}

resource "softlayer_virtual_guest" "dcos_master" {
    hostname = "${format("${var.dcos_cluster_name}-master-%02d", count.index)}"
    
    count         = "${var.dcos_master_count}"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    connection {
      user = "core"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${self.ipv4_address}"
    }
    
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "COREOS_LATEST_64"
    datacenter = "${var.datacenter}"
    hourly_billing = "true"
    cores = "${var.master_cores}"
    memory = "${var.master_memory}"
    network_speed = "${var.master_network}"
    local_disk = "true"
    disks = "${var.master_disk}"
  
	  provisioner "local-exec" {
	    command = "echo ${format("MASTER_%02d", count.index)}=\"${self.ipv4_address}\" >> ips.txt"
	  }

	  provisioner "local-exec" {
	    command = "while [ ! -f ./do-install.sh ]; do sleep 1; done"
	  }

	  provisioner "file" {
	    source = "./do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }

	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh master  > /tmp/install-master.log"
	  }
}

resource "softlayer_virtual_guest" "dcos_agent" {
  hostname = "${format("${var.dcos_cluster_name}-agent-%02d", count.index)}"
  depends_on = ["softlayer_virtual_guest.dcos_bootstrap"]
  
    count         = "${var.dcos_agent_count}"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    connection {
      user = "core"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${self.ipv4_address}"
    }
    
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "COREOS_LATEST_64"
    datacenter = "${var.datacenter}"
    hourly_billing = "true"
    cores = "${var.agent_cores}"
    memory = "${var.agent_memory}"
    local_disk = "true"
    network_speed = "${var.agent_network}"
    disks = "${var.agent_disk}"
  
	  provisioner "local-exec" {
	    command = "while [ ! -f ./do-install.sh ]; do sleep 1; done"
	  }

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_agent} && echo done waiting agent ready"
    }
      
	  provisioner "file" {
	    source = "do-install.sh"
	    destination = "/tmp/do-install.sh"
	  }
	  
	  provisioner "remote-exec" {
	    inline = "bash /tmp/do-install.sh slave  > /tmp/install-slave.log"
	  }
}


resource "softlayer_virtual_guest" "dcos_public_agent" {
  hostname = "${format("${var.dcos_cluster_name}-public-agent-%02d", count.index)}"
  depends_on = ["softlayer_virtual_guest.dcos_bootstrap"]

    count         = "${var.dcos_public_agent_count}"
    domain = "yl.softlayer.com"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    connection {
      user = "core"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${self.ipv4_address}"
    }

    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "COREOS_LATEST_64"
    datacenter = "${var.datacenter}"
    hourly_billing = "true"
    cores = "${var.agent_cores}"
    memory = "${var.agent_memory}"
    network_speed = "${var.agent_network}"
    local_disk = "true"
    disks = "${var.agent_disk}"

    provisioner "local-exec" {
      command = "while [ ! -f ./do-install.sh ]; do sleep 1; done"
    }
  
    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_agent} && echo done waiting public agent ready"
    }
      
	provisioner "file" {
      source = "do-install.sh"
      destination = "/tmp/do-install.sh"
    }
  
    provisioner "remote-exec" {
      inline = "bash /tmp/do-install.sh slave_public > /tmp/install-slave-public.log"
    }
}
