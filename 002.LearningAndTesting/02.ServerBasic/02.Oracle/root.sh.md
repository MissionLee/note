# 脚本

## root.sh [这个是网上找的,参数里面的目录路径是不同的]

如果你执行下以下命令基本上会在Oracle软件目录下会发现两个root.sh的脚本

```txt
[oracle@rh64 Templates]$ find /u01/ -name root.sh |xargs ls -ltr
-rwxrwx--- 1 oracle oinstall  10 May 14 02:37 /u01/app/db11g/product/11.2.0/dbhome_1/inventory/Templates/root.sh
-rwxr-x--- 1 oracle oinstall 512 May 14 02:47 /u01/app/db11g/product/11.2.0/dbhome_1/root.sh
```

第一个脚本里面没啥东西，我们今天主要来研究下第二个root.sh是干啥用的，也就是我们安装软件后需要运行的这个root.sh的主要作用。

[oracle@rh64 ~]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/root.sh

```bash
#!/bin/sh
. /u01/app/db11g/product/11.2.0/dbhome_1/install/utl/rootmacro.sh "$@"
. /u01/app/db11g/product/11.2.0/dbhome_1/install/utl/rootinstall.sh
/u01/app/db11g/product/11.2.0/dbhome_1/install/unix/rootadd.sh


#
# Root Actions related to network
#
/u01/app/db11g/product/11.2.0/dbhome_1/network/install/sqlnet/setowner.sh 


#
# Invoke standalone rootadd_rdbms.sh
#
/u01/app/db11g/product/11.2.0/dbhome_1/rdbms/install/rootadd_rdbms.sh


/u01/app/db11g/product/11.2.0/dbhome_1/rdbms/install/rootadd_filemap.sh 
```

[oracle@rh64 ~]$
可以看到上面脚本里面包含了6个小的脚本，我们一一来分析下看看这个root.sh里面的脚本都是干啥的。


1.第一个脚本
[oracle@rh64 ~]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/install/utl/rootmacro.sh

```bash
#!/bin/sh
#
# $Id: rootmacro.sbs /st_buildtools_11.2.0/2 2012/11/06 02:43:45 rmallego Exp $
# Copyright (c) 2004, 2012, Oracle and/or its affiliates. All rights reserved. 
#
# root.sh
#
# This script is intended to be run by root.  The script contains
# all the product installation actions that require root privileges.
#
# IMPORTANT NOTES - READ BEFORE RUNNING SCRIPT
#
# (1) ORACLE_HOME and ORACLE_OWNER can be defined in user's
#     environment to override default values defined in this script.
#
# (2) The environment variable LBIN (defined within the script) points to
#     the default local bin area.  Three executables will be moved there as
#     part of this script execution.
#
# (3) Define (if desired) LOG variable to name of log file.
#
-------->>>上面明确说明运行脚本之前ORACLE_HOME，ORACLE_OWNER一定要设置
AWK=/bin/awk
CAT=/bin/cat
CHGRP=/bin/chgrp
CHOWN=/bin/chown
CHMOD=/bin/chmod
CP=/bin/cp
DIFF=/usr/bin/diff
ECHO=echo
GREP=/bin/grep
LBIN=/usr/local/bin
MKDIR=/bin/mkdir
ORATABLOC=/etc
ORATAB=${ORATABLOC}/oratab
RM=/bin/rm
SED=/bin/sed
UNAME=/bin/uname
DATE=/bin/date
TEE=/usr/bin/tee
TMPORATB=/var/tmp/oratab$$


if [ `$UNAME` = "SunOS" ]
then
      GREP=/usr/xpg4/bin/grep
fi 


# Variable based on installation
OUI_SILENT=false


#
# Default values set by Installer
#


ORACLE_HOME=/u01/app/db11g/product/11.2.0/dbhome_1
ORACLE_OWNER=oracle
OSDBA_GROUP=oinstall
MAKE=/usr/bin/make


#
# conditional code execution starts. This set of code is invoked exactly once
# regardless of number of scripts that source rootmacro.sh
# 这是个创建日志LOG名称的脚本,要求不管这个脚本执行了多少次,只有一个日志文件
if [ "x$WAS_ROOTMACRO_CALL_MADE" = "x" ]; then
  WAS_ROOTMACRO_CALL_MADE=YES ; export WAS_ROOTMACRO_CALL_MADE
  LOG=${ORACLE_HOME}/install/root_`$UNAME -n`_`$DATE +%F_%H-%M-%S`.log ; export LOG
# 如果 "x$.." = "x" 也就是 $.. 不存在
# 那么把这个参数复制为YES,并且 export


#
# Parse argument
#
  while [ $# -gt 0 ]
  # $# 代表传递给脚本或函数的参数个数 正常情况下是 没有的 因为上级在调用这个函数的时候
  #                                                   把自己的参数打包过来,但是上级
  #                                                   自己没有参数
  do
    case $1 in
      -silent)  SILENT_F=1;;         # silent is set to true 
      # 如果传入参数为 slient
      -crshome) shift; CRSHOME=$1; export CRSHOME;;  # CRSHOME is set
      # 如果传入参数为crshome 那么赋值
      -bindir) shift; LBIN=$1; export LBIN;;
    esac;
    shift
  done


#
# If LOG is not set, then send output to /dev/null
#


  if [ "x${LOG}" = "x" -o "${LOG}" = "" ];then
    LOG=/dev/null
  else
    $CP $LOG ${LOG}0 2>/dev/null
    $ECHO "" > $LOG
  fi


# 判断是否静默安装
# Silent variable is set based on :
# if OUI_SILENT is true or if SILENT_F is 1
# OUI_SILENT 在上麦呢被设置成 false   -o就是或者
  if [ "${OUI_SILENT}" = "true" -o "$SILENT_F" ]
  then
    SILENT=1
  else
    SILENT=0
  fi

# 如果是静默安装
  if [ $SILENT -eq 1 ]
  then
    $ECHO "Check $LOG for the output of root script"
    exec > $LOG 2>&1
    # exec 执行?, $LOG  这边涉及 shell重定向?
  else
    mkfifo $LOG.pipe
    # 建立一个管道
    tee < $LOG.pipe $LOG &
    exec &> $LOG.pipe
    rm $LOG.pipe
  fi
#
# check for valid crshome
#


  if [ "$CRSHOME" -a ! -d "$CRSHOME" ]; then
  #             -a 与 / !反向逻辑  / -d 是否是目录
  # 如果CRSHOME存在 并且 不是一个目录
    $ECHO "ERROR: CRS home $CRSHOME is not a valid directory." | $TEE -a $LOG
  exit 1
  fi
----->>>检查是否设置crshome
#
# Determine how to suppress newline with $ECHO command.
#


  case ${N}$C in
  "") if $ECHO "\c"| $GREP c >/dev/null 2>&1;then
        N='-n'
      else
        C='\c'
      fi;;
  esac


# 
# check for zero UID
#


  RUID=`/usr/bin/id|$AWK -F\( '{print $1}'|$AWK -F= '{print $2}'`
  if [ $RUID -ne 0 ];then
    $ECHO "You must be logged in as user with UID as zero (e.g. root user) to run root configuration script."| $TEE -a $LOG
    $ECHO "Log in as user with UID as zero (e.g. root user) and restart root configuration script execution."| $TEE -a $LOG
    exit 1
  fi
----->>>检查是否以root用户执行操作
#
# Display abort message on interrupt.
#


  trap '$ECHO "Oracle root script execution aborted!"| $TEE -a $LOG;exit' 1 2 3 15
  # trap 用来捕捉脚本执行时候系统给的信号 1:挂起 2:终端 3:退出 15:软件结束

#
# Check for $LOG file existence and if it exists, change the ownership to oracle_owner:oracle_owner_group and permissions to 600
#


        if [ -f $LOG ];then
          $CHOWN $ORACLE_OWNER:$OSDBA_GROUP $LOG
          $CHMOD 600 $LOG
        fi
fi
#conditional code execution ends
```

------>>>>修改权限，修改宿主，拥有者，日志权限为600
可以看到上述脚本主要是检查是否为root用户，修改宿主，并且需要在环境变量有相应的ORACLE_HOME，ORACLE_OWNER等
[oracle@rh64 ~]$ 
第二个脚本
[oracle@rh64 ~]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/install/utl/rootinstall.sh

```bash
# 上个脚本 中给ECHO=echo 应该是参数可以共享
$ECHO "Performing root user operation for Oracle 11g "

$ECHO ""
$ECHO "The following environment variables are set as:"
$ECHO "    ORACLE_OWNER= $ORACLE_OWNER"
$ECHO "    ORACLE_HOME=  $ORACLE_HOME"


#
# Get name of local bin directory
#


saveLBIN=$LBIN
retry='r'
while [ "$retry" = "r" ]
do
  if [ $SILENT -eq 0 ]
  then
    LBIN=$saveLBIN
    $ECHO ""
    $ECHO $N "Enter the full pathname of the local bin directory: $C"
    DEFLT=${LBIN}; . $ORACLE_HOME/install/utl/read.sh; LBIN=$RDVAR
  fi


  if [ ! -d $LBIN ];then
    $ECHO "Creating ${LBIN} directory..."
    $MKDIR -p ${LBIN} 2>&1
    $CHMOD 755 ${LBIN} 2>&1
  fi
  if [ ! -w $LBIN ]
  then
    if [ $SILENT -eq 0 ]
    then
      $ECHO ""
      $ECHO $N "$LBIN is read only.  Continue without copy (y/n) or retry (r)? $C"
      DEFLT='y' ; . $ORACLE_HOME/install/utl/read.sh ; retry=$RDVAR
    else
      retry='y'  # continue without copy
    fi
  else
    retry='y'
  fi
done
if [ "$retry" = "n" ] ; then
  $ECHO "Warning: Script terminated by user."
  exit 1
fi


#
# Move files to LBIN, and set permissions
#


DBHOME=$ORACLE_HOME/bin/dbhome
ORAENV=$ORACLE_HOME/bin/oraenv
CORAENV=$ORACLE_HOME/bin/coraenv
FILES="$DBHOME $ORAENV $CORAENV"
#----->>>这里就是移动这几个文件，然后设置相应的权限。上面三个环境变量比较熟悉，我们需要升级备份的时候通常需要备份这些东西，
#其实这个东西可以从$ORACLE_HOME/bin下拷贝过到/usr/local/bin，所以屌丝们以后可以不用担心了～～～
if [ -w $LBIN ]
then
  for f in $FILES ; do
    if [ -f $f ] ; then
      $CHMOD 755 $f  2>&1 2>> $LOG
      short_f=`$ECHO $f | $SED 's;.*/;;'`
      lbin_f=$LBIN/$short_f
      if [ -f $lbin_f -a $SILENT -eq 0 ] ; then
        DIFF_STATUS=`$DIFF $f $lbin_f`
        if [ $? -ne 0 ] ; then
          # The contents of $lbin_f and $f are different (User updated $lbin_f)
          # Prompt user before overwriting $lbin_f.
          $ECHO $n "The file \"$short_f\" already exists in $LBIN.  Overwrite it? (y/n) $C"
          DEFLT='n'; . $ORACLE_HOME/install/utl/read.sh; OVERWRITE=$RDVAR
        else
          # The contents of $lbin_f and $f are identical. Don't overwrite.
          $ECHO "The contents of \"$short_f\" have not changed. No need to overwrite."
          OVERWRITE='n';        
        fi
      else
        OVERWRITE='y';
      fi
      if [ "$OVERWRITE" = "y" -o "$OVERWRITE" = "Y" ] ; then
        $CP $f $LBIN  2>&1 2>>  $LOG
        $CHMOD 755 $lbin_f  2>&1 2>> $LOG
        $CHOWN $ORACLE_OWNER $LBIN/`$ECHO $f | $AWK -F/ '{print $NF}'` 2>&1 2>> $LOG
        $ECHO "   Copying $short_f to $LBIN ..."
      fi
    fi
  done
#------>>>注意这几个权限为755,下面是对比下$ORACLE_HOME和/usr/local/bin下几个文件权限和宿主的区别
```

[oracle@rh64 bin]$ ls -ltr dbhome
-rwxr-xr-x 1 oracle oinstall 2415 Jan  1  2000 dbhome
[oracle@rh64 bin]$ ls -tlr coraenv
-rwxr-xr-x 1 oracle oinstall 5778 Jan  1  2000 coraenv
[oracle@rh64 bin]$ ls -ltr oraenv
-rwxr-xr-x 1 oracle oinstall 6183 Jan  1  2000 oraenv


[root@rh64 bin]# ls -ltr dbhome
-rwxr-xr-x 1 oracle root 2415 Oct 30  2013 dbhome
[root@rh64 bin]# ls -ltr oraenv
-rwxr-xr-x 1 oracle root 6183 Oct 30  2013 oraenv
[root@rh64 bin]# ls -ltr coraenv
-rwxr-xr-x 1 oracle root 5778 Oct 30  2013 coraenv


------->>>>看到了吗？权限都是755，但是/usr/local/bin的拥有者为`oracle:root`，如果不慎丢失需要手工拷过来的时候记得需要改成755，oracle:root

```bash
#还是这个脚本
else
  $ECHO ""
  $ECHO "Warning: $LBIN is read only. No files will be copied."
fi
$ECHO ""


#
# Make sure an oratab file exists on this system
#


# Variable to determine whether oratab is new or not; default is true
NEW="true"


if [ ! -s ${ORATAB} ];then
  # -s => 文件大小非 0 时为真
  $ECHO "" 
  $ECHO "Creating ${ORATAB} file..."
  if [ ! -d ${ORATABLOC} ];then
    $MKDIR -p ${ORATABLOC}
  fi


  $CAT <<!>> ${ORATAB}
#






# This file is used by ORACLE utilities.  It is created by root.sh
# and updated by either Database Configuration Assistant while creating
# a database or ASM Configuration Assistant while creating ASM instance.


# A colon, ':', is used as the field terminator.  A new line terminates
# the entry.  Lines beginning with a pound sign, '#', are comments.
#
# Entries are of the form:
#   \$ORACLE_SID:\$ORACLE_HOME:<N|Y>:
#
# The first and second fields are the system identifier and home
# directory of the database respectively.  The third filed indicates
# to the dbstart utility that the database should , "Y", or should not,
# "N", be brought up at system boot time.
#
# Multiple entries with the same \$ORACLE_SID are not allowed.
#
#
!


else
# Oratab file exists; this is not a new installation on this system.
# We check if temporary install/oratab exists, and then check if the entry
# in temporary install/oratab has been added to the oratab file.
# In case of patchset this is usually the case, and we don't want to reappend
# the same entry to oratab again.
  if [ -f $ORACLE_HOME/install/oratab ]
  then
    TMP_ENTRY=`$GREP "${ORACLE_HOME}" $ORACLE_HOME/install/oratab`


    FOUND=`$GREP "${TMP_ENTRY}" ${ORATAB}`
    if [ -n "${FOUND}" ]
    then
      NEW="false"
    fi
  fi
fi
----->>>>注意，我们所有root.sh脚本执行的日志都会在$ORACLE_HOME/install/下面有的，以便我们进行错误定位
$CHOWN $ORACLE_OWNER:$OSDBA_GROUP ${ORATAB}
$CHMOD 664 ${ORATAB}
----->>>/etc/oratab的权限为664
#
# If there is an old entry with no sid and same oracle home,
# that entry will be marked as a comment.
#


FOUND_OLD=`$GREP "^*:${ORACLE_HOME}:" ${ORATAB}`
if [ -n "${FOUND_OLD}" ];then
  $SED -e "s?^*:$ORACLE_HOME:?# *:$ORACLE_HOME:?" $ORATAB > $TMPORATB
  $CAT $TMPORATB > $ORATAB
  $RM -f $TMPORATB 2>/dev/null
fi




$ECHO "Entries will be added to the ${ORATAB} file as needed by"
$ECHO "Database Configuration Assistant when a database is created"


#
# Append the dbca temporary oratab entry to oratab
# In the case of ASM and RAC install, oratab is not yet created when root.sh
# is run, so we need to check for its existence before attempting to append it.
#
if [ -f $ORACLE_HOME/install/oratab -a $NEW = "true" ]
then
  $CAT $ORACLE_HOME/install/oratab >> $ORATAB
fi


$ECHO "Finished running generic part of root script."
$ECHO "Now product-specific root actions will be performed."


第三个脚本
[oracle@rh64 ~]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/install/unix/rootadd.sh
#!/bin/sh
#!/usr/bin/sh
ORACLE_HOME=/u01/app/db11g/product/11.2.0/dbhome_1
. $ORACLE_HOME/install/utl/rootmacro.sh


# the following commands need to run as root after installing 
# the OEM Daemon


AWK=/usr/bin/awk
CAT=/usr/bin/cat
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
CHMODR="/usr/bin/chmod -R"
CP=/usr/bin/cp
ECHO=/usr/bin/echo
MKDIR=/usr/bin/mkdir
TEE=/usr/bin/tee
RM=/bin/rm
MV=/bin/mv
GREP=/usr/bin/grep
CUT=/bin/cut
SED=/usr/bin/sed


PLATFORM=`uname`


if [ ${PLATFORM} = "Linux" ] ; then
  CAT=/bin/cat
  CHOWN=/bin/chown
  CHMOD=/bin/chmod
  CHMODR="/bin/chmod -R"
  CP=/bin/cp
  ECHO=/bin/echo
  MKDIR=/bin/mkdir
  GREP=/bin/grep
  if [ ! -f $CUT ] ; then
     CUT=/usr/bin/cut
  fi
  SED=/bin/sed
fi


if [ ${PLATFORM} = "SunOS" ] ; then
   GREP=/usr/xpg4/bin/grep
fi


if [ ${PLATFORM} = "Darwin" ] ; then 
  CAT=/bin/cat 
  CHOWN="/usr/sbin/chown" 
  CHMOD="/bin/chmod" 
  CHMODR="/bin/chmod -R" 
  CP=/bin/cp 
  ECHO=/bin/echo 
  MKDIR=/bin/mkdir 
  CUT=/usr/bin/cut 
fi 




# change owner and permissions of the remote operations executible
if [ -f  ${ORACLE_HOME}/bin/nmo.0 ];
then
  $RM -f ${ORACLE_HOME}/bin/nmo
  $CP -p ${ORACLE_HOME}/bin/nmo.0 ${ORACLE_HOME}/bin/nmo
fi
$CHOWN root $ORACLE_HOME/bin/nmo
$CHMOD 4710 $ORACLE_HOME/bin/nmo


# change owner and permissions of the program that does memory computations
if [ -f  ${ORACLE_HOME}/bin/nmb.0 ];
then
  $RM -f ${ORACLE_HOME}/bin/nmb
  $CP -p ${ORACLE_HOME}/bin/nmb.0 ${ORACLE_HOME}/bin/nmb
fi
$CHOWN root $ORACLE_HOME/bin/nmb
$CHMOD 4710 $ORACLE_HOME/bin/nmb


# change owner and permissions of the storage metrics executible
if [ -f  ${ORACLE_HOME}/bin/nmhs.0 ];
then
  $RM -f ${ORACLE_HOME}/bin/nmhs
  $CP -p ${ORACLE_HOME}/bin/nmhs.0 ${ORACLE_HOME}/bin/nmhs
fi
$CHOWN root $ORACLE_HOME/bin/nmhs
$CHMOD 4710 $ORACLE_HOME/bin/nmhs


#change permissions on emdctl and emagent
$CHMOD 700 $ORACLE_HOME/bin/emagent
$CHMOD 700 $ORACLE_HOME/bin/emdctl


# change permissions so they are accessible by users from groups
# other than the agent user group.
$CHMOD 755 $ORACLE_HOME/bin
$CHMODR a+rX $ORACLE_HOME/lib
$CHMODR a+rX $ORACLE_HOME/perl
#$CHMODR a+rX $ORACLE_HOME/sysman/admin/scripts
$CHMODR a+rX $ORACLE_HOME/jdk
$CHMOD 755 $ORACLE_HOME/bin/nmocat


#
# Following changes to system executables are needed for getting
# host inventory metrics on HP-UX
#
if [ ${PLATFORM} = "HP-UX" ] ; then
  $CHMOD 555 /usr/sbin/swapinfo
  #$CHMOD +r /dev/rdsk/*
fi


$ECHO "Finished product-specific root actions."| $TEE -a $LOG


[oracle@rh64 ~]$


第四个脚本：
[oracle@rh64 ~]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/network/install/sqlnet/setowner.sh 
#!/bin/sh
ORACLE_HOME=/u01/app/db11g/product/11.2.0/dbhome_1
. $ORACLE_HOME/install/utl/rootmacro.sh
:
if [ ! -d /var/tmp/.oracle ]
then
  $MKDIR -p /var/tmp/.oracle;
fi


$CHMOD 01777 /var/tmp/.oracle
$CHOWN root  /var/tmp/.oracle


if [ ! -d /tmp/.oracle ]
then
  $MKDIR -p /tmp/.oracle;
fi


$CHMOD 01777 /tmp/.oracle
$CHOWN root  /tmp/.oracle
------->>>这个地方要注意了，这个临时文件的.oracle，有点意思
第五个脚本：
[oracle@rh64 ~]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/rdbms/install/rootadd_rdbms.sh
#!/bin/sh


ORACLE_HOME=/u01/app/db11g/product/11.2.0/dbhome_1
CHOWN=/bin/chown
CHMOD=/bin/chmod
RM=/bin/rm
AWK=/bin/awk
ECHO=/bin/echo
CP=/bin/cp


#
# check for zero UID
#
RUID=`/usr/bin/id|$AWK -F\( '{print $1}'|$AWK -F= '{print $2}'`
if [ $RUID -ne 0 ];then
  $ECHO "You must be logged in as user with UID as zero (e.g. root user) to run root.sh."
  $ECHO "Log in as user with UID as zero (e.g. root user) and restart root.sh execution."
  exit 1
fi


if [ -f $ORACLE_HOME/bin/oradism ]; then
        $CHOWN root $ORACLE_HOME/bin/oradism
        $CHMOD 4750 $ORACLE_HOME/bin/oradism
fi
# remove backup copy
if [ -f $ORACLE_HOME/bin/oradism.old ]; then
        $RM -f $ORACLE_HOME/bin/oradism.old
fi
# copy extjobo to extjob if it doesn't exist
if [ ! -f $ORACLE_HOME/bin/extjob -a -f $ORACLE_HOME/bin/extjobo ]; then
        $CP -p $ORACLE_HOME/bin/extjobo $ORACLE_HOME/bin/extjob
fi
if [ -f $ORACLE_HOME/bin/extjob ]; then
        $CHOWN root $ORACLE_HOME/bin/extjob
        $CHMOD 4750 $ORACLE_HOME/bin/extjob
fi
if [ -f $ORACLE_HOME/rdbms/admin/externaljob.ora ]; then
        $CHOWN root $ORACLE_HOME/rdbms/admin/externaljob.ora
        $CHMOD 640 $ORACLE_HOME/rdbms/admin/externaljob.ora
fi
# properly setup job scheduler switch user executable
if [ -f $ORACLE_HOME/bin/jssu ]; then
        $CHOWN root $ORACLE_HOME/bin/jssu
        $CHMOD 4750 $ORACLE_HOME/bin/jssu
fi
# remove backup copy
if [ -f $ORACLE_HOME/rdbms/admin/externaljob.ora.orig ]; then
        $RM -f $ORACLE_HOME/rdbms/admin/externaljob.ora.orig
fi


# tighten permissions on $ORACLE_HOME/scheduler/wallet
$CHMOD 0700 $ORACLE_HOME/scheduler/wallet


# Add a large number to file-max kernel param for memory_target on Linux
OSINFO=`/bin/uname -a`
SYSCTL=/sbin/sysctl
FSMAXFILE=/proc/sys/fs/file-max
FSMVAL=""
SYSCTLCONF=/etc/sysctl.conf
AWK=/bin/awk
SED=/bin/sed
case $OSINFO in
Linux*)
 # Read value from /etc/sysctl.conf
 if [ -w $SYSCTLCONF ]; then
  while read line
  do
  case ${line} in
    fs.file-max*)
      # Value exists in /etc/sysctl.conf. Strip space/tabs and store its value.
      FSMVAL=`$ECHO ${line} | $SED 's/fs.file-max\s*=\s*//g'`
    ;;
   esac
  done < $SYSCTLCONF
 fi
 
 # Update the filemax for current usage
 # bug 9797468: change value from 6.4M to 6815744 (due to validated configs)
 if [ -z $FSMVAL ] || [ $FSMVAL -lt 6815744 ]; then
   # Value is less than our 6815744, update it
   $SYSCTL -q -w fs.file-max=6815744
   if [ -f $FSMAXFILE ]; then
    $ECHO 6815744 > $FSMAXFILE
   fi
 fi
------->>>>这里是修改filemax的，需要注意  
 # Update the filemax across machine reboots by persisting to /etc/sysctl.conf
 if [ $FSMVAL ]; then
    # Value exists, but less than our requirement. So overwrite it.
    if [ $FSMVAL -lt 6815744 ]; then
     # Persist it to /etc/sysctl.conf using sed
     # Take into account tabs/spaces - bug 9462640
     if [ -f $SED ]; then
        $SED -i.bak -e "s/^fs.file-max\s*=.*/fs.file-max = 6815744/" $SYSCTLCONF 
     fi
    fi
 else
    # Value does not exist, so append our required value.
    FSMVAL="fs.file-max = 6815744"
    $ECHO $FSMVAL >> $SYSCTLCONF
 fi


;;
esac


第六个脚本：
[oracle@rh64 tmp]$ cat /u01/app/db11g/product/11.2.0/dbhome_1/rdbms/install/rootadd_filemap.sh 
#!/bin/sh
# The filemap binaries need to exist under /opt/ORCLfmap/prot1_X where
# X is either 32 for 32-bit Solaris machines and 64 for 64-bit Solaris
# machines.
#
# Other UNIX platforms will have to do something similar  
ORACLE_HOME=/u01/app/db11g/product/11.2.0/dbhome_1
. $ORACLE_HOME/install/utl/rootmacro.sh


ORCLFMAPLOC=/opt/ORCLfmap
FILEMAPLOC=$ORCLFMAPLOC/prot1_64 # needs to be prot1_32 for 32 bit platforms


if [ ! -d $ORCLFMAPLOC ];then
$MKDIR $ORCLFMAPLOC
fi
if [ ! -d $FILEMAPLOC ];then
$MKDIR $FILEMAPLOC
fi
if [ ! -d $FILEMAPLOC/bin ];then
$MKDIR $FILEMAPLOC/bin
fi
if [ ! -d $FILEMAPLOC/etc ];then
$MKDIR $FILEMAPLOC/etc
fi
if [ ! -d $FILEMAPLOC/log ];then
$MKDIR $FILEMAPLOC/log
fi


if [ ! -z "$OSDBA_GROUP" ];then
  FMPUTL_GROUP=$OSDBA_GROUP
else
  FMPUTL_GROUP=root
fi


$CP $ORACLE_HOME/bin/fmputl $FILEMAPLOC/bin
$CP $ORACLE_HOME/bin/fmputlhp $FILEMAPLOC/bin
$CHMOD 550 $FILEMAPLOC/bin/fmputl
$CHGRP $FMPUTL_GROUP $FILEMAPLOC/bin/fmputlhp 
$CHMOD 4550 $FILEMAPLOC/bin/fmputlhp
if [ ! -f $FILEMAPLOC/etc/filemap.ora ];then
$CP $ORACLE_HOME/rdbms/install/filemap.ora $FILEMAPLOC/etc
fi


我把/usr/local/bin/下的东西删除后，对数据库启动关闭没啥影响，





看过一遍脚本后，就明白了root.sh是用来干嘛的，希望大家有时间多看看oracle自带的东西，一定会有所收获了。
oracle是高度模块化的东西，什么几乎都可以重建。就算是备份恢复，当你明白了原理，在面对意外恢复时，你也会想出metalink
想不到的好方法，一切在自己的思维了，跳出了固定模式的思维，你才会进步。