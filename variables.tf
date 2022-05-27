# ---------------------------------------------------------------------------------------------------------------------
# SSH Keys - Put this to top level because they are required
# ---------------------------------------------------------------------------------------------------------------------

variable "ssh_provided_key" {
  default = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Settings
# --------------------------------------------------------------------------------------------------------------------- 
variable "useExistingVcn" {
  default = "false"
}

variable "custom_cidrs" {
  default = "false"
}

variable "VCN_CIDR" {
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  default = "10.0.2.0/24"
}

variable "private_cidr" {
  default = "10.0.3.0/24"
}

variable "blockvolume_cidr" {
  default = "10.0.4.0/24"
}

variable "myVcn" {
  default = " "
}

variable "privateSubnet" {
  default = " "
}

variable "publicSubnet" {
  default = " "
}

variable "blockvolumeSubnet" {
  default = " "
}

variable "vcn_dns_label" { 
  default = "hadoopvcn"
}

variable "secondary_vnic_count" {
  default = "0"
}

variable "blockvolume_subnet_id" {
  default = " "
}

variable "worker_domain" {
  default = " "
}

# ---------------------------------------------------------------------------------------------------------------------
# ORM Schema variables
# You should modify these based on deployment requirements.
# These default to recommended values
# --------------------------------------------------------------------------------------------------------------------- 

variable "enable_block_volumes" {
  default = "true"
}

variable "provide_ssh_key" {
  default = "true"
}

variable "enable_secondary_vnic" {
  default = "false"
}

variable "dynamic_ocpus" {
  default = "0"
}

variable "memory_in_gbs" {
  default = "0"
}

variable "master_dynamic_ocpus" {
  default = "0"
}

variable "master_memory_in_gbs" {
  default = "0"
}

variable "edge_dynamic_ocpus" {
  default = "0"
}

variable "edge_memory_in_gbs" {
  default = "0"
}
# ---------------------------------------------------------------------------------------------------------------------
# Hadoop variables
# You should modify these based on deployment requirements.
# These default to recommended minimum values in most cases
# ---------------------------------------------------------------------------------------------------------------------

variable "hadoop_version" { 
    default = "3.3.3" 
}

variable "hadoop_par" {}

variable "zk_version" {
    default = "3.8.0"
}

variable "worker_instance_shape" {
  default = "VM.Standard2.8"
}

# This should not increment.
variable "worker_node_count" {
  default = "1"
}

# Increment module count to scale workers or suffer from btree delays during deployment
variable "worker_module_count" {
  default = "3"
}

variable "hdfs_blocksize_in_gbs" {
  default = "1000"
}

variable "block_volumes_per_worker" {
   default = "3"
}

variable "customize_block_volume_performance" {
   default = "false"
}

variable "block_volume_high_performance" {
   default = "false"
}

variable "block_volume_cost_savings" {
   default = "false"
}

variable "vpus_per_gb" {
   default = "10"
}

variable "edge_instance_shape" {
  default = "VM.Standard2.4"
}

variable "master_instance_shape" {
  default = "VM.Standard2.8"
}

variable "master_node_count" {
  default = "3"
}

# Size for NameNode and SecondaryNameNode data volume (Journal Data)

variable "nn_volume_size_in_gbs" {
  default = "500"
}

# Which AD to target - this can be adjusted.  Default 1 for single AD regions.
variable "availability_domain" {
  default = "1"
}

variable "cluster_name" {
  default = "TestCluster"
}

variable "UsePrefix" {
  default = "False"
}


# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/oracle/oci-quickstart-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "compartment_ocid" {}

# Required by the OCI Provider

variable "tenancy_ocid" {}
variable "region" {}

# ---------------------------------------------------------------------------------------------------------------------
# Constants
# You probably don't need to change these.
# ---------------------------------------------------------------------------------------------------------------------
// See https://docs.oracle.com/en-us/iaas/images/image/25bc6749-4c60-4f7e-9461-c28b26ac87e4/
// Oracle-provided image "Oracle-Linux-7.9-2022.04.26-0"
// Kernel Version: 5.4.17-2136.306.1.3.el7uek.x86_64
// Release Date: April 26 2022
variable "OELImageOCID" {
  type = map
  default = {
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaalca6pvvgdlngrznndjebcebwcr6amyz4mjjkdol64vpfxbx7rxwq"
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaaxyz3qaewli7lembyzrjhck6eiigrgvk2ryo6vwcgas5b7nqtf4ea"
    ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaa6ativ3xstoirvvfcroyktiljhs6duhe2jdwzm3s43qk5lc3zjsqa"
    ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaa7rhgxtzgp6ild6k6wxnrtkx5yf7xp3ax4m3coiexbqvohunwsklq"
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa4aei7nav7u7e6zavqcv2ilzlm5sljuxahtdop72m7tksp72w4jdq"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaafdazymy4bbmgd7to2mkboxvegmh22clelvazeydfvoybcrjadnmq"
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaghjqdrw2r6fndlh4l32gmwmhkts7crsstaddlib76lwjbd24f2uq"
    ap-singapore-1 = "ocid1.image.oc1.ap-singapore-1.aaaaaaaa6yqva3rg7f3zuk4semo2eckp4yzisqiqaapc4xqzoarcocvzm77q"
    ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaay6hyrlwzzkyont5hxtgbdjnyf5givevld54yb573wlsc76flxuha"
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaabqqrdukbryvji2acqqzy6v6kc4p2mwyj6iuppzog2jowmrk2ghdq"
    ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaayy3udj23qy6t4dmh2gavldacevdwswhfeosymyykjrtnak2fq2wa"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaayaeisnugnqxkjgpn7vh65vx77m6wuhrejbovyxubhic472bz7uia"
    eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaaqzww24j22cjvicdtewqosylgz43s4ke7p2e5r6xnbmianovqft4q"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaala4erxrt3hqrbqlrya2eca3arvp2aud24wz77e4pbgrxoovorbrq"
    eu-marseille-1 = "ocid1.image.oc1.eu-marseille-1.aaaaaaaah7fhow2vkziqa4pjjmhkyfdxclx25udwtvozyixsblmcrnoiocua"
    eu-milan-1 = "ocid1.image.oc1.eu-milan-1.aaaaaaaabgklpm4tiaxb66poc5gtrmgx6h2bn4zbelqqnxqvgbswcbqxptha"
    eu-stockholm-1 = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaaib3bnlybc7dyj26pjethyinx5pchhaxtggfl5ax25yj274nweqhq"
    eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaaiq3tbcrtzpix5quyfxincuuko4d35zrobyqltvfouvdf34eck6nq"
    il-jerusalem-1 = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaa6x52ehp4gupwxp4mn4iihwc56wgk63wiokelgzrmrqwg7n5jvgoq"
    me-abudhabi-1 = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaaeqo4evknraspjgpc3zyzni6z42334evmtgfxc5r2xc4ynp6gwxqa"
    me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaa4sohakkoar2scopa4xfthgr4h3kiy4cynuk6sijpfbueatqctrna"
    me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaan6krof27whunkocwk2aqjuspuhuxji5adelj4kh2hag6giv2lrla"
    sa-santiago-1 = "ocid1.image.oc1.sa-santiago-1.aaaaaaaaz5wn5v4yj6fsyoxcopqpdtribr2czgkgviqoecino7rqwz3vgisa"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaal74kbomz2rhi6y2sfajkuucpmqtyz3siysbqsd52iv7b6rx3khda"
    sa-vinhedo-1 = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaadn6ttlk6bcmvucuvrfjah2clojpsmy4ovxhohqbqj5whvpzz7gma"
    uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaag7ny555zssuumbkzeoj6jn6vb6owmtevld6sote7kkkozims35la"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaadwao26icgeoa7oqi7asokxkdllua6ypyyc2avm5yb2qovrup6zaa"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaaeffkobm7eba7aqcncosczcadqdacnfjbr7dzzpx3hqj5suiygoqa"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaaquhxkq4ooskqa7afrlp2ohjuwurlq5ncompqzaz62j3ln67s52lq"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaana3f2ru4eyqyvkkbur7xjatzctfu3vuddbxbzhhlfricbkdvaz5q"
  }
}

