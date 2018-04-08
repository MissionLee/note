# 脚本

重新发现Oracle太美之orainstRoot.sh
我们安装数据库软件的时候，都要会执行orainstRoot.sh,今天就来仔细看看这个脚本是来干嘛的。
平台为RedHat 6.4 x64位的，数据库版本为11.2.0.4.2
下面是脚本的内容
[oracle@rh64 ~]$ cd /u01/app/oraInventory/
[oracle@rh64 oraInventory]$ ls -ltr
total 24
drwxrwx--- 2 oracle oinstall 4096 Oct 30  2013 ContentsXML
-rwxrwx--- 1 oracle oinstall 1620 Oct 30  2013 orainstRoot.sh
-rw-rw---- 1 oracle oinstall   56 Oct 30  2013 oraInst.loc
drwxrwx--- 3 oracle oinstall 4096 May 14 02:47 backup
drwxrwx--- 2 oracle oinstall 4096 May 14 03:16 logs
drwxrwx--- 2 oracle oinstall 4096 May 15 00:27 oui
[oracle@rh64 oraInventory]$ cat orainstRoot.sh 
#!/bin/sh
AWK=/bin/awk
CHMOD=/bin/chmod
CHGRP=/bin/chgrp
CP=/bin/cp
ECHO=/bin/echo
MKDIR=/bin/mkdir
RUID=`/usr/bin/id|$AWK -F\( '{print $1}'|$AWK -F\= '{print $2}'`
if [ ${RUID} != "0" ];then
   $ECHO "This script must be executed as root"
   exit 1
fi
----->>>这里会首先校验权限,看看是不是以root用户执行的，如果不是就退出
if [ -d "/etc" ]; then
$CHMOD 755 /etc;
else
$MKDIR -p /etc;
fi
if [ -f "/u01/app/oraInventory/oraInst.loc" ]; then
$CP /u01/app/oraInventory/oraInst.loc /etc/oraInst.loc;
$CHMOD 644 /etc/oraInst.loc
else
INVPTR=/etc/oraInst.loc
INVLOC=/u01/app/oraInventory
GRP=oinstall
PTRDIR="`dirname $INVPTR`";
----->>>如果Central Inventory存在的话，即上面的oraInst.loc，就会复制一份到/etc/下面，作为Central Inventory Pointer File,从名字上就能知道，
这个是Central Inventory的Pointed File
# Create the software inventory location pointer file
if [ ! -d "$PTRDIR" ]; then
 $MKDIR -p $PTRDIR;
fi
$ECHO "Creating the Oracle inventory pointer file ($INVPTR)";
$ECHO    inventory_loc=$INVLOC > $INVPTR
$ECHO    inst_group=$GRP >> $INVPTR
chmod 644 $INVPTR
# Create the inventory directory if it doesn't exist
if [ ! -d "$INVLOC" ];then
 $ECHO "Creating the Oracle inventory directory ($INVLOC)";
 $MKDIR -p $INVLOC;
fi
fi
----->>>>如果不存在，就会一一创建，并且需要修改权限
$ECHO "Changing permissions of /u01/app/oraInventory.
Adding read,write permissions for group.
Removing read,write,execute permissions for world.
";
$CHMOD -R g+rw,o-rwx /u01/app/oraInventory;
----->>>>对于这个目录,组要有读写权限，宿主要有读写执行的权限
if [ $? != 0 ]; then
 $ECHO "OUI-35086:WARNING: chmod of /u01/app/oraInventory
Adding read,write permissions for group.
,Removing read,write,execute permissions for world.
 failed!";
fi
$ECHO "Changing groupname of /u01/app/oraInventory to oinstall.";
$CHGRP -R oinstall /u01/app/oraInventory;
----->>>注意这里的组是oinstall
if [ $? != 0 ]; then
 $ECHO "OUI-10057:WARNING: chgrp of /u01/app/oraInventory to oinstall failed!";
fi
$ECHO "The execution of the script is complete."
[oracle@rh64 oraInventory]$ 


从上面看到，这个脚本无非就是创建oraInst.loc,然后给这个产品目录修改权限，注意组权限是读写，宿主为777，oraInventory的组要是oinstall
其他也没有多少东西。知道干嘛的就行了，学会了就没啥了，哪里报错哪里重新检查就OK了。