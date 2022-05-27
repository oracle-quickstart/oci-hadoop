data "oci_core_vcn" "vcn_info" {
  vcn_id = var.useExistingVcn ? var.myVcn : module.network.vcn-id 
}

data "oci_core_subnet" "private_subnet" {
  subnet_id = var.useExistingVcn ? var.privateSubnet : module.network.private-id
}

data "oci_core_subnet" "public_subnet" {
  subnet_id = var.useExistingVcn ? var.publicSubnet : module.network.public-id 
}

data "null_data_source" "values" {
  inputs = {
    worker_domain = "${data.oci_core_subnet.private_subnet.dns_label}.${data.oci_core_vcn.vcn_info.vcn_domain_name}"
  }
}

data "null_data_source" "vpus" {
  inputs = {
    block_vpus = var.block_volume_high_performance ? 20 : 0
  }
}

module "edge" {
        source  = "./modules/edge"
        instances = "1"
	worker_count = var.worker_module_count
	region = var.region
	compartment_ocid = var.compartment_ocid
        subnet_id =  var.useExistingVcn ? var.publicSubnet : module.network.public-id
	availability_domain = var.availability_domain
	image_ocid = var.OELImageOCID[var.region]
        ssh_public_key = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.key.public_key_openssh
	edge_instance_shape = var.edge_instance_shape
        user_data = base64gzip(file("scripts/edge_boot.sh"))
	worker_shape = var.worker_instance_shape
	cluster_name = var.cluster_name
	UsePrefix = var.UsePrefix
	private_subnet = data.oci_core_subnet.private_subnet.dns_label
	public_subnet = data.oci_core_subnet.public_subnet.dns_label
	worker_block_volume_count = var.enable_block_volumes ? var.block_volumes_per_worker : 0
	worker_domain = data.null_data_source.values.outputs["worker_domain"]
        hadoop_version = var.hadoop_version
	hadoop_par = var.hadoop_par
	is_flex_shape = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Optimized3.Flex", "VM.Standard3.Flex"], var.edge_instance_shape)
	dynamic_ocpus = var.edge_dynamic_ocpus
        memory_in_gbs = var.edge_memory_in_gbs
}

module "master" {
        source  = "./modules/master"
        instances = var.master_node_count
	worker_count = var.worker_module_count
	region = var.region
	compartment_ocid = var.compartment_ocid
        subnet_id =  var.useExistingVcn ? var.privateSubnet : module.network.private-id
	availability_domain = var.availability_domain
        image_ocid = var.OELImageOCID[var.region]
        ssh_public_key = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.key.public_key_openssh
	master_instance_shape = var.master_instance_shape
        user_data = base64gzip(file("scripts/master_boot.sh"))
	hadoop_version = var.hadoop_version
	hadoop_par = var.hadoop_par
	zk_version = var.zk_version
	cluster_name = var.cluster_name
	UsePrefix = var.UsePrefix
	worker_shape = var.worker_instance_shape
	worker_ocpus = var.dynamic_ocpus
        worker_memory = var.memory_in_gbs
	worker_block_volume_count = var.enable_block_volumes ? var.block_volumes_per_worker : 0
	worker_domain = data.null_data_source.values.outputs["worker_domain"]
	is_flex_shape = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Optimized3.Flex", "VM.Standard3.Flex"], var.master_instance_shape)
	dynamic_ocpus = var.master_dynamic_ocpus
        memory_in_gbs = var.master_memory_in_gbs
}

module "worker" {
        source  = "./modules/worker"
        count = var.worker_module_count
	worker_module_count = count.index
	worker_count = var.worker_module_count
        instances = var.worker_node_count
	region = var.region
	compartment_ocid = var.compartment_ocid
        subnet_id =  var.useExistingVcn ? var.privateSubnet : module.network.private-id
	blockvolume_subnet_id = var.useExistingVcn ? var.blockvolumeSubnet : module.network.blockvolume-id
	availability_domain = var.availability_domain
	image_ocid = var.OELImageOCID[var.region]
	worker_instance_shape = var.worker_instance_shape
        ssh_public_key = var.provide_ssh_key ? var.ssh_provided_key : tls_private_key.key.public_key_openssh
	hdfs_blocksize_in_gbs = var.hdfs_blocksize_in_gbs
        user_data = base64gzip(file("scripts/boot.sh"))
	block_volume_count = var.enable_block_volumes ? var.block_volumes_per_worker : 0
	vpus_per_gb = var.customize_block_volume_performance ? data.null_data_source.vpus.outputs["block_vpus"] : 10 
        enable_secondary_vnic = var.enable_secondary_vnic
        secondary_vnic_count = var.enable_secondary_vnic ? 1 : 0
	worker_domain = data.null_data_source.values.outputs["worker_domain"]
	cluster_name = var.cluster_name
	UsePrefix = var.UsePrefix
	hadoop_version = var.hadoop_version
	hadoop_par = var.hadoop_par
	is_flex_shape = contains(["VM.Standard.E3.Flex", "VM.Standard.E4.Flex", "VM.Optimized3.Flex", "VM.Standard3.Flex"], var.worker_instance_shape)
	dynamic_ocpus = var.dynamic_ocpus
        memory_in_gbs = var.memory_in_gbs
}
