output "master-ip" {
  value = "${join(",", softlayer_virtual_guest.xgboost_master.*.ipv4_address)}"
}

output "worker-ip" {
  value = "${join(",", softlayer_virtual_guest.xgboost_worker.*.ipv4_address)}"
}

output "ZK_MASTER" {
  value = "${join(",",formatlist("%s:2181",softlayer_virtual_guest.xgboost_master.*.ipv4_address))}"
}

output "SPARK_MASTER" {
  value = "${join(",",formatlist("%s:7077",softlayer_virtual_guest.xgboost_master.*.ipv4_address))}"
}
