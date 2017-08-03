
resource "softlayer_bare_metal" "dcos_bm_agent" {

    count         = "${var.dcos_bm_agent_count}"

    hostname = "${format("${var.dcos_cluster_name}-bm-agent-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_dcos.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.dcos_ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"

    network_speed = "${var.agent_network}"

    fixed_config_preset = "${var.softlayer_bm_fixed_config}" 

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_bm} && echo done waiting agent BM ready"
    }
    
}

resource "null_resource" "nfs_bm_agent" {
    
    count = "${var.enable_file_storage * var.dcos_bm_agent_count}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_bare_metal.dcos_bm_agent.*.public_ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}

}


resource "null_resource" "dcos_bm_agent_docker" {
    
    count = "${var.dcos_install_docker * var.dcos_bm_agent_count}"
    depends_on = ["null_resource.nfs_bm_agent"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_bare_metal.dcos_bm_agent.*.public_ipv4_address, count.index)}"
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

resource "null_resource" "gpu_bm_agent" {
    
    count = "${var.enable_gpu * var.dcos_bm_agent_count}"
    depends_on = ["null_resource.dcos_bm_agent_docker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_bare_metal.dcos_bm_agent.*.public_ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/enable_gpu.sh"
      destination = "/tmp/enable_gpu.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/enable_gpu.sh  > /tmp/enableGPU.log"
	}
}

resource "null_resource" "dcos_bm_agent_install" {

    count = "${var.dcos_bm_agent_count}"
    
    depends_on = ["null_resource.dcos_bootstrap_install","null_resource.gpu_bm_agent"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.dcos_ssh_key_path)}"
      host = "${element(softlayer_bare_metal.dcos_bm_agent.*.public_ipv4_address, count.index)}"
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

