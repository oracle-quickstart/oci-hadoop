#!/bin/bash
LOG_FILE="/var/log/OCI-Hadoop.log"
log() { 
	echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}" 
}
function waitforMaster() {
        timeout 600  \
        bash -c "while ! echo exit | nc -z -w5  ${master1fqdn} 8020
        do
        echo 'Waiting for ${master1fqdn}:8020 RPC NameNode service'
        sleep 10
   done"
}
function yum_install() {
package=$1
success=1
while [ $success != 0 ]; do
  yum install $package -y >> $LOG_FILE
  success=$?
done;
}
hadoop_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hadoop_version`
hadoop_par=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hadoop_par`
install_hive=`curl -L http://169.254.169.254/opc/v1/instance/metadata/install_hive`
hive_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hive_version`
hive_par=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hive_par`
zk_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/zk_version`
cluster_name=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cluster_name`
agent_hostname=`curl -L http://169.254.169.254/opc/v1/instance/metadata/agent_hostname`
fqdn_fields=`echo -e ${agent_hostname} | gawk -F '.' '{print NF}'`
cluster_domain=`echo -e ${agent_hostname} | cut -d '.' -f 2-${fqdn_fields}`
kerberos_domain=`echo -e ${cluster_domain} | cut -d '.' -f 2-$((fqdn_fields-1))`
worker_block_count=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_block_volume_count`
if [ -z ${worker_block_count}] ; then
        worker_block_count=0
fi
# Expect 1 volume for NameNode data
block_volume_count=1
enable_secondary_vnic=`curl -L http://169.254.169.254/opc/v1/instance/metadata/enable_secondary_vnic`
worker_shape=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_shape`
worker_count=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_count`
worker_ocpus=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/worker_ocpus`
worker_memory=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/worker_memory`
worker_memory=$((worker_memory*1024))
# This needs to be customized if hostnames are modified from default in Terraform
master1fqdn="master-1.${cluster_domain}"
master2fqdn="master-2.${cluster_domain}"
master3fqdn="master-3.${cluster_domain}"
#
hostfqdn=`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/agent_hostname`
if [ $enable_secondary_vnic = "true" ]; then
        EXECNAME="SECONDARY VNIC"
	host_shape=` curl -L http://169.254.169.254/opc/v1/instance/shape`
	case ${host_shape} in 
		BM.HPC2.36)
		log "-> Skipping setup, RDMA setup not implemented"
		;;

		*) 
	        log "->Download setup script"
	        wget https://docs.cloud.oracle.com/en-us/iaas/Content/Resources/Assets/secondary_vnic_all_configure.sh
	        mkdir -p /opt/oci/
		mv secondary_vnic_all_configure.sh /opt/oci/
		chmod +x /opt/oci/secondary_vnic_all_configure.sh
	        log "->Configure"
	        /opt/oci/secondary_vnic_all_configure.sh -c >> $LOG_FILE
	        log "->rc.local enable"
	        echo "/opt/oci/secondary_vnic_all_configure.sh -c" >> /etc/rc.local
		;;
	esac
fi
EXECNAME="TUNING"
log "->TUNING START"
sed -i.bak 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
setenforce 0
EXECNAME="JAVA"
log "->INSTALL"
yum_install java-1.8.0-openjdk.x86_64
log "->Set global TTL"
javaver=`ssh -i .ssh/id_rsa cdh-utility1 'alternatives --list | grep ^java'`
javapath=`echo ${javaver} | gawk '{print $3}'| cut -d '/' -f 1-6`
sed -i 's/#networkaddress.cache.ttl=-1/networkaddress.cache.ttl=60/g' ${javapath}/lib/security/java.security
EXECNAME="NSCD, NC"
log "->INSTALL"
yum_install nscd 
yum_install nc 
systemctl start nscd.service
EXECNAME="KERBEROS"
log "->INSTALL"
yum_install krb5-workstation
log "->krb5.conf"
kdc_fqdn=${ambari}
realm="hadoop.com"
REALM="HADOOP.COM"
log "-> CONFIG"
rm -f /etc/krb5.conf
cat > /etc/krb5.conf << EOF
# Configuration snippets may be placed in this directory as well
includedir /etc/krb5.conf.d/

[libdefaults]
 default_realm = ${REALM}
 dns_lookup_realm = false
 dns_lookup_kdc = false
 rdns = false
 ticket_lifetime = 24h
 renew_lifetime = 7d  
 forwardable = true
 udp_preference_limit = 1000000
 default_tkt_enctypes = rc4-hmac 
 default_tgs_enctypes = rc4-hmac
 permitted_enctypes = rc4-hmac

[realms]
    ${REALM} = {
        kdc = ${kdc_fqdn}:88
        admin_server = ${kdc_fqdn}:749
        default_domain = ${realm}
    }

[domain_realm]
    .${realm} = ${REALM}
     ${realm} = ${REALM}
    .public.${kerberos_domain} = ${REALM}
    .private.${kerberos_domain} = ${REALM}

[kdc]
    profile = /var/kerberos/krb5kdc/kdc.conf

[logging]
    kdc = FILE:/var/log/krb5kdc.log
    admin_server = FILE:/var/log/kadmin.log
    default = FILE:/var/log/krb5lib.log
EOF
EXECNAME="TUNING"
log "->OS"
echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled
echo "echo never | tee -a /sys/kernel/mm/transparent_hugepage/enabled" | tee -a /etc/rc.local
echo vm.swappiness=1 | tee -a /etc/sysctl.conf
echo 1 | tee /proc/sys/vm/swappiness
echo net.ipv4.tcp_timestamps=0 >> /etc/sysctl.conf
echo net.ipv4.tcp_sack=1 >> /etc/sysctl.conf
echo net.core.rmem_max=4194304 >> /etc/sysctl.conf
echo net.core.wmem_max=4194304 >> /etc/sysctl.conf
echo net.core.rmem_default=4194304 >> /etc/sysctl.conf
echo net.core.wmem_default=4194304 >> /etc/sysctl.conf
echo net.core.optmem_max=4194304 >> /etc/sysctl.conf
echo net.ipv4.tcp_rmem="4096 87380 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_wmem="4096 65536 4194304" >> /etc/sysctl.conf
echo net.ipv4.tcp_low_latency=1 >> /etc/sysctl.conf
sed -i "s/defaults        1 1/defaults,noatime        0 0/" /etc/fstab
echo "hdfs  -       nofile  32768
hdfs  -       nproc   2048
hbase -       nofile  32768
hbase -       nproc   2048" >> /etc/security/limits.conf
ulimit -n 262144
log "->FirewallD"
systemctl stop firewalld
systemctl disable firewalld
#
# Disk Setup Functions
#
vol_match() {
case $i in
        1) disk="oraclevdb";;
        2) disk="oraclevdc";;
        3) disk="oraclevdd";;
        4) disk="oraclevde";;
        5) disk="oraclevdf";;
        6) disk="oraclevdg";;
        7) disk="oraclevdh";;
        8) disk="oraclevdi";;
        9) disk="oraclevdj";;
        10) disk="oraclevdk";;
        11) disk="oraclevdl";;
        12) disk="oraclevdm";;
        13) disk="oraclevdn";;
        14) disk="oraclevdo";;
        15) disk="oraclevdp";;
        16) disk="oraclevdq";;
        17) disk="oraclevdr";;
        18) disk="oraclevds";;
        19) disk="oraclevdt";;
        20) disk="oraclevdu";;
        21) disk="oraclevdv";;
        22) disk="oraclevdw";;
        23) disk="oraclevdx";;
        24) disk="oraclevdy";;
        25) disk="oraclevdz";;
        26) disk="oraclevdab";;
        27) disk="oraclevdac";;
        28) disk="oraclevdad";;
        29) disk="oraclevdae";;
        30) disk="oraclevdaf";;
        31) disk="oraclevdag";;
esac
}
iscsi_detection() {
	iscsiadm -m discoverydb -D -t sendtargets -p 169.254.2.$i:3260 2>&1 2>/dev/null
	iscsi_chk=`echo -e $?`
	if [ $iscsi_chk = "0" ]; then
		iqn[${i}]=`iscsiadm -m discoverydb -D -t sendtargets -p 169.254.2.${i}:3260 | gawk '{print $2}'`
		log "-> Discovered volume $((i-1)) - IQN: ${iqn[${i}]}"
		continue
	else
		volume_count="${#iqn[@]}"
		log "--> Discovery Complete - ${#iqn[@]} volumes found"
	fi
}
iscsi_setup() {
        log "-> ISCSI Volume Setup - Volume ${i} : IQN ${iqn[$n]}"
        iscsiadm -m node -o new -T ${iqn[$n]} -p 169.254.2.${n}:3260
        log "--> Volume ${iqn[$n]} added"
        iscsiadm -m node -o update -T ${iqn[$n]} -n node.startup -v automatic
        log "--> Volume ${iqn[$n]} startup set"
        iscsiadm -m node -T ${iqn[$n]} -p 169.254.2.${n}:3260 -l
        log "--> Volume ${iqn[$n]} done"
}
EXECNAME="DISK DETECTION"
log "->Begin Block Volume Detection Loop"
detection_flag="0"
while [ "$detection_flag" = "0" ]; do
        log "-- Detecting Block Volumes --"
        for i in `seq 2 33`; do
                if [ -z $volume_count ]; then
			iscsi_detection
		fi
        done;
	log "-- $block_volume_count block volumes expected $volume_count volumes found --"
        if [ "$volume_count" != "$block_volume_count" ]; then
                log "-- Sanity Check Failed - $volume_count Volumes found, $block_volume_count expected.  Re-running --"
		unset volume_count
		unset iqn
                sleep 15
                continue
	else
                log "-- Setup for ${#iqn[@]} Block Volumes --"
                for i in `seq 1 ${#iqn[@]}`; do
                        n=$((i+1))
                        iscsi_setup
                done;
                detection_flag="1"
        fi
done;

EXECNAME="DISK PROVISIONING"
data_mount () {
  log "-->Mounting /dev/$disk to /data$dcount"
  mkdir -p /data$dcount
  mount -o noatime -t xfs /dev/$disk /data$dcount
  UUID=`blkid /dev/$disk | cut -d '"' -f2`
  echo "UUID=$UUID   /data$dcount    xfs   defaults,noatime,discard,barrier=0 0 1" | tee -a /etc/fstab
}

block_data_mount () {
  log "-->Mounting /dev/oracleoci/$disk to /data$dcount"
  mkdir -p /data$dcount
  mount -o noatime -t xfs /dev/oracleoci/$disk /data$dcount
  UUID=`blkid /dev/oracleoci/$disk | cut -d '"' -f 2`
  if [ ! -z $UUID ]; then 
  	echo "UUID=$UUID   /data$dcount    xfs   defaults,_netdev,nofail,noatime,discard,barrier=0 0 2" | tee -a /etc/fstab
  fi
}
EXECNAME="DISK SETUP"
log "->Checking for disks..."
dcount=0
for disk in `ls /dev/ | grep nvme | grep n1`; do
        log "-->Processing /dev/$disk"
	mkfs.xfs /dev/${disk}
        data_mount
        dcount=$((dcount+1))
done;
if [ ${#iqn[@]} -gt 0 ]; then
for i in `seq 1 ${#iqn[@]}`; do
        n=$((i+1))
        dsetup="0"
        while [ $dsetup = "0" ]; do
		vol_match
                log "-->Checking /dev/oracleoci/$disk"
                if [ -h /dev/oracleoci/$disk ]; then
			mkfs.xfs /dev/oracleoci/$disk
			block_data_mount
                        /sbin/tune2fs -i0 -c0 /dev/oracleoci/$disk
			unset UUID
                        dsetup="1"
                else
                        log "--->${disk} not found, running ISCSI again."
                        log "-- Re-Running Detection & Setup Block Volumes --"
			unset volume_count
			log "-- Detecting Block Volumes --"
			for i in `seq 2 33`; do
		                if [ -z $volume_count ]; then
                		        iscsi_detection
		                fi
		        done;
			for j in `seq 1 ${#iqn[@]}`; do
				n=$((j+1))
	                        iscsi_setup
			done
                fi
        done;
done;
fi
EXECNAME="HADOOP"
log "-->Download Hadoop ${hadoop_version}"
#
# Hadoop Setup 
#
if [ ${hadoop_version} = "custom" ]; then
        wget --no-check-certificate ${hadoop_par} -O hadoop-custom.tar.gz
        tar -zxvf hadoop-custom.tar.gz -C /usr/local/
        hadoop_version=`ls /usr/local/ | grep hadoop | cut -d '-' -f 2`
else
        wget --no-check-certificate https://www.apache.org/dist/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz
        tar -xf hadoop-${hadoop_version}.tar.gz -C /usr/local/
fi
log "--> Download OCI HDFS Object Storage connector"
wget --no-check-certificate https://github.com/oracle/oci-hdfs-connector/releases/download/v3.3.1.0.3.4/oci-hdfs.zip -O /usr/local/hadoop-${hadoop_version}/share/hadoop/common/
unzip /usr/local/hadoop-${hadoop_version}/share/hadoop/common/oci-hdfs.zip
log "--> Setting ownership for /usr/local/hadoop-${hadoop_version}"
chown -R opc:opc /usr/local/hadoop-${hadoop_version}
chmod -R 755 /usr/local/hadoop-${hadoop_version}
log "-->Cleanup"
rm -f oci-hdfs.zip
rm -f hadoop-${hadoop_version}.tar.gz
rm -f hadoop-custom.tar.gz

if [ ${install_hive} = "true" ]; then
        log "-->HIVE setup"
        if [ ${hive_version} = "custom" ]; then
                wget --no-check-certificate ${hive_par} -O hive-custom.tar.gz
                tar -zxf hive-custom.tar.gz -C /usr/local/
                hive_version=`ls /usr/local/ | grep hive | cut -d '-' -f 3`
        else
                wget --no-check-certificate https://dlcdn.apache.org/hive/hive-${hive_version}/apache-hive-${hive_version}-bin.tar.gz
                tar -xf apache-hive-${hive_version}-bin.tar.gz -C /usr/local/
        fi
        chown -R opc:opc /usr/local/apache-hive-${hive_version}-bin
        chmod -R 755 /usr/local/apache-hive-${hive_version}-bin
        log "-->Cleanup"
        rm -f apache-hive-${hive_version}-bin.tar.gz
        rm -f hive-custom.tar.gz
fi

#Setup user-env
echo " 
export JAVA_HOME=\$(readlink -f /usr/bin/java | sed "s:bin/java::")  
export HADOOP_INSTALL=/usr/local/hadoop-${hadoop_version} 
export PATH=\$PATH:\$HADOOP_INSTALL/bin 
export PATH=\$PATH:\$HADOOP_INSTALL/sbin 
export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL 
export HADOOP_COMMON_HOME=\$HADOOP_INSTALL 
export HADOOP_HDFS_HOME=\$HADOOP_INSTALL 
export YARN_HOME=\$HADOOP_INSTALL
" >>/root/.bashrc
#Setup hadoop-env
echo "
export JAVA_HOME=\$(readlink -f /usr/bin/java | sed "s:bin/java::")
export HADOOP_HOME=/usr/local/hadoop-${hadoop_version}
export HADOOP_CONF_DIR=/usr/local/hadoop-${hadoop_version}/etc/hadoop
export HADOOP_LOG_DIR=\$HADOOP_HOME/logs
export HADOOP_CLASSPATH=\$HADOOP_CLASSPATH:/usr/local/hadoop-${hadoop_version}/etc/hadoop
" >>/usr/local/hadoop-${hadoop_version}/etc/hadoop/hadoop-env.sh
# Build Tuning Params
worker_shape_length=`echo ${worker_shape} | gawk -F '.' '{print NF}'`
case ${worker_shape_length} in
        3)
        ocpu=`echo ${worker_shape} | cut -d '.' -f 3`
        if [ ${worker_shape} = "BM.HPC2.36" ]; then
                RAM=786432
        else
                gen_type=`echo $worker_shape | cut -d '.' -f2`
                case $gen_type in
                        Standard1|DenseIO1)
                        RAM=$((7168*ocpu))
                        ;;

                        Standard2|DenseIO2)
                        RAM=$((15360*ocpu))
                        ;;

                        Standard3)
                        ocpu=${worker_ocpus}
                        RAM=${worker_memory}
                        ;;

                        esac
        fi
        ;;

        4)
        third_field=`echo ${worker_shape} | cut -d '.' -f 3`
        case ${third_field} in
                B1)
                ocpu=`echo ${worker_shape} | cut -d '.' -f 4`
                RAM=$((12288*ocpu))
                ;;
                E2)
                ocpu=`echo ${worker_shape} | cut -d '.' -f 4`
                RAM=$((8192*ocpu))
                ;;

                E3|E4)
                ocpu=${worker_ocpus}
                RAM=${worker_memory}
                ;;

                *)
                ## Safety Catch-all
                ocpu=1
                RAM=8192
                ;;
	esac
	;;

        5)
        # E2.Micro host
        ocpu=1
        RAM=1024
        ;;

        *)
        ## Safety Catch-all
        ocpu=1
        RAM=8192
        ;;
esac
# Set system overhead here, defaulting to 90%
yarn_nodemanager_resource_memory_mb=$(((RAM/10)*9))
# Allowing full memory use for single application - adjust if needed 
yarn_scheduler_maximum_allocation__mb=${yarn_nodemanager_resource_memory_mb}
# Build HDFS Disk Count
log "->Building HDFS disk count for Worker ${worker_shape} with ${worker_block_count} block volumes."
case ${worker_shape} in 
	BM.DenseIO2.52|BM.DenseIO.E4.128)
	nvme_disks=8
	;;
	VM.DenseIO2.24)
	nvme_disks=4
	;;
        VM.DenseIO2.16)
	nvme_disks=2
	;;
	VM.DenseIO2.8|BM.HPC2.36)
	nvme_disks=1
	;;
	*)
	nvme_disks=0
	;;
esac
hdfs_disks=$((nvme_disks+worker_block_count))
# Turn on Data Tiering for Heterogenous Storage
if [ ${nvme_disks} -gt 0 ]; then 
	if [ ${worker_block_count} -gt 0 ]; then 
		log "->Heterogenous Storage detected - Enabling data tiering"
		data_tiering="true"
	fi
else
	log "->Homogenous Storage detected - Disabling data tiering"
	data_tiering="false"
fi
log "->Building Hadoop Configuration - core-site.xml"
#Configure core-site.xml
echo "<configuration>
   <property>
      <name>fs.defaultFS</name>
      <value>hdfs://${master1fqdn}:8020</value>
    </property>
   <property>
      <name>ha.zookeeper.quorum</name>
      <value>${master1fqdn}:2181,${master2fqdn}:2181,${master3fqdn}:2181</value>
    </property>
   <property>
      <name>hadoop.tmp.dir</name>
      <value>/data0</value>
   </property>
   <property>
      <name>fs.oci.client.jersey.logging.enabled</name>
      <value>true</value>
   </property>
   <property>
      <name>fs.oci.client.jersey.logging.level</name>
      <value>WARNING</value>
   </property>
   <property>
      <name>fs.oci.client.jersey.logging.verbosity</name>
      <value>HEADERS_ONLY</value>
   </property>
</configuration>" >/usr/local/hadoop-${hadoop_version}/etc/hadoop/core-site.xml
log "->Building Hadoop Configuration - hdfs-site.xml"
#Configure hdfs-site.xml
echo "<configuration>
   <property>
      <name>dfs.namenode.name.dir</name>
      <value>/data0/nn</value>
   </property>
   <property>
      <name>dfs.replication</name>
      <value>3</value>
   </property>
   <property>
      <name>dfs.permissions</name>
      <value>false</value>
   </property>
   <property>
      <name>dfs.namenode.handler.count</name>
      <value>100</value>
   </property>
   <property>
      <name>dfs.blocksize</name>
      <value>268435456</value>
   </property>" >/usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
if [ ${data_tiering} = "true" ]; then 
	for d in `seq 1 ${hdfs_disks}`; do 
	if [ ${d} -le ${nvme_disks} ]; then 
echo "   <property>
      <name>dfs.datanode.data.dir</name>
      <value>[DISK]/data$((d-1))/</value>
   </property>" >> /usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
	else
echo "   <property>
      <name>dfs.datanode.data.dir</name>
      <value>[ARCHIVE]/data$((d-1))/</value>
   </property>" >> /usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
	fi
	done;
else
	for d in `seq 1 ${hdfs_disks}`; do 
echo "   <property>
      <name>dfs.datanode.data.dir</name>
      <value>/data$((d-1))/</value>
   </property>" >> /usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
	done;
fi
echo "</configuration>" >> /usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
log "->Building Hadoop Configuration - mapred-site.xml"
#Configure mapred-site.xml
echo "
<configuration>
   <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
   </property>
   <property>
      <name>mapreduce.jobhistory.address</name>
      <value>${master2fqdn}:10020</value>
   </property>
    <property>
      <name>yarn.app.mapreduce.am.job.client.port-range</name>
      <value>60000-60050</value>
   </property>
   <property>
      <name>yarn.app.mapreduce.am.resource.mb</name>
      <value>4096</value>
   </property>
   <property>
      <name>mapreduce.application.classpath</name>
      <value>/usr/local/hadoop-${hadoop_version}/etc/hadoop:/usr/local/hadoop-${hadoop_version}/share/hadoop/common/lib/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/common/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/hdfs:/usr/local/hadoop-${hadoop_version}/share/hadoop/hdfs/lib/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/hdfs/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/mapreduce/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/yarn:/usr/local/hadoop-${hadoop_version}/share/hadoop/yarn/lib/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/yarn/*</value>
   </property>
   <property>
      <name>yarn.app.mapreduce.am.env</name>
      <value>HADOOP_MAPRED_HOME=\$HADOOP_HOME</value>
   </property>
   <property>
      <name>mapreduce.map.env</name>
      <value>HADOOP_MAPRED_HOME=\$HADOOP_HOME</value>
   </property>
   <property>
      <name>mapreduce.reduce.env</name>
      <value>HADOOP_MAPRED_HOME=\$HADOOP_HOME</value>
   </property>
</configuration>" > /usr/local/hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml
log "->Building Hadoop Configuration - yarn-site.xml"
#Configure yarn-site.xml
echo "<configuration>
   <property>
      <name>yarn.resourcemanager.hostname</name>
      <value>${master2fqdn}</value>
   </property>
   <property>
      <name>yarn.nodemanager.aux-services</name>
      <value>mapreduce_shuffle</value>
   </property>
   <property>
      <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
      <value>org.apache.hadoop.mapred.ShuffleHandler</value>
   </property>
   <property>
      <name>yarn.resourcemanager.address</name>
      <value>http://${master2fqdn}:8032</value>
   </property>
   <property>
      <name>yarn.resourcemanager.resource-tracker.address</name>
      <value>${master2fqdn}:8031</value>
   </property>
   <property>
      <name>yarn.resourcemanager.scheduler.address</name>
      <value>${master2fqdn}:8030</value>
   </property>
   <property>
      <name>yarn.nodemanager.resource.memory-mb</name>
      <value>${yarn_nodemanager_resource_memory_mb}</value>
   </property>
   <property>
      <name>yarn.scheduler.maximum-allocation-mb</name>
      <value>${yarn_scheduler_maximum_allocation__mb}</value>
   </property>
   <property>
      <name>yarn.scheduler.maximum-allocation-vcores</name>
      <value>$((ocpu*2))</value>
   </property>
   <property>
      <name>yarn.nodemanager.vmem-check-enabled</name>
      <value>false</value>
   </property>
   <property>
      <name>yarn.acl.enable</name>
      <value>false</value>
   </property>
   <property>
      <name>yarn.application.classpath</name>
      <value>/usr/local/hadoop-${hadoop_version}/etc/hadoop:/usr/local/hadoop-${hadoop_version}/share/hadoop/common/lib/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/common/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/hdfs:/usr/local/hadoop-${hadoop_version}/share/hadoop/hdfs/lib/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/hdfs/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/mapreduce/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/yarn:/usr/local/hadoop-${hadoop_version}/share/hadoop/yarn/lib/*:/usr/local/hadoop-${hadoop_version}/share/hadoop/yarn/*</value>
   </property>
   <property>
      <name>yarn.log-aggregation-enable</name>
      <value>true</value>
   </property>
   <property>
      <name>yarn.log-aggregation.retain-seconds</name>
      <value>10800</value>
   </property>
   <property>
      <name>yarn.log-aggregation.retain-check-interval-seconds</name>
      <value>0</value>
   </property>
   <property>
      <name>yarn.nodemanager.remote-app-log-dir</name>
      <value>/tmp/logs</value>
   </property>
   <property>      
      <name>yarn.nodemanager.remote-app-log-dir-suffix</name>
      <value>logs</value>
   </property>
   <property>
      <name>yarn.resourcemanager.recovery.enabled</name>
      <value>true</value>
   </property>
   <property>
      <name>yarn.resourcemanager.store.class</name>
      <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.FileSystemRMStateStore</value>
   </property>" > /usr/local/hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml
for w in `seq 1 ${worker_count}`; do 
echo "   <property>
      <name>yarn.nodemanager.address</name>
      <value>worker-${w}.${cluster_domain}:7999</value>
   </property>" >> /usr/local/hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml 
done;

echo "</configuration>" >> /usr/local/hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml

log "->Start Hadoop Service Configuration"

yarn3_setup (){
	log "->Setting up $1 in SystemD"
cat > /lib/systemd/system/$1.service << EOF
[Unit]
Description=Hadoop YARN $1 service
After=zk.service
[Service]
User=root
Group=root
Type=forking
ExecStart=  /usr/local/hadoop-${hadoop_version}/bin/yarn --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --daemon start $1
ExecStop=  /usr/local/hadoop-${hadoop_version}/bin/yarn --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --daemon stop $1
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
	log "-> Starting $1"
	systemctl start $1 >> ${LOG_FILE}
	systemctl enable $1 >> ${LOG_FILE}
}

yarn2_setup (){
        log "->Setting up $1 in SystemD"
cat > /lib/systemd/system/$1.service << EOF
[Unit]
Description=Hadoop YARN $1 service
After=zk.service
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/hadoop-${hadoop_version}/sbin/yarn-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ start $1
ExecStop= /usr/local/hadoop-${hadoop_version}/sbin/yarn-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ stop $1
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
	log "->Starting $1"
	systemctl start $1
	systemctl enable $1
}

zk_setup (){
        #Zookeeper
	wget https://downloads.apache.org/zookeeper/zookeeper-${zk_version}/apache-zookeeper-${zk_version}-bin.tar.gz
        tar -xf apache-zookeeper-${zk_version}-bin.tar.gz -C /usr/local/
	mkdir -p /data0/zk
	echo ${myid} > /data0/zk/myid
	mkdir -p /data0/nn
	mkdir -p /data0/jn/${cluster_name}
	echo "
tickTime=2000
dataDir=/data0/zk
clientPort=2181
initLimit=5
syncLimit=2
server.1=${master1fqdn}:2888:3888
server.2=${master2fqdn}:2888:3888
server.3=${master3fqdn}:2888:3888
" >> /usr/local/apache-zookeeper-${zk_version}-bin/conf/zoo.cfg
log "->Setting up Apache Zookeeper (zk.service) in SystemD"
cat > /lib/systemd/system/zk.service << EOF
[Unit]
Description=Apache Zookeeper service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/apache-zookeeper-${zk_version}-bin/bin/zkServer.sh start
ExecStop= /usr/local/apache-zookeeper-${zk_version}-bin/bin/zkServer.sh stop
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
        log "->Starting Zookeeper service"
        systemctl start zk.service
        systemctl enable zk.service
}

zkfc_setup (){
	log "->Setting up Hadoop Zookeeper (zkfc.service) in SystemD"
cat > /lib/systemd/system/zkfc.service << EOF
[Unit]
Description=Hadoop Zookeeper service
After=zk.service
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/hadoop-${hadoop_version}/bin/hdfs --daemon start zkfc
ExecStop= /usr/local/hadoop-${hadoop_version}/bin/hdfs --daemon stop zkfc
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
        log "->Starting Hadoop Zookeeper service"
        systemctl start zkfc.service
        systemctl enable zkfc.service
}

source ~/.bashrc
hadoop_major_version=`echo $hadoop_version | cut -d '.' -f 1`
#
# Main Host setup detection
#
case ${hostfqdn} in
        ${master1fqdn})
        log "->Setting up Hadoop Zookeeper"
        myid=1
        zk_setup >> ${LOG_FILE}
        /usr/local/hadoop-${hadoop_version}/bin/hdfs zkfc -formatZK >> ${LOG_FILE}
	zkfc_setup >> ${LOG_FILE}
        log "->Setting up NameNode"
	log "->Formattting NameNode for ${cluster_name}"
        /usr/local/hadoop-${hadoop_version}/bin/hdfs namenode -format ${cluster_name} >> ${LOG_FILE} 2>&1
	sleep 10
	log "->Starting NameNode"
	case $hadoop_major_version in 
		3)
		log "->Setting up NameNode in SystemD"
cat > /lib/systemd/system/namenode.service << EOF
[Unit]
Description=Hadoop NameNode service
After=zkfc.service
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/hadoop-${hadoop_version}/bin/hdfs --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --daemon start namenode
ExecStop= /usr/local/hadoop-${hadoop_version}/bin/hdfs --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --daemon stop namenode
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
		;;

		2)
	        log "->Setting up NameNode in SystemD"
cat > /lib/systemd/system/namenode.service << EOF
[Unit]
Description=Hadoop NameNode service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/hadoop-${hadoop_version}/sbin/hadoop-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --script hdfs start namenode
ExecStop= /usr/local/hadoop-${hadoop_version}/sbin/kill-namenode.sh
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
cat > /usrlocal/hadoop-${hadoop_version}/sbin/kill-namenode.sh << EOF
		echo "
#!/bin/bash
/bin/ps -ef | /bin/grep java | /bin/grep NameNode | /bin/awk '{print \$2}' | /bin/xargs kill -9
EOF
		chmod +x /usrlocal/hadoop-${hadoop_version}/sbin/kill-namenode.sh
		;;
	esac
	log "->Starting NameNode Service"
        systemctl start namenode.service >> ${LOG_FILE}
        systemctl enable namenode.service >> ${LOG_FILE}
        ;;

        ${master2fqdn})
        log "->Setting up Zookeeper"
        myid=2
        zk_setup >> ${LOG_FILE}
	zkfc_setup >> ${LOG_FILE}
	waitforMaster >> ${LOG_FILE}
        case $hadoop_major_version in
                3)
	        log "->Setting up ResourceManager"
	        /usr/local/hadoop-${hadoop_version}/bin/yarn resourcemanager -format-state-store >> ${LOG_FILE} 2>&1
        	sleep 5
		yarn3_setup resourcemanager
		yarn3_setup timelineserver
		yarn3_setup proxyserver
	        log "->Setting up HistoryServer in SystemD"
cat > /lib/systemd/system/historyserver.service << EOF
[Unit]
Description=Hadoop YARN historyserver service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/hadoop-${hadoop_version}/bin/mapred --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --daemon start historyserver
ExecStop= /usr/local/hadoop-${hadoop_version}/bin/mapred --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ --daemon stop historyserver
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
		log "->Starting HistoryServer"
		systemctl start historyserver.service >> ${LOG_FILE}
		systemctl enable historyserver.service >> ${LOG_FILE}
                ;;

                2)
		yarn2_setup resourcemanager
		yarn2_setup timelineserver
		yarn2_setup proxyserver
                log "->Setting up MapReduce HistoryServer in SystemD"
cat > /lib/systemd/system/historyserver.service << EOF 
[Unit]
Description=Hadoop YARN historyserver service
After=network.target
[Service]
User=root
Group=root
Type=forking
ExecStart= /usr/local/hadoop-${hadoop_version}/sbin/mr-jobhistory-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ start historyserver
ExecStop= /usr/local/hadoop-${hadoop_version}/sbin/mr-jobhistory-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop/ stop historyserver
Restart=on-failure
RestartSec=10s
PrivateTmp=true
[Install]
WantedBy=multi-user.target
EOF
		log "->Starting MapReduce HistoryServer"
		systemctl start historyserver.service >> ${LOG_FILE}
		systemctl enable historyserver.service >> ${LOG_FILE}
                ;;
        esac
        ;;
        
	${master3fqdn})
        log "->Setting up Zookeeper"
        myid=3
        zk_setup >> ${LOG_FILE}
	zkfc_setup >> ${LOG_FILE}
        ;;

        *)
	log "->ERROR agent_hostname $hostfqdn failed to match master role! This node will not have any cluster roles set." 
	;;

esac

EXECNAME="END"
log "->DONE"
