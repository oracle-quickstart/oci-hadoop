# Init Script Files
data "template_file" "setup_slave" {
  template = "${file("${path.module}/scripts/setup_slave.sh")}"

  vars {
    hadoop_version                       = "${var.hadoop_version}"
    nn_port                              = "${var.nn_port}"
    rm_port                              = "${var.rm_port}"
    jhs_port                             = "${var.jhs_port}"
    hadoop_master_ip                     = "${var.hadoop_master_ip}"
    hadoop_master_name_node_url          = "{hdfs://${var.hadoop_master_ip}:${var.nn_port}"
    hadoop_master_resource_manger_url    = "${var.hadoop_master_ip}:${var.rm_port}"
    hadoop_master_job_history_server_url = "${var.hadoop_master_ip}:${var.jhs_port}"
  }
}

# hadoop Slaves
resource "oci_core_instance" "TFhadoopSlave" {
  count               = "${var.slave_count}"
  availability_domain = "${var.availability_domains[count.index%length(var.availability_domains)]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
  shape               = "${var.shape}"

  create_vnic_details {
    subnet_id        = "${var.subnet_ids[count.index%length(var.subnet_ids)]}"
    display_name     = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
    assign_public_ip = false
    hostname_label   = "${var.slave_display_name}-${count.index+1}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }

  provisioner "file" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    content     = "${data.template_file.setup_slave.rendered}"
    destination = "~/setup_slave.sh"
  }

  # Register & Launch slave
  provisioner "remote-exec" {
    connection = {
      host        = "${self.private_ip}"
      agent       = false
      timeout     = "10m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    inline = [
      "sudo chmod +x ~/setup_slave.sh",
      "sudo ~/setup_slave.sh ",
    ]
  }
}
