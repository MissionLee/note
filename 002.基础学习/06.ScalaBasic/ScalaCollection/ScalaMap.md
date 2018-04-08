# Map(映射)是一种可迭代的键值对（key/value）结构。

所有的值都可以通过键来获取。

Map 中的键都是唯一的。

Map 也叫哈希表（Hash tables）。

Map 有两种类型，可变与不可变，区别在于可变对象可以修改它，而不可变对象不可以。

`默认情况下 Scala 使用不可变 Map。如果你需要使用可变集合，你需要显式的引入 import scala.collection.mutable.Map 类`

在 Scala 中 你可以同时使用可变与不可变 Map，不可变的直接使用 Map，可变的使用 mutable.Map。以下实例演示了不可变 Map 的应用：

// 空哈希表，键为字符串，值为整型
var A:Map[Char,Int] = Map()

// Map 键值对演示
val colors = Map("red" -> "#FF0000", "azure" -> "#F0FFFF")
定义 Map 时，需要为键值对定义类型。如果需要添加 key-value 对，可以使用 + 号，如下所示：

A += ('I' -> 1)
A += ('J' -> 5)
A += ('K' -> 10)
A += ('L' -> 100)

## Map 基本操作

Scala Map 有三个基本操作：

|方法	|描述
|-|-
|keys	|返回 Map 所有的键(key)
|values	|返回 Map 所有的值(value)
|isEmpty	|在 Map 为空时返回true

实例
以下实例演示了以上三个方法的基本应用：

```scala
object Test {
   def main(args: Array[String]) {
      val colors = Map("red" -> "#FF0000",
                       "azure" -> "#F0FFFF",
                       "peru" -> "#CD853F")

      val nums: Map[Int, Int] = Map()

      println( "colors 中的键为 : " + colors.keys )
      println( "colors 中的值为 : " + colors.values )
      println( "检测 colors 是否为空 : " + colors.isEmpty )
      println( "检测 nums 是否为空 : " + nums.isEmpty )
   }
}
```

执行以上代码，输出结果为：
```sh
$ scalac Test.scala 
$ scala Test
colors 中的键为 : Set(red, azure, peru)
colors 中的值为 : MapLike(#FF0000, #F0FFFF, #CD853F)
检测 colors 是否为空 : false
检测 nums 是否为空 : true
```
## Map 合并

你可以使用 ++ 运算符或 Map.++() 方法来连接两个 Map，Map 合并时会移除重复的 key。以下演示了两个 Map 合并的实例:

```scala
object Test {
   def main(args: Array[String]) {
      val colors1 = Map("red" -> "#FF0000",
                        "azure" -> "#F0FFFF",
                        "peru" -> "#CD853F")
      val colors2 = Map("blue" -> "#0033FF",
                        "yellow" -> "#FFFF00",
                        "red" -> "#FF0000")

      //  ++ 作为运算符
      var colors = colors1 ++ colors2
      println( "colors1 ++ colors2 : " + colors )

      //  ++ 作为方法
      colors = colors1.++(colors2)
      println( "colors1.++(colors2)) : " + colors )

   }
}
```

执行以上代码，输出结果为：

```sh
$ scalac Test.scala 
$ scala Test
colors1 ++ colors2 : Map(blue -> #0033FF, azure -> #F0FFFF, peru -> #CD853F, yellow -> #FFFF00, red -> #FF0000)
colors1.++(colors2)) : Map(blue -> #0033FF, azure -> #F0FFFF, peru -> #CD853F, yellow -> #FFFF00, red -> #FF0000)
```

- 输出 Map 的 keys 和 values

以下通过 foreach 循环输出 Map 中的 keys 和 values：

```scala
object Test {
   def main(args: Array[String]) {
      val sites = Map("runoob" -> "http://www.runoob.com",
                       "baidu" -> "http://www.baidu.com",
                       "taobao" -> "http://www.taobao.com")

      sites.keys.foreach{ i =>  
                           print( "Key = " + i )
                           println(" Value = " + sites(i) )}
   }
}
```

执行以上代码，输出结果为：

```sh
$ scalac Test.scala 
$ scala Test
Key = runoob Value = http://www.runoob.com
Key = baidu Value = http://www.baidu.com
Key = taobao Value = http://www.taobao.com
```

- 查看 Map 中是否存在指定的 Key

你可以使用 Map.contains 方法来查看 Map 中是否存在指定的 Key。实例如下：

```scala
object Test {
   def main(args: Array[String]) {
      val sites = Map("runoob" -> "http://www.runoob.com",
                       "baidu" -> "http://www.baidu.com",
                       "taobao" -> "http://www.taobao.com")

      if( sites.contains( "runoob" )){
           println("runoob 键存在，对应的值为 :"  + sites("runoob"))
      }else{
           println("runoob 键不存在")
      }
      if( sites.contains( "baidu" )){
           println("baidu 键存在，对应的值为 :"  + sites("baidu"))
      }else{
           println("baidu 键不存在")
      }
      if( sites.contains( "google" )){
           println("google 键存在，对应的值为 :"  + sites("google"))
      }else{
           println("google 键不存在")
      }
   }
}
```

执行以上代码，输出结果为：

```scala
$ scalac Test.scala 
$ scala Test
runoob 键存在，对应的值为 :http://www.runoob.com
baidu 键存在，对应的值为 :http://www.baidu.com
google 键不存在
Scala Map 方法
```

下表列出了 Scala Map 常用的方法：

序号	方法及描述
1	
def ++(xs: Map[(A, B)]): Map[A, B]

返回一个新的 Map，新的 Map xs 组成

2	
def -(elem1: A, elem2: A, elems: A*): Map[A, B]

返回一个新的 Map, 移除 key 为 elem1, elem2 或其他 elems。

3	
def --(xs: GTO[A]): Map[A, B]

返回一个新的 Map, 移除 xs 对象中对应的 key

4	
def get(key: A): Option[B]

返回指定 key 的值

5	
def iterator: Iterator[(A, B)]

创建新的迭代器，并输出 key/value 对

6	
def addString(b: StringBuilder): StringBuilder

将 Map 中的所有元素附加到StringBuilder，可加入分隔符

7	
def addString(b: StringBuilder, sep: String): StringBuilder

将 Map 中的所有元素附加到StringBuilder，可加入分隔符

8	
def apply(key: A): B

返回指定键的值，如果不存在返回 Map 的默认方法

9	
def clear(): Unit

清空 Map

10	
def clone(): Map[A, B]

从一个 Map 复制到另一个 Map

11	
def contains(key: A): Boolean

如果 Map 中存在指定 key，返回 true，否则返回 false。

12	
def copyToArray(xs: Array[(A, B)]): Unit

复制集合到数组

13	
def count(p: ((A, B)) => Boolean): Int

计算满足指定条件的集合元素数量

14	
def default(key: A): B

定义 Map 的默认值，在 key 不存在时返回。

15	
def drop(n: Int): Map[A, B]

返回丢弃前n个元素新集合

16	
def dropRight(n: Int): Map[A, B]

返回丢弃最后n个元素新集合

17	
def dropWhile(p: ((A, B)) => Boolean): Map[A, B]

从左向右丢弃元素，直到条件p不成立

18	
def empty: Map[A, B]

返回相同类型的空 Map

19	
def equals(that: Any): Boolean

如果两个 Map 相等(key/value 均相等)，返回true，否则返回false

20	
def exists(p: ((A, B)) => Boolean): Boolean

判断集合中指定条件的元素是否存在

21	
def filter(p: ((A, B))=> Boolean): Map[A, B]

返回满足指定条件的所有集合

22	
def filterKeys(p: (A) => Boolean): Map[A, B]

返回符合指定条件的的不可变 Map

23	
def find(p: ((A, B)) => Boolean): Option[(A, B)]

查找集合中满足指定条件的第一个元素

24	
def foreach(f: ((A, B)) => Unit): Unit

将函数应用到集合的所有元素

25	
def init: Map[A, B]

返回所有元素，除了最后一个

26	
def isEmpty: Boolean

检测 Map 是否为空

27	
def keys: Iterable[A]

返回所有的key/p>

28	
def last: (A, B)

返回最后一个元素

29	
def max: (A, B)

查找最大元素

30	
def min: (A, B)

查找最小元素

31	
def mkString: String

集合所有元素作为字符串显示

32	
def product: (A, B)

返回集合中数字元素的积。

33	
def remove(key: A): Option[B]

移除指定 key

34	
def retain(p: (A, B) => Boolean): Map.this.type

如果符合满足条件的返回 true

35	
def size: Int

返回 Map 元素的个数

36	
def sum: (A, B)

返回集合中所有数字元素之和

37	
def tail: Map[A, B]

返回一个集合中除了第一元素之外的其他元素

38	
def take(n: Int): Map[A, B]

返回前 n 个元素

39	
def takeRight(n: Int): Map[A, B]

返回后 n 个元素

40	
def takeWhile(p: ((A, B)) => Boolean): Map[A, B]

返回满足指定条件的元素

41	
def toArray: Array[(A, B)]

集合转数组

42	
def toBuffer[B >: A]: Buffer[B]

返回缓冲区，包含了 Map 的所有元素

43	
def toList: List[A]

返回 List，包含了 Map 的所有元素

44	
def toSeq: Seq[A]

返回 Seq，包含了 Map 的所有元素

45	
def toSet: Set[A]

返回 Set，包含了 Map 的所有元素

46	
def toString(): String

返回字符串对象