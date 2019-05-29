#!/bin/bash
#nodes:means your cluster hosts
#loop needed: To note a job need loop to run
Time=`date +%F`
echo "Author: Hwilu, contact Hwilu if you have any question. " | tee ${Time}_Daily_Check_result.log
yesterday=`date -d "1 day ago" +"%Y%m%d"`                                                  
cluster_name=`hostname | awk -F "-" '{print $2}' `

read -p "it is your turn to check, Enter your name:" name
echo
echo "Today is $Time, it is turn to $name checking"
#>Tmp_Daily_check_result.log
function Host_status(){
	echo "----------------Host_Status----------------------" >> Tmp_Daily_check_result.log
	for ip in `cat nodes | awk '{print $1}'`
	do
		ping -c 1 $ip > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			echo "$ip is Online" >>Tmp_Daily_check_result.log
     		else
			echo "$ip is Offline" >> Tmp_Daily_check_result.log
		
	#	let unpingable+=1
     		fi
	done
	#print ping result.
	
	#sleep 10
	pingable=`grep "Online" Tmp_Daily_check_result.log | wc -l`
	unpingable=`grep "Offline" Tmp_Daily_check_result.log | wc -l`
	echo "The  num of online  hosts are :$pingable"
	echo "The num of offline hosts are :$unpingable"
	if [ $unpingable -ne 0 ];then
		echo "The offline host is : $unpingable"
	else
		echo "There is no host offline"
	fi	
	#awk -F "is" '/Offline/{print "The offline host is :",$1}' Tmp_Daily_check_result.log
	
	}

function Disk_Status(){
	echo "----------------Disk_Status----------------------" >> Tmp_Daily_check_result.log
	echo
	echo "------------------disk number of every host------------------------"
	#loop needed , cause slowly
	for ip in `cat all_cluster_nodes | awk '{print $1}'`
	do
		#the number of disk ,check whether have disks dropped 
		ssh root@$ip "echo numofdisk:\$(hostname;df -h | wc -l)" >> Tmp_Daily_check_result.log
		#check whether have some broken disks 
		ssh root@$ip "echo -e statusofdisk:\$(hostname;ls /* | grep 'Input/output error')" >> Tmp_Daily_check_result.log
	done
	awk '/^numofdisk:MASTER/{if($2!=4){print "the hosts disk_number is wrong: " $0}else{print $0 ":disk_number is right"}}'  Tmp_Daily_check_result.log
	awk '/^numofdisk:DataNode/{if($2!=15){print "the hosts disk number is wrong: " $0}else{print $0 ":disk_number is right"}}'  Tmp_Daily_check_result.log
	#awk '/error/{print $0} Tmp_Daily_check_result.log' 
	echo "------------------disk status in every host------------------------"
	echo
	status=`grep "Input\/output error" Tmp_Daily_check_result.log`
	if [ -z "$status" ]
	then
		echo "All disk status is nice"
	else
		echo "Some disk maybe broken, details is followed"
		echo "$status"
	fi
	echo
	}	
	
function disk_usage(){
	#disk space used percent
	#loop needed
	echo "---------------------disk usage --------------------------" >> Tmp_Daily_check_result.log
	echo >> Tmp_Daily_check_result.log
	for ip in `grep "BJXXG-JFcluster-DN" all_cluster_nodes | awk '{print $1}'`
	do
		host=disk_usage_$ip:
		echo "-------------------$host---------------------" >>Tmp_Daily_check_result.log
		ssh root@$ip "df -h | awk -v var=$host '{print var \$0}'" >>Tmp_Daily_check_result.log
		echo >> Tmp_Daily_check_result.log
	done
	
	echo "find the space of non-data disk used more than 80%"
	echo
	grep "disk_usage" Tmp_Daily_check_result.log | grep -v Filesystem  | awk '$7 ~/data/{if ($6 >80){print "Critical!!",$1,$2,$6}else{print "no such non-data disk"}}'
	
	#per_host_disk_usage
	echo "per_host_disk_usage ,Maximum and Minimal, to judge whether data is balance" | tee per_host_disk_usage_$Time 
	echo
	for ip in `cat nodes | awk '{print $1}'`
	do
		echo -e "per_disk_of_host \t dir \t percent"
		grep $ip Tmp_Daily_check_result.log | grep disk_usage |awk '{print $1 "\t" $7 "\t" $6}'
		
		echo -e "per_host_data-disk_usage \t host_ip \t usage_percent"
		grep $ip Tmp_Daily_check_result.log | grep disk_usage | awk 'BEGIN{n=0;usage=0}{n++;usage+=$6}END{print "per_host" "\t" $1 "\t" usage/n"%"}' >> per_host_disk_usage_$Time 
	
	done
	
	echo -e "\t five_minimal_data_disk_used_host \t percent"
	grep "per_host" per_host_disk_usage_$Time | sort -k2 -n | head -n 5 
	echo -e "\t five_maximum_data_disk_used_host \t percent"
	grep "per_host" per_host_disk_usage_$Time | sort -k2 -n | tail -n 5 
	
	awk '/disk_usage/&&/data/{print $0}' per_host_disk_usage_$Time | sort -k6 -n |sed '1p;$p' |sed '1s/^/minumal /g' |sed '2s/^/maximal /g' 
	}

#cluser CPU、memory used  1 day ago
function CpuMemUsage_yesterday(){
	today=`date |awk '{print $1}'` 
	echo "time        Datanode_mem_used_avg      DataNode_cpu_used_avg "
	#datanode memory&cpu avg_used
	if ($today = "Fri");then
		grep "$yesterday" weekdaily.log.$Time | awk 'BEGIN{n=0;cpu_avg=0;mem_avg=0}{print $1,$2,$6,$7;n++;cpu_avg+=$6;mem_avg+=$7}END{print "datanode_cpu_avg_used "cpu_avg/n"%","datanode_mem_used"mem_avg/n"%"}'

	else
		grep "$yesterday" weekdaily.log| awk 'BEGIN{n=0;cpu_avg=0;mem_avg=0}{print $1,$2,$6,$7;n++;cpu_avg+=$6;mem_avg+=$7}END{print "datanode_cpu_avg_used "cpu_avg/n"%","datanode_mem_used"mem_avg/n"%"}'
	fi
	#flume cluster memory&cpu avg_used
	echo -e "time \t flume_mem_usage_avg \t flume_cpu_usage_avg "
	grep "$yesterday" weekdaily.csv | awk 'BEGIN{n=0;cpu_avg=0;mem_avg=0}{print $1,$2,$6,$7;n++;cpu_avg+=$6;mem_avg+=$7}END{print "flume_cpu_avg_used "cpu_avg/n"%","flume_mem_used"mem_avg/n"%"}'
		
	}
	
function HDFS_status(){
	echo "----------------check HDFS_status ----------------" >> Tmp_Daily_check_result.log
	
	HDFS_used=`hadoop fs -df -h | grep hdfs |awk '{print $5}'`
	echo "$cluster_name HDFS space have used：$HDFS_used"
	./bin/hadoop jar hadoop-mapreduce-examples-2.6.0.jar wordcount /tmp/aa /tmp/test20170801
	if [$? -eq 0];then
		echo "HDFS_status is :nice"
	else
		echo "HDFS_status is :bad"
	fi
	hadoop fs -rmr /tmp/test20170801
	
	if [$? -eq 0];then
		echo "The result of wordcount is removed"
	else
		echo "You have not removed /tmp/test20170801"
	fi
	master02=`hdfs haadmin -getServiceState nn1`
	echo "master02 is :$master02 namenode"
	
	master04=`hdfs haadmin -getServiceState nn2`
	echo "master04 is :$master04 namenode"
	
	#DataNode process status
	live_datanode=`hdfs dfsadmin -report -live | grep "Live datanodes" `
	echo "$live_datanode"
	
	dead_datanode=`hdfs dfsadmin -report -live | grep "Dead datanodes" `
	echo "$dead_datanode"	
	exit 3
	}
	
function yarn_status(){
	live_nodemanager=`yarn node -list | grep "Total node" |awk -F: '{print $2}'`
	echo "The live nodemanager is $live_nodemanager"
su - yarn <<EOF

	kinit -kt /etc/security/keytabs/rm.service.keytab rm@XXXKDC
	
	echo -n "The status of Resource Manager in master02 is : " ;/cmss/bch/bc1.3.2/hadoop/bin/yarn rmadmin -getServiceState rm1
	echo -n "The status of Resource Manager in master04 is : " ;/cmss/bch/bc1.3.2/hadoop/bin/yarn rmadmin -getServiceState rm2	
EOF
	
	}
	
#cluser cluster only
function hive_status(){
	echo "show databases;" | hive
	if [ $? -eq 0];then
		echo "Hive status is：nice."
	else
		echo "Hive status is：bad, please check it."
	fi
}

#cluser cluster only
function HBase_status(){
	#hbase status
	echo list | hbase shell
	if [ $? -eq 0];then
		echo "HBase status is：nice."
	else
		echo "HBase status is：bad, please check it."
	fi
	#RegionServer status monitor
	echo $(echo RegionServer_status;echo status | hbase shell 2>/dev/null | grep 'servers')
	
	#hbase_tables_space
	printf "Table_name \t Table_size \t Table_space \n"
	hadoop fs -du -h /apps/hbase/data/data/default | awk '{print $5 "\t" $1$2 "\t" $3$4}'		
	}

function zookeeper_status(){
	#zookeeper server status
	echo "------------------------start check zookeeper status------------------"
	 ./zookeeper/bin/zkServer.sh status 
	
	#zookeeper client
	echo "zookeeper client: Not to check it temporarily"
	 }

function kerberos_status(){
	#KDC status
	echo "Not to check kerberos now."
	 }
function flume_status(){
	#flume status
	echo "------------------------start check flume status------------------"
	#need loop
	for flumeip in `cat all_cluster_nodes | grep "FLUME" | awk '{print $1}'`
	do	
		ssh root@$flumeip "echo flume_status $(hostname -i;ps -ef | grep flume.node.Application |grep -v grep | awk '{print $1}')" >> Tmp_Daily_check_result.log
	done
	awk '/^flume_status/{if ($3 == "flume")print $2"_flume_status is: nice" "\t";else print $2"_flume_status is: bad"}'  Tmp_Daily_check_result.log
	 
	 }	 

function main(){
#	echo "-------------- start check Host_status -----------------"
	Host_status		
#	echo "-------------- start check disk_status ------------------"
#	Disk_Status	
	echo "-------------- start check disk usage ------------------"
	disk_usage	
#	echo "-------------- start check Cpu_Mem usage yesterday ------------------"
#	CpuMemUsage_yesterday
#	echo "-------------- start check hdfs_status------------------"
#	HDFS_status
#	echo "-------------- start check yarn-status ------------------"
#	yarn_status
#	echo "-------------- start check Hive-status ------------------"
	hive_status
#	echo "-------------- start check HBase-status------------------"
#	HBase_status
#	echo "-------------- start check yarn-status ------------------"
#	zookeeper_status
#	echo "-------------- start check zookeeper-status ------------------"
	kerberos_status
#	echo "-------------- start check flume-status ------------------"	
	flume_status	
}
main | tee ${Time}_Daily_Check_result.log

