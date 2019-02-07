variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domains" {
  description = "The Availability Domain of the instance."
  type        = "list"
}

variable "hadoop_version" {
  description = "The version of the hadoop distribution."
}

variable "hadoop_master_name" {
  description = "Hadoop Master Host Name"
}

variable "slave_display_name" {
  description = "The name of the slave instance."
}

variable "subnet_ids" {
  description = "The OCID of the slave subnet to create the VNIC in. "
  type        = "list"
}

variable "shape" {
  description = "Instance shape to use for master instance. "
}

variable "slave_count" {
  description = "Slave Instances count."
}

variable "boot_volume_size_in_gbs" {
  description = "The size of the boot volume in GBs. "
  default     = "50"
}

variable "block_storage_sizes_in_gbs" {
  description = "Sizes of volumes to create and attach to each instance. "
  type        = "list"
}

variable "block_vols_per_node" {
  description = "Number of block volumes per instance. "
}

variable "attachment_type" {
  description = "Attachment type. "
  default     = "iscsi"
}

variable "use_chap" {
  description = "Whether to use CHAP authentication for the volume attachment. "
  default     = false
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
}

variable "image_id" {
  description = "The OCID of an image for an instance to use. "
}

variable "user_data" {
  description = "A User Data script to execute while the server is booting."
}

variable "nn_port" {
  description = "The port to use for hadoop Name Node. "
}

variable "rm_port" {
  description = "The Port to use for hadoop Resource Manager. "
}

variable "jhs_port" {
  description = "The Port to use for hadoop Job History Server. "
}

variable "bastion_host" {
  description = "The bastion host IP."
}

variable "bastion_user" {
  description = "The SSH user to connect to the bastion host."
}

variable "bastion_private_key" {
  description = "The private key path to access the bastion host."
}
