# 目前是CDH自动部署的Kafka

- kafka在 02,03节点
- zookeeper 在 04,05,06节点
- 创建 kafka-topics --create --zookeeper hosts:2181 --replication-factor 1 --partitions 1 --topic topic_name
- 发送端[BigData-03] kafka-console-producer --broker-list BigData-02:9092 --topic test
- 接收端[BigData-02] kafka-console-consumer --zookeeper BigData-05:2181 --topic test --from-beginning
- 查看当前有哪些topic kafka-topics --list --zookeeper BigData-05:2181
- 删除一个topic kafka-topics --delete --zookeeper BigData-05:2181 --topic test