- 获取集群所有主机CPU使用率平均值
```vim
#!/bin/bash

echo "-----------------时间----------------cpu使用率-------------节点数--------"

while [ 0 ]

do
	current=`/bin/date +"%Y/%m/%d %H:%M:%S"`

	curl -g -u admin:admin http://10.10.143.23:8080/api/v1/clusters/clusterName/hosts?fields=metrics/cpu/cpu_user > monitor_api_data

	grep 'cpu_user' monitor_api_data | awk -v dt="$current" -F: '{sum+=$2}END{print "cpu_usage","	",dt,"	", sum/NR,"	",NR}'
	
	sleep 10
  
done
```
