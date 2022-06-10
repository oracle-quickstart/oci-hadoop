#!/bin/bash
LOG_FILE="/var/log/OCI-initialize.log"
log() {
        echo "$(date) [${EXECNAME}]: $*" >> "${LOG_FILE}"
}
function yum_install() {
package=$1
success=1
while [ $success != 0 ]; do
  yum install $package -y >> $LOG_FILE
  success=$?
done;
}
region=`curl -L http://169.254.169.254/opc/v1/instance/region`
hadoop_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hadoop_version`
hadoop_par=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hadoop_par`
install_hive=`curl -L http://169.254.169.254/opc/v1/instance/metadata/install_hive`
hive_version=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hive_version`
hive_par=`curl -L http://169.254.169.254/opc/v1/instance/metadata/hive_par`
cluster_name=`curl -L http://169.254.169.254/opc/v1/instance/metadata/cluster_name`
worker_count=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_count`
worker_shape=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_shape`
cluster_domain=`curl -L http://169.254.169.254/opc/v1/instance/metadata/worker_domain`
fqdn_fields=`echo -e ${cluster_domain} | gawk -F '.' '{print NF}'`
kerberos_domain=`echo -e ${cluster_domain} | cut -d '.' -f 2-$((fqdn_fields-1))`
master1fqdn="master-1.${cluster_domain}"
master2fqdn="master-2.${cluster_domain}"
master3fqdn="master-3.${cluster_domain}"
date=`date +%Y%m%d-%H%M`
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
EXECNAME="NSCD, NC, screen"
log "->INSTALL"
yum_install nscd 
yum_install nc 
yum_install screen 
systemctl start nscd.service
EXECNAME="KERBEROS"
log "->INSTALL"
yum_install krb5-workstation 
log "->krb5.conf"
kdc_fqdn=`hostname -f`
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
        log "-->Building /root/hive-init.sh setup script"
        cat > /root/hive-init.sh << EOF
#!/bin/bash
/usr/local/hadoop-${hadoop_version}/bin/hadoop fs -mkdir -p       /tmp
/usr/local/hadoop-${hadoop_version}/bin/hadoop fs -mkdir -p      /user/hive/warehouse
/usr/local/hadoop-${hadoop_version}/bin/hadoop fs -chmod g+w   /tmp
/usr/local/hadoop-${hadoop_version}/bin/hadoop fs -chmod g+w   /user/hive/warehouse
EOF
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
export HADOOP_HOME=\$HADOOP_INSTALL
export HIVE_HOME=/usr/local/hive-${hive_version}
" >>/root/.bashrc
cp /root/.bashrc /home/opc/.bashrc
chown opc:opc /home/opc/.bashrc
#Setup hadoop-env
echo "
export JAVA_HOME=\$(readlink -f /usr/bin/java | sed "s:bin/java::")
export HADOOP_HOME=/usr/local/hadoop-${hadoop_version}
export HADOOP_CONF_DIR=/usr/local/hadoop-${hadoop_version}/etc/hadoop
export HADOOP_LOG_DIR=\$HADOOP_HOME/logs
export HADOOP_CLASSPATH=\$HADOOP_CLASSPATH:/usr/local/hadoop-${hadoop_version}/etc/hadoop
" >>/usr/local/hadoop-${hadoop_version}/etc/hadoop/hadoop-env.sh
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
   </property>
</configuration>" >/usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml
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
log "->DONE"
EXECNAME="BASHRC HADOOP PATH"
echo "export PATH=\${PATH}:/usr/local/hadoop-${hadoop_version}/bin" >> ~/.bashrc
log "->DONE"
EXECNAME="CLUSTER MANAGEMENT SCRIPT"
log "->Building script"
cat > /home/opc/manage-cluster.sh << EOF
#!/bin/bash

if [ ! -f ~/.ssh/id_rsa ]; then 
	echo "Private key missing in ~/.ssh/id_rsa!  Please ensure this exists and is valid for cluster hosts."
	exit
fi

usage () {
echo "Usage is (start/stop) (all/hdfs/yarn)"
exit
}

manage_service (){
	ssh -i ~/.ssh/id_rsa -oStrictHostKeyChecking=no opc@\${cluster_host} "sudo systemctl \$1 \$2"
}

worker_count=\`curl -s -L http://169.254.169.254/opc/v1/instance/metadata/worker_count\`
# Update cluster_domain if this is modified in stack"
cluster_domain="private.hadoopvcn.oraclevcn.com"

case \$1 in
	start)
		case \$2 in
			all)
                        echo "HDFS (NameNode) \$1 on Master 1"
                        cluster_host="master-1.\${cluster_domain}"
                        manage_service \$1 namenode
                        echo "YARN \$1 on Master 2"
                        cluster_host="master-2.\${cluster_domain}"
                        manage_service \$1 historyserver
                        manage_service \$1 proxyserver
                        manage_service \$1 timelineserver
                        manage_service \$1 resourcemanager
                        for w in \`seq 1 \${worker_count}\`; do 
                                cluster_host="worker-\${w}.\${cluster_domain}"
                                echo "HDFS \$1 on Worker \$w"
                                manage_service \$1 hdfs 
                                echo "NodeManager \$1 on Worker \$w"
                                manage_service \$1 nodemanager
                        done
			;;

			hdfs)
                        echo "HDFS (NameNode) \$1 on Master 1"
                        cluster_host="master-1.\${cluster_domain}"
                        manage_service \$1 namenode
                        for w in \`seq 1 \${worker_count}\`; do
                                cluster_host="worker-\${w}.\${cluster_domain}"
                                echo "HDFS \$1 on Worker \$w"
                                manage_service \$1 hdfs
                        done
			;;
	
			yarn)
                        echo "YARN \$1 on Master 2"
                        cluster_host="master-2.\${cluster_domain}"
                        manage_service \$1 historyserver
                        manage_service \$1 proxyserver
                        manage_service \$1 timelineserver
                        manage_service \$1 resourcemanager
                        for w in \`seq 1 \${worker_count}\`; do
                                cluster_host="worker-\${w}.\${cluster_domain}"
                                echo "NodeManager \$1 on Worker \$w"
                                manage_service \$1 nodemanager
                        done
			;;

			*) usage
			;;
		esac	
	;;

	stop)
		case \$2 in 
			all)
			for w in \`seq 1 \${worker_count}\`; do 
				cluster_host="worker-\${w}.\${cluster_domain}"
				echo "HDFS \$1 on Worker \$w"
				manage_service \$1 hdfs
				echo "NodeManager \$1 on Worker \$w"
				manage_service \$1 nodemanager
			done
			echo "YARN \$1 on Master 2"
			cluster_host="master-2.\${cluster_domain}"
			manage_service \$1 historyserver
			manage_service \$1 proxyserver
			manage_service \$1 timelineserver
			manage_service \$1 resourcemanager
			echo "HDFS (NameNode) \$1 on Master 1"
			cluster_host="master-1.\${cluster_domain}"
			manage_service \$1 namenode
			;;

			hdfs)
                        for w in \`seq 1 \${worker_count}\`; do 
                                cluster_host="worker-\${w}.\${cluster_domain}"
                                echo "HDFS \$1 on Worker \$w"
                                manage_service \$1 hdfs 
                        done
                        echo "HDFS (NameNode) \$1 on Master 1"
                        cluster_host="master-1.\${cluster_domain}"
                        manage_service \$1 namenode
			;;

			yarn)
                        for w in \`seq 1 \${worker_count}\`; do 
                                cluster_host="worker-\${w}.\${cluster_domain}"
                                echo "NodeManager \$1 on Worker \$w"
                                manage_service \$1 nodemanager
                        done   
                        cluster_host="master-2.\${cluster_domain}"
                        manage_service \$1 historyserver
                        manage_service \$1 proxyserver
                        manage_service \$1 timelineserver
                        manage_service \$1 resourcemanager
			;;

			*) usage
			;;

		esac
		;;

	*) usage
	;;
esac
EOF
log "->Changing Permissions"
chown opc:opc /home/opc/manager-cluster.sh
chmod +x /home/opc/manage-cluster.sh
log "->DONE - /home/opc/manage-cluster.sh"

