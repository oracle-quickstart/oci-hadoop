# Init Script Files
data "template_file" "setup_slave" {
  template = "${file("${path.module}/scripts/setup_slave.sh")}"

  vars {
    hadoop_version                       = "${var.hadoop_version}"
    nn_port                              = "${var.nn_port}"
    rm_port                              = "${var.rm_port}"
    jhs_port                             = "${var.jhs_port}"
    hadoop_master_name                   = "${var.hadoop_master_name}.masterad"
    hadoop_master_name_node_url          = "{hdfs://${var.hadoop_master_name}:${var.nn_port}"
    hadoop_master_resource_manger_url    = "${var.hadoop_master_name}:${var.rm_port}"
    hadoop_master_job_history_server_url = "${var.hadoop_master_name}:${var.jhs_port}"
    replication_count                    = "${var.slave_count <= "3" ? var.slave_count : 3}"
    vols_per_node                        = "${var.block_vols_per_node}"
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
    subnet_id      = "${var.subnet_ids[count.index%length(var.subnet_ids)]}"
    display_name   = "${var.label_prefix}${var.slave_display_name}-${count.index+1}"
    hostname_label = "${var.slave_display_name}-${count.index+1}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    boot_volume_size_in_gbs = "${var.boot_volume_size_in_gbs}"
    source_id               = "${var.image_id}"
    source_type             = "image"
  }

  timeouts {
    create = "10m"
  }
}

# Volume
resource "oci_core_volume" "TFhadoopSlave" {
  depends_on = ["oci_core_instance.TFhadoopSlave"]

  //  count = "${var.slave_count * length(var.block_storage_sizes_in_gbs)}"
  count               = "${var.slave_count * var.block_vols_per_node}"
  availability_domain = "${oci_core_instance.TFhadoopSlave.*.availability_domain[count.index % var.slave_count]}"
  compartment_id      = "${var.compartment_ocid}"
  display_name        = "TFhadoopSlave${count.index}"
  size_in_gbs         = "${element(var.block_storage_sizes_in_gbs, count.index % length(var.block_storage_sizes_in_gbs))}"
}

# Volume Attachment
resource "oci_core_volume_attachment" "TFhadoopSlave" {
  depends_on      = ["oci_core_volume.TFhadoopSlave"]
  count           = "${var.slave_count * var.block_vols_per_node}"
  attachment_type = "${var.attachment_type}"
  compartment_id  = "${var.compartment_ocid}"
  instance_id     = "${oci_core_instance.TFhadoopSlave.*.id[count.index % var.slave_count]}"
  volume_id       = "${oci_core_volume.TFhadoopSlave.*.id[count.index]}"
  use_chap        = "${var.use_chap}"
}

resource "null_resource" "TFhadoopSlave" {
  count = "${var.slave_count}"

  triggers = {
    TFhadoopSlave_ids = "${join(",",oci_core_instance.TFhadoopSlave.*.id)}"
  }

  provisioner "file" {
    connection = {
      host                = "${(oci_core_instance.TFhadoopSlave.*.private_ip[count.index])}"
      agent               = false
      timeout             = "10m"
      user                = "opc"
      private_key         = "${file("${var.ssh_private_key}")}"
      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    content     = "${data.template_file.setup_slave.rendered}"
    destination = "~/setup_slave.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${(oci_core_instance.TFhadoopSlave.*.private_ip[count.index])}"
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
