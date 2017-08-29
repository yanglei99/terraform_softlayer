output "master-ip-public" {
  value = "${join(",", softlayer_virtual_guest.yarn_master.*.ipv4_address)}"
}

output "master-ip-private" {
  value = "${join(",", softlayer_virtual_guest.yarn_master.*.ipv4_address_private)}"
}

output "worker-ip-public" {
  value = "${join(",", softlayer_virtual_guest.yarn_worker.*.ipv4_address)}"
}

output "worker-ip-private" {
  value = "${join(",", softlayer_virtual_guest.yarn_worker.*.ipv4_address_private)}"
}

output "bm-worker-ip-public" {
  value = "${join(",", softlayer_bare_metal.yarn_bm_worker.*.public_ipv4_address)}"
}

output "bm-worker-ip-private" {
  value = "${join(",", softlayer_bare_metal.yarn_bm_worker.*.private_ipv4_address)}"
}

output "status-hdfs" {
  value = "${softlayer_virtual_guest.yarn_master.ipv4_address_private}:50070"
}

output "status-yarn" {
  value = "${softlayer_virtual_guest.yarn_master.ipv4_address_private}:8088"
}
