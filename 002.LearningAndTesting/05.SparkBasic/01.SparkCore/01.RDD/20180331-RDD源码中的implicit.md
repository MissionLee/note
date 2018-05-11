#

>首先贴上基础RDD的 伴生对象 源代码，里面就是 implicits

参考：  https://blog.csdn.net/accptanggang/article/details/52138748

MissingLi：  我在学习RDD的源码的时候发现，RDD 其中使用的 reduceByKey 方法，本类中并没有这个方法，这个方法查找出来是在 OrderedRDDFunction 类里面的， 但是RDD类还有RDD的衍生类都没有 继承这个类，思考了一段时间，觉得可能是隐式转换让RDD 可以直接使用 这些方法，下方：


- Spark源码中的Scala的 implicit 的使用

這個東西意義非常重大，RDD 本身沒有所謂的 Key, Value，只不過是自己本身解讀的時候把它變成 Key Value 的方法去解讀，RDD 本身就是一個 Record。

```scala
// 最初我是在分析这个方法，然后发现 sortByKey 并不是RDD 中的方法
  def sortBy[K](
      f: (T) => K,
      ascending: Boolean = true,
      numPartitions: Int = this.partitions.length)
      (implicit ord: Ordering[K], ctag: ClassTag[K]): RDD[T] = withScope {
    this.keyBy[K](f)
        .sortByKey(ascending, numPartitions)
        .values
  }
```

```scala
object RDD {

  private[spark] val CHECKPOINT_ALL_MARKED_ANCESTORS =
    "spark.checkpoint.checkpointAllMarkedAncestors"

  // The following implicit functions were in SparkContext before 1.3 and users had to
  // `import SparkContext._` to enable them. Now we move them here to make the compiler find
  // them automatically. However, we still keep the old functions in SparkContext for backward
  // compatibility and forward to the following functions directly.

  implicit def rddToPairRDDFunctions[K, V](rdd: RDD[(K, V)])
    (implicit kt: ClassTag[K], vt: ClassTag[V], ord: Ordering[K] = null): PairRDDFunctions[K, V] = {
    new PairRDDFunctions(rdd)

  }

  implicit def rddToAsyncRDDActions[T: ClassTag](rdd: RDD[T]): AsyncRDDActions[T] = {
    new AsyncRDDActions(rdd)
  }

  implicit def rddToSequenceFileRDDFunctions[K, V](rdd: RDD[(K, V)])
      (implicit kt: ClassTag[K], vt: ClassTag[V],
                keyWritableFactory: WritableFactory[K],
                valueWritableFactory: WritableFactory[V])
    : SequenceFileRDDFunctions[K, V] = {
    implicit val keyConverter = keyWritableFactory.convert
    implicit val valueConverter = valueWritableFactory.convert
    new SequenceFileRDDFunctions(rdd,
      keyWritableFactory.writableClass(kt), valueWritableFactory.writableClass(vt))
  }

  implicit def rddToOrderedRDDFunctions[K : Ordering : ClassTag, V: ClassTag](rdd: RDD[(K, V)])
    : OrderedRDDFunctions[K, V, (K, V)] = {
    new OrderedRDDFunctions[K, V, (K, V)](rdd)
        // 隐式转换 关注的是 类型！！！
    //  在这个隐式转换中  输入类型为   ：  RDD[K,V]
    //                  返回类型为   ：  OrderedRDDFunction[K,V]对象

    // 会看上面的 sortByKey
    // this.keyBy 的返回类型是 RDD[K,V] 所以输入类型符合
    // RDD[K,V]被 隐式转换成了 类对象 new OrderedRDDFunctions[K, V, (K, V)](rdd)
    // 然后调用 了 类 里面的 sortByKey方法

    // ！！！ 隐式转换是 在编译的时候会确定下来
    // 在这里 编译器会 查找 范围内的隐式转换，看谁符合要求，并且拥有 sortByKey 方法，之后全定转换成什么
    //  ！！！ 这个是我看了一些 文章之后 判断的结论。  编译器会为了能够通过编译作出努力的
    //   ！！！ 本身 PariRDDFunction 也是输入的 RDD[K,V] 但是里面 没有 sortByKey方法
  }

  implicit def doubleRDDToDoubleRDDFunctions(rdd: RDD[Double]): DoubleRDDFunctions = {
    new DoubleRDDFunctions(rdd)
  }

  implicit def numericRDDToDoubleRDDFunctions[T](rdd: RDD[T])(implicit num: Numeric[T])
    : DoubleRDDFunctions = {
    new DoubleRDDFunctions(rdd.map(x => num.toDouble(x)))
  }
}

```

>如果源對象、目標對象、伴生類、伴生對象都找不到這個隐式转换的話，就需要手動把它導進來，這對於代碼的重構也是非常重要的。

这里又一个明确的例子

import spark.implicits._
import spark.sql