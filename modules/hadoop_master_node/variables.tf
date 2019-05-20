variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domain" {
  description = "The Availability Domain of the instance. "
}

variable "hadoop_version" {
  description = "The version of the hadoop distribution."
}

variable "master_display_name" {
  description = "The name of the master instance. "
}

variable "subnet_id" {
  description = "The OCID of the master subnet to create the VNIC in. "
}

variable "hadoop_master_name" {
  description = "Hadoop Master host name"
  default     = ""
}

variable "shape" {
  description = "Instance shape to use for master instance. "
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
