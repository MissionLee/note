# Scala Set(集合)

Scala 集合 Scala 集合

Scala Set(集合)是没有重复的对象集合，所有的元素都是唯一的。

Scala 集合分为可变的和不可变的集合。

默认情况下，Scala 使用的是不可变集合，如果你想使用可变集合，需要引用 scala.collection.mutable.Set 包。

默认引用 scala.collection.immutable.Set，不可变集合实例如下：
```scala
val set = Set(1,2,3)
println(set.getClass.getName) // 

println(set.exists(_ % 2 == 0)) //true
println(set.drop(1)) //Set(2,3)
```

`如果需要使用可变集合需要引入 scala.collection.mutable.Set：`

```scala
import scala.collection.mutable.Set // 可以在任何地方引入 可变集合

val mutableSet = Set(1,2,3)
println(mutableSet.getClass.getName) // scala.collection.mutable.HashSet

mutableSet.add(4)
mutableSet.remove(1)
mutableSet += 5
mutableSet -= 2

println(mutableSet) // Set(5, 3, 4)

val another = mutableSet.toSet
println(another.getClass.getName) // scala.collection.immutable.Set
```

注意： 虽然可变Set和不可变Set都有添加或删除元素的操作，但是有一个非常大的差别。对不可变Set进行操作，会产生一个新的set，原来的set并没有改变，这与List一样。 而对可变Set进行操作，改变的是该Set本身，与ListBuffer类似。

## 集合基本操作

Scala集合有三个基本操作：

- head 返回集合第一个元素
- tail 返回一个集合，包含除了第一元素之外的其他元素
- isEmpty 在集合为空时返回true
对于Scala集合的任何操作都可以使用这三个基本操作来表达。实例如下:

```scala
object Test {
   def main(args: Array[String]) {
      val site = Set("Runoob", "Google", "Baidu")
      val nums: Set[Int] = Set()

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
最后一个网站是 : Set(Google, Baidu)
查看列表 site 是否为空 : false
查看 nums 是否为空 : true
```
- 连接集合

你可以使用 ++ 运算符或 Set.++() 方法来连接两个集合。如果元素有重复的就会移除重复的元素。实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val site1 = Set("Runoob", "Google", "Baidu")
      val site2 = Set("Faceboook", "Taobao")

      // ++ 作为运算符使用
      var site = site1 ++ site2
      println( "site1 ++ site2 : " + site )

      //  ++ 作为方法使用
      site = site1.++(site2)
      println( "site1.++(site2) : " + site )
   }
}
```

执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
site1 ++ site2 : Set(Faceboook, Taobao, Google, Baidu, Runoob)
site1.++(site2) : Set(Faceboook, Taobao, Google, Baidu, Runoob)
```

- 查找集合中最大与最小元素

你可以使用 Set.min 方法来查找集合中的最小元素，使用 Set.max 方法查找集合中的最大元素。实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val num = Set(5,6,9,20,30,45)

      // 查找集合中最大与最小元素
      println( "Set(5,6,9,20,30,45) 集合中的最小元素是 : " + num.min )
      println( "Set(5,6,9,20,30,45) 集合中的最大元素是 : " + num.max )
   }
}
```
执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
Set(5,6,9,20,30,45) 集合中的最小元素是 : 5
Set(5,6,9,20,30,45) 集合中的最大元素是 : 45
```
- 交集

你可以使用 Set.& 方法或 Set.intersect 方法来查看两个集合的交集元素。实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val num1 = Set(5,6,9,20,30,45)
      val num2 = Set(50,60,9,20,35,55)

      // 交集
      println( "num1.&(num2) : " + num1.&(num2) )
      println( "num1.intersect(num2) : " + num1.intersect(num2) )
   }
}
```

执行以上代码，输出结果为：
```sh
$ vim Test.scala 
$ scala Test.scala 
num1.&(num2) : Set(20, 9)
num1.intersect(num2) : Set(20, 9)
```

Scala Set 常用方法
下表列出了 Scala Set 常用的方法：

序号	方法及描述
1	
def +(elem: A): Set[A]

为集合添加新元素，x并创建一个新的集合，除非元素已存在

2	
def -(elem: A): Set[A]

移除集合中的元素，并创建一个新的集合

3	
def contains(elem: A): Boolean

如果元素在集合中存在，返回 true，否则返回 false。

4	
def &(that: Set[A]): Set[A]

返回两个集合的交集

5	
def &~(that: Set[A]): Set[A]

返回两个集合的差集

6	
def +(elem1: A, elem2: A, elems: A*): Set[A]

通过添加传入指定集合的元素创建一个新的不可变集合

7	
def ++(elems: A): Set[A]

合并两个集合

8	
def -(elem1: A, elem2: A, elems: A*): Set[A]

通过移除传入指定集合的元素创建一个新的不可变集合

9	
def addString(b: StringBuilder): StringBuilder

将不可变集合的所有元素添加到字符串缓冲区

10	
def addString(b: StringBuilder, sep: String): StringBuilder

将不可变集合的所有元素添加到字符串缓冲区，并使用指定的分隔符

11	
def apply(elem: A)

检测集合中是否包含指定元素

12	
def count(p: (A) => Boolean): Int

计算满足指定条件的集合元素个数

13	
def copyToArray(xs: Array[A], start: Int, len: Int): Unit

复制不可变集合元素到数组

14	
def diff(that: Set[A]): Set[A]

比较两个集合的差集

15	
def drop(n: Int): Set[A]]

返回丢弃前n个元素新集合

16	
def dropRight(n: Int): Set[A]

返回丢弃最后n个元素新集合

17	
def dropWhile(p: (A) => Boolean): Set[A]

从左向右丢弃元素，直到条件p不成立

18	
def equals(that: Any): Boolean

equals 方法可用于任意序列。用于比较系列是否相等。

19	
def exists(p: (A) => Boolean): Boolean

判断不可变集合中指定条件的元素是否存在。

20	
def filter(p: (A) => Boolean): Set[A]

输出符合指定条件的所有不可变集合元素。

21	
def find(p: (A) => Boolean): Option[A]

查找不可变集合中满足指定条件的第一个元素

22	
def forall(p: (A) => Boolean): Boolean

查找不可变集合中满足指定条件的所有元素

23	
def foreach(f: (A) => Unit): Unit

将函数应用到不可变集合的所有元素

24	
def head: A

获取不可变集合的第一个元素

25	
def init: Set[A]

返回所有元素，除了最后一个

26	
def intersect(that: Set[A]): Set[A]

计算两个集合的交集

27	
def isEmpty: Boolean

判断集合是否为空

28	
def iterator: Iterator[A]

创建一个新的迭代器来迭代元素

29	
def last: A

返回最后一个元素

30	
def map[B](f: (A) => B): immutable.Set[B]

通过给定的方法将所有元素重新计算

31	
def max: A

查找最大元素

32	
def min: A

查找最小元素

33	
def mkString: String

集合所有元素作为字符串显示

34	
def mkString(sep: String): String

使用分隔符将集合所有元素作为字符串显示

35	
def product: A

返回不可变集合中数字元素的积。

36	
def size: Int

返回不可变集合元素的数量

37	
def splitAt(n: Int): (Set[A], Set[A])

把不可变集合拆分为两个容器，第一个由前 n 个元素组成，第二个由剩下的元素组成

38	
def subsetOf(that: Set[A]): Boolean

如果集合中含有子集返回 true，否则返回false

39	
def sum: A

返回不可变集合中所有数字元素之和

40	
def tail: Set[A]

返回一个不可变集合中除了第一元素之外的其他元素

41	
def take(n: Int): Set[A]

返回前 n 个元素

42	
def takeRight(n: Int):Set[A]

返回后 n 个元素

43	
def toArray: Array[A]

将集合转换为数字

44	
def toBuffer[B >: A]: Buffer[B]

返回缓冲区，包含了不可变集合的所有元素

45	
def toList: List[A]

返回 List，包含了不可变集合的所有元素

46	
def toMap[T, U]: Map[T, U]

返回 Map，包含了不可变集合的所有元素

47	
def toSeq: Seq[A]

返回 Seq，包含了不可变集合的所有元素

48	
def toString(): String

返回一个字符串，以对象来表示