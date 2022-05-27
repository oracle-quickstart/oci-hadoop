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
// See https://docs.oracle.com/en-us/iaas/images/image/3318ef81-3970-4d69-92bc-e91392f87a13/
// Oracle-provided image "Oracle-Linux-7.9-2022.02.25-0"
// Kernel Version: 5.4.17-2136.304.4.1.el7uek.x86_64
// Release Date: Feb 24 2022
variable "OELImageOCID" {
  type = map
  default = {
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaaxvekzldxyzjpnxnuxdowlu6ho4un2sw2coxixrpq64djg7inpl2q"
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaa5aff7kdkhzs7gzmxh4wi52dbnae5zxnvgjffbtfumer2hmmc7moq"
    ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaaiu2nndms7shqu2jwd4z4va5y3x4y5yz5v6vlpkx73bugcisbafna"
    ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaacktqb2oerddzpslv6wcmbtrhsce5qrv4ki7jmejkwvydm3uwxvoa"
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaa7zcgmsnxysoeazvs77zzc55oxcudauugxlw2kuwoy5tol2q2vdlq"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaae4osl2jgcuo6jgutwphvc2iz2sccsnlmlcptg52z6senzizfms6a"
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaabzfzbjvrnniwe3potr5gzfdr3pd6od67qpthxkadog4clopnnapa"
    ap-singapore-1 = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaljcu5ewefzyknhwa5hdl2lwwv6i4zj6vzplbk5dfpnahajpel6ca"
    ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaa7xnavkdqu5icyudbkdz3numakse5i5azmawfalcbafkaygtsvkxq"
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaa74yhcgjr6lsaafb4bu73mhgtgu2sd3fmpqzps6tusf4ks3nsn24q"
    ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaaeiblhv3x5pgwmpbnp24lvnroeqd5wlpbuwxlxk3kvma5zhpwahaa"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaadhxm5f6xnahswbfcnsvfsxesf7fyfmyyba3blmynb2rw2dq54phq"
    eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaauor5p52vuv75irlqwqkbkymfi6tp6tf57h44ycc6q7p26ajujyya"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaajyizdzdpwwdqawcn6kq5fz6auhy7q7awzheqffmn535pchugemiq"
    eu-marseille-1 = "ocid1.image.oc1.eu-marseille-1.aaaaaaaaczknazt2whvgfk5pjbzjn6xkqpcri3iq6ijx4eaoywlwni6o75nq"
    eu-milan-1 = "ocid1.image.oc1.eu-milan-1.aaaaaaaa45gdkcbcspanf6dbisxdhxhzuzb5lcuqjzksrsyql4ihg7acl5ca"
    eu-stockholm-1 = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaar2rdbeecipspxatocaj5rrax44vr5iomwegsfoh7deuimz54gfgq"
    eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaa5jbwndc4koldqavzujvpm4ha3fpvgxzfkdmtj5cuvxchkraaa3sa"
    il-jerusalem-1 = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaa5l5aqivauoilbojyuzvlq7hd3xrl55oudmpvdxavwbtimd227ueq"
    me-abudhabi-1 = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaal7uxo3opvtdbfelckq25t35thxuyrrgbihb7isjci5avltlhdapa"
    me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaah4ed3bknejs6xlxcw7kd3jcvrhvpw5wgoyghmjaconlrb35xua4a"
    me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaw7dltirqsj7dg5ka3eibidydva32mollrrxdmej4rclhxsiwllfq"
    sa-santiago-1 = "ocid1.image.oc1.sa-santiago-1.aaaaaaaam4gcsxtox4kn5k54ypbj5qrnnekqk66hpl3q6tgwffwkrki3gtrq"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaap4vqnlbv42uqk3u64e4tgurbf25i26kv5ab5b22vj5i4r6w7ld6a"
    sa-vinhedo-1 = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaartdav3gsynhx5zplkuea4kaszczgsfufveieqbgc47rcu2gdqigq"
    uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaakxw4vzawetby4acmecjhr44x53jwepqyxyne7ubfdgtf44dag37q"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaaqegyqal6efvnaysz47bdz7x3i4teub5y7mt3balcysydnqiak5aa"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaapfdqrbk6n4txcqv5h5da3d5wyfi4h7jweomf4y5wb3tw2mfmn4dq"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaawkx4fuf5yd4wz7mqvd2wkyzy4dgity63xn7tnpn4bxkcjt3inaaa"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaay7ab6mxghu7suiy3jl6q2xrcscnh7wp2hojaxn23ddkisqoydg5a"
  }
}

