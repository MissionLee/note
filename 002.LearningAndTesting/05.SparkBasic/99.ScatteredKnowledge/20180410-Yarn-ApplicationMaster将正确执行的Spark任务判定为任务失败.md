# 1

使用Oozie部署Spark2 任务，提交给Yarn

现象：

Spark任务正常执行，看到的结果，处理效果，日志等内容，均没有找到错误，但是仍然触发了 AM的 retry机制。而正常执行过后， hdfs上的Spark临时数据 （在  user/hdfs/.sparkStaging目录下）会被删除。retry的时候，会在临时文件夹里面寻找提交的任务jar包。这当然是找不到的，所以报错

最终解决：

把 程序入口由java 实现改为 scala实现

处理过程：

因为 wordcount程序是可以正常执行的。而我们自己编写的程序，直接使用 spark2-submit 也能够正确执行，没有任何问题。所以基本排除代码内容的问题

在整个过程中，做了如下努力：
- 排除 程序中使用mysql连接的问题（注释调相关代码，无效）
- 排除 项目配置文件问题（在当前项目中写一遍wordcount，可以正确执行）
- 排除 打包方式问题，打包整个项目，或者执行artifact指定入口打包（无效）
- 排除 YarnMode影响（local，yarn，yarn-cluster）

- 用Scala重写 程序入口（成功）

原因未知！