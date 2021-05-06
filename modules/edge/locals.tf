locals {
  is_edge_flex_shape = var.edge_instance_shape == "VM.Standard.E3.Flex" ? [var.dynamic_ocpus] : []
}
