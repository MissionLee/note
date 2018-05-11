# MySQL数据目录

linux下，MySQL默认的数据文档存储目录为/var/lib/mysql 假如要把MySQL目录移到/home/data下需要进行下面几步：

1、home目录下建立data目录
mkdir /home/data

2、把MySQL服务进程停掉：
service mysqld stop

3、把/var/lib/mysql整个目录移到/home/data
cp -afir /var/lib/mysql /home/data/mysql

这样就把MySQL的数据文档移动到了/home/data/mysql下
mv /var/lib/mysql /var/lib/mysql.bak  #重命名备份下

4、找到my.cnf配置文档假如/etc/目录下没有my.cnf配置文档，请到/usr/share/mysql/下找到*.cnf文档，拷贝其中一个到/etc/并改名为my.cnf)中。命令如下：
# cp /usr/share/mysql/my-medium.cnf /etc/my.cnf

5、编辑MySQL的配置文档/etc/my.cnf
为确保MySQL能够正常工作，需要指明mysql.sock文档的产生位置。修改socket=/var/lib/mysql/mysql.sock一行中等号右边的值为：/home/data/mysql/mysql.sock 。操作如下：

vi /etc/my.cnf　　　 (用vi工具编辑my.cnf文档，找到下列数据修改之)
#datadir=/var/lib/mysql
datadir=/home/data/mysql
#socket=/var/lib/mysql/mysql.sock
socket=/home/data/mysql/mysql.sock


6、修改MySQL启动脚本/etc/init.d/mysql

最后，需要修改MySQL启动脚本/etc/init.d/mysql，把其中datadir=/var/lib/mysql一行中，等号右边的路径改成您现在的实际存放路径：home/data/mysql。

vi /etc/init.d/mysqld

#get_mysql_option mysqld datadir "/var/lib/mysql"
get_mysql_option mysqld datadir "/home/data/mysql"

如果是CentOS还要改 /usr/bin/mysqld_safe 相关文件位置；

yum安装的mysql需要修改mysql_config中的内容：
vi /usr/lib64/mysql/mysql_config

#ldata='/var/lib/mysql'
ldata='/home/data/mysql/'

#socket='/var/lib/mysql/mysql.sock'
socket='/home/data/mysql/mysql.sock'

vi /usr/bin/mysqld_safe
#  DATADIR=/var/lib/mysql
  DATADIR=/home/data/mysql

7、重新启动MySQL服务
/etc/init.d/mysql start


报错记录：
160914 10:19:09 mysqld_safe Starting mysqld daemon with databases from /root/mysql_restore_test/mysql
/usr/libexec/mysqld: Table 'plugin' is read only
160914 10:19:09 [ERROR] Can't open the mysql.plugin table. Please run mysql_upgrade to create it.
160914 10:19:09  InnoDB: Initializing buffer pool, size = 8.0M
160914 10:19:09  InnoDB: Completed initialization of buffer pool
160914 10:19:09  InnoDB: Started; log sequence number 0 44233
160914 10:19:09 [ERROR] Can't start server : Bind on unix socket: Permission denied
160914 10:19:09 [ERROR] Do you already have another mysqld server running on socket: /root/mysql_restore_test/mysql/mysql.sock ?
160914 10:19:09 [ERROR] Aborting
160914 10:19:09  InnoDB: Starting shutdown...
160914 10:19:14  InnoDB: Shutdown completed; log sequence number 0 44233
160914 10:19:14 [Note] /usr/libexec/mysqld: Shutdown complete
160914 10:19:14 mysqld_safe mysqld from pid file /var/run/mysqld/mysqld.pid ended

解决方法：
应该是权限问题，将chmod 777 -R /home 修改为777就可以了,这样可能权限有些大，可以将数据目录建立到单独的一个目录中之后设置为777

参考：
http://www.osyunwei.com/archives/566.html
https://my.oschina.net/tinglanrmb32/blog/496236?p=1