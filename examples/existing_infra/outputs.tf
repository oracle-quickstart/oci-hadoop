output "Hadoop_Data_Node_private_ips" {
  value = ["${module.hadoop.slave_private_ips}"]
}

output "Hadoop_Master_Node_private_ip" {
  value = "${module.hadoop.master_private_ip}"
}
