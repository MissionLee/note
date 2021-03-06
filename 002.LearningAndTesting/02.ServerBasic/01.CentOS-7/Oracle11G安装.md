# Oracle11G安装

```txt
CentOS 7.4
Oracle 11G
```


## 需要有图形化界面,参考同级目录下可视化界面安装文档

`其中 设置登陆用户的时候把 root 改为 oracle`

## 安装准备

- 修改操作系统核心参数,在Root用户下执行以下步骤：
  - 修改用户的SHELL的限制，修改/etc/security/limits.conf文件
  - 输入命令：vi /etc/security/limits.conf，按i键进入编辑模式，将下列内容加入该文件。
    ```bash
    oracle soft nproc 2047

    oracle hard nproc 16384

    oracle soft nofile 1024

    oracle hard nofile 65536
    ```

  - 编辑完成后按Esc键，输入“:wq”存盘退出
- 修改/etc/pam.d/login 文件，
  - 输入命令：vi /etc/pam.d/login，按i键进入编辑模式，将下列内容加入该文件。
    ```bash
    session required /lib/security/pam_limits.so
    session required pam_limits.so
    ```
  - 编辑完成后按Esc键，输入“:wq”存盘退出
- 修改linux内核，修改/etc/sysctl.conf文件
  - 输入命令: vi /etc/sysctl.conf ，按i键进入编辑模式，将下列内容加入该文件
    ```bash
    fs.file-max = 6815744

    fs.aio-max-nr = 1048576

    #kernel.shmall = 2097152
    # 因为报错,这个参数比攻略调整了
    kernel.shmall = 4194304

    #kernel.shmmax = 2147483648*2
    #同上
    kernel.shmmax = 4294967295

    kernel.shmmni = 4096

    kernel.sem = 250 32000 100 128

    net.ipv4.ip_local_port_range = 9000 65500

    net.core.rmem_default = 4194304

    net.core.rmem_max = 4194304

    net.core.wmem_default = 262144

    net.core.wmem_max = 1048576
    ```
  - 编辑完成后按Esc键，输入“:wq”存盘退出
- 要使 /etc/sysctl.conf 更改立即生效，执行以下命令。 输入：sysctl -p 显示如下：
    ```bash
    linux:~ # sysctl -p

    net.ipv4.icmp_echo_ignore_broadcasts = 1

    net.ipv4.conf.all.rp_filter = 1

    fs.file-max = 6815744

    fs.aio-max-nr = 1048576

    kernel.shmall = 2097152

    kernel.shmmax = 2147483648

    kernel.shmmni = 4096

    kernel.sem = 250 32000 100 128

    net.ipv4.ip_local_port_range = 9000 65500

    net.core.rmem_default = 4194304

    net.core.rmem_max = 4194304

    net.core.wmem_default = 262144

    net.core.wmem_max = 1048576
    ```
  - 具体内容还包含原有的参数,不过没有什么影响
- 编辑 /etc/profile 
  - 输入命令：vi /etc/profile，按i键进入编辑模式，将下列内容加入该文件。
    ```bash
    if [ $USER = "oracle" ]; then
    if [ $SHELL = "/bin/ksh" ]; then
    ulimit -p 16384
    ulimit -n 65536
    else
    ulimit -u 16384 -n 65536
    fi
    fi
    ```
  - 编辑完成后按Esc键，输入“:wq”存盘退出
- 创建相关用户和组，作为软件安装和支持组的拥有者。
  - groupadd oinstall
  - groupadd dba
  - useradd -g oinstall -g dba -m oracle
  - passwd oracle
  - 然后会让你输入密码，密码任意输入2次，但必须保持一致，回车确认。(密码:123456)
- 创建数据库软件目录和数据文件存放目录，目录的位置，根据自己的情况来定，注意磁盘空间即可，这里我把其放到oracle用户下
    ```bash
    mkdir /home/oracle/app

    mkdir /home/oracle/app/oracle

    mkdir /home/oracle/app/oradata

    mkdir /home/oracle/app/oracle/product

    chown -R oracle:oinstall /home/oracle/app
    ```
- 配置oracle用户的环境变量，
  - 首先，切换到新创建的oracle用户下,输入：su – oracle 
  - 然后直接在输入 ： vi .bash_profile,按i编辑 .bash_profile,进入编辑模式，增加以下内容：
    ```bash
    export ORACLE_BASE=/home/oracle/app

    export ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/dbhome_1

    export ORACLE_SID=orcl

    export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin

    export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
    ```
  -编辑完成后按Esc键，输入“:wq”存盘退出

## 安装过程

- 在图形界面以Oracle用户登陆。首先将下载的Oracle安装包复制到linux中
  - 解压准备好的oracle源文件;`如果没有unzip则使用yum安装`
    ```bash
    unzip linux.x64_11gR2_database_1of2.zip

    unzip linux.x64_11gR2_database_2of2.zip
    ```
  - 解压完成后 cd 进入其解压后的目录database
- `因为是在VNC远程登陆的环境,可能有些问题,.bash_profile没有被执行?,需要source一下,建议刚进入界面的时候就执行以下这个命令`
- 执行安装，输入命令：./runInstaller
- 输入邮箱[随意]
- 跳过更新
- Install database software only
- Single Instance database installation
- Engilsh
- Enterprise Edition
- 目录按照需求设置,本次安装目录为之前准备的目录(也就是默认目录)
- Database Administrator Group:`dba`
- Database Operator Group:`oinstall`
- 此处检查如要的rpm包
  - 例如提醒缺少 Package: gcc-4.1.0
  - yum list | gcc
  - 查看yum库里面有gcc 相关的什么,可以安装对应版本,或更高版本
  - 安装完成后 Check Again
  - yum 没有的包则需要自己下载
  - CentOS系统下载rpm包并手动安装
- 完成以上所有内容 开始自动安装即可
  - 安装过程中到某个阶段会弹出一个框,需要`root`用户运行两个脚本.
  - 脚本中遇到需要输入的情况`直接回车`

## 数据库建库

- 图形界面oracle用户中，新开启一个终端，直接输入命令dbca
  - 按需要配置参数
  - 注意`character set`会影响对汉字的支持

## 配置监听及本地网络服务

- 图形界面oracle用户中，新开启一个终端，输入命令netca 

## 启动测试oracle

```bash
sqlplus /nolog
conn /as sysdba
start up
```

显示

```bash
ORACLE instance started.

Total System Global Area 6664212480 bytes
Fixed Size    2265824 bytes
Variable Size 3539995936 bytes
Database Buffers 3103784960 bytes
Redo Buffers   18165760 bytes
Database mounted.
Database opened.
```

- 这样oracle服务器安装配置基本就完成了

## 报错集锦

- pdksh-* 这个rpm需要自己下载安装
- VNC图形化界面从root登陆,然后切换到oracle用户不能启动oracle的runInstall.sh,需要直接从oracle登陆图形化界面
- ORA-01078: failure in processing system parameters LRM-00109: could not open parameter file '/u01/app/oracle/product/12.1.0/db_1/dbs/initorcl.ora'
    `因为还没建库就尝试链接,所以报这个错`

## .bash_profile

```bash
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/.local/bin:$HOME/bin

export PATH

export ORACLE_BASE=/home/oracle/app/oracle
# oracle的自动脚本 这里的路径是 ORACLE_BASE=/home/oracle/app
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/dbhome_1
# oracle的自动脚本 这里的路径是 ORACLE_HOME=$ORACLE_BASE/oracle/product/11.2.0/dbhome_1
export ORACLE_SID=orcl

export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
export LANG="en_US.UTF-8"
```

## 中文界面出现乱码 

解决:使用英文界面(添加中文缺少的字体什么的麻烦,没必要)
临时处理:$ export LC_CTYPE=en_US 临时切换成英文
