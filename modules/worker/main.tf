resource "oci_core_instance" "Worker" {
  count               = var.instances
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  shape               = var.worker_instance_shape
  display_name        = var.UsePrefix ? "${var.cluster_name}-Worker ${format("%01d", var.worker_module_count+1)}" : "WWorker ${format("%01d", var.worker_module_count+1)}"

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
  }

  create_vnic_details {
    subnet_id          = var.enable_secondary_vnic ? var.blockvolume_subnet_id : var.subnet_id
    display_name        = "Worker ${format("%01d", var.worker_module_count+1)}"
    hostname_label      = "${var.enable_secondary_vnic ? local.primary_label_prefix : local.secondary_label_prefix}${format("%01d", var.worker_module_count+1)}"
    assign_public_ip  = false 
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data		= var.user_data
    agent_hostname      = "worker-${var.worker_module_count+1}.${var.worker_domain}"
  }

  extended_metadata = {
    worker_block_volume_count = var.block_volume_count
    enable_secondary_vnic = var.enable_secondary_vnic
    cluster_name        = var.cluster_name
    UsePrefix        = var.UsePrefix
    hadoop_version      = var.hadoop_version
    hadoop_par          = var.hadoop_par
    install_hive        = var.install_hive
    hive_version        = var.hive_version
    hive_par            = var.hive_par
    worker_count        = var.worker_count
    worker_ocpus        = var.dynamic_ocpus
    worker_memory       = var.memory_in_gbs
  }

  dynamic "shape_config" {
    for_each = local.is_worker_flex_shape
      content {
	baseline_ocpu_utilization="BASELINE_1_1"
        ocpus = shape_config.value.ocpus
        memory_in_gbs = shape_config.value.memory_in_gbs
      }
  }

  timeouts {
    create = "30m"
  }
}

data "oci_core_vnic" "secondary_vnic" {
  count = var.secondary_vnic_count * var.instances
  vnic_id = element(oci_core_vnic_attachment.secondary_vnic_attachment.*.vnic_id, count.index)
}

resource "oci_core_vnic_attachment" "secondary_vnic_attachment" {
  count = var.secondary_vnic_count * var.instances
  instance_id  = oci_core_instance.Worker[floor(count.index/var.secondary_vnic_count)].id
  display_name = "SecondaryVnicAttachment_${count.index}"

  create_vnic_details {
    subnet_id              = var.subnet_id
    display_name           = "SecondaryVnic_${count.index}"
    assign_public_ip       = false
    hostname_label      = "Worker-${format("%01d", count.index+1)}"
  }
  nic_index     = "1"
}

// Block Volume Creation for Worker 

# Data Volumes for HDFS
resource "oci_core_volume" "WorkerDataVolume" {
  count               = (var.instances * var.block_volume_count)
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_ocid
  display_name        = "Worker ${format("%01d", var.worker_module_count+1)} Data ${format("%01d", floor((count.index%(var.block_volume_count))+1))}"
  size_in_gbs         = var.hdfs_blocksize_in_gbs
  vpus_per_gb         = var.vpus_per_gb
}

resource "oci_core_volume_attachment" "WorkerDataAttachment" {
  count               = (var.instances * var.block_volume_count)
  attachment_type = "iscsi"
  instance_id     = oci_core_instance.Worker[floor(count.index/var.block_volume_count)].id
  volume_id       = oci_core_volume.WorkerDataVolume[count.index].id
  device          = var.data_volume_attachment_device[count.index%(var.block_volume_count)]
}

