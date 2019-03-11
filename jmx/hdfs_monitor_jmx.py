#!/usr/bin/env python
#coding=utf-8
import urllib2
import json
import os
import urllib
import sys
#不同的集群使用不同的masterIP，这个为HDFS所有NameNode IP
masterIP = ("192.168.x.x","192.168.x.x")
argvstr = sys.argv

#get_activeNameNode()函数用于判断集群中active NameNode节点
def get_activeNameNode():
    for stri in masterIP:
        url="http://"+stri+":50070/jmx?qry=Hadoop:service=NameNode,name=FSNamesystem"
        cont=urllib2.Request(url)
        try:
            resu=urllib2.urlopen(cont)
        except urllib2.HTTPError, e:
            return "error"
        except urllib2.URLError, e:
            return "error"
        else:
            val1=json.loads(resu.read())
            val2=val1['beans'][0]['tag.HAState']
            if val2 == 'active':
                return stri

#get_NameNodeInfo(activeNodeIP)获取NameNode的相关信息
def get_NameNodeInfo(activeNodeIP):
	url="http://"+activeNodeIP+":50070/jmx?qry=Hadoop:service=NameNode,name=NameNodeInfo"
	cont=urllib2.Request(url)
	try:
		resu=urllib2.urlopen(cont)
	except urllib2.HTTPError, e:
		return "error"
	except urllib2.URLError, e:
		return "error"
	else:
		val1=json.loads(resu.read())
		return val1['beans'][0]

#get_FSNamesystem(activeNodeIP)获取FSNamesystem的相关信息
def get_FSNamesystem(activeNodeIP):
	url="http://"+activeNodeIP+":50070/jmx?qry=Hadoop:service=NameNode,name=FSNamesystem"
	cont=urllib2.Request(url)
	try:
		resu=urllib2.urlopen(cont)
	except urllib2.HTTPError, e:
		return "error"
	except urllib2.URLError, e:
		return "error"
	else:
		val1=json.loads(resu.read())
		return val1['beans'][0]

#get_FSNamesystemState(activeNodeIP)获取FSNamesystemState的相关信息
def get_FSNamesystemState(activeNodeIP):
	url="http://"+activeNodeIP+":50070/jmx?qry=Hadoop:service=NameNode,name=FSNamesystemState"
	cont=urllib2.Request(url)
	try:
		resu=urllib2.urlopen(cont)
	except urllib2.HTTPError, e:
		return "error"
	except urllib2.URLError, e:
		return "error"
	else:
		val1=json.loads(resu.read())
		return val1['beans'][0]

#get_RpcActivityForPort(activeNodeIP)获取RPC的相关信息
def get_RpcActivityForPort(activeNodeIP):
	url="http://"+activeNodeIP+":50070/jmx?qry=Hadoop:service=NameNode,name=RpcActivityForPort8022"
	cont=urllib2.Request(url)
	try:
		resu=urllib2.urlopen(cont)
	except urllib2.HTTPError, e:
		return "error"
	except urllib2.URLError, e:
		return "error"
	else:
		val1=json.loads(resu.read())
		return val1['beans'][0]

#get_JvmMetrics(activeNodeIP)获取JVM的相关信息
def get_JvmMetrics(activeNodeIP):
	url="http://"+activeNodeIP+":50070/jmx?qry=Hadoop:service=NameNode,name=JvmMetrics"
	cont=urllib2.Request(url)
	try:
		resu=urllib2.urlopen(cont)
	except urllib2.HTTPError, e:
		return "error"
	except urllib2.URLError, e:
		return "error"
	else:
		val1=json.loads(resu.read())
		return val1['beans'][0]
		
activeNodeIP = get_activeNameNode()
#判断get_activeNameNode是否打开网址并返回结果
if activeNodeIP != 'error':
	#判断输入参数的长度，如果python脚本后面未接相应的参数则返回告知用法
	if len(argvstr) < 2:
		print 'usage: python hdfs_monitor_jmx.py TotalFiles|TotalBlocks|PercentUsed|BlockPoolUsedSpace|Total|Used|MissingBlocks|NumLiveDataNodes|NumDeadDataNodes|VolumeFailuresTotal|RpcProcessingTimeAvgTime|CallQueueLength|MemHeapUsedM|ThreadsBlocked|ThreadsWaiting'
		sys.exit()
	#判断输入的参数属于哪一类，则打印相应的结果
	if argvstr[1] in ('TotalFiles', 'TotalBlocks', 'PercentUsed', 'BlockPoolUsedSpace', 'Total', 'Used'):
		NameNodeInfoList = get_NameNodeInfo(activeNodeIP)
		print NameNodeInfoList[argvstr[1]]
		sys.exit()	
	elif argvstr[1] in ('MissingBlocks'):
		FSNamesystemList = get_FSNamesystem(activeNodeIP)
		print FSNamesystemList[argvstr[1]]
		sys.exit()
	elif argvstr[1] in ('NumLiveDataNodes', 'NumDeadDataNodes', 'VolumeFailuresTotal'):
		FSNamesystemStateList = get_FSNamesystemState(activeNodeIP)
		print FSNamesystemStateList[argvstr[1]]
		sys.exit()
	elif argvstr[1] in ('RpcProcessingTimeAvgTime', 'CallQueueLength'):
		RpcActivityForPortList = get_RpcActivityForPort(activeNodeIP)
		print RpcActivityForPortList[argvstr[1]]
		sys.exit()
	elif argvstr[1] in ('MemHeapUsedM', 'ThreadsBlocked', 'ThreadsWaiting'):
		JvmMetricsList = get_JvmMetrics(activeNodeIP)
		print JvmMetricsList[argvstr[1]]
		sys.exit()
	else:
		print 'usage: python hdfs_monitor_jmx.py TotalFiles|TotalBlocks|PercentUsed|BlockPoolUsedSpace|Total|Used|MissingBlocks|NumLiveDataNodes|NumDeadDataNodes|VolumeFailuresTotal|RpcProcessingTimeAvgTime|CallQueueLength|MemHeapUsedM|ThreadsBlocked|ThreadsWaiting'
		sys.exit()
else:
	print "The url cannot open!!"
