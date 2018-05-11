 ```scala
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
// 最简单的情况，这个函数是这个样子
def sortBy(){}
// 加上泛型，表示可以接受任意类型 ,和泛型匹配的参数
def sortBy[K](f:(T)=>K,asceding:Boolean=true,numParitions:Int=this.paritions.length)(){}
// 这里有三个参数，
//    1. 一个函数， sortBy 的类型，应该和 这个函数的返回值类型一样的，函数的输入类型倒是无所谓
//    2.第二个参数， 表示生序还是降序，这里scala的语法，这个参数如果不提供，会给默认值，表示上升
//    3.第三个参数，宝石分区个数，默认保持原始分区不表
//  ！！！！！ attention  这里想到一点，如果这个sort 比较考前， 可以先让sort 用原始分区数来分区，在最后 数据量缩减之后，再 merge 然后 sort 之类的，应该是优化的一个思路

// 再加上隐式转换 
// 这里贴上一点 代码  ---  取别名
  type Ordering[T] = scala.math.Ordering[T]
  val Ordering = scala.math.Ordering
```
[Ordering的介绍](./20180330-Ordered和Ordering.md)
```scala
def sortBy[泛型](参数&默认参数)(implict 隐式参数):返回值类型={}
// 在这里 ，隐式参数 (implicit ord: Ordering[K], ctag: ClassTag[K])
//  这个隐式参数应该是 环境中提供的  环境中应该有这样的依据
implicit val ord:Ordering[K] = xxxx;

//------------ 我做了一个例子
  implicit val ord:Ordering[String] = null
  def say[K](name : String)(implicit ord:Ordering[K])={
    println(name)
  }
  say("limingshun")
  // 如果有 第一句话 implicit 。。。 可以正常运行
  // 如果没有，编译报错，缺少参数


  // 不过 还有另外一种 方法 显示的提供隐式参数也是可以的
  val ord:Ordering[String] = null
  def say[K](name : String)(implicit ord:Ordering[K])={
    println(name)
  }
  say("limingshun")(ord)//这样可以正常运行
```
下面回到我们的函数
```scala
  def sortBy[K](//泛型 K
    // 参数列表
      f: (T) => K,
      ascending: Boolean = true,
      numPartitions: Int = this.partitions.length)
      (implicit ord: Ordering[K], ctag: ClassTag[K]// 隐式参数列表
      ): RDD[T] //返回类型
      = withScope {
    this.keyBy[K](f)
        .sortByKey(ascending, numPartitions)
        .values
  }
```