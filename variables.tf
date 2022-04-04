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

variable "master_dynamic_ocpus" {
  default = "0"
}

variable "edge_dynamic_ocpus" {
  default = "0"
}
# ---------------------------------------------------------------------------------------------------------------------
# Hadoop variables
# You should modify these based on deployment requirements.
# These default to recommended minimum values in most cases
# ---------------------------------------------------------------------------------------------------------------------

variable "hadoop_version" { 
    default = "3.3.0" 
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
  default = "true"
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

// See https://docs.oracle.com/en-us/iaas/images/image/1cf73ff7-d8ac-49ec-85c6-6190fb32d169/
// Oracle-provided image "Oracle-Linux-8.5-2022.02.25-0"
// Kernel Version: 5.4.17-2136.304.4.1.el7uek.x86_64
// Release Date: Feb 24 2022
variable "OELImageOCID" {
  type = map
  default = {
    af-johannesburg-1 = "ocid1.image.oc1.af-johannesburg-1.aaaaaaaaoqnff25djsyaa6r7knzfzditt7j3reobxw7do6zb6bral2c3h7uq"
    ap-chuncheon-1 = "ocid1.image.oc1.ap-chuncheon-1.aaaaaaaayq6t7uhte35nob7wp35owrogfgcdnnbhvy6clag332sn7qvcmfwq"
    ap-hyderabad-1 = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaap6rdaqb6iumopf2myl3dacgdp23qhpfjm536we4qkhrm7buqu2jq"
    ap-melbourne-1 = "ocid1.image.oc1.ap-melbourne-1.aaaaaaaa2hegvmnfuuysurnuidtdobjcp445huwebslxvlijhoxvpiji4boa"
    ap-mumbai-1 = "ocid1.image.oc1.ap-mumbai-1.aaaaaaaaekyt2v46comr7vcfnasistr5lnvwilq2xkfi4brcvgy4smdk6via"
    ap-osaka-1 = "ocid1.image.oc1.ap-osaka-1.aaaaaaaaqokbytwa3kzztdqw6pmq3ih6ybptjj4ttym52edg7yqgajp7ut2q"
    ap-seoul-1 = "ocid1.image.oc1.ap-seoul-1.aaaaaaaaogh5s2mibx3m3euq6rs4vmljf7eeltuloqgrzlcrqfkc7zadbeyq"
    ap-singapore-1 = "ocid1.image.oc1.ap-singapore-1.aaaaaaaaljtcl6ocojto7qso37zd5opicez2k2vbsd7th3dprts4cbf5llsq"
    ap-sydney-1 = "ocid1.image.oc1.ap-sydney-1.aaaaaaaalfjoajuzimnlblwvmxmiowj34eqqhipesao7nd3d2e2ktond47ka"
    ap-tokyo-1 = "ocid1.image.oc1.ap-tokyo-1.aaaaaaaabv4pyn2rovf3fu47qfccubejjbs7r5fbx4pgiyvcokl6xmvttepa"
    ca-montreal-1 = "ocid1.image.oc1.ca-montreal-1.aaaaaaaa7o7mnzt3blgj4zqo6mnnq473uiidveclvkarlcws6frer4x3p2fq"
    ca-toronto-1 = "ocid1.image.oc1.ca-toronto-1.aaaaaaaabml54zsahs32vvlfn2x75rxxtabhgbr6omsn3zmt32fscb4bqhza"
    eu-amsterdam-1 = "ocid1.image.oc1.eu-amsterdam-1.aaaaaaaajru7svi5fneczeqs23632tazdtthlxwkvzelwzl43esuixofbabq"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa5ptzaqz6jwvl46f3ulfhcxmg7nklogfmmkibazu73zxztkf2d7qa"
    eu-marseille-1 = "ocid1.image.oc1.eu-marseille-1.aaaaaaaauak4chuewxexvjxo5xwvn7hh3w6v4oqeozi7mwzqs64qpnxvw63q"
    eu-milan-1 = "ocid1.image.oc1.eu-milan-1.aaaaaaaai6uhcknyngdlvfqhkhz4zhmjh3q6wehten27ijfbckrfwe2r4x6q"
    eu-stockholm-1 = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaaugnnipytarizhi6fiysc2s5tl3suynwixyq3c2c7b5feiysumbmq"
    eu-zurich-1 = "ocid1.image.oc1.eu-zurich-1.aaaaaaaan2lo2qcmedsi3ukmmfr3nkw3ow5huvw4mqnchbmo4cpisjjceata"
    il-jerusalem-1 = "ocid1.image.oc1.il-jerusalem-1.aaaaaaaaty5ljeq2lgajxwascel4pk4ymfz6dtf7irpt6zgcsp3x6anv3ula"
    me-abudhabi-1 = "ocid1.image.oc1.me-abudhabi-1.aaaaaaaavi3lcgnbzid6xnmo6ypy6mjglruakl3pyi6mwwjsffr7eobeidbq"
    me-dubai-1 = "ocid1.image.oc1.me-dubai-1.aaaaaaaafruc77id7cwynpxtzuunyoon5ichd7a2f2vpavy7llb4gh2wijgq"
    me-jeddah-1 = "ocid1.image.oc1.me-jeddah-1.aaaaaaaaokglrsbxhqtdl2neui2mcobankmydnrjvj734a4imtxxl4eykguq"
    sa-santiago-1 = "ocid1.image.oc1.sa-santiago-1.aaaaaaaatbokidaduj2m2ghsgsnulmbrrhimwswtq4m4azjr2c5dhwoywtfa"
    sa-saopaulo-1 = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaacmp22xm6sm6stjoukkjgqsmfxnx7jxhyxqgxztemw57udxs3geua"
    sa-vinhedo-1 = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaasqhn7upn4qyfnfv24zlg773bqeot5asj2mwfsj7z6wmla5ludffq"
    uk-cardiff-1 = "ocid1.image.oc1.uk-cardiff-1.aaaaaaaazp5bpncc4dycbm4eiaximsjray4a6bkfdy6zw7anvfpbowcrv7jq"
    uk-london-1 = "ocid1.image.oc1.uk-london-1.aaaaaaaaadjm5mskcp6zmpoxajqutyiictchscltnunfmheq65rkcqpb3yua"
    us-ashburn-1 = "ocid1.image.oc1.iad.aaaaaaaazcrj3jkhp6tglg65qn7gjgxqgq5z7k4lvjoiunqwskb24t6sf6nq"
    us-phoenix-1 = "ocid1.image.oc1.phx.aaaaaaaa3imx2f53jbfwtl6akamfxbl2kkke74jbrek2hk5xgjvcgrw6v6fa"
    us-sanjose-1 = "ocid1.image.oc1.us-sanjose-1.aaaaaaaav3gtaebdkdbmxgojoxcpg56tj6tydphlnm3ekb5kafs3yl5plyzq"
  }
}

