# Spark Operator

```scala
/**
 * Spark 2.2.0
 * Scala 2.11.0
 * @author : MissionLee
 * @date : 20180412
 */
```

Spark Operator
  - Transformation
    - RDD
      - [Map](#map)
      - [flatMap](#flatmap)
      - [filter](#filter)
      - [distinct&union](#distinct&union)
      - [sortBy](#sortBy)
      - [intersection](#intersection)
      - [glom](#glom)
      - [cartesian](#cartesian)
      - [groupBy](#groupBy)
      - [zip](#zip)
  - Action
    - RDD
      - [foreach-无测试]
      - [foreachPartiton](#foreachPartition)
      - [collect](#collect)
      - [toLocalIterator](#toLocalIterator)
      - [subtract](#subtract)
      - [reduce](#redcue)
      - [treeReduce](#treeReduce)
      - [fold](#fold)
      - [aggregate](#aggregate)
      - [count](#count)

##  <span id ="map">Map</span>


```scala
  /**
   * Return a new RDD by applying a function to all elements of this RDD.
   */
  def map[U: ClassTag](f: T => U): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[U, T](this, (context, pid, iter) => iter.map(cleanF))
  }
```

- 入参是一个 函数
- 对每行执行这个函数

- 方法细节探究
  - [withScope](../../相关内容/01.withScope.md)

  - [sc.clean](../../相关内容/02.sc.clean.md) -未完成

  - [解析lambda表达式(context, pid, iter) => iter.map(cleanF)](../../相关内容/04.Lambda表达式.md)

> 以下测试

测试数据
```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
```

```scala
package basic

import org.apache.spark.rdd.RDD
import org.apache.spark.sql.SparkSession

/**
  *
  */
class Wrap(x : String){
  val name = x;
  def sayName(): String ={
    println(x)
    "123"
  }

  def getName(): String = {
    this.x
  }
}
class Transform {

}
object Transform{
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  def run(): Unit ={
    val list = rdd.map(r => List(new Wrap(r)))
    println("sayName")
    val saylist =list.map(_(0).sayName())
    println("sayName + collect")
    saylist.collect()
    println("sayName + println")
    saylist.foreach(println)
    println()
    println("getName + println")
    list.map(_(0).getName()).foreach(println)
    println("---------")
    

    val x =rdd.map(r=>r.split(",",-1)).map(r=>(r(0),r)).sortByKey(false).saveAsTextFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic2.txt")

  }

  def main(args: Array[String]): Unit = {
    run()
  }
}

```
控制台打印输出结果

```note
sayName
sayName + collect
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
sayName + println
1,a,c,b1111111111
123
2,w,gd,h
123
3,h,r,x11
123
4,6,s,b11
123
5,h,d,o111111111
123
6,q,w,e111111111111111111111111
123

getName + println
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
---------
```
- 这里可以看到 map的一些注意事项
  - 在map中执行的函数因为惰性机制，在 collect的时候才会触发执行
  - 在 sayName+collect的情况下可以看到
    -  map 与 foreach 是 流式执行的，每次 执行一次 sayName之后，会执行一个对应的 println

排序的 文件输出结果
```note
(6,[Ljava.lang.String;@de8649d)
(5,[Ljava.lang.String;@5e00618e)
(4,[Ljava.lang.String;@52b91a05)
(3,[Ljava.lang.String;@70251ddc)
(2,[Ljava.lang.String;@6ee2155b)
(1,[Ljava.lang.String;@3118cff0)
```

## 总结

- map的用法
  - 可以用来讲 RDD中的每一行包装成一个类
    - 处理结构化/半结构化数据
  - 可以在其中执行 方法（函数）
    - 用于对数据进行计算

- map的注意实现
  - 需要 行动算子 触发执行
  - （map）链式操作是以一行为单位进行的，而不是对所有数据进行其中一个步骤，结束后再进行下一个步骤

## ##  <span id ="flatmap">flatMap</span>


```scala
  /**
   *  Return a new RDD by first applying a function to all elements of this
   *  RDD, and then flattening the results.
   */
  def flatMap[U: ClassTag](f: T => TraversableOnce[U]): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[U, T](this, (context, pid, iter) => iter.flatMap(cleanF))
  }
```
方法解析
- U:ClassTag [ClassTag](../../相关内容/03.classTag.md)
- TraversableOnce[U] scala collection 下的一个trait :A template trait for collections which can be traversed either once only or one or more times.  
  - 我翻看了以下collection的源码， Iterable 是继承了这个类的，也就是所有的scala集合类型应该都符合要求，这里用这个特质代表泛型，应该是强调这个collection是可以1次或多次迭代的（lms： 20180402 推测）
  




源码注释：
  - 1.对RDD所有内容执行这个操作
  - 然后摊平结果

原本最经典的例子就是 WordCount使用flatMap 计算每个单词的数量，这里我做一个类似的

```scala
package basic

import org.apache.spark.sql.SparkSession
import shapeless.ops.nat.GT.>

import scala.collection.immutable.HashSet

/**
  *
  */
object TestFlatMap {
  val ss = SparkSession.builder().master("local").appName("1").getOrCreate()
  val sc = ss.sparkContext
  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    rdd.foreach(println)
    val flatrdd = rdd.flatMap(line=>line.split(",",-1))
    // String.split 返回的是个 String[]

    println("------------------")
    flatrdd.foreach(println)
    println("-------------------")

    // 这里定义一个 返回 Set 的函数
    def myfuc(line:String ):Set[String]={
      val list0 = line.split(",",-1)
      var hset = new HashSet[String]
      hset =hset + list0(0)
      hset =hset + list0(1)
      hset
    }
    val flatrdd2 = rdd.flatMap(myfuc)
    flatrdd2.foreach(println)
  }
}
```

控制台打印结果
```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
------------------
1
a
c
b
2
w
gd
h
3
h
r
x
4
6
s
b
5
h
d
o
6
q
w
e
-------------------
a
1
2
w
h
3
4
6
5
h
6
q
```

##  <span id ="filter">filter</span>


```scala
  /**
   * Return a new RDD containing only the elements that satisfy a predicate.
   */
  def filter(f: T => Boolean): RDD[T] = withScope {
    val cleanF = sc.clean(f)
    new MapPartitionsRDD[T, T](
      this,
      (context, pid, iter) => iter.filter(cleanF),
      preservesPartitioning = true)
  }
```

类似与之前的flatMap，最终做运算的是Iterator底层的方法


[Scala Iterator filter](../../../../06.ScalaBasic/ScalaCollection/Iterator/ScalaIterator-filter.md)

- 说明
  - 对rdd的每个元素进行筛选，符合条件的保留
  - 接受一个返回 布尔值 的函数作为参数
  - 返回 true保留，false

- 测试

```scala
package basic

import org.apache.spark.sql.SparkSession

/**
  * @author: MissingLi
  * @date: 02/04/18 16:52
  * @Description:
  * @Modified by:
  */
object TestFilter {
  val ss = SparkSession.builder().master("local").appName("1").getOrCreate()
  val sc = ss.sparkContext
  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    rdd.foreach(println)

    println("------------------")
    rdd.map(line=>line.split(",",-1)).filter(r=>1==(r(0).toInt%2)).map(_.mkString("_")).foreach(println)
    // 1. 用 ， 分隔开 每行
    // 2. 筛选第一个数字未奇数的行
    // 3. 拼成字符串
    // 4. 打印

    // 锻炼以下 scala的使用 
    def oddFilter[T](strA : Array[T]):Boolean={
      val num = strA(0).toString.toInt
      return 1==num%2
    }
    rdd.map(line=>line.split(",",-1)).filter(oddFilter).map(_.mkString("_")).foreach(println)

  }

}
```
打印结果
```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
------------------
1_a_c_b
3_h_r_x
5_h_d_o
```

- 以上，符合预期




##  <span id ="distinct&union">distinct&union</span>


```scala
  /**
   * Return a new RDD containing the distinct elements in this RDD.
   */
  def distinct(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
    map(x => (x, null)).reduceByKey((x, y) => x, numPartitions).map(_._1)
  }

  /**
   * Return a new RDD containing the distinct elements in this RDD.
   */
  def distinct(): RDD[T] = withScope {
    distinct(partitions.length)
  }


    /**
   * Return the union of this RDD and another one. Any identical elements will appear multiple
   * times (use `.distinct()` to eliminate them).
   */
  def union(other: RDD[T]): RDD[T] = withScope {
    sc.union(this, other)
  }

  /**
   * Return the union of this RDD and another one. Any identical elements will appear multiple
   * times (use `.distinct()` to eliminate them).
   */
  def ++(other: RDD[T]): RDD[T] = withScope {
    this.union(other)
  }
```

- union 和 ++ 实际上是同一个方法

union测试代码

```scala
object DistinctAndUnion {
  val ss =SparkSession.builder().appName("1").master("local").getOrCreate();
  val sc = ss.sparkContext

  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd3 = rdd++rdd2
    val rdd4 = rdd.union(rdd2)
    println("rdd")
    rdd.foreach(println)
    println("rdd2")
    rdd2.foreach(println)
    println("rdd3 = rdd1 ++rdd2")
    rdd3.foreach(println)
    println("rdd4 = rdd.union(rdd2)")
    rdd3.foreach(println)
  }
}
```

打印结果

```note
rdd
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
rdd2
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
rdd3 = rdd1 ++rdd2
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
rdd4 = rdd.union(rdd2)
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
```

Distinct测试代码-对基本类型

```scala
object DistinctAndUnion {
  val ss =SparkSession.builder().appName("1").master("local").getOrCreate();
  val sc = ss.sparkContext

  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd3 = rdd++rdd2
    rdd3.foreach(println)
    println("---------------")
    rdd3.distinct().foreach(println)
  }
}
```

测试结果

```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
---------------
2,w,gd,h
5,h,d,o
6,q,w,e
1,a,c,b
4,6,s,b
3,h,r,x
```

Distinct测试 - 引用类型 - Collection

```scala
object DistinctAndUnion {

  val ss =SparkSession.builder().appName("1").master("local").getOrCreate();
  val sc = ss.sparkContext

  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd3 = (rdd++rdd2).map(r=>{
      val list = new util.ArrayList[String]()
      list.add(r)
      list
    })


    rdd3.map(r=>r.get(0)).foreach(println)
    println("---------------")
    rdd3.distinct().map(r=>r.get(0)).foreach(println)

  }
}
```

结果- 成功去重

```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
---------------
4,6,s,b
6,q,w,e
1,a,c,b
3,h,r,x
2,w,gd,h
5,h,d,o
```

Distinct测试 - 引用类型 - Collection - 补充测试

```scala
object DistinctAndUnion {

  val ss =SparkSession.builder().appName("1").master("local").getOrCreate();
  val sc = ss.sparkContext

  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd3 = (rdd++rdd2).map(r=>{
      val list = new util.ArrayList[String]()
      list.add(r)
      if(2*Math.random()>1)
        list.add("limingshun")
      list
    })
    // 这里 list 有一定随机性，用来判断distinct 是否是比较整个list内容全不相同
    rdd3.map(r=>r.get(0)).foreach(println)
    println("---------------")
    rdd3.distinct().map(r=>r.get(0)).foreach(println)

  }
}

```

结果

```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
---------------
4,6,s,b
6,q,w,e
3,h,r,x
1,a,c,b
3,h,r,x
5,h,d,o
2,w,gd,h
5,h,d,o
2,w,gd,h
```

从结果看，是比较整个list的内容是否完全相同

Distinct - 自定义对象测试

```scala
//对象
class User(val name:String) extends Serializable {

  def getName(): String ={
    name
  }
}
object User
```

```scala
object DistinctAndUnion {

  val ss =SparkSession.builder().appName("1").master("local").getOrCreate();
  val sc = ss.sparkContext

  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd3 = (rdd++rdd2).map(r=>{
      val list = new util.ArrayList[String]()
      list.add(r)
      if(2*Math.random()>1)
        list.add("limingshun")
      list
    })


    println("====================================")
    val rdd4=(rdd++rdd2).map(r=>new User(r))
    rdd4.map(r=>r.getName()).foreach(println)
    println("----------------------")
    rdd4.distinct().map(r=>r.getName()).foreach(println)
  }
}
```

结果

```note
====================================
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
----------------------
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
3,h,r,x
3,h,r,x
5,h,d,o
1,a,c,b
2,w,gd,h
2,w,gd,h
6,q,w,e
4,6,s,b
```

结果看出，没有影响

Distinct - 自定义对象测试 -增强版本 

```scala
//对象有如下变化 其他代码不变
class User(val name:String) extends Serializable {

  def getName(): String ={
    name
  }

  override def hashCode(): Int = {

    var h:Int = 0;
    if (h == 0 && name.length > 0) {
      val ar: Array[Char] = name.toCharArray;
      for( c <- ar){
        h=31*h+c
      }
    }
     h
  }
   override def equals(obj: Any): Boolean = {
     println(" here equals ")
     this.hashCode() == obj.hashCode()
  }
}
object User
```

结果

```scala
====================================
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
----------------------
 here equals 
 here equals 
2,w,gd,h
5,h,d,o
 here equals 
 here equals 
 here equals 
 here equals 
6,q,w,e
1,a,c,b
4,6,s,b
3,h,r,x
```

- 结论： distinct 会使用 equals 方法来对对象是否相同进行判断


##  <span id ="sortBy">sortBy</span>


```scala
  /**
   * Return this RDD sorted by the given key function.
   */
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

接受三个参数
- 排序因子的提取函数
- 升序降序的标志位-默认升
- 分区数量-默认与RDD的数量相同

基本测试： 按照数字大小

```scala
object TestSortBy {

    val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
    val sc = ss.sparkContext
    sc.setLogLevel("error")
    val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")

    def main(args: Array[String]): Unit = {
      rdd.sortBy(r=>{
        r.split(",",-1)(0).toInt
      },false,1).foreach(println)
    }
}
```

```note
6,q,w,e
5,h,d,o
4,6,s,b
3,h,r,x
2,w,gd,h
1,a,c,b
```

- 更换以下 排序因子的提取函数 ： 字母自然顺序

```scala
// 按照切分后的 第三个成员排序
object TestSortBy {

    val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
    val sc = ss.sparkContext
    sc.setLogLevel("error")
    val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")

    def main(args: Array[String]): Unit = {
      rdd.sortBy(r=>{
        r.split(",",-1)(2)
      },false,1).foreach(println)
    }
}
```

```note
6,q,w,e
4,6,s,b
3,h,r,x
2,w,gd,h
5,h,d,o
1,a,c,b
```

- 如果出现 排序因子 相等（此结果不完全可信）

```scala
object TestSortBy {

    val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
    val sc = ss.sparkContext
    sc.setLogLevel("error")
    val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")

    def main(args: Array[String]): Unit = {
      (rdd++rdd++rdd++rdd++rdd).sortBy(r=>{
        r.split(",",-1).length
      },false,1).foreach(println)
    }
}

```


```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
```





##  <span id ="intersection">intersection</span>


```scala
  /**
   * Return the intersection of this RDD and another one. The output will not contain any duplicate
   * elements, even if the input RDDs did.
   *
   * @note This method performs a shuffle internally.
   */
  def intersection(other: RDD[T]): RDD[T] = withScope {
    this.map(v => (v, null)).cogroup(other.map(v => (v, null)))
        .filter { case (_, (leftGroup, rightGroup)) => leftGroup.nonEmpty && rightGroup.nonEmpty }
        .keys
  }

  /**
   * Return the intersection of this RDD and another one. The output will not contain any duplicate
   * elements, even if the input RDDs did.
   *
   * @note This method performs a shuffle internally.
   *
   * @param partitioner Partitioner to use for the resulting RDD
   */
  def intersection(
      other: RDD[T],
      partitioner: Partitioner)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
    this.map(v => (v, null)).cogroup(other.map(v => (v, null)), partitioner)
        .filter { case (_, (leftGroup, rightGroup)) => leftGroup.nonEmpty && rightGroup.nonEmpty }
        .keys
  }

  /**
   * Return the intersection of this RDD and another one. The output will not contain any duplicate
   * elements, even if the input RDDs did.  Performs a hash partition across the cluster
   *
   * @note This method performs a shuffle internally.
   *
   * @param numPartitions How many partitions to use in the resulting RDD
   */
  def intersection(other: RDD[T], numPartitions: Int): RDD[T] = withScope {
    intersection(other, new HashPartitioner(numPartitions))
  }
```

参数
- 一个RDD
- 一个可选参数Partitioner[如果某个RDD已经有分区了，会优先使用原分区-未验证]
  - Spark提供了几种Partitioner
    - Parititoner（下面两个的父类）
    - HashParitioner（默认）
    - RangePartitioner

两份原始数据
```note
--------sparkbasic.txt
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
--------sparkbasic3.txt
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
7,j,s,b
8,h,m,o
9,q,w,c
```

测试程序

```scala
object TestIntersection {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic3.txt")

  def main(args: Array[String]): Unit = {
    val rdd3 = rdd.intersection(rdd2)
    rdd3.foreach(println)
  }

}
```

输出结果

```note
6,q,w,e
4,6,s,b
5,h,d,o
3,h,r,x
```

- 测试对象的情况

```scala
//User用的是 distince&union测试中的User

object TestIntersection {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic3.txt")

  def main(args: Array[String]): Unit = {
    val rdd3 = rdd.map(r=>new User(r))
    val rdd4= rdd2.map(r=>new User(r))
    val rdd5 = rdd3.intersection(rdd4)
    rdd5.map(_.getName())foreach(println)
  }

}
```

打印结果


```note
 here equals 
 here equals 
 here equals 
 here equals 
6,q,w,e
4,6,s,b
5,h,d,o
3,h,r,x
```

- 结论： 在取交集的时候，也是调用的 equals方法

##  <span id ="glom">glom</span>


```scala
/**
 * Return an RDD created by coalescing all elements within each partition into an array.
 */
def glom(): RDD[Array[T]] = withScope {
      new MapPartitionsRDD[Array[T], T](this, (context, pid, iter) => Iterator(iter.toArray))
}
```

作用： 把rdd的每个分区的内容用一个Array存起来

测试代码
```scala
object TestGlom {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
  val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic3.txt")

  def main(args: Array[String]): Unit = {
    val rdd3 = rdd++ rdd2
    rdd3.glom().foreach(r=>{
      for(str <- r){
        println(str)
      }
      println("--------------")
    })
  }
}
```

输出
```note
1,a,c,b
2,w,gd,h
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
--------------
3,h,r,x
4,6,s,b
5,h,d,o
6,q,w,e
7,j,s,b
8,h,m,o
9,q,w,c
--------------
```



##  <span id ="cartesian">cartesian</span>


```scala  
  /**
   * Return the Cartesian product of this RDD and another one, that is, the RDD of all pairs of
   * elements (a, b) where a is in `this` and b is in `other`.
   */
  def cartesian[U: ClassTag](other: RDD[U]): RDD[(T, U)] = withScope {
    new CartesianRDD(sc, this, other)
  }
```

- 两个rdd取笛卡尔集
- 新的rdd 每个元素为一个二元组
- 没有什么好说的，直接看测试与结果

测试代码
```scala
object Cartesian {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic3.txt")
    val rdd3 = rdd.cartesian(rdd2)
    rdd3.map(r=>r._1+r._2).foreach(println)
  }
}
```

结果

```scala
1,a,c,b3,h,r,x
1,a,c,b4,6,s,b
1,a,c,b5,h,d,o
1,a,c,b6,q,w,e
1,a,c,b7,j,s,b
1,a,c,b8,h,m,o
1,a,c,b9,q,w,c
2,w,gd,h3,h,r,x
2,w,gd,h4,6,s,b
2,w,gd,h5,h,d,o
2,w,gd,h6,q,w,e
2,w,gd,h7,j,s,b
2,w,gd,h8,h,m,o
2,w,gd,h9,q,w,c
3,h,r,x3,h,r,x
3,h,r,x4,6,s,b
3,h,r,x5,h,d,o
3,h,r,x6,q,w,e
3,h,r,x7,j,s,b
3,h,r,x8,h,m,o
3,h,r,x9,q,w,c
4,6,s,b3,h,r,x
4,6,s,b4,6,s,b
4,6,s,b5,h,d,o
4,6,s,b6,q,w,e
4,6,s,b7,j,s,b
4,6,s,b8,h,m,o
4,6,s,b9,q,w,c
5,h,d,o3,h,r,x
5,h,d,o4,6,s,b
5,h,d,o5,h,d,o
5,h,d,o6,q,w,e
5,h,d,o7,j,s,b
5,h,d,o8,h,m,o
5,h,d,o9,q,w,c
6,q,w,e3,h,r,x
6,q,w,e4,6,s,b
6,q,w,e5,h,d,o
6,q,w,e6,q,w,e
6,q,w,e7,j,s,b
6,q,w,e8,h,m,o
6,q,w,e9,q,w,c
```




##  <span id ="groupBy">groupBy</span>

```scala
  /**
   * Return an RDD of grouped items. Each group consists of a key and a sequence of elements
   * mapping to that key. The ordering of elements within each group is not guaranteed, and
   * may even differ each time the resulting RDD is evaluated.
   *
   * @note This operation may be very expensive. If you are grouping in order to perform an
   * aggregation (such as a sum or average) over each key, using `PairRDDFunctions.aggregateByKey`
   * or `PairRDDFunctions.reduceByKey` will provide much better performance.
   */
  def groupBy[K](f: T => K)(implicit kt: ClassTag[K]): RDD[(K, Iterable[T])] = withScope {
    groupBy[K](f, defaultPartitioner(this))
  }

  /**
   * Return an RDD of grouped elements. Each group consists of a key and a sequence of elements
   * mapping to that key. The ordering of elements within each group is not guaranteed, and
   * may even differ each time the resulting RDD is evaluated.
   *
   * @note This operation may be very expensive. If you are grouping in order to perform an
   * aggregation (such as a sum or average) over each key, using `PairRDDFunctions.aggregateByKey`
   * or `PairRDDFunctions.reduceByKey` will provide much better performance.
   */
  def groupBy[K](
      f: T => K,
      numPartitions: Int)(implicit kt: ClassTag[K]): RDD[(K, Iterable[T])] = withScope {
    groupBy(f, new HashPartitioner(numPartitions))
  }

  /**
   * Return an RDD of grouped items. Each group consists of a key and a sequence of elements
   * mapping to that key. The ordering of elements within each group is not guaranteed, and
   * may even differ each time the resulting RDD is evaluated.
   *
   * @note This operation may be very expensive. If you are grouping in order to perform an
   * aggregation (such as a sum or average) over each key, using `PairRDDFunctions.aggregateByKey`
   * or `PairRDDFunctions.reduceByKey` will provide much better performance.
   */
  def groupBy[K](f: T => K, p: Partitioner)(implicit kt: ClassTag[K], ord: Ordering[K] = null)
      : RDD[(K, Iterable[T])] = withScope {
    val cleanF = sc.clean(f)
    this.map(t => (cleanF(t), t)).groupByKey(p)
  }
```

- 最简单的形式是 接受一个 返回分组因子的函数
- 返回一个二元组，第一个元素为提取出来的因子，第二个元素为这个因子对应的内容的集合（Iterator）

```scala
object TestGroupBy {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")

  def main(args: Array[String]): Unit = {
    val rdd = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic.txt")
    val rdd2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkbasic3.txt")
    val rdd3 = (rdd++rdd2).groupBy(r=>{
      r.split(",",-1)(0)
    }).foreach(r=>{
      println("-------------------")
      println(r._1)
      for(str <- r._2){
        println(str)
      }
    })
  }
}
```

测试结果

```note
-------------------
4
4,6,s,b
4,6,s,b
-------------------
8
8,h,m,o
-------------------
6
6,q,w,e
6,q,w,e
-------------------
2
2,w,gd,h
-------------------
7
7,j,s,b
-------------------
5
5,h,d,o
5,h,d,o
-------------------
9
9,q,w,c
-------------------
3
3,h,r,x
3,h,r,x
-------------------
1
1,a,c,b
```



##  <span id ="zip">zip</span>


```scala
  /**
   * Zips this RDD with another one, returning key-value pairs with the first element in each RDD,
   * second element in each RDD, etc. Assumes that the two RDDs have the *same number of
   * partitions* and the *same number of elements in each partition* (e.g. one was made through
   * a map on the other).
   */
  def zip[U: ClassTag](other: RDD[U]): RDD[(T, U)] = withScope {
    zipPartitions(other, preservesPartitioning = false) { (thisIter, otherIter) =>
      new Iterator[(T, U)] {
        def hasNext: Boolean = (thisIter.hasNext, otherIter.hasNext) match {
          case (true, true) => true
          case (false, false) => false
          case _ => throw new SparkException("Can only zip RDDs with " +
            "same number of elements in each partition")
        }
        def next(): (T, U) = (thisIter.next(), otherIter.next())
      }
    }
  }

  /**
   * Zip this RDD's partitions with one (or more) RDD(s) and return a new RDD by
   * applying a function to the zipped partitions. Assumes that all the RDDs have the
   * *same number of partitions*, but does *not* require them to have the same number
   * of elements in each partition.
   */
  def zipPartitions[B: ClassTag, V: ClassTag]
      (rdd2: RDD[B], preservesPartitioning: Boolean)
      (f: (Iterator[T], Iterator[B]) => Iterator[V]): RDD[V] = withScope {
    new ZippedPartitionsRDD2(sc, sc.clean(f), this, rdd2, preservesPartitioning)
  }

  def zipPartitions[B: ClassTag, V: ClassTag]
      (rdd2: RDD[B])
      (f: (Iterator[T], Iterator[B]) => Iterator[V]): RDD[V] = withScope {
    zipPartitions(rdd2, preservesPartitioning = false)(f)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C], preservesPartitioning: Boolean)
      (f: (Iterator[T], Iterator[B], Iterator[C]) => Iterator[V]): RDD[V] = withScope {
    new ZippedPartitionsRDD3(sc, sc.clean(f), this, rdd2, rdd3, preservesPartitioning)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C])
      (f: (Iterator[T], Iterator[B], Iterator[C]) => Iterator[V]): RDD[V] = withScope {
    zipPartitions(rdd2, rdd3, preservesPartitioning = false)(f)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, D: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C], rdd4: RDD[D], preservesPartitioning: Boolean)
      (f: (Iterator[T], Iterator[B], Iterator[C], Iterator[D]) => Iterator[V]): RDD[V] = withScope {
    new ZippedPartitionsRDD4(sc, sc.clean(f), this, rdd2, rdd3, rdd4, preservesPartitioning)
  }

  def zipPartitions[B: ClassTag, C: ClassTag, D: ClassTag, V: ClassTag]
      (rdd2: RDD[B], rdd3: RDD[C], rdd4: RDD[D])
      (f: (Iterator[T], Iterator[B], Iterator[C], Iterator[D]) => Iterator[V]): RDD[V] = withScope {
    zipPartitions(rdd2, rdd3, rdd4, preservesPartitioning = false)(f)
  }
```


讲两个RDD组合成key-value的形式。要求两个RDD有相同的分区数，每个分区的元素数量相同

```note
#测试数据
# sparkzip1.txt
A1
A2
A3
A4
# sparkzip2.txt
A5
A6
# sparkzip3.txt
B1
B2
B3
B4
# sparkzip4.txt
B5
B6
```
测试代码
```scala
object TestZip {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    val a = a1++a2
    val b = b1++b2
    val ziprdd = a.zip(b)
    ziprdd.foreach(a=>println(a._1+""+a._2))
  }
}
```
运行结果

```note
A1B1
A2B2
A3B3
A4B4
A5B5
A6B6
```

根据描述，zip对于操作的RDD有比较严格的要求，我们来改动一下程序看看结果

```scala
object TestZip {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    val a = a1++a2
//    val b = b1++b2
    val b = b2++b1
    val ziprdd = a.zip(b)
    ziprdd.foreach(a=>println(a._1+""+a._2))
  }
}
```


```note
18/04/09 09:30:51 INFO StateStoreCoordinatorRef: Registered StateStoreCoordinator endpoint
A1B5
A2B6
18/04/09 09:30:52 ERROR Executor: Exception in task 0.0 in stage 0.0 (TID 0)
org.apache.spark.SparkException: Can only zip RDDs with same number of elements in each partition
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.hasNext(RDD.scala:860)
	at scala.collection.Iterator$class.foreach(Iterator.scala:893)
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.foreach(RDD.scala:856)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:87)
	at org.apache.spark.scheduler.Task.run(Task.scala:108)
	at org.apache.spark.executor.Executor$TaskRunner.run(Executor.scala:335)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
18/04/09 09:30:52 ERROR TaskSetManager: Task 0 in stage 0.0 failed 1 times; aborting job
A5B1
A6B2
18/04/09 09:30:52 ERROR Executor: Exception in task 1.0 in stage 0.0 (TID 1)
org.apache.spark.SparkException: Can only zip RDDs with same number of elements in each partition
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.hasNext(RDD.scala:860)
	at scala.collection.Iterator$class.foreach(Iterator.scala:893)
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.foreach(RDD.scala:856)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:87)
	at org.apache.spark.scheduler.Task.run(Task.scala:108)
	at org.apache.spark.executor.Executor$TaskRunner.run(Executor.scala:335)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
Exception in thread "main" org.apache.spark.SparkException: Job aborted due to stage failure: Task 0 in stage 0.0 failed 1 times, most recent failure: Lost task 0.0 in stage 0.0 (TID 0, localhost, executor driver): org.apache.spark.SparkException: Can only zip RDDs with same number of elements in each partition
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.hasNext(RDD.scala:860)
	at scala.collection.Iterator$class.foreach(Iterator.scala:893)
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.foreach(RDD.scala:856)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:87)
	at org.apache.spark.scheduler.Task.run(Task.scala:108)
	at org.apache.spark.executor.Executor$TaskRunner.run(Executor.scala:335)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)

Driver stacktrace:
	at org.apache.spark.scheduler.DAGScheduler.org$apache$spark$scheduler$DAGScheduler$$failJobAndIndependentStages(DAGScheduler.scala:1499)
	at org.apache.spark.scheduler.DAGScheduler$$anonfun$abortStage$1.apply(DAGScheduler.scala:1487)
	at org.apache.spark.scheduler.DAGScheduler$$anonfun$abortStage$1.apply(DAGScheduler.scala:1486)
	at scala.collection.mutable.ResizableArray$class.foreach(ResizableArray.scala:59)
	at scala.collection.mutable.ArrayBuffer.foreach(ArrayBuffer.scala:48)
	at org.apache.spark.scheduler.DAGScheduler.abortStage(DAGScheduler.scala:1486)
	at org.apache.spark.scheduler.DAGScheduler$$anonfun$handleTaskSetFailed$1.apply(DAGScheduler.scala:814)
	at org.apache.spark.scheduler.DAGScheduler$$anonfun$handleTaskSetFailed$1.apply(DAGScheduler.scala:814)
	at scala.Option.foreach(Option.scala:257)
	at org.apache.spark.scheduler.DAGScheduler.handleTaskSetFailed(DAGScheduler.scala:814)
	at org.apache.spark.scheduler.DAGSchedulerEventProcessLoop.doOnReceive(DAGScheduler.scala:1714)
	at org.apache.spark.scheduler.DAGSchedulerEventProcessLoop.onReceive(DAGScheduler.scala:1669)
	at org.apache.spark.scheduler.DAGSchedulerEventProcessLoop.onReceive(DAGScheduler.scala:1658)
	at org.apache.spark.util.EventLoop$$anon$1.run(EventLoop.scala:48)
	at org.apache.spark.scheduler.DAGScheduler.runJob(DAGScheduler.scala:630)
	at org.apache.spark.SparkContext.runJob(SparkContext.scala:2022)
	at org.apache.spark.SparkContext.runJob(SparkContext.scala:2043)
	at org.apache.spark.SparkContext.runJob(SparkContext.scala:2062)
	at org.apache.spark.SparkContext.runJob(SparkContext.scala:2087)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1.apply(RDD.scala:918)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1.apply(RDD.scala:916)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:151)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:112)
	at org.apache.spark.rdd.RDD.withScope(RDD.scala:362)
	at org.apache.spark.rdd.RDD.foreach(RDD.scala:916)
	at basic.TestZip$.main(TestZip.scala:25)
	at basic.TestZip.main(TestZip.scala)
Caused by: org.apache.spark.SparkException: Can only zip RDDs with same number of elements in each partition
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.hasNext(RDD.scala:860)
	at scala.collection.Iterator$class.foreach(Iterator.scala:893)
	at org.apache.spark.rdd.RDD$$anonfun$zip$1$$anonfun$apply$27$$anon$2.foreach(RDD.scala:856)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.rdd.RDD$$anonfun$foreach$1$$anonfun$apply$28.apply(RDD.scala:918)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2062)
	at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:87)
	at org.apache.spark.scheduler.Task.run(Task.scala:108)
	at org.apache.spark.executor.Executor$TaskRunner.run(Executor.scala:335)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)

Process finished with exit code 1

```

- 可以看出，符合条件的部分还是按照预期数除了
- zip会按照顺序对rdd和rdd中的元素进行匹配
  - 如果RDD分区数量不同，会直接报错，不执行程序（测试很简单，没在例子中展示）
  - 如果对应RDD中元素不同，程序还是会匹配一部分合格的数据

##  <span id ="foreachPartition">foreachPartition</span>

```scala
// 源码
 /**
   * Applies a function f to each partition of this RDD.
   */
  def foreachPartition(f: Iterator[T] => Unit): Unit = withScope {
    val cleanF = sc.clean(f)
    sc.runJob(this, (iter: Iterator[T]) => cleanF(iter))
  }
```

输入
  - 一个函数
    - 入参是一个 Iterator
    - 无返回值
作用
  - 内部会把一个分区的数据的Iterator当作参数传给开发者定义的函数，完成相映的工作

```测试代码
object TestForEachPartition{
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    val rdd = a1++a2++b1++b2
    rdd.foreachPartition(
      r=>{
        var x = ""
        while (r.hasNext){
          x=x+r.next().toString
        }
        println(x)
      }
    )

  }
}
```

测试结果
```scala
A1A2A3A4
A5A6
B1B2B3B4
B5B6
```

- 可以看到，每个分区被连接成了字符串

##  <span id ="collect">collect</span>


```scala
  /**
   * Return an array that contains all of the elements in this RDD.
   *
   * @note This method should only be used if the resulting array is expected to be small, as
   * all the data is loaded into the driver's memory.
   */
  def collect(): Array[T] = withScope {
    val results = sc.runJob(this, (iter: Iterator[T]) => iter.toArray)
    Array.concat(results: _*)
  }

    /**
   * Return an RDD that contains all matching values by applying `f`.
   */
  def collect[U: ClassTag](f: PartialFunction[T, U]): RDD[U] = withScope {
    val cleanF = sc.clean(f)
    filter(cleanF.isDefinedAt).map(cleanF)
  }
```

返回一个包含RDD中所有的元素的数组

注意： 因为所有数据会在这个步骤装载到内存中，我们希望这个数组不要太大

>基础方法测试

```scala
object TestCollect {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    val rdd = a1++a2++b1++b2
    val array = rdd.collect()
    for(str<-array){
      println(str)
    }

  }
}
```

输出

```note
A1
A2
A3
A4
A5
A6
B1
B2
B3
B4
B5
B6
```

>带过滤的方法测试

在源代码中可以看到，collect实际上把我们提供的函数传-一个标准偏函数-递给了 filter

filter实际上是要求对元素进行判断并返回布尔值

```scala
// 自己实现的一个偏函数，因为spark 总使用，需要可序列化
class MyParitialFunction extends Serializable   with PartialFunction [Any,String]{
  override def isDefinedAt(x: Any): Boolean = if(x.toString.startsWith("A")) true else false

  override def apply(v1: Any): String = v1.toString
}
// 测试如下
object TestCollect {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    val rdd4 = sc.parallelize(List(1, 2, 3))
    val rdd = a1 ++ a2 ++ b1 ++ b2
    val array = rdd.collect()
    for (str <- array) {
      println(str)
    }

    val array2 = rdd.collect { case a: String => {
      if (a.startsWith("A")) a
    }
    }
    val array3 = rdd.collect(new MyParitialFunction)


    println(" array2")
    for (str <- array2) {
      println(str)
    }
    println("array 3")
    for (str <- array3) {
      println(str)
    }
  }
}
```

结果

```note
A1
A2
A3
A4
A5
A6
B1
B2
B3
B4
B5
B6
 array2
A1
A2
A3
A4
A5
A6
()
()
()
()
()
()
array 3
A1
A2
A3
A4
A5
A6
```

- 结论
  - 在List类型的collect中给定一个 case实现的偏函数是一种很方便的提取指定类型数据，然后操作返回的方法
  - 在SparkRDD中这样操作我个人目前没发发现太大的一以，因为RDD中一般存储相同类型的内容，没有必要用偏函数的过滤特性，而如果我们需要筛选，在之前多一部 filter函数，可能是更优秀的选择

##  <span id ="toLocalIterator">toLocalIterator</span>


 ```scala
 /**
   * Return an iterator that contains all of the elements in this RDD.
   *
   * The iterator will consume as much memory as the largest partition in this RDD.
   *
   * @note This results in multiple Spark jobs, and if the input RDD is the result
   * of a wide transformation (e.g. join with different partitioners), to avoid
   * recomputing the input RDD should be cached first.
   */
  def toLocalIterator: Iterator[T] = withScope {
    def collectPartition(p: Int): Array[T] = {
      sc.runJob(this, (iter: Iterator[T]) => iter.toArray, Seq(p)).head
    }
    (0 until partitions.length).iterator.flatMap(i => collectPartition(i))
  }
```

返回一个包含RDD所有元素的iterator。iterator占用RDD中最大分区的内存大小

源码分析
```scala
//首先是一个内部方法
    def collectPartition(p: Int): Array[T] = {
      sc.runJob(this, (iter: Iterator[T]) => iter.toArray, Seq(p)).head
    }
    
```
从方法名可以看出，这是用来获取分区的
其中 sc.runJob
```scala
// runJob有许多重载，我们看直接使用的这一个
  /**
   * Run a function on a given set of partitions in an RDD and return the results as an array.
   *
   * @param rdd target RDD to run tasks on
   * @param func a function to run on each partition of the RDD
   * @param partitions set of partitions to run on; some jobs may not want to compute on all
   * partitions of the target RDD, e.g. for operations like `first()`
   * @return in-memory collection with a result of the job (each collection element will contain
   * a result from one partition)
   */
  def runJob[T, U: ClassTag](
      rdd: RDD[T],
      func: Iterator[T] => U,
      partitions: Seq[Int]): Array[U] = {
    val cleanedFunc = clean(func)
    runJob(rdd, (ctx: TaskContext, it: Iterator[T]) => cleanedFunc(it), partitions)
  }
  //在RDD的指定的某些分区中执行给定的函数，返回一个结果数组
  // runJob的体系和DAG相关，不再往后查找了（点了点代码，太深了）
```
再toLocalIterator代码中，传递给runJob的方法是
```scala
(iter: Iterator[T]) => iter.toArray
// 这个方法是交给 spark 来执行的，spark会把自己的rdd的iterator带入这个函数，返回的是这个iterator的 .toArray => 完成的工作就是整个RDD元素转未了Array
```

回到最外层的代码中
```scala
  def toLocalIterator: Iterator[T] = withScope {
    def collectPartition(p: Int): Array[T] = {
      sc.runJob(this, (iter: Iterator[T]) => iter.toArray, Seq(p)).head
    }
    (0 until partitions.length).iterator.flatMap(i => collectPartition(i))
  }
```
其中
```scala
    (0 until partitions.length).iterator.flatMap(i => collectPartition(i))
// 0 until 10 获取的是一个 Range 
// 下面简单看一下Range的定义 不做过多解释
class Range(val start: Int, val end: Int, val step: Int)
extends scala.collection.AbstractSeq[Int]
   with IndexedSeq[Int]
   with scala.collection.CustomParallelizable[Int, ParRange]
   with Serializable
```
这里有一点就是 iterator 中的flatMap
```scala
  /** Creates a new iterator by applying a function to all values produced by this iterator
   *  and concatenating the results.
   *
   *  @param f the function to apply on each element.
   *  @return  the iterator resulting from applying the given iterator-valued function
   *           `f` to each value produced by this iterator and concatenating the results.
   *  @note    Reuse: $consumesAndProducesIterator
   */
  def flatMap[B](f: A => GenTraversableOnce[B]): Iterator[B] = new AbstractIterator[B] {
//missingli： 这实际上就是一个 嵌套的 iterator，外层iterator存储的元素是一个iterator，每次外部访问，向循环 外层iterator存储的iterator，然后 循环外层iterator

    // 要求输入参数 返回一个 可遍历的 类型
    // 返回一个iterator
    
    // 这个Iterator是一个 AbstractIterator的 实例

    private var cur: Iterator[B] = empty
    //获得一个空的 iterator

    private def nextCur() { cur = f(self.next()).toIterator }
    // nextCur  

    def hasNext: Boolean = {
      // Equivalent to cur.hasNext || self.hasNext && { nextCur(); hasNext }
      // but slightly shorter bytecode (better JVM inlining!)
      while (!cur.hasNext) {  //如果当前存储的iterator 没有元素了 就把外部的元素向下走一位置，并且把 
        if (!self.hasNext) return false//遍历外层 如果外层没有了，就真的没有了
        nextCur()//当前到头了，外部还每到头，就  =>外部的下个元素的 iterator 指向 cur
      }
      true
    }
    def next(): B = (if (hasNext) cur else empty).next()
  }
  // 对一个 iterator 的每个元素执行一个function，并把所有的结果汇总返回成一个 iterator

  // 内外代码整合大概是下面这个逻辑
    // 1.collectPartition 把RDD每个分区转成一个Array
    // 2.通过Range的flatMap,获得一个(分区Iterator-分区Array.toIterator) 复合的Iterator
  
```


测试代码

```scala
object TestToLocalIterator {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    val rdd = a1++a2++b1++b2
    val iter = rdd.toLocalIterator
    while (iter.hasNext){
      println(iter.next())
    }
  }
}
```
测试结果
```note
A1
A2
A3
A4
A5
A6
B1
B2
B3
B4
B5
B6
```

##  <span id ="subtract">subtract</span>


```scala
/**
   * Return an RDD with the elements from `this` that are not in `other`.
   *
   * Uses `this` partitioner/partition size, because even if `other` is huge, the resulting
   * RDD will be &lt;= us.
   */
  def subtract(other: RDD[T]): RDD[T] = withScope {
    subtract(other, partitioner.getOrElse(new HashPartitioner(partitions.length)))
  }

  /**
   * Return an RDD with the elements from `this` that are not in `other`.
   */
  def subtract(other: RDD[T], numPartitions: Int): RDD[T] = withScope {
    subtract(other, new HashPartitioner(numPartitions))
  }

  /**
   * Return an RDD with the elements from `this` that are not in `other`.
   */
  def subtract(
      other: RDD[T],
      p: Partitioner)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
    if (partitioner == Some(p)) {
      // Our partitioner knows how to handle T (which, since we have a partitioner, is
      // really (K, V)) so make a new Partitioner that will de-tuple our fake tuples
      val p2 = new Partitioner() {
        override def numPartitions: Int = p.numPartitions
        override def getPartition(k: Any): Int = p.getPartition(k.asInstanceOf[(Any, _)]._1)
      }
      // Unfortunately, since we're making a new p2, we'll get ShuffleDependencies
      // anyway, and when calling .keys, will not have a partitioner set, even though
      // the SubtractedRDD will, thanks to p2's de-tupled partitioning, already be
      // partitioned by the right/real keys (e.g. p).
      this.map(x => (x, null)).subtractByKey(other.map((_, null)), p2).keys
    } else {
      this.map(x => (x, null)).subtractByKey(other.map((_, null)), p).keys
    }
  }
```

- 减法操作，返回当前rdd中，与提供rdd不同的部分

- 主要测试内容与结论
  - rdd3=rdd1.subtract(rdd2) 
  - 1.验证减操作
  - 2.验证当rdd1 存在多份与rdd2 中相同内容的情况

```scala
A1
A2
A3
A4
A5
A6
 subtract 
A1
A3
A2
A4
--------------------
A1
A2
A3
A4
A5
A6
A5
A6
subtract
A1
A4
A2
A3

Process finished with exit code 0

```

结论： 当rdd中存在多份相同数据，而减法操作中出现了相同数据的时候，所有数据都会被匹配并去除

##  <span id ="reduce">reduce</span>

```scala
  /**
   * Reduces the elements of this RDD using the specified commutative and
   * associative binary operator.
   */
  def reduce(f: (T, T) => T): T = withScope {
    val cleanF = sc.clean(f)
    val reducePartition: Iterator[T] => Option[T] = iter => {
      if (iter.hasNext) {
        Some(iter.reduceLeft(cleanF))
      } else {
        None
      }
    }
    var jobResult: Option[T] = None
    val mergeResult = (index: Int, taskResult: Option[T]) => {
      if (taskResult.isDefined) {
        jobResult = jobResult match {
          case Some(value) => Some(f(value, taskResult.get))
          case None => taskResult
        }
      }
    }
    sc.runJob(this, reducePartition, mergeResult)
    // Get the final result out of our Option, or throw an exception if the RDD was empty
    jobResult.getOrElse(throw new UnsupportedOperationException("empty collection"))
  }
```

- 作用： 给定一个函数，输入 rdd两个元素，返回一个同类型元素

-测试代码
```scala
package basic

import org.apache.spark.sql.SparkSession

/**
  * 
  */
object TestReduce {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val a1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip1.txt")
  val a2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip2.txt")
  val b1 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip3.txt")
  val b2 = sc.textFile("/home/missingli/IdeaProjects/SparkLearn/src/main/resources/sparkzip4.txt")

  def main(args: Array[String]): Unit = {
    println("---------String-----")
    val rdd1 = a1 ;
    val rdd2 =rdd1.reduce(_+_)
    println(rdd2)
    println("----------Int-----------")
    val c = sc.parallelize(1 to 10)
    val c2 = c.reduce(_+_)
    println(c2)
    println("----------Int with partition--------")
    val c3 = c++c++c;
    val c4 =c3.reduce(_+_)
    println(c4)

  }
}
```

代码输出

```note
---------String-----
A1A2A3A4
----------Int-----------
55
----------Int with partition--------
165
```

- 结论
  - 按照指定的函数进行计算
  - 会计算整个rdd（跨分区）
  - 因为需要用计算结果带入提供的函数连续计算，所以限制了返回类型必须和输入类型一样
- 作用
  - 可以用来数字求和
  - 可以用来求最值
  - 其他

```scala
//求最值写法
    println("----------find the largest number-----------")
    val c5 = c.reduce((x,y)=>if(x>y) x else y)
    println(c5)
```


```note
----------find the largest number-----------
10
```


##  <span id ="treeReduce">treeReduce</span>

```scala
  /**
   * Reduces the elements of this RDD in a multi-level tree pattern.
   *
   * @param depth suggested depth of the tree (default: 2)
   * @see [[org.apache.spark.rdd.RDD#reduce]]
   */
  def treeReduce(f: (T, T) => T, depth: Int = 2): T = withScope {
    require(depth >= 1, s"Depth must be greater than or equal to 1 but got $depth.")
    val cleanF = context.clean(f)
    val reducePartition: Iterator[T] => Option[T] = iter => {
      if (iter.hasNext) {
        Some(iter.reduceLeft(cleanF))
      } else {
        None
      }
    }
    val partiallyReduced = mapPartitions(it => Iterator(reducePartition(it)))
    val op: (Option[T], Option[T]) => Option[T] = (c, x) => {
      if (c.isDefined && x.isDefined) {
        Some(cleanF(c.get, x.get))
      } else if (c.isDefined) {
        c
      } else if (x.isDefined) {
        x
      } else {
        None
      }
    }
    partiallyReduced.treeAggregate(Option.empty[T])(op, op, depth)
      .getOrElse(throw new UnsupportedOperationException("empty collection"))
  }
```

- 从作用上看 reduce 与 tree reduce 差不多

```scala
package basic

import org.apache.spark.sql.SparkSession

/**
  * 
  */
object TestTreeRedcue {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  def main(args: Array[String]): Unit = {

    println("----------reduce-----------")
    val c = sc.parallelize(1 to 10)
    val c2 = c.reduce(_+_)
    println(c2)
    println("-----------tree redcue-------")
    val c3 = c.treeReduce(_+_);
    println(c3)
  }
}

```

结果

```scala
----------reduce-----------
55
-----------tree redcue-------
55
```

区别（攻略文档中看到的）
- TreeReduce 应用与单个reduce操作开销较大的情况，会针对每个分区现行计算，然后聚合得到最终结果。
- 实际应用中可以代替 reduce

##  <span id ="fold">fold</span>

- 通过给定的 associative function(结合函数)和一个"zero value"。对每个分区的元素进行聚合得到相应结果，然后对每个分区的结果进行聚合 
- fold与reduce类似，区别是可以给定一个零值/初始值
```scala
  /**
   * Aggregate the elements of each partition, and then the results for all the partitions, using a
   * given associative function and a neutral "zero value". The function
   * op(t1, t2) is allowed to modify t1 and return it as its result value to avoid object
   * allocation; however, it should not modify t2.
   *
   * This behaves somewhat differently from fold operations implemented for non-distributed
   * collections in functional languages like Scala. This fold operation may be applied to
   * partitions individually, and then fold those results into the final result, rather than
   * apply the fold to each element sequentially in some defined ordering. For functions
   * that are not commutative, the result may differ from that of a fold applied to a
   * non-distributed collection.
   *
   * @param zeroValue the initial value for the accumulated result of each partition for the `op`
   *                  operator, and also the initial value for the combine results from different
   *                  partitions for the `op` operator - this will typically be the neutral
   *                  element (e.g. `Nil` for list concatenation or `0` for summation)
   * @param op an operator used to both accumulate results within a partition and combine results
   *                  from different partitions
   */
  def fold(zeroValue: T)(op: (T, T) => T): T = withScope {
    // Clone the zero value since we will also be serializing it as part of tasks
    var jobResult = Utils.clone(zeroValue, sc.env.closureSerializer.newInstance())
    val cleanOp = sc.clean(op)
    val foldPartition = (iter: Iterator[T]) => iter.fold(zeroValue)(cleanOp)
    val mergeResult = (index: Int, taskResult: T) => jobResult = op(jobResult, taskResult)
    sc.runJob(this, foldPartition, mergeResult)
    jobResult
  }
```

测试代码

```scala
object TestFold {
  val ss = SparkSession.builder().master("local").appName("basic").getOrCreate()
  val sc = ss.sparkContext
  sc.setLogLevel("error")
  val x = List(1,2,3,4,5,6,7,8,9);
  val rdd1 = sc.parallelize(x,1)
  val rdd2 = sc.parallelize(x,2)
  val a1 =rdd1.fold(100)((x,y)=>x+y)
  val a2 =rdd2.fold(100)((x,y)=>x+y)


  def main(args: Array[String]): Unit = {
    println("a1:" + a1)
    print("a2:" + a2)
  }
}
```
测试结果

```note
a1:245
a2:345
```

- 结论
  - a1 所对应的rdd 只有一个分区
    - 首先 计算 100（零数值）+1，2，3，4，5，6，7，8，9 得到 145
    - 然后计算 100 + 各个分区的结果（因为只有一个分区，所以是 145）
    - 最终结果 245
  - a2 对应rdd 有来嗯个分区
    - 首先每个分区计算  100 + 分区内容合
    - 然后计算分区总赫 100 + 分区1结果 + 分区2结果
    - 就是  100 + 100+ 分区1内容 + 10 + 分区2 内容  （其中 分区1内容+ 分区2 内容为 45）
    - 结果 345

##  <span id ="aggregate">aggregate</span>


- 源码解析
  - 1. 参数 zeroValue 类型 U
  - 2. 参数函数1 seqOp (U,T)=>U
    - 用来对一个分区中的元素进行晕眩
  - 3. 参数函数2 comOp (U,U)=>U
    - 用来对分区之间的结果进行计算
  - 

```scala
 /**
   * Aggregate the elements of each partition, and then the results for all the partitions, using
   * given combine functions and a neutral "zero value". This function can return a different result
   * type, U, than the type of this RDD, T. Thus, we need one operation for merging a T into an U
   * and one operation for merging two U's, as in scala.TraversableOnce. Both of these functions are
   * allowed to modify and return their first argument instead of creating a new U to avoid memory
   * allocation.
   *
   * @param zeroValue the initial value for the accumulated result of each partition for the
   *                  `seqOp` operator, and also the initial value for the combine results from
   *                  different partitions for the `combOp` operator - this will typically be the
   *                  neutral element (e.g. `Nil` for list concatenation or `0` for summation)
   * @param seqOp an operator used to accumulate results within a partition
   * @param combOp an associative operator used to combine results from different partitions
   */
  def aggregate[U: ClassTag](zeroValue: U)(seqOp: (U, T) => U, combOp: (U, U) => U): U = withScope {
    // Clone the zero value since we will also be serializing it as part of tasks
    var jobResult = Utils.clone(zeroValue, sc.env.serializer.newInstance())
    val cleanSeqOp = sc.clean(seqOp)
    val cleanCombOp = sc.clean(combOp)
    val aggregatePartition = (it: Iterator[T]) => it.aggregate(zeroValue)(cleanSeqOp, cleanCombOp)
    val mergeResult = (index: Int, taskResult: U) => jobResult = combOp(jobResult, taskResult)
    sc.runJob(this, aggregatePartition, mergeResult)
    jobResult
  }

  /**
   * Aggregates the elements of this RDD in a multi-level tree pattern.
   *
   * @param depth suggested depth of the tree (default: 2)
   * @see [[org.apache.spark.rdd.RDD#aggregate]]
   */
  def treeAggregate[U: ClassTag](zeroValue: U)(
      seqOp: (U, T) => U,
      combOp: (U, U) => U,
      depth: Int = 2): U = withScope {
    require(depth >= 1, s"Depth must be greater than or equal to 1 but got $depth.")
    if (partitions.length == 0) {
      Utils.clone(zeroValue, context.env.closureSerializer.newInstance())
    } else {
      val cleanSeqOp = context.clean(seqOp)
      val cleanCombOp = context.clean(combOp)
      val aggregatePartition =
        (it: Iterator[T]) => it.aggregate(zeroValue)(cleanSeqOp, cleanCombOp)
      var partiallyAggregated = mapPartitions(it => Iterator(aggregatePartition(it)))
      var numPartitions = partiallyAggregated.partitions.length
      val scale = math.max(math.ceil(math.pow(numPartitions, 1.0 / depth)).toInt, 2)
      // If creating an extra level doesn't help reduce
      // the wall-clock time, we stop tree aggregation.

      // Don't trigger TreeAggregation when it doesn't save wall-clock time
      while (numPartitions > scale + math.ceil(numPartitions.toDouble / scale)) {
        numPartitions /= scale
        val curNumPartitions = numPartitions
        partiallyAggregated = partiallyAggregated.mapPartitionsWithIndex {
          (i, iter) => iter.map((i % curNumPartitions, _))
        }.reduceByKey(new HashPartitioner(curNumPartitions), cleanCombOp).values
      }
      partiallyAggregated.reduce(cleanCombOp)
    }
  }
```

- aggregate 和 reduce/fold有些类似
  - 复习一下
    - reduce 对数据进行 reduce
    - fold 对数据进行有初始值的 reduce（注意数据分区情况下存在的问题）
  - aggregate

首先还是用一个普通的示例：
```scala
    val rdd = sc.parallelize(List(1,2,3,4,5,6,7,8,9))
    val result = rdd.aggregate(0)((x,y)=>x+y,(x,y)=>x+y);
    println(result) //45
```

从参数函数 seqOp 可以看到， aggregate可以生成与RDD中元素不同类型的结果（RDD： T ，结果 ：U）

我们下面做一个简单测试

```scala
    val result2 = rdd.aggregate((0, 0))(
      (x, y) => (x._1 + 1, x._2 + y)
    ,
      (a, b) => (a._1 + b._1, a._2 + b._2))
    println(result2) //(9,45)
```

这里 我们的 类型 U 实际是一个 二元组，相当于 key-value的形式。

在处理过程中，要保证 zeroValue和来个函数的返回值保持同一个形式

稍微改动一下函数，看一下运行过程

```scala
    val result2 = rdd.aggregate((0, 0))(
      (x, y) => {
        println("x:"+x)
        (x._1 + 1, x._2 + y)}
    ,
      (a, b) => (a._1 + b._1, a._2 + b._2))
    println(result2) //(9,45)
    }
```

打印出来的流程

```note
x:(0,0)
x:(1,1)
x:(2,3)
x:(3,6)
x:(4,10)
x:(5,15)
x:(6,21)
x:(7,28)
x:(8,36)
```

##  <span id ="count">count</span>

```scala

  /**
   * Return the number of elements in the RDD.
   */
  def count(): Long = sc.runJob(this, Utils.getIteratorSize _).sum

  /**
   * Approximate version of count() that returns a potentially incomplete result
   * within a timeout, even if not all tasks have finished.
   *
   * The confidence is the probability that the error bounds of the result will
   * contain the true value. That is, if countApprox were called repeatedly
   * with confidence 0.9, we would expect 90% of the results to contain the
   * true count. The confidence must be in the range [0,1] or an exception will
   * be thrown.
   *
   * @param timeout maximum time to wait for the job, in milliseconds
   * @param confidence the desired statistical confidence in the result
   * @return a potentially incomplete result, with error bounds
   */
  def countApprox(
      timeout: Long,
      confidence: Double = 0.95): PartialResult[BoundedDouble] = withScope {
    require(0.0 <= confidence && confidence <= 1.0, s"confidence ($confidence) must be in [0,1]")
    val countElements: (TaskContext, Iterator[T]) => Long = { (ctx, iter) =>
      var result = 0L
      while (iter.hasNext) {
        result += 1L
        iter.next()
      }
      result
    }
    val evaluator = new CountEvaluator(partitions.length, confidence)
    sc.runApproximateJob(this, countElements, evaluator, timeout)
  }
```
这里的这个方法的返回值挺有意思

[PartialResult[BoundedDouble]](../../相关内容/07.ParticalResult.md)

```scala
  /**
   * Return the count of each unique value in this RDD as a local map of (value, count) pairs.
   *
   * @note This method should only be used if the resulting map is expected to be small, as
   * the whole thing is loaded into the driver's memory.
   * To handle very large results, consider using
   *
   * {{{
   * rdd.map(x => (x, 1L)).reduceByKey(_ + _)
   * }}}
   *
   * , which returns an RDD[T, Long] instead of a map.
   */
  def countByValue()(implicit ord: Ordering[T] = null): Map[T, Long] = withScope {
    map(value => (value, null)).countByKey()
  }

  /**
   * Approximate version of countByValue().
   *
   * @param timeout maximum time to wait for the job, in milliseconds
   * @param confidence the desired statistical confidence in the result
   * @return a potentially incomplete result, with error bounds
   */
  def countByValueApprox(timeout: Long, confidence: Double = 0.95)
      (implicit ord: Ordering[T] = null)
      : PartialResult[Map[T, BoundedDouble]] = withScope {
    require(0.0 <= confidence && confidence <= 1.0, s"confidence ($confidence) must be in [0,1]")
    if (elementClassTag.runtimeClass.isArray) {
      throw new SparkException("countByValueApprox() does not support arrays")
    }
    val countPartition: (TaskContext, Iterator[T]) => OpenHashMap[T, Long] = { (ctx, iter) =>
      val map = new OpenHashMap[T, Long]
      iter.foreach {
        t => map.changeValue(t, 1L, _ + 1L)
      }
      map
    }
    val evaluator = new GroupedCountEvaluator[T](partitions.length, confidence)
    sc.runApproximateJob(this, countPartition, evaluator, timeout)
  }

  /**
   * Return approximate number of distinct elements in the RDD.
   *
   * The algorithm used is based on streamlib's implementation of "HyperLogLog in Practice:
   * Algorithmic Engineering of a State of The Art Cardinality Estimation Algorithm", available
   * <a href="http://dx.doi.org/10.1145/2452376.2452456">here</a>.
   *
   * The relative accuracy is approximately `1.054 / sqrt(2^p)`. Setting a nonzero (`sp` is greater
   * than `p`) would trigger sparse representation of registers, which may reduce the memory
   * consumption and increase accuracy when the cardinality is small.
   *
   * @param p The precision value for the normal set.
   *          `p` must be a value between 4 and `sp` if `sp` is not zero (32 max).
   * @param sp The precision value for the sparse set, between 0 and 32.
   *           If `sp` equals 0, the sparse representation is skipped.
   */
  def countApproxDistinct(p: Int, sp: Int): Long = withScope {
    require(p >= 4, s"p ($p) must be >= 4")
    require(sp <= 32, s"sp ($sp) must be <= 32")
    require(sp == 0 || p <= sp, s"p ($p) cannot be greater than sp ($sp)")
    val zeroCounter = new HyperLogLogPlus(p, sp)
    aggregate(zeroCounter)(
      (hll: HyperLogLogPlus, v: T) => {
        hll.offer(v)
        hll
      },
      (h1: HyperLogLogPlus, h2: HyperLogLogPlus) => {
        h1.addAll(h2)
        h1
      }).cardinality()
  }

  /**
   * Return approximate number of distinct elements in the RDD.
   *
   * The algorithm used is based on streamlib's implementation of "HyperLogLog in Practice:
   * Algorithmic Engineering of a State of The Art Cardinality Estimation Algorithm", available
   * <a href="http://dx.doi.org/10.1145/2452376.2452456">here</a>.
   *
   * @param relativeSD Relative accuracy. Smaller values create counters that require more space.
   *                   It must be greater than 0.000017.
   */
  def countApproxDistinct(relativeSD: Double = 0.05): Long = withScope {
    require(relativeSD > 0.000017, s"accuracy ($relativeSD) must be greater than 0.000017")
    val p = math.ceil(2.0 * math.log(1.054 / relativeSD) / math.log(2)).toInt
    countApproxDistinct(if (p < 4) 4 else p, 0)
  }

```

- count 的基本作用是 计算rdd中的元素个数
  - countApprox 估算元素个数，给定一个限定时间 timeout，时间结束后直接返回结果（即使此时还未计算完成）
    - 参数1 ： 毫秒为的限定时间
    - 参数2 ： 希望的统计可信度
    - 返回： 一个带有一定范围误差的结果
    - 如果在限定时间内完成，会返回准确的结果
    - 返回的是一个区间，意思是 最终的count值，估计在这个结果区间内，可信度为给定可信度
    - `没有作出能反映更多细节的DEMO`
  - countByValue
    - 返回一个，计算每个元素分别出现的此书，返回 健值对形式 
    ```scala
    val rdd = sc.parallelize(Range(1,10,1))
    val rdd2 = sc.parallelize(Range(1,10,2))
    val rdd3 = rdd++rdd2;
    rdd3.countByValue().foreach(println)
    // 结果如下
    (5,2)
    (1,2)
    (6,1)
    (9,2)
    (2,1)
    (7,2)
    (3,2)
    (8,1)
    (4,1)
    ```
  - countByValueApprox
    - countByValue对应的估算版本
  - countApproxDistinct  - 计算单一元素（不与其他重复的元素）在rdd中大概出现的次数
    - 单一元素： 例如 List(1,2,3,4,4) 那么 1，2，3 会被这个算子计算到
    - 有两个重载
      - 提供两个精度值的版本
        - 参数1 p， 普通set的精度值，介于 4 和参数2之间（如果参数2不为0）
        - 参数2 sp，稀疏set的精度值，在0～32 之间。如果sp为0，会跳过 稀疏表示
      - 提供 一个相对精度
    - 这两者对应数学上不同的算法，暂时没有深入研究
    ```scala
        val rdd = sc.parallelize(Range(1,1000))
    val x =rdd.countApproxDistinct(0.1)
    val y = rdd.countApproxDistinct(0.2)
    val z = rdd.countApproxDistinct(0.6)
    val num = rdd.countApproxDistinct(1)
    val num2 = rdd.countApproxDistinct(100)

    println(x) //1194
    println(y) //1476
    println(z) //1213
    println(num) //1213
    println(num2) //1213
    ```
    - 测试了其中第二个版本，但是测试量很小，当前例子，在给定参数比较小的时候，可以得到较为精确的值（0.01时为1000）