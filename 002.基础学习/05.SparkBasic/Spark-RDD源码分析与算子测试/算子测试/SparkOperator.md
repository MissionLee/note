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