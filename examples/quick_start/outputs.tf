output "Hadoop_Data_Node_private_ips" {
  value = "${module.hadoop.slave_private_ips}"
}

output "Hadoop_Master_Node_private_ip" {
  value = "${module.hadoop.master_private_ip}"
}

output "Bastion_Public_IP" {
  value = "${oci_core_instance.hadoopBastion.public_ip}"
}

output "Hadoop_Namenode_Web_UI" {
  value = "https://${oci_load_balancer.hadoopLB.ip_addresses.0}/dfshealth.html"
}

output "Hadoop_Resource_Manager_Web_UI" {
  value = "https://${oci_load_balancer.hadoopLB.ip_addresses.0}/cluster"
}

output "Hadoop_Job_History_Server_Web_UI" {
  value = "https://${oci_load_balancer.hadoopLB.ip_addresses.0}/jobhistory"
}
