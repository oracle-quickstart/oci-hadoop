variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "dns_label" {
  description = "Allows assignment of DNS hostname when launching an Instance. "
  default     = ""
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "master_ad" {
  description = "The Availability Domain for hadoop master. "
  default     = ""
}

variable "master_subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
  default     = ""
}

variable "hadoop_version" {
  description = "The verion of hadoop distribution. "
  default     = ""
}

variable "master_display_name" {
  description = "The name of the  master and resource manager instance. "
  default     = "tf-hadoop-master"
}

variable "master_image_id" {
  description = "The OCID of an image for a master instance to use. "
  default     = ""
}

variable "master_shape" {
  description = "Instance shape to use for master instance. "
  default     = "VM.Standard2.1"
}

variable "master_user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for master instance. "
  default     = ""
}

variable "slave_count" {
  description = "Number of slave instances to launch. "
  default     = "3"
}

variable "slave_ads" {
  description = "The Availability Domain(s) for hadoop slave(s). "
  default     = [0]
}

variable "slave_subnet_ids" {
  description = "List of hadoop slave subnets' id. "
  default     = []
}

variable "slave_display_name" {
  description = "The name of the slave instance. "
  default     = "tf-hadoop-slave"
}

variable "slave_image_id" {
  description = "The OCID of an image for slave instance to use.  "
  default     = ""
}

variable "slave_shape" {
  description = "Instance shape to use for slave instance. "
  default     = "VM.Standard2.1"
}

variable "slave_user_data" {
  description = "Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration for slave instance. "
  default     = ""
}

variable "slave_block_storage_sizes_in_gbs" {
  description = "Sizes of volumes to create and attach to each instance. "
  default     = ["50"]
}

variable "slave_block_vols_per_node" {
  description = "Number of block volumes per instance. "
  default     = "2"
}

variable "nn_port" {
  description = "The port to use for hadoop Name Node. "
  default     = 50070
}

variable "rm_port" {
  description = "The Port to use for hadoop Resource Manager. "
  default     = 8088
}

variable "jhs_port" {
  description = "The Port to use for hadoop Job History Server. "
  default     = 19888
}

variable "bastion_host" {
  description = "The bastion host IP."
}

variable "bastion_user" {
  description = "The SSH user to connect to the bastion host."
  default     = "opc"
}

variable "bastion_private_key" {
  description = "The private key path to access the bastion host."
}
