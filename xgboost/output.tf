output "master-public-ip" {
  value = "${join(",", softlayer_virtual_guest.xgboost_master.*.ipv4_address)}"
}

output "master-private-ip" {
  value = "${join(",", softlayer_virtual_guest.xgboost_master.*.ipv4_address_private)}"
}

output "worker-public-ip" {
  value = "${join(",", softlayer_virtual_guest.xgboost_worker.*.ipv4_address)}"
}

output "worker-private-ip" {
  value = "${join(",", softlayer_virtual_guest.xgboost_worker.*.ipv4_address_private)}"
}

output "ZK_MASTER" {
  value = "${join(",",formatlist("%s:2181",softlayer_virtual_guest.xgboost_master.*.ipv4_address))}"
}

output "SPARK_MASTER" {
  value = "${ var.master_public_ip ? join(",",formatlist("%s:7077",softlayer_virtual_guest.xgboost_master.*.ipv4_address)) : join(",",formatlist("%s:7077",softlayer_virtual_guest.xgboost_master.*.ipv4_address_private))}"
}

output "SPARK_MASTER_CLUSTER" {
  value = "${ var.master_public_ip ? join(",",formatlist("%s:6066",softlayer_virtual_guest.xgboost_master.*.ipv4_address)) : join(",",formatlist("%s:6066",softlayer_virtual_guest.xgboost_master.*.ipv4_address_private))}"
}
