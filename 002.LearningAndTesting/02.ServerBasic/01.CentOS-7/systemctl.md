# SYSTEMCTL

## systemctl -help

```txt
[root@bd-07 ~]# systemctl -help
systemctl [OPTIONS...] {COMMAND} ...

Query or send control commands to the systemd manager.

  -h --help           Show this help
     --version        Show package version
     --system         Connect to system manager
  -H --host=[USER@]HOST
                      Operate on remote host
  -M --machine=CONTAINER
                      Operate on local container
  -t --type=TYPE      List units of a particular type
     --state=STATE    List units with particular LOAD or SUB or ACTIVE state
  -p --property=NAME  Show only properties by this name
  -a --all            Show all loaded units/properties, including dead/empty
                      ones. To list all units installed on the system, use
                      the 'list-unit-files' command instead.
  -l --full           Don't ellipsize unit names on output
  -r --recursive      Show unit list of host and local containers
     --reverse        Show reverse dependencies with 'list-dependencies'
     --job-mode=MODE  Specify how to deal with already queued jobs, when
                      queueing a new job
     --show-types     When showing sockets, explicitly show their type
  -i --ignore-inhibitors
                      When shutting down or sleeping, ignore inhibitors
     --kill-who=WHO   Who to send signal to
  -s --signal=SIGNAL  Which signal to send
     --now            Start or stop unit in addition to enabling or disabling it
  -q --quiet          Suppress output
     --no-block       Do not wait until operation finished
     --no-wall        Don't send wall message before halt/power-off/reboot
     --no-reload      Don't reload daemon after en-/dis-abling unit files
     --no-legend      Do not print a legend (column headers and hints)
     --no-pager       Do not pipe output into a pager
     --no-ask-password
                      Do not ask for system passwords
     --global         Enable/disable unit files globally
     --runtime        Enable unit files only temporarily until next reboot
  -f --force          When enabling unit files, override existing symlinks
                      When shutting down, execute action immediately
     --preset-mode=   Apply only enable, only disable, or all presets
     --root=PATH      Enable unit files in the specified root directory
  -n --lines=INTEGER  Number of journal entries to show
  -o --output=STRING  Change journal output mode (short, short-iso,
                              short-precise, short-monotonic, verbose,
                              export, json, json-pretty, json-sse, cat)
     --plain          Print unit dependencies as a list instead of a tree
Unit Commands:
  list-units [PATTERN...]         List loaded units
  list-sockets [PATTERN...]       List loaded sockets ordered by address
  list-timers [PATTERN...]        List loaded timers ordered by next elapse
  start NAME...                   Start (activate) one or more units
  --启动
  stop NAME...                    Stop (deactivate) one or more units
  --停止
  reload NAME...                  Reload one or more units
  --重载
  restart NAME...                 Start or restart one or more units
  --重启
  try-restart NAME...             Restart one or more units if active
  --如果正在启动 重启
  reload-or-restart NAME...       Reload one or more units if possible,
                                  otherwise start or restart
  reload-or-try-restart NAME...   Reload one or more units if possible,
                                  otherwise restart if active
  isolate NAME                    Start one unit and stop all others
  kill NAME...                    Send signal to processes of a unit
  --kill
  is-active PATTERN...            Check whether units are active
  --查看是否在巡行
  is-failed PATTERN...            Check whether units are failed
  --查看是否失败
  status [PATTERN...|PID...]      Show runtime status of one or more units
  show [PATTERN...|JOB...]        Show properties of one or more
                                  units/jobs or the manager
  cat PATTERN...                  Show files and drop-ins of one or more units
  set-property NAME ASSIGNMENT... Sets one or more properties of a unit
  help PATTERN...|PID...          Show manual for one or more units
  reset-failed [PATTERN...]       Reset failed state for all, one, or more
                                  units
  list-dependencies [NAME]        Recursively show units which are required
                                  or wanted by this unit or by which this
                                  unit is required or wanted

Unit File Commands:
  list-unit-files [PATTERN...]    List installed unit files
  enable NAME...                  Enable one or more unit files
  disable NAME...                 Disable one or more unit files
  reenable NAME...                Reenable one or more unit files
  preset NAME...                  Enable/disable one or more unit files
                                  based on preset configuration
  preset-all                      Enable/disable all unit files based on
                                  preset configuration
  is-enabled NAME...              Check whether unit files are enabled
  mask NAME...                    Mask one or more units
  unmask NAME...                  Unmask one or more units
  link PATH...                    Link one or more units files into
                                  the search path
  add-wants TARGET NAME...        Add 'Wants' dependency for the target
                                  on specified one or more units
  add-requires TARGET NAME...     Add 'Requires' dependency for the target
                                  on specified one or more units
  edit NAME...                    Edit one or more unit files
  get-default                     Get the name of the default target
  set-default NAME                Set the default target
Machine Commands:
  list-machines [PATTERN...]      List local containers and host

Job Commands:
  list-jobs [PATTERN...]          List jobs
  cancel [JOB...]                 Cancel all, one, or more jobs

Snapshot Commands:
  snapshot [NAME]                 Create a snapshot
  delete NAME...                  Remove one or more snapshots

Environment Commands:
  show-environment                Dump environment
  set-environment NAME=VALUE...   Set one or more environment variables
  unset-environment NAME...       Unset one or more environment variables
  import-environment [NAME...]    Import all or some environment variables

Manager Lifecycle Commands:
  daemon-reload                   Reload systemd manager configuration
  daemon-reexec                   Reexecute systemd manager

System Commands:
  is-system-running               Check whether system is fully running
  default                         Enter system default mode
  rescue                          Enter system rescue mode
  emergency                       Enter system emergency mode
  halt                            Shut down and halt the system
  poweroff                        Shut down and power-off the system
  reboot [ARG]                    Shut down and reboot the system
  kexec                           Shut down and reboot the system with kexec
  exit                            Request user instance exit
  switch-root ROOT [INIT]         Change to a different root file system
  suspend                         Suspend the system
  hibernate                       Hibernate the system
  hybrid-sleep                    Hibernate and suspend the system
```

我们对service和chkconfig两个命令都不陌生，systemctl 是管制服务的主要工具， 它整合了chkconfig 与 service功能于一体。

systemctl is-enabled iptables.service
systemctl is-enabled servicename.service #查询服务是否开机启动

- systemctl enable *.service #开机运行服务
- systemctl disable *.service #取消开机运行
- systemctl start *.service #启动服务
- systemctl stop *.service #停止服务
- systemctl restart *.service #重启服务
- systemctl reload *.service #重新加载服务配置文件
- systemctl status *.service #查询服务运行状态
- systemctl --failed #显示启动失败的服务

注：*代表某个服务的名字，如http的服务名为httpd

例如在CentOS 7 上安装http

[root@CentOS7 ~]# yum -y install httpd

启动服务（等同于service httpd start）
systemctl start httpd.service

停止服务（等同于service httpd stop）
systemctl stop httpd.service

重启服务（等同于service httpd restart）
systemctl restart httpd.service

查看服务是否运行（等同于service httpd status）
systemctl status httpd.service

开机自启动服务（等同于chkconfig httpd on）
systemctl enable httpd.service

开机时禁用服务（等同于chkconfig httpd on）
systemctl disable httpd.service

查看服务是否开机启动 （等同于chkconfig --list）