variable "compartment_ocid" {
  description = "Compartment's OCID where VCN will be created. "
}

variable "availability_domains" {
  description = "The Availability Domain of the instance. "
  default     = []
}

#variable "availability_domain" {
#  description = "The Availability Domain of the instance. "
#  default     = []
#}

variable "hadoop_version" {
  description = "The version of the hadoop distribution."
  default     = "2.9.2"
}

variable "hadoop_master_ip" {
  description = "Hadoop Master private ip"
  default     = ""
}

variable "hadoop_master_nn_port" {
  description = "describe your variable"
  default     = ""
}

variable "slave_display_name" {
  description = "The name of the slave instance. "
  default     = ""
}

variable "subnet_ids" {
  description = "The OCID of the slave subnet to create the VNIC in. "
  default     = []
}

#variable "slave_ads" {
#  description = "ADs list for slave instances"
#  default     = "${data.template_file.ad_names.*.rendered}" 
#}

variable "shape" {
  description = "Instance shape to use for master instance. "
  default     = ""
}

variable "slave_count" {
  description = "Slave Instances count. "
  default     = "3"
}

variable "label_prefix" {
  description = "To create unique identifier for multiple clusters in a compartment."
  default     = ""
}

variable "assign_public_ip" {
  description = "Whether the VNIC should be assigned a public IP address."
  default     = false
}

variable "ssh_authorized_keys" {
  description = "Public SSH keys path to be included in the ~/.ssh/authorized_keys file for the default user on the instance. "
  default     = ""
}

variable "ssh_private_key" {
  description = "The private key path to access instance. "
  default     = ""
}

variable "image_id" {
  description = "The OCID of an image for an instance to use. "
  default     = ""
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
  default     = "opc"
}

variable "bastion_private_key" {
  description = "The private key path to access the bastion host."
}
