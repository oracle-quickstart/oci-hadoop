########################################################
#Hadoop Master Node (Namenode and Resource Manager)
########################################################
module "hadoop_master_node" {
  source              = "./modules/hadoop_master_node"
  availability_domain = "${var.master_ad}"
  compartment_ocid    = "${var.compartment_ocid}"
  master_display_name = "${var.master_display_name}"
  image_id            = "${var.master_image_id}"
  shape               = "${var.master_shape}"
  label_prefix        = "${var.label_prefix}"
  subnet_id           = "${var.master_subnet_id}"
  hadoop_version      = "${var.hadoop_version}"
  nn_port             = "${var.nn_port}"
  rm_port             = "${var.rm_port}"
  jhs_port            = "${var.jhs_port}"
  ssh_authorized_keys = "${var.ssh_authorized_keys}"
  ssh_private_key     = "${var.ssh_private_key}"
  user_data           = "${var.master_user_data}"
  bastion_host        = "${var.bastion_host}"
  bastion_user        = "${var.bastion_user}"
  bastion_private_key = "${var.bastion_private_key}"
}

######################################################
#Hadoop slave(s) (Date node and Node Manager)
######################################################
module "hadoop_slave_node" {
  source                     = "./modules/hadoop_slave_node"
  availability_domains       = "${var.slave_ads}"
  compartment_ocid           = "${var.compartment_ocid}"
  slave_display_name         = "${var.slave_display_name}"
  image_id                   = "${var.slave_image_id}"
  shape                      = "${var.slave_shape}"
  block_storage_sizes_in_gbs = "${var.slave_block_storage_sizes_in_gbs}"
  block_vols_per_node        = "${var.slave_block_vols_per_node}"
  label_prefix               = "${var.label_prefix}"
  subnet_ids                 = "${var.slave_subnet_ids}"
  hadoop_version             = "${var.hadoop_version}"
  slave_count                = "${var.slave_count}"
  nn_port                    = "${var.nn_port}"
  rm_port                    = "${var.rm_port}"
  jhs_port                   = "${var.jhs_port}"
  hadoop_master_name         = "${module.hadoop_master_node.master_display_name}"
  ssh_authorized_keys        = "${var.ssh_authorized_keys}"
  ssh_private_key            = "${var.ssh_private_key}"
  user_data                  = "${var.slave_user_data}"
  bastion_host               = "${var.bastion_host}"
  bastion_user               = "${var.bastion_user}"
  bastion_private_key        = "${var.bastion_private_key}"
}
