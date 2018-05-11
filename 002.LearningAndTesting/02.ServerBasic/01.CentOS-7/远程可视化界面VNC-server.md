# VNC server

本身是在最小化安装的系统上CentOS7.4,所以少了很多内容

- yum groupinstall "X Window System"

- yum install gnome-classic-session gnome-terminal nautilus-open-terminal control-center liberation-mono-fonts

- yum install tigervnc-server -y

## 配置 VNC

原先的配置文件位置在 /etc/sysconfig/vncservcers
打开这个文件看到
`# THIS FILE HAS BEEN REPLACED BY /lib/systemd/system/vncserver@.service`

`注意!!!原先的命令比如 vncserver :1 / vncserver:2 / vncserver -list与当前情况不相符,感觉像是CENTOS6时候遗留的功能,虽然还能用,但是在CENTOS7里面不符合预期`

找到指定的文件
```txt
# The vncserver service unit file
#
# Quick HowTo:
# 1. Copy this file to /etc/systemd/system/vncserver@.service
# 2. Replace <USER> with the actual user name and edit vncserver
#    parameters appropriately
#   ("User=<USER>" and "/home/<USER>/.vnc/%H%i.pid")
# 3. Run `systemctl daemon-reload`
# 4. Run `systemctl enable vncserver@:<display>.service`
#
# DO NOT RUN THIS SERVICE if your local area network is
# untrusted!  For a secure way of using VNC, you should
# limit connections to the local host and then tunnel from
# the machine you want to view VNC on (host A) to the machine
# whose VNC output you want to view (host B)
#
# [user@hostA ~]$ ssh -v -C -L 590N:localhost:590M hostB
#
# this will open a connection on port 590N of your hostA to hostB's port 590M
# (in fact, it ssh-connects to hostB and then connects to localhost (on hostB).
# See the ssh man page for details on port forwarding)
#
# You can then point a VNC client on hostA at vncdisplay N of localhost and with
# the help of ssh, you end up seeing what hostB makes available on port 590M
#
# Use "-nolisten tcp" to prevent X connections to your VNC server via TCP.
#
# Use "-localhost" to prevent remote VNC clients connecting except when
# doing so through a secure tunnel.  See the "-via" option in the
# `man vncviewer' manual page.


[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=<USER>

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=-/usr/bin/vncserver -kill 1
ExecStart=/usr/bin/vncserver 1
PIDFile=/home/<USER>/.vnc/%H%i.pid
ExecStop=-/usr/bin/vncserver -kill 1

[Install]
WantedBy=multi-user.target
```

## 部署一次 root 用户

[root@bd-07 ~]# find / -name vncserver@.service
/usr/lib/systemd/system/vncserver@.service

`根据vncserver@.service里面的要求`

cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:1.service \
并且编辑如下`特别注意root用户的路径没有/home这一层`

```txt
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=root

# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=-/usr/bin/vncserver -kill %i
ExecStart=/usr/bin/vncserver %i
PIDFile=/root/.vnc/%H%i.pid
ExecStop=-/usr/bin/vncserver -kill %i

[Install]
WantedBy=multi-user.target
```

## 再来一个 例如 oracle 用户

cp /usr/lib/systemd/system/vncserver@.service /etc/systemd/system/vncserver@:2.service \
编辑如下
```txt
[Unit]
Description=Remote desktop service (VNC)
After=syslog.target network.target

[Service]
Type=forking
User=oracle
# Clean any existing files in /tmp/.X11-unix environment
ExecStartPre=-/usr/bin/vncserver -kill %i
ExecStart=/usr/bin/vncserver %i
PIDFile=/home/oracle/.vnc/%H%i.pid
ExecStop=-/usr/bin/vncserver -kill %i

[Install]
WantedBy=multi-user.target
```

根据要求 

```bash
vncserver
- 输入密码
- 确认密码


[root@bd-07 system]# systemctl daemon-reload
[root@bd-07 system]# systemctl enable vncserver@:1.service
Created symlink from /etc/systemd/system/multi-user.target.wants/vncserver@:1.service to /etc/systemd/system/vncserver@:1.service.
[root@bd-07 system]# systemctl enable vncserver@:2.service
Created symlink from /etc/systemd/system/multi-user.target.wants/vncserver@:2.service to /etc/systemd/system/vncserver@:2.service.
[root@bd-07 system]# systemctl start  vncserver@1.service
Job for vncserver@1.service failed because the control process exited with error code. See "systemctl status vncserver@1.service" and "journalctl -xe" for details.
# 这里的报错就很奇怪了 百度到: Type改成simple,实际上没验证出来,因为最后成功的时候,root用户使用的simple,oracle用户使用的 forking
# 还有说要删除 /tmp/.X11什么的那个文件,也没动这个
# 我当时是更改了正确的 home路径(root用户跟路径刚开始写错了)
# 再次执行 systemctl daemon-reload
# 然后 disable /enable 两个 vncserver@:<dispaly>.server
```

## 一些问题

### 还有一个无法启动的原因， 没给vncserver 这只密码

vncserver :n 这种命令总是启动 一个root用户的,没去验证是否是启动 vncserver@:1.service

验证:

mv vncserver@:1.service vncserver@:3.service
然后 进行 reload disable 等配套操作 

结果 使用 vncserver :1 还是能启动,并且正常登陆

之后进行了一系列的开关验证,并且在oracle用户下做一些验证,结论如下

- 1: `vncserver -list 只能看到当前用户开启的vncserver进程,但是2属于例外情况`
- 2: root用户下,使用 systemctl start vncserver@:<display>.service的时候,如果配置里面是其他用户,比如oracle,那么在root用户下,vncserver -list是看不到的,在oracle下面可以看到
- 3: 不管在什么用户下 使用 vncserver :n 开启一个实例,都会开启 root实例,并且在本用户下可见
- 4: 一个情景有助于理解: 在root下 使用 systemctl开启一个oracle的server,在root下面是list看不到的,在oracle用户下,可以看到,用 kill命令关闭这个server,那么 在 root节点用 systemctl status 可以看到这个server变成关闭的了