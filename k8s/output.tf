output "master-ip" {
  value = "${join(",", softlayer_virtual_guest.k8s_master.*.ipv4_address)}"
}

output "worker-ip" {
  value = "${join(",", softlayer_virtual_guest.k8s_worker.*.ipv4_address)}"
}

output "proxy" {
	value =  "http://127.0.0.1:${var.k8s_proxy_port}/api/v1"
}
