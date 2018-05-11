# Spark 2.2.1

## SparkSession
>The entry to programming Spark with the Dataset and Datarame API

###  1. 获取
>In environments that this has been created upfront (e.g. REPL, notebooks), use the builder to get an existing session:
>在环境中，SparkSession已经预先创建好了

- builder 同时也可以用来创建新的Session
  - 获取现有的 session
    - SparkSession.builder().getOrCreate()
  - 新创建一个 session
    - SparkSession.builder.master("local").appName("Word Count").config("spark.some.config.option", "some-value").getOrCreate()

关于Session，我们可以看到其中的 getOrCreate 方法
```scala
    // ！ SparkSession.builder 中的方法
    def getOrCreate(): SparkSession = synchronized {
      // Get the session from current thread's active session.
      var session = activeThreadSession.get()
      if ((session ne null) && !session.sparkContext.isStopped) {
        options.foreach { case (k, v) => session.sessionState.conf.setConfString(k, v) }
        if (options.nonEmpty) {
          logWarning("Using an existing SparkSession; some configuration may not take effect.")
        }
        return session
      }
```
其中，activeThreadSession 在SparkSession中如此定义
```scala
  /** The active SparkSession for the current thread. */
  private val activeThreadSession = new InheritableThreadLocal[SparkSession]
```
实际上`新建和获取`（API文档直译）都调用getOrCreate方法，所以获取的都是同一个SparkSession