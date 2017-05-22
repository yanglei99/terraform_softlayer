output "master-ip" {
  value = "${join(",", softlayer_virtual_guest.ingest_master.*.ipv4_address)}"
}

output "worker-ip" {
  value = "${join(",", softlayer_virtual_guest.ingest_worker.*.ipv4_address)}"
}

output "ZK_MASTER" {
  value = "${join(",",formatlist("%s:2181",softlayer_virtual_guest.ingest_master.*.ipv4_address))}"
}

output "SPARK_MASTER" {
  value = "${join(",",formatlist("%s:7077",softlayer_virtual_guest.ingest_master.*.ipv4_address))}"
}

output "KAFKA_BROKER" {
  value = "${var.master_install_kafka ? join(",",formatlist("%s:9092",concat(softlayer_virtual_guest.ingest_master.*.ipv4_address,softlayer_virtual_guest.ingest_worker.*.ipv4_address))) : join(",",formatlist("%s:9092",softlayer_virtual_guest.ingest_worker.*.ipv4_address)) }"
}
