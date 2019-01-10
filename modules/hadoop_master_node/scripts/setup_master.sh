#!/bin/bash

##Install JDK
yum -y install java-1.8.0-openjdk

#Install hadoop

wget https://www-us.apache.org/dist/hadoop/common/stable/hadoop-${hadoop_version}.tar.gz
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


#Enable web access firewall ports 

firewall-cmd --zone=public --permanent --add-port=${nn_port}/tcp
firewall-cmd --zone=public --permanent --add-port=${rm_port}/tcp
firewall-cmd --zone=public --permanent --add-port=${jhs_port}/tcp



#Default ports
#19888           -- Job history server Webapp Address
#10033           -- mapreduce.jobhistory.admin.address 
#50070           -- Namenode Webapp Address
#8080            -- Mapreduce Job tracker
#8030            -- Yarn resource manager Scheduler
#8031            -- yarn ResourceManager  Tracker
#8032            -- yarn ResourceManager
#8033            -- yarn ResourceManager Admin
#10020           -- JobHistory server listner
#9000            -- hdfs namenode listner
#8088            -- Resource Manager Web App port


firewall-cmd --zone=public --permanent --add-port=9000/tcp   
firewall-cmd --zone=public --permanent --add-port=8030/tcp   
firewall-cmd --zone=public --permanent --add-port=8031/tcp   
firewall-cmd --zone=public --permanent --add-port=8032/tcp 
firewall-cmd --zone=public --permanent --add-port=8033/tcp 
firewall-cmd --zone=public --permanent --add-port=8080/tcp 
firewall-cmd --zone=public --permanent --add-port=10033/tcp 
firewall-cmd --zone=public --permanent --add-port=10020/tcp


#"sudo firewall-cmd --reload " works with only 4 rules. Terrafor remote-exec loses the connection after the reload with more than 4 rules. 
#Hence doing stop/start of the service

echo "stopping firewall"

systemctl stop firewalld.service

echo "starting firewall"

systemctl start firewalld.service

echo "Done!"


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
      <value>hdfs://${hadoop_master_ip}:9000</value>
   </property>
</configuration>
" >/usr/local/hadoop-${hadoop_version}/etc/hadoop/core-site.xml

#Configure Hadoop hdfs-site.xml
echo "
<configuration>
   <property>
      <name>dfs.replication</name>
      <value>3</value>
   </property>
   <property>
      <name>dfs.namenode.name.dir</name>
      <value>file:///home/opc/hadoop/NamenodeStore</value>
   </property>
   <property>
      <name>dfs.permissions</name>
      <value>false</value>
   </property>
   <property>
      <name>dfs.namenode.http-address</name>
      <value>${hadoop_master_ip}:${nn_port}</value>
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
      <value>${hadoop_master_ip}:10020</value>
    </property>
    <property>
      <name>mapreduce.jobhistory.webapp.address</name>
      <value>${hadoop_master_ip}:${jhs_port}</value>
    </property>
 </configuration>
" > /usr/local/hadoop-${hadoop_version}/etc/hadoop/mapred-site.xml

#Configure yarn-site.xml
echo "
<configuration>
   <property>
      <name>yarn.resourcemanager.hostname</name>
      <value>${hadoop_master_ip}</value>
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
      <name>yarn.resourcemanager.webapp.address</name>
      <value>${hadoop_master_ip}:${rm_port}</value>
   </property>
</configuration>
" > /usr/local/hadoop-${hadoop_version}/etc/hadoop/yarn-site.xml 

#Start services
/usr/local/hadoop-${hadoop_version}/bin/hadoop namenode -format
/usr/local/hadoop-${hadoop_version}/sbin/hadoop-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop --script hdfs start namenode
/usr/local/hadoop-${hadoop_version}/sbin/yarn-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop start resourcemanager
/usr/local/hadoop-${hadoop_version}/sbin/yarn-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop start proxyserver
/usr/local/hadoop-${hadoop_version}/sbin/mr-jobhistory-daemon.sh --config /usr/local/hadoop-${hadoop_version}/etc/hadoop start historyserver

#setup hdfs permissions
/usr/local/hadoop-${hadoop_version}/bin/hadoop fs -chown -R opc  /
