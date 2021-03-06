# 

[原文连接](https://yq.aliyun.com/articles/60482?spm=a2c4e.11155435.0.0.24874c87mNh7Xi)

- 一些概念

一个partition 对应一个task,一个task 必定存在于一个Executor,一个Executor 对应一个JVM.
Partition 是一个可迭代数据集合
Task 本质是作用于Partition的线程

- 问题

Task 里如何使用Kafka Producer 将数据发送到Kafaka呢。 其他譬如HBase/Redis/MySQL 也是如此。

- 解决方案
直观的解决方案自然是能够在Executor(JVM)里有个Prodcuer Pool（或者共享单个Producer实例），但是我们的代码都是现在Driver端执行，然后将一些函数序列化到Executor端执行，这里就有序列化问题，正常如Pool,Connection都是无法序列化的。
一个简单的解决办法是定义个Object 类，
- 譬如
```scala
object SimpleHBaseClient {
  private val DEFAULT_ZOOKEEPER_QUORUM = "127.0.0.1:2181"

  private lazy val (table, conn) = createConnection

  def bulk(items:Iterator) = {
      items.foreach(conn.put(_))
      conn.flush....
  } 
 ......
}
```
然后保证这个类在map,foreachRDD等函数下使用，譬如：
```scala
dstream.foreachRDD{ rdd =>
    rdd.foreachPartition{iter=>
        SimpleHBaseClient.bulk(iter)  
    }
}
```

为什么要保证放到foreachRDD /map 等这些函数里呢？Spark的机制是先将用户的程序作为一个单机运行(运行者是Driver)，Driver通过序列化机制，将对应算子规定的函数发送到Executor进行执行。这里，foreachRDD/map 等函数都是会发送到Executor执行的，Driver端并不会执行。里面引用的object 类 会作为一个stub 被序列化过去，object内部属性的的初始化其实是在Executor端完成的，所以可以避过序列化的问题。

Pool也是类似的做法。然而我们并不建议使用pool,因为Spark 本身已经是分布式的，举个例子可能有100个executor,如果每个executor再搞10个connection的pool,则会有100*10 个链接，Kafka也受不了。一个Executor 维持一个connection就好。

关于Executor挂掉丢数据的问题，其实就看你什么时候flush,这是一个性能的权衡。