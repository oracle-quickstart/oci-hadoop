output "vcn-id" {
	value = var.useExistingVcn ? var.myVcn : oci_core_vcn.hadoop_vcn.0.id
}

output "private-id" {
	value = var.useExistingVcn ? var.privateSubnet : oci_core_subnet.private.0.id
}

output "public-id" {
        value = var.useExistingVcn ? var.publicSubnet : oci_core_subnet.public.0.id
}

output "blockvolume-id" {
	value = var.useExistingVcn ? var.blockvolumeSubnet : oci_core_subnet.blockvolume.0.id
}
