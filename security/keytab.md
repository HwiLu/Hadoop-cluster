* [在kerberos的kdc上执行kadmin.local](#在kerberos的kdc上执行kadmin.local)
* [新增认证规则](#新增认证规则)

## 在kerberos的kdc上执行kadmin.local

```vim
kadmin.local
```
## 新增认证规则

在kadmin shell下运行以下命令
```vim
addprinc -randkey ${user}/${hostname}@HDPKDCRELM
```
## 创建keytab文件

```vim
xst -norandkey -k /${your_path}/${your_name}.keytab ${user}/${hostname}@HDPKDCRELM
```
## 退出

```vim
exit
```
## chmod
```vim
sudo chown ${user}：${group} ${your_name}.keytab
```

**kerberos操作** 

查看当前的认证用户: `klist`

查看keytab包含的principal：`klist -kt ${keytabname}`

认证用户:`kinit -kt /xx/xx/kerberos.keytab hdfs/hosts`

删除当前的认证的缓存: `kdestroy`

**Example**
```vim
addprinc -randkey username@HDPKDCRELM

xst -norandkey -k /path/username.keytab userename@HDPKDCRELM
 
kinit -kt username.keytab username
```
