provider "softlayer" {
    username = "${var.softlayer_user}"
    api_key = "${var.softlayer_api_key}"
}

# This will create a new SSH key that will show up under the \
# Devices>Manage>SSH Keys in the SoftLayer console.
resource "softlayer_ssh_key" "terraform_k8s" {
    label = "terraform_k8s"
    notes = "terraform key for k8s"
    public_key = "${file(var.ssh_public_key_path)}"
}

resource "softlayer_virtual_guest" "k8s_master" {

    count  = "${var.master_count}"

    hostname = "${format("${var.cluster_name}-master-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_k8s.id}"]
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

resource "null_resource" "k8s_master_install" {

    count = "${var.master_count}"
    depends_on = ["softlayer_virtual_guest.k8s_master"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.k8s_master.*.ipv4_address, count.index)}"
    }
    
    provisioner "file" {
      source = "./install/install-k8s.sh"
      destination = "/tmp/install-k8s.sh"
    }
   
    provisioner "file" {
      source = "./install/initialize-k8s.sh"
      destination = "/tmp/initialize-k8s.sh"
    }

    provisioner "file" {
      source = "./install/install-pod-network.sh"
      destination = "/tmp/install-pod-network.sh"
    }

    provisioner "file" {
      source = "./install/weave-daemonset-k8s-1.6-fix.yaml"
      destination = "/tmp/weave-daemonset-k8s-1.6-fix.yaml"
    }
 
	provisioner "remote-exec" {
	    inline = [
	       "echo install k8s on master && bash /tmp/install-k8s.sh > /tmp/install-k8s.log",
	       "echo initialize k8s on master && bash /tmp/initialize-k8s.sh ${element(softlayer_virtual_guest.k8s_master.*.ipv4_address, count.index)} ${var.k8s_pod_network_cidr} > /tmp/initialize-k8s.log",
	       "echo install pod network on master && bash /tmp/install-pod-network.sh /tmp/weave-daemonset-k8s-1.6-fix.yaml > /tmp/install-pod-network.log"
	    ]
	}

	provisioner "local-exec" {
	    command = "echo initialize local environment && chmod +x ./install/initialize_local_env.sh  && . ./install/initialize_local_env.sh ${element(softlayer_virtual_guest.k8s_master.*.ipv4_address, 0)}"
	}

}

resource "null_resource" "k8s_local_proxy" {

    count         = "${var.enable_local_k8s_proxy}"

    depends_on = ["null_resource.k8s_master_install"]

	provisioner "local-exec" {
	    command = "echo create local proxy && nohup kubectl proxy --port=${var.k8s_proxy_port} &"
	}

}


resource "softlayer_virtual_guest" "k8s_worker" {
  
    count         = "${var.worker_count}"

    hostname = "${format("${var.cluster_name}-worker-%02d", count.index)}"
    domain =  "${var.softlayer_domain}"
    ssh_key_ids = ["${softlayer_ssh_key.terraform_k8s.id}"]
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
  
resource "null_resource" "k8s_worker_install" {

    count = "${var.worker_count}"
    depends_on = ["softlayer_virtual_guest.k8s_worker","null_resource.k8s_master_install"]
    connection {
      user = "${var.softlayer_vm_user}"
      private_key = "${file(var.ssh_key_path)}"
      host = "${element(softlayer_virtual_guest.k8s_worker.*.ipv4_address, count.index)}"
    }
    
     provisioner "file" {
      source = "./install/install-k8s.sh"
      destination = "/tmp/install-k8s.sh"
    }
    
    provisioner "file" {
      source = "./do-join-node.sh"
      destination = "/tmp/do-join-node.sh"
    }


	provisioner "remote-exec" {
	    inline = [
	        "echo install k8s on worker && bash /tmp/install-k8s.sh > /tmp/install-k8s.log",
	    	"echo join k8s cluster && bash /tmp/do-join-node.sh > /tmp/do-join-node.log"
	    ]
	}
}

