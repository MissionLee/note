# Hbase 故障处理集合

- 20180203 ERROR: Connection refused
  - 可以 list看到表 但是 scan的时候 ERROR: Connection refused
  - hbase server和 hbase shell 都在 root用户下启动的时候错误消失
  - hbase server在hadoop用户启动的时候 出现这个错误