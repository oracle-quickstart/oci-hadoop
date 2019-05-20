#!/bin/bash

function waitforMaster() { 
   timeout 600  \
   bash -c "while ! echo exit | nc -z -w5  ${hadoop_master_name} 9000
   do
      sleep 10
      echo 'Waiting for Master'
   done"
}

function add_block_vols() {
count=1
while [ "$count" -le "${vols_per_node}" ]
do
   count=$(expr $count + 1)
   sudo iscsiadm -m discoverydb -D -t sendtargets -p 169.254.2.$count:3260 2>&1 2>/dev/null
done

sudo iscsiadm -m node -l
iscsi_chk=`echo -e $?`

if [ $iscsi_chk == 0 ]
then
        echo -e "Discovering iscsi disk(s)"
        echo -e "Setting automatic startup for disk"
        sudo iscsiadm -m node -n node.startup -v automatic
else
        echo -e "iscsi discovery failed"
        exit
fi

#Creating file system and adding entry to fstab
count=0
for disk in `fdisk -l | grep sd | grep -v sda | gawk '{print substr($2, 1, length($2)-1)}'`
do
   UUID=`sudo lsblk -no UUID $disk`
   echo "UUID=$UUID}   /datastore$count    ext4   defaults,_netdev,nofail,noatime,discard,barrier=0 0 2" | sudo tee -a /etc/fstab
   sudo mke2fs -F -t ext4 -b 4096 $disk
   sudo mkdir /datastore$count
   sudo mount $disk /datastore$count
   count=$(expr $count + 1)
   vollist[$count]="/datastore$count"
done
dfs_datanode_dir=`(IFS=,; echo "$${vollist[*]}")`
}

##Install JDK
 yum -y install java-1.8.0-openjdk
 yum -y install nc

#Install hadoop

wget https://www-us.apache.org/dist/hadoop/common/hadoop-${hadoop_version}/hadoop-${hadoop_version}.tar.gz
tar -xf hadoop-${hadoop_version}.tar.gz -C /usr/local/
chown -R opc:opc /usr/local/hadoop-${hadoop_version}
chmod -R 755 /usr/local/hadoop-${hadoop_version}

#Setup user env
echo " 
export JAVA_HOME=\$(readlink -f /usr/bin/java | sed "s:bin/java::")  
export HADOOP_INSTALL=/usr/local/hadoop-${hadoop_version} 
export PATH=\$PATH:\$HADOOP_INSTALL/bin 
export PATH=\$PATH:\$HADOOP_INSTALL/sbin 
export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL 
export HADOOP_COMMON_HOME=\$HADOOP_INSTALL 
export HADOOP_HDFS_HOME=\$HADOOP_INSTALL 
export YARN_HOME=\$HADOOP_INSTALL
" >>/home/opc/.bashrc

nodename=`hostname`


#Enable hadoop default firewall ports 

# 8042            -- yarn NodeManager Webapp Address
# 13562           -- mapreduce.shuffle.port
# 50010           -- dfs.datanode.address (Used for DFS data transfer)
# 50075           -- dfs.datanode.http.address (Used for DFS http UI)
# 50020           -- dfs.datanode.ipc.address (Used for Block metadata operation and recovery)
# 8040            -- yarn.nodemanager.localizer.address
# 57068           -- Yarn Nodemanager http  address (User for resource manager to node mager communication)
# 60000-600050    -- yarn.app.mapreduce.am.job.client.port-range ( Dynamic ports for runtime application containers)
# 7999            -- yarn.nodemanager.address

 firewall-cmd --zone=public --permanent --add-port=50075/tcp 
 firewall-cmd --zone=public --permanent --add-port=50010/tcp 
 firewall-cmd --zone=public --permanent --add-port=57068/tcp 
 firewall-cmd --zone=public --permanent --add-port=50020/tcp 
 firewall-cmd --zone=public --permanent --add-port=8042/tcp 
 firewall-cmd --zone=public --permanent --add-port=8040/tcp
 firewall-cmd --zone=public --permanent --add-port=13562/tcp 
 firewall-cmd --zone=public --permanent --add-port=7999/tcp 
 firewall-cmd --zone=public --permanent --add-port=60000-60050/tcp

#" firewall-cmd --reload " works with only 4 rules. Terraform remote-exec loses the connection after the reload with more than 4 rules. 
#Hence doing stop/start of the service

echo "stopping firewall"

systemctl stop firewalld.service

echo "starting firewall"

systemctl start firewalld.service

echo " firewall started "

#Discovering block volume(s)

add_block_vols

#Setup hadoop-env

echo "
export JAVA_HOME=\$(readlink -f /usr/bin/java | sed "s:bin/java::")
export HADOOP_HOME=/usr/local/hadoop-${hadoop_version}
export HADOOP_CONF_DIR=/usr/local/hadoop-${hadoop_version}/etc/hadoop
export HADOOP_LOG_DIR=\$HADOOP_HOME/logs
export HADOOP_CLASSPATH=\$HADOOP_CLASSPATH:/usr/local/hadoop-${hadoop_version}/etc/hadoop
" >>/usr/local/hadoop-${hadoop_version}/etc/hadoop/hadoop-env.sh


#Configure Hadoop core-site.xml

echo "
<configuration>
   <property>
      <name>fs.defaultFS</name>
      <value>hdfs://${hadoop_master_name}:9000</value>
    </property>
</configuration>
" >/usr/local/hadoop-${hadoop_version}/etc/hadoop/core-site.xml

#Configure Hadoop hdfs-site.xml
echo "
<configuration>
   <property>
      <name>dfs.replication</name>
      <value>${replication_count}</value>
   </property>
   <property>
      <name>dfs.datanode.data.dir</name>
      <value>$dfs_datanode_dir</value>
   </property>
   <property>
      <name>dfs.permissions</name>
      <value>false</value>
   </property>
</configuration>
" >/usr/local/hadoop-${hadoop_version}/etc/hadoop/hdfs-site.xml

#Configure Hadoop Mapred-site
echo "
<configuration>
   <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
   </property>
   <property>
      <name>mapreduce.jobhistory.address</name>
      <value>${hadoop_master_name}:10020</value>
   </property>
    <property>
      <name>yarn.app.mapreduce.am.job.client.port-range</name>
      <value>60000-60050</value>
   </property>
</configuration>
" > /usr/local/hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml

#Configure yarn-site.xml
echo "
<configuration>
   <property>
      <name>yarn.resourcemanager.hostname</name>
      <value>${hadoop_master_name}</value>
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
      <value>http://${hadoop_master_name}:8032</value>
   </property>
   <property>
      <name>yarn.resourcemanager.resource-tracker.address</name>
      <value>${hadoop_master_name}:8031</value>
   </property>
   <property>
      <name>yarn.resourcemanager.scheduler.address</name>
      <value>${hadoop_master_name}:8030</value>
   </property>
     <property>
      <name>yarn.nodemanager.address</name>
      <value>$nodename:7999</value>
   </property>
</configuration>
" > /usr/local/hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml 



waitforMaster

#Start services
 /usr/local/hadoop-${hadoop_version}/sbin/hadoop-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop --script hdfs start datanode
 /usr/local/hadoop-${hadoop_version}/sbin/yarn-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop start nodemanager

#setup hdfs permissions
 /usr/local/hadoop-${hadoop_version}/bin/hadoop fs -chown -R opc  /
