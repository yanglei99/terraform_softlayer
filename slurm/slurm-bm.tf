
resource "softlayer_bare_metal" "slurm_bm_worker" {

    count         = "${var.bm_worker_count}"

    hostname = "${format("${var.cluster_name}-bm-agent-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_slurm.id}"]
    user_metadata     = "#cloud-config\n\nssh_authorized_keys:\n  - \"${file("${var.ssh_public_key_path}")}\"\n"
    os_reference_code = "${var.softlayer_os_reference_code}"
    datacenter = "${var.softlayer_datacenter}"
    hourly_billing = "true"

    network_speed = "${var.worker_network}"

    fixed_config_preset = "${var.softlayer_bm_fixed_config}" 

  	provisioner "local-exec" {
	    command = "echo \"NodeName=${self.hostname} NodeAddr=${self.private_ipv4_address} CPUs=${var.softlayer_bm_fixed_config_cores} Gres=gpu:${var.softlayer_bm_fixed_config_gpu} State=UNKNOWN\" >> cluster_info.txt"
	}

    provisioner "local-exec" {
	    command = "sleep ${var.wait_time_bm} && echo done waiting agent BM ready"
    }
    
}

resource "null_resource" "nfs_bm_worker" {
    
    count = "${var.enable_file_storage * var.bm_worker_count}"
    depends_on = ["softlayer_file_storage.storage" ]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_bare_metal.slurm_bm_worker.*.public_ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "install/install_nfs.sh"
      destination = "/tmp/install_nfs.sh"
    }

    provisioner "remote-exec" {
	  inline = "bash /tmp/install_nfs.sh ${softlayer_file_storage.storage.mountpoint} ${var.nfs_dir} > /tmp/installNFS.log"
	}

}


resource "null_resource" "gpu_bm_worker" {
    
    count = "${var.enable_gpu * var.bm_worker_count}"
    depends_on = ["null_resource.nfs_bm_worker"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_bare_metal.slurm_bm_worker.*.public_ipv4_address, count.index)}"
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
    depends_on = ["null_resource.gpu_bm_worker", "null_resource.master_install"]
    connection {
	  user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_bare_metal.slurm_bm_worker.*.public_ipv4_address, count.index)}"
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

