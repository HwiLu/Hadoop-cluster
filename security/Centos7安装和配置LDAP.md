原文来自于：[Step by Step OpenLDAP Server Configuration on CentOS 7 / RHEL 7](https://www.itzgeek.com/how-tos/linux/centos-how-tos/step-step-openldap-server-configuration-centos-7-rhel-7.html)

# 环境

假设有这么两台主机，Ldap server 与client为1对多的关系。

| Hostname        | Ip            | OS      | purpose     |
| --------------- | ------------- | ------- | ----------- |
| node01.site.com | 192.168.1.100 | Centos7 | Ldap server |
| node02.site.com | 192.168.1.101 | Centos7 | Ldap client |



#  预置条件

1. 确保所有主机都可以访问
2. 确保/etc/hosts已配置主机的ip对应关系

```vim
192.168.1.100	node01.site.com	node01
192.168.1.101	node02.site.com	node02
```



# 安装openLDAP

在Ldap server节点安装一下安装包：

```bash
yum -y install openldap compat-openldap openldap-clients openldap-servers openldap-servers-sql openldap-devel
```

启动ldap服务并设置开机自启动

```
systemctl start slapd
systemctl enable slapd
```

严重ldap服务是否启动

```bash
netstat -anp | grep 389
```

输出如下：

```sh
tcp        0      0 0.0.0.0:389             0.0.0.0:*               LISTEN      1520/slapd          
tcp6       0      0 :::389                  :::*                    LISTEN      1520/slapd
```

# 设置ldap admin的密码

使用以下命令为ldap admin设置密码

```sh
slappasswd -h {SSHA} -s "密码"
```

以上命令会生成一个你输入密码的hash串，该密码将在之后的配置中使用到，所以需要记住。

**Output:**

```shell
{SSHA}9/l2ELwbWtBTip6h35bD6SQzvZMG/pMc
```

# 配置ldap server

openLDAP server的配置在/etc/openldap/sldap.d/目录下，需要将`/etc/openldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif` 中以下配置进行修改

```powershell
olcSuffix – Database Suffix, it is the domain name for which the LDAP server provides the information. In simple words, it should be changed to your domain
name.

olcRootDN – Root Distinguished Name (DN) entry for the user who has the unrestricted access to perform all administration activities on LDAP, like a root user.

olcRootPW – LDAP admin password for the above RootDN.
```

但是不推荐直接对该文件进行修改，所以新建一个.ldif文件。

```
vi db.ldif
```

插入以下内容：

```sh 
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=site,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=ldapadm,dc=site,dc=com

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: {SSHA}9/l2ELwbWtBTip6h35bD6SQzvZMG/pMc	
```

将该配置导入到ldap server内

```
ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif
```

