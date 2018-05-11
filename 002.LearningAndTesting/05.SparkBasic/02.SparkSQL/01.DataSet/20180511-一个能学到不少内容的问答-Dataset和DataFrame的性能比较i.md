# 
通过阅读这篇文章，拓展了一些知识

- top-K 算法
- JMH
- JIT
- benchmark性能测试
- java jit即时编译
- 更多很重要的scala/spark细节，需要在回答里面看

原文：

[Spark中，Dataset和DataFrame的性能比较？
关注问题写回答](https://www.zhihu.com/question/264251623)

## 问题

Spark中，Dataset和DataFrame的性能比较？
```scala
import org.apache.spark.sql.types._
import org.apache.spark.sql._

object Main {
def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder
        .master("local")
        .appName("example")
        .getOrCreate()
    val sc = spark.sparkContext
    val sql = spark.sqlContext

    val schema = new StructType(Array(StructField("id",
        IntegerType), StructField("age", IntegerType)))
    val rdd = sc.parallelize(for (i <- 5000000.to(1, -1)) yield Row(i, i))
    val df = spark.createDataFrame(rdd, schema)
    var start = System.currentTimeMillis()
    df.sort("age").show
    println("DataFrame: "+(System.currentTimeMillis()-start))

    val rdd1 = sc.parallelize(for (i <- 5000000.to(1, -1)) yield User(i, i))
    import sql.implicits._
    val ds = rdd1.toDS
    start = System.currentTimeMillis()
    ds.sort("age").show
    println("Dataset: "+(System.currentTimeMillis()-start))
    }
}

case class User(name: Int, age: Int) {}
````
上面这个例子为什么Dataset会比DataFrame快四五倍，
还是local模式下比较没意义？
Dataset和DataFrame的效率跟Tungsten计划有没有关系？
spark版本是2.2.0
问题补充：
分别注释执行或者交换顺序执行结论也是一样的
```note
Dataset:
== Physical Plan ==
*Sort [age#4 ASC NULLS FIRST], true, 0
+- Exchange rangepartitioning(age#4 ASC NULLS FIRST, 200)
   +- *SerializeFromObject [assertnotnull(input[0, User, true]).name AS name#3, assertnotnull(input[0, User, true]).age AS age#4]
      +- Scan ExternalRDDScan[obj#2]

DataFrame:
== Physical Plan ==
*Sort [age#11 ASC NULLS FIRST], true, 0
+- Exchange rangepartitioning(age#11 ASC NULLS FIRST, 200)
   +- Scan ExistingRDD[id#10,age#11]
```

## 回答-作者 连城

作者：连城
链接：https://www.zhihu.com/question/264251623/answer/279310456
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

@朱诗雄 说的缺少 warm-up 代码是对的。看到题主补充说对调了 Dataset 和 DataFrame 的代码后 Dataset 仍然比 DataFrame 快，于是在本地尝试重现了一下，发现的确如此。仔细看了看，这个 benchmark 还有几个问题。

第一个问题是构造 df 时显式用了 
```scala
Row：for (i <- 5000000.to(1, -1)) yield Row(i, i)
```
这行 code 实际上将会创建至少 2,000 万个对象（此处 for ... yield 返回结果的容器是个 Vector，不是 lazy 的）：
- 500 万 GenericRow（trait Row 的默认实现）
- 每个 GenericRow 内各一个 Array[Any]，共计 500 万
- 由于数据存在 Array[Any] 内，每行的两个 Int 被 auto-box 成了 java.lang.Integer，共计一千万

另一方面，构造 ds 时，同样情况下对象创建数只有 df 的四分之一（User 内的 Int 不会被 auto-box）。

第二个问题在于 show()。题主这个 benchmark 的本意应该是对 500 万行数据进行排序然后输出。然而 show() 默认只显式 20 行，因此题主的排序代码实际上类似于 df.limit(20).sort().show()，而 Spark 会将带 limit 的 sort 自动优化为 [top-K](../../15.算法/top-K.md) 来计算。题主后来补充在问题中的 query plan 应该是分别通过
```scala
df.sort("age").explain()
```
和
```scala
ds.sort("age").explain()
```

得到的。而这样打印出的 physical plan 并不包含 show() 中额外添加的 limit()。要查看实际的 query plan，可以在 main() 的末尾加上 sleep 然后打开 localhost:4040，进入 Spark UI 的 SQL tab 后，可以分别查看两个 job 对应的 query plan。

- DataFrame job 的 plan：
```note
== Parsed Logical Plan ==
GlobalLimit 21
+- LocalLimit 21
   +- Sort [age#14 ASC NULLS FIRST], true
      +- LogicalRDD [id#13, age#14]

== Analyzed Logical Plan ==
id: int, age: int
GlobalLimit 21
+- LocalLimit 21
   +- Sort [age#14 ASC NULLS FIRST], true
      +- LogicalRDD [id#13, age#14]

== Optimized Logical Plan ==
GlobalLimit 21
+- LocalLimit 21
   +- Sort [age#14 ASC NULLS FIRST], true
      +- LogicalRDD [id#13, age#14]

== Physical Plan ==
TakeOrderedAndProject(limit=21, orderBy=[age#14 ASC NULLS FIRST], output=[id#13,age#14])
+- Scan ExistingRDD[id#13,age#14] 
```
- Dataset job 的 plan：
```note
== Parsed Logical Plan ==
GlobalLimit 21
+- LocalLimit 21
   +- Sort [age#4 ASC NULLS FIRST], true
      +- SerializeFromObject [assertnotnull(assertnotnull(input[0, ammonite.$file.Zhihu$User, true])).name AS name#3, assertnotnull(assertnotnull(input[0, ammonite.$file.Zhihu$User, true])).age AS age#4]
         +- ExternalRDD [obj#2]

== Analyzed Logical Plan ==
name: int, age: int
GlobalLimit 21
+- LocalLimit 21
   +- Sort [age#4 ASC NULLS FIRST], true
      +- SerializeFromObject [assertnotnull(assertnotnull(input[0, ammonite.$file.Zhihu$User, true])).name AS name#3, assertnotnull(assertnotnull(input[0, ammonite.$file.Zhihu$User, true])).age AS age#4]
         +- ExternalRDD [obj#2]

== Optimized Logical Plan ==
GlobalLimit 21
+- LocalLimit 21
   +- Sort [age#4 ASC NULLS FIRST], true
      +- SerializeFromObject [assertnotnull(input[0, ammonite.$file.Zhihu$User, true]).name AS name#3, assertnotnull(input[0, ammonite.$file.Zhihu$User, true]).age AS age#4]
         +- ExternalRDD [obj#2]

== Physical Plan ==
TakeOrderedAndProject(limit=21, orderBy=[age#4 ASC NULLS FIRST], output=[name#3,age#4])
+- *SerializeFromObject [assertnotnull(input[0, ammonite.$file.Zhihu$User, true]).name AS name#3, assertnotnull(input[0, ammonite.$file.Zhihu$User, true]).age AS age#4]
   +- Scan ExternalRDDScan[obj#2]
```

可见，logical plan 中多了 limit 的操作，而 physical plan 里的 TakeOrderedAndProject 就是 top-K（出于 show() 的实现细节，这里实际上取了 21 行，此处略去不表）。

由于这个 top-K 优化的存在，真正的 query 执行时间实际上很短，并没有真的对 500 万行数据进行排序。那么时间都花到哪里去了呢？这跟第三个问题有关。

第三个问题在于两个 job 各 500 万行数据都是`在 driver 端生成的`。在用 for ... yield 生成数据时，500 万个 Row、500 万个 User 都是一次性生成完毕的。由于 Spark 的分布式性质，要求所有 task 都可序列化（Serializable）。Spark 在提交 job 之前会`预先尝试做一遍序列化`，以确保 task 的确可以序列化。这个检查即便是 local mode 也不会免除。所以在这个 benchmark 里，时间都花到数千万对象的序列化上去了。我在本地用 `jvisualvm` 简单 profile 了一下也证实了这点。同时，由于问题一的存在，df 涉及的 object 要多出三倍，序列化消耗的时间自然就比 ds 就更高了。如果把 df 的生成改成 lazy 的，就可以避免掉这重序列化开销：
```scala
val rdd = sc.parallelize(5000000 to 1 by -1).map { i => Row(i, i) }
```

注意这里第一步的 `5000000 to 1 by -1` 返回的是一个 Scala Range，是 lazy 的；第二步用 RDD 的 map 来构造 Row，也是 lazy 的。同理，ds 的生成可以改为：
```scala
val rdd = sc.parallelize(5000000 to 1 by -1).map { i => User(i, i) }
```

这样一来，由于数据的生成挪到了 executor 端，Spark task 的序列化成本大大缩减，就不会再出现 ds 比 df 快若干倍的问题了。`很多情况下，Dataset 的性能实际上是会比 DataFrame 要来得差的，因为 Dataset 会涉及到额外的数据格式转换成本。这可以说是 Dataset 为了类型安全而付出的代价。`尤其是在 Dataset query 中还内嵌了多个强类型的 Scala closure 的时候，Spark 会插入额外的序列化操作，在内部的 UnsafeRow 格式和 Dataset 携带的 Java 类型间反复倒腾数据。从第二组 plan 中也可以看到比第一组多了一个 SerializeFromObject 节点。但在题主的测试，用例过于简单，这个对比体现不出来。再者，由于 `DataFrame 实际上就是 Dataset[Row]`，所以也这个 benchmark 里同样存在从 Row 转换到 UnsafeRow 的开销。

可以将题主的代码修改一下。Top-K 的优化估计不是题主的本意，但其实也不妨碍这个 benchmark。在这个前提下，DataFrame 部分可以改为：
```scala
spark.range(5000000, 0, -1).select($"id", $"id" as "age").sort($"age").show()
```

这里 spark.range() 直接流式吐出 UnsafeRow，省掉了 Row 到 UnsafeRow 的转换开销。Dataset 部分可以改为：
```scala
spark.range(5000000, 0, -1).map { id => User(id, id) }.sort($"age")).show()
```
我在本地用 Ammonite 简单跑了一下，每个 query 在正式测之前各跑了 30 遍 warm-up，最后结果是：DataFrame: 568Dataset: 601如果真的要看对所有数据排序的性能，可以将 show() 换成 `foreach { _ => }`。我这么做 benchmark 仍然很粗糙。JVM 因为 JIT 等因素，裸写 benchmark 代码有很多需要考虑的地方。严肃的 JVM 上的 benchmark 建议用 JMH 来做。