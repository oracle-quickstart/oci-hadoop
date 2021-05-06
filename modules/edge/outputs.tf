output "edge-url" { value = "http://${data.oci_core_vnic.edge_vnic.public_ip_address}" }
output "grafana-url" { value = "http://${data.oci_core_vnic.edge_vnic.public_ip_address}:3000" }
output "public-ip" { value = data.oci_core_vnic.edge_vnic.public_ip_address }
