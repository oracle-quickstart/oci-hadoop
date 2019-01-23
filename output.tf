output "master_instance_id" {
  value = "${module.hadoop_master_node.id}"
}

output "master_public_ip" {
  value = "${module.hadoop_master_node.public_ip}"
}

output "master_private_ip" {
  value = "${module.hadoop_master_node.private_ip}"
}

output "slave_instance_ids" {
  value = ["${module.hadoop_slave_node.ids}"]
}

output "slave_private_ips" {
  value = ["${module.hadoop_slave_node.private_ips}"]
}
