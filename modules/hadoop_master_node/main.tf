# Init Script Files
data "template_file" "setup_hadoop" {
  template = "${file("${path.module}/scripts/setup_master.sh")}"

  vars {
    hadoop_version     = "${var.hadoop_version}"
    hadoop_master_name = "${var.master_display_name}"
    nn_port            = "${var.nn_port}"
    rm_port            = "${var.rm_port}"
    jhs_port           = "${var.jhs_port}"
  }
}

## Hadoop MASTER INSTANCE
resource "oci_core_instance" "TFhadoopMaster" {
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_ocid}"
  shape               = "${var.shape}"
  display_name        = "${var.label_prefix}${var.master_display_name}"

  create_vnic_details {
    subnet_id      = "${var.subnet_id}"
    display_name   = "${var.label_prefix}${var.master_display_name}"
    hostname_label = "${var.master_display_name}"
  }

  metadata {
    ssh_authorized_keys = "${file("${var.ssh_authorized_keys}")}"
  }

  source_details {
    source_id   = "${var.image_id}"
    source_type = "image"
  }

  timeouts {
    create = "10m"
  }
}

resource "null_resource" "TFhadoopMaster" {
  triggers = {
    TFhadoopMaster_id = "${element(oci_core_instance.TFhadoopMaster.*.id, 0)}"
  }

  provisioner "file" {
    connection = {
      host        = "${element(oci_core_instance.TFhadoopMaster.*.private_ip, 0)}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    content     = "${data.template_file.setup_hadoop.rendered}"
    destination = "~/setup.sh"
  }

  provisioner "remote-exec" {
    connection = {
      host        = "${element(oci_core_instance.TFhadoopMaster.*.private_ip, 0)}"
      agent       = false
      timeout     = "5m"
      user        = "opc"
      private_key = "${file("${var.ssh_private_key}")}"

      bastion_host        = "${var.bastion_host}"
      bastion_user        = "${var.bastion_user}"
      bastion_private_key = "${file("${var.bastion_private_key}")}"
    }

    inline = [
      "sudo chmod +x ~/setup.sh",
      "sudo ~/setup.sh",
    ]
  }
}
