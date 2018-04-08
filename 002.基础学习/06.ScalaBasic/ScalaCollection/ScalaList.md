# Scala 列表类似于数组，它们所有元素的类型都相同，但是它们也有所不同：列表是不可变的，值一旦被定义了就不能改变，其次列表 具有递归的结构（也就是链接表结构）而数组不是。。

列表的元素类型 T 可以写成 List[T]。例如，以下列出了多种类型的列表：
```scala
// 字符串列表
val site: List[String] = List("Runoob", "Google", "Baidu")

// 整型列表
val nums: List[Int] = List(1, 2, 3, 4)

// 空列表
val empty: List[Nothing] = List()

// 二维列表
val dim: List[List[Int]] =
   List(
      List(1, 0, 0),
      List(0, 1, 0),
      List(0, 0, 1)
   )
```
## 构造列表的两个基本单位是 Nil 和 ::

- Nil 也可以表示为一个空列表。

以上实例我们可以写成如下所示：
```scala
// 字符串列表
val site = "Runoob" :: ("Google" :: ("Baidu" :: Nil))

// 整型列表
val nums = 1 :: (2 :: (3 :: (4 :: Nil)))

// 空列表
val empty = Nil

// 二维列表
val dim = (1 :: (0 :: (0 :: Nil))) ::
          (0 :: (1 :: (0 :: Nil))) ::
          (0 :: (0 :: (1 :: Nil))) :: Nil
```
## 列表基本操作

Scala列表有三个基本操作：

- head 返回列表第一个元素
- tail 返回一个列表，包含除了第一元素之外的其他元素
- isEmpty 在列表为空时返回true

对于Scala列表的任何操作都可以使用这三个基本操作来表达。实例如下:
```scala
object Test {
   def main(args: Array[String]) {
      val site = "Runoob" :: ("Google" :: ("Baidu" :: Nil))
      val nums = Nil

      println( "第一网站是 : " + site.head )
      println( "最后一个网站是 : " + site.tail )
      println( "查看列表 site 是否为空 : " + site.isEmpty )
      println( "查看 nums 是否为空 : " + nums.isEmpty )
   }
}
```

执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
第一网站是 : Runoob
最后一个网站是 : List(Google, Baidu)
查看列表 site 是否为空 : false
查看 nums 是否为空 : true
```
- 连接列表

你可以使用 ::: 运算符或 List.:::() 方法或 List.concat() 方法来连接两个或多个列表。实例如下:
```scala
object Test {
   def main(args: Array[String]) {
      val site1 = "Runoob" :: ("Google" :: ("Baidu" :: Nil))
      val site2 = "Facebook" :: ("Taobao" :: Nil)

      // 使用 ::: 运算符
      var fruit = site1 ::: site2
      println( "site1 ::: site2 : " + fruit )
      
      // 使用 Set.:::() 方法
      fruit = site1.:::(site2)
      println( "site1.:::(site2) : " + fruit )

      // 使用 concat 方法
      fruit = List.concat(site1, site2)
      println( "List.concat(site1, site2) : " + fruit  )
      

   }
}
```

执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
site1 ::: site2 : List(Runoob, Google, Baidu, Facebook, Taobao)
site1.:::(site2) : List(Facebook, Taobao, Runoob, Google, Baidu)
List.concat(site1, site2) : List(Runoob, Google, Baidu, Facebook, Taobao)
```

- List.fill()

我们可以使用 List.fill() 方法来创建一个指定重复数量的元素列表：
```scala
object Test {
   def main(args: Array[String]) {
      val site = List.fill(3)("Runoob") // 重复 Runoob 3次
      println( "site : " + site  )

      val num = List.fill(10)(2)         // 重复元素 2, 10 次
      println( "num : " + num  )
   }
}
```
执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
site : List(Runoob, Runoob, Runoob)
num : List(2, 2, 2, 2, 2, 2, 2, 2, 2, 2)
```
- List.tabulate()

List.tabulate() 方法是通过给定的函数来创建列表。

方法的第一个参数为`元素的数量`，可以是二维的，第二个参数为`指定的函数`，我们通过指定的函数计算结果并返回值插入到列表中，起始值为 0，实例如下：

```scala
object Test {
   def main(args: Array[String]) {
      // 通过给定的函数创建 5 个元素
      val squares = List.tabulate(6)(n => n * n)
      println( "一维 : " + squares  )

      // 创建二维列表
      val mul = List.tabulate( 4,5 )( _ * _ )      
      println( "多维 : " + mul  )
   }
}
```

执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
一维 : List(0, 1, 4, 9, 16, 25)
多维 : List(List(0, 0, 0, 0, 0), List(0, 1, 2, 3, 4), List(0, 2, 4, 6, 8), List(0, 3, 6, 9, 12))
```

- List.reverse

List.reverse 用于将列表的顺序反转，实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val site = "Runoob" :: ("Google" :: ("Baidu" :: Nil))
      println( "site 反转前 : " + site )

      println( "site 反转前 : " + site.reverse )
   }
}
```
执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
site 反转前 : List(Runoob, Google, Baidu)
site 反转前 : List(Baidu, Google, Runoob)
```
## Scala List 常用方法

下表列出了 Scala List 常用的方法：
```scala

1	
def +:(elem: A): List[A]

为列表预添加元素(并没有想象中的效果，如果 下面 y 已经是一个列表 List(2),那么结果会变成 List(List(2),1)
真正的解释是  把一个 y 加到 List(1) 的前面

scala> val x = List(1)
x: List[Int] = List(1)

scala> val y = 2 +: x
y: List[Int] = List(2, 1)

scala> println(x)
List(1)


2	
def ::(x: A): List[A]

在列表开头添加元素 


3	
def :::(prefix: List[A]): List[A]

在列表开头添加指定列表的元素
y: List[Int] = List(2, 1)
scala> y:::List(3)
res6: List[Int] = List(2, 1, 3)
scala> List(4):::y
res8: List[Int] = List(4, 2, 1)
scala> y
res7: List[Int] = List(2, 1)
这里可以看到，其实无所未 在开头 还是结尾添加 只再与两个列表的书写数据， 操作结果是返回一个新的列表（因为不管y写在前面还是后面，y这个列表都没变，还是需要一个新的）
4	
def :+(elem: A): List[A]

复制添加元素后列表。

scala> val a = List(1)
a: List[Int] = List(1)

scala> val b = a :+ 2
b: List[Int] = List(1, 2)

scala> println(a)
List(1)
// 着一个没什么好说的了， 和 +： 对应

5	
def addString(b: StringBuilder): StringBuilder

将列表的所有元素添加到 StringBuilder
scala> y
res9: List[Int] = List(2, 1)

scala> y.apply(0)
res10: Int = 2

scala> val sb = new StringBuilder
sb: StringBuilder =

scala> y.addString(sb)
res11: StringBuilder = 21

scala> sb
res12: StringBuilder = 21

scala> y.addString(sb)
res13: StringBuilder = 2121


6	
def addString(b: StringBuilder, sep: String): StringBuilder

将列表的所有元素添加到 StringBuilder，并指定分隔符

7	
def apply(n: Int): A

通过列表索引获取元素
scala> y
res9: List[Int] = List(2, 1)

scala> y.apply(0)
res10: Int = 2
8	
def contains(elem: Any): Boolean

检测列表中是否包含指定的元素

9	
def copyToArray(xs: Array[A], start: Int, len: Int): Unit

将列表的元素复制到数组中。
// 总结以下内容： 
//  Array必须和 List 数据类型一样
//  指定长度大与 List的长度 不报错！！！
scala> val array = new Array(10)
array: Array[Nothing] = Array(null, null, null, null, null, null, null, null, null, null)

scala> y.copyToArray(array,0,2)
<console>:14: error: type mismatch;
 found   : Array[Nothing]
 required: Array[Int]
Note: Nothing <: Int, but class Array is invariant in type T.
You may wish to investigate a wildcard type such as `_ <: Int`. (SLS 3.2.10)
       y.copyToArray(array,0,2)
                     ^

scala> val array = new Array[Int](10)
array: Array[Int] = Array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

scala> y.copyToArray(array,0,2)

scala> array
res17: Array[Int] = Array(2, 1, 0, 0, 0, 0, 0, 0, 0, 0)

scala> y.copyToArray(array,0,3)

scala> y
res19: List[Int] = List(2, 1)

scala> array
res20: Array[Int] = Array(2, 1, 0, 0, 0, 0, 0, 0, 0, 0)


10	
def distinct: List[A]

去除列表的重复元素，并返回新列表

11	
def drop(n: Int): List[A]

丢弃前n个元素，并返回新列表

12	
def dropRight(n: Int): List[A]

丢弃最后n个元素，并返回新列表

13	
def dropWhile(p: (A) => Boolean): List[A]

从左向右丢弃元素，直到条件p不成立

14	
def endsWith[B](that: Seq[B]): Boolean

检测列表是否以指定序列结尾

15	
def equals(that: Any): Boolean

判断是否相等

16	
def exists(p: (A) => Boolean): Boolean

判断列表中指定条件的元素是否存在。

判断l是否存在某个元素:

scala> l.exists(s => s == "Hah")
res7: Boolean = true
17	
def filter(p: (A) => Boolean): List[A]

输出符号指定条件的所有元素。

过滤出长度为3的元素:

scala> l.filter(s => s.length == 3)
res8: List[String] = List(Hah, WOW)
18	
def forall(p: (A) => Boolean): Boolean

检测所有元素。

例如：判断所有元素是否以"H"开头：

scala> l.forall(s => s.startsWith("H")) res10: Boolean = false
19	
def foreach(f: (A) => Unit): Unit

将函数应用到列表的所有元素

20	
def head: A

获取列表的第一个元素

21	
def indexOf(elem: A, from: Int): Int

从指定位置 from 开始查找元素第一次出现的位置

22	
def init: List[A]

返回所有元素，除了最后一个

23	
def intersect(that: Seq[A]): List[A]

计算多个集合的交集

24	
def isEmpty: Boolean

检测列表是否为空

25	
def iterator: Iterator[A]

创建一个新的迭代器来迭代元素

26	
def last: A

返回最后一个元素

27	
def lastIndexOf(elem: A, end: Int): Int

在指定的位置 end 开始查找元素最后出现的位置

28	
def length: Int

返回列表长度

29	
def map[B](f: (A) => B): List[B]

通过给定的方法将所有元素重新计算

30	
def max: A

查找最大元素

31	
def min: A

查找最小元素

32	
def mkString: String

列表所有元素作为字符串显示

33	
def mkString(sep: String): String

使用分隔符将列表所有元素作为字符串显示

34	
def reverse: List[A]

列表反转

35	
def sorted[B >: A]: List[A]

列表排序

36	
def startsWith[B](that: Seq[B], offset: Int): Boolean

检测列表在指定位置是否包含指定序列

37	
def sum: A

计算集合元素之和

38	
def tail: List[A]

返回所有元素，除了第一个

39	
def take(n: Int): List[A]

提取列表的前n个元素

40	
def takeRight(n: Int): List[A]

提取列表的后n个元素

41	
def toArray: Array[A]

列表转换为数组

42	
def toBuffer[B >: A]: Buffer[B]

返回缓冲区，包含了列表的所有元素

43	
def toMap[T, U]: Map[T, U]

List 转换为 Map

44	
def toSeq: Seq[A]

List 转换为 Seq

45	
def toSet[B >: A]: Set[B]

List 转换为 Set

46	
def toString(): String

列表转换为字符串