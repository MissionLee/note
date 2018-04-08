# ZOOKEEPER

- zookeeper的几个命令入口

  - zookeeper-client
  - zookeeper-server
  - zookeeper-server-cleanup
  - zookeeper-server-initialize
  - zsoelim ?这个不确定
  - 以上的是被封装了一次的,原生的类似 zkServer.sh 这种
  - 例如 原生的 zkCli.sh被 CDH封装为了 zookeeper-client

  ```bash
  #!/bin/bash
  # Reference: http://stackoverflow.com/questions/59895/can-a-bash-script-tell-what-directory-its-stored-in
  SOURCE="${BASH_SOURCE[0]}"
  BIN_DIR="$( dirname "$SOURCE" )"
  while [ -h "$SOURCE" ]
  do
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
    BIN_DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd )"
  done
  BIN_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  LIB_DIR=$BIN_DIR/../lib

    # Autodetect JAVA_HOME if not defined
    . $LIB_DIR/bigtop-utils/bigtop-detect-javahome

    export ZOOKEEPER_HOME=${ZOOKEEPER_CONF:-$LIB_DIR/zookeeper}
    export ZOOKEEPER_CONF=${ZOOKEEPER_CONF:-/etc/zookeeper/conf}
    export CLASSPATH=$CLASSPATH:$ZOOKEEPER_CONF:$ZOOKEEPER_HOME/*:$ZOOKEEPER_HOME/lib/*
    export ZOOCFGDIR=${ZOOCFGDIR:-$ZOOKEEPER_CONF}
    env CLASSPATH=$CLASSPATH $LIB_DIR/zookeeper/bin/zkCli.sh "$@"
  ```

- 一些命令
  - zookeeper-server start [zoo.cfg]
  `可以指定不同的cfg文件`

- zookeeper的shell操作
  - 通过 zookeeper-client[CDH封装好了的] 或者 zkCli.sh -server localhost:2181[原生 已被CDH改了]进入
  - help 命令
  ```bash
  ZooKeeper -server host:port cmd args
    stat path [watch]
    set path data [version]
    ls path [watch]
    # ls /
    # 查看zk中所包含内容
    delquota [-n|-b] path
    ls2 path [watch]
    setAcl path acl
    setquota -n|-b val path
    history 
    redo cmdno
    printwatches on|off
    delete path [version]
    # 删除znode
    sync path
    listquota path
    rmr path
    get path [watch]
    # get /hbase
    # 查看某个znode下面的内容
    create [-s] [-e] path data acl
    # create /zk myData
    # zk[znode] 关联 myData
    addauth scheme auth
    quit
    getAcl path
    close
    connect host:port
    set path str_aso
    #对某个znode的所关联字符串进行设置
    # set /zk newData
  ```