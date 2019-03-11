#!/usr/bin/env python
#coding=utf-8
import urllib2
import json
import os
import urllib
import sys
#不同的集群使用不同的masterIP，这个为HBase所有HMaster IP
masterIP = ("192.168.x.x","192.168.x.x")
argvstr = sys.argv

#get_activeMaster()函数用于判断集群中active Master节点
def get_activeMaster():
    for stri in masterIP:
        url="http://"+stri+":60010/jmx?qry=Hadoop:service=HBase,name=Master,sub=Server"
        cont=urllib2.Request(url)
        try:
            resu=urllib2.urlopen(cont)
        except urllib2.HTTPError, e:
            return "error"
        except urllib2.URLError, e:
            return "error"
        else:
            val1=json.loads(resu.read())
            val2=val1['beans'][0]['tag.isActiveMaster']
            if val2 == 'true':
                return stri

#get_MasterServerInfo(activeMasterIP)获取HBase集群的相关信息
def get_MasterServerInfo(activeMasterIP):
	url="http://"+activeMasterIP+":60010/jmx?qry=Hadoop:service=HBase,name=Master,sub=Server"
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
		
#get_MasterAssignmentMangerInfo(activeMasterIP)获取HBase集群分配管理的相关信息
def get_MasterAssignmentMangerInfo(activeMasterIP):
	url="http://"+activeMasterIP+":60010/jmx?qry=Hadoop:service=HBase,name=Master,sub=AssignmentManger"
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
	
def get_avgBlockLocality(activeMasterIP):
	MasterServerInfoList = get_MasterServerInfo(activeMasterIP)
	LiveRSList = MasterServerInfoList['tag.liveRegionServers'].split(';')
	numRS = MasterServerInfoList['numRegionServers']
	totalBlockLocality = 0
	for RSHostName in LiveRSList:
		url = "http://"+RSHostName.split(',')[0]+":60030/jmx?qry=Hadoop:service=HBase,name=RegionServer,sub=Server"
		cont=urllib2.Request(url)
		try:
			resu=urllib2.urlopen(cont)
		except urllib2.HTTPError, e:
			totalBlockLocality += 0
		except urllib2.URLError, e:
			totalBlockLocality += 0
		else:
			val1=json.loads(resu.read())
			totalBlockLocality += val1['beans'][0]['percentFilesLocal']
	return totalBlockLocality/float(numRS)

	
activeMasterIP = get_activeMaster()
#判断get_activeMaster是否打开网址并返回结果
if activeMasterIP != 'error':
	#判断输入参数的长度，如果python脚本后面未接相应的参数则返回告知用法
	if len(argvstr) < 2:
		print 'usage: python hmaster_monitor_jmx.py numRegionServers|numDeadRegionServers|clusterRequests|ritCount|ritCountOverThreshold|ritOldestAge|avgBlockLocality'
		sys.exit()
	#判断输入的参数属于哪一类，则打印相应的结果
	if argvstr[1] in ('numRegionServers', 'numDeadRegionServers', 'clusterRequests'):
		MasterServerInfoList = get_MasterServerInfo(activeMasterIP)
		print MasterServerInfoList[argvstr[1]]
		sys.exit()	
	elif argvstr[1] in ('ritCount', 'ritCountOverThreshold', 'ritOldestAge'):
		MasterAssignmentMangerInfoList = get_MasterAssignmentMangerInfo(activeMasterIP)
		print MasterAssignmentMangerInfoList[argvstr[1]]
		sys.exit()
	elif argvstr[1] == 'avgBlockLocality':
		print get_avgBlockLocality(activeMasterIP)
		sys.exit()
	else:
		print 'usage: python hmaster_monitor_jmx.py numRegionServers|numDeadRegionServers|clusterRequests|ritCount|ritCountOverThreshold|ritOldestAge|avgBlockLocality'
		sys.exit()
else:
	print "The url cannot open!!"
