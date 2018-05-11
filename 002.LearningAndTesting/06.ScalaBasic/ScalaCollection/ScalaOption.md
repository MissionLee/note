# Scala Option(选项)

Scala 集合 Scala 集合

Scala Option(选项)类型用来表示一个值是可选的（有值或无值)。

Option[T] 是一个类型为 T 的可选值的容器： 如果值存在， Option[T] 就是一个 Some[T] ，如果不存在， Option[T] 就是对象 None 。

接下来我们来看一段代码：
```scala
// 虽然 Scala 可以不定义变量的类型，不过为了清楚些，我还是
// 把他显示的定义上了
 
val myMap: Map[String, String] = Map("key1" -> "value")
val value1: Option[String] = myMap.get("key1")
val value2: Option[String] = myMap.get("key2")
 
println(value1) // Some("value1")
println(value2) // None
```

在上面的代码中，myMap 一个是一个 Key 的类型是 String，Value 的类型是 String 的 hash map，但不一样的是他的 get() 返回的是一个叫 Option[String] 的类别。

Scala 使用 Option[String] 来告诉你：`「我会想办法回传一个 String，但也可能没有 String 给你」`。

myMap 里并没有 key2 这笔数据，get() 方法返回 None。

`Option 有两个子类别，一个是 Some，一个是 None`，当他回传 Some 的时候，代表这个函式成功地给了你一个 String，而你可以透过 get() 这个函式拿到那个 String，如果他返回的是 None，则代表没有字符串可以给你。

另一个实例：
```scala
object Test {
   def main(args: Array[String]) {
      val sites = Map("runoob" -> "www.runoob.com", "google" -> "www.google.com")
      
      println("sites.get( \"runoob\" ) : " +  sites.get( "runoob" )) // Some(www.runoob.com)
      println("sites.get( \"baidu\" ) : " +  sites.get( "baidu" ))  //  None
   }
}
```

执行以上代码，输出结果为：
```sh
$ scalac Test.scala 
$ scala Test
sites.get( "runoob" ) : Some(www.runoob.com)
sites.get( "baidu" ) : None
```

你也可以通过模式匹配来输出匹配值。实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val sites = Map("runoob" -> "www.runoob.com", "google" -> "www.google.com")
      
      println("show(sites.get( \"runoob\")) : " +  
                                          show(sites.get( "runoob")) )
      println("show(sites.get( \"baidu\")) : " +  
                                          show(sites.get( "baidu")) )
   }
   
   def show(x: Option[String]) = x match {
      case Some(s) => s
      case None => "?"
   }
}
```
执行以上代码，输出结果为：
```sh
$ scalac Test.scala 
$ scala Test
show(sites.get( "runoob")) : www.runoob.com
show(sites.get( "baidu")) : ?
```

- getOrElse() 方法
你可以使用 getOrElse() 方法来获取元组中存在的元素或者使用其默认的值，实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val a:Option[Int] = Some(5)
      val b:Option[Int] = None 
      
      println("a.getOrElse(0): " + a.getOrElse(0) )
      println("b.getOrElse(10): " + b.getOrElse(10) )
   }
}
```
执行以上代码，输出结果为：
```scala
$ scalac Test.scala 
$ scala Test
a.getOrElse(0): 5
b.getOrElse(10): 10
isEmpty() 方法
```

你可以使用 isEmpty() 方法来检测元组中的元素是否为 None，实例如下：
```scala
object Test {
   def main(args: Array[String]) {
      val a:Option[Int] = Some(5)
      val b:Option[Int] = None 
      
      println("a.isEmpty: " + a.isEmpty )
      println("b.isEmpty: " + b.isEmpty )
   }
}
```

执行以上代码，输出结果为：
```sh
$ scalac Test.scala 
$ scala Test
a.isEmpty: false
b.isEmpty: true
```

Scala Option 常用方法
下表列出了 Scala Option 常用的方法：

序号	方法及描述
1	
def get: A

获取可选值

2	
def isEmpty: Boolean

检测可选类型值是否为 None，是的话返回 true，否则返回 false

3	
def productArity: Int

返回元素个数， A(x_1, ..., x_k), 返回 k

4	
def productElement(n: Int): Any

获取指定的可选项，以 0 为起始。即 A(x_1, ..., x_k), 返回 x_(n+1) ， 0 < n < k.

5	
def exists(p: (A) => Boolean): Boolean

如果可选项中指定条件的元素是否存在且不为 None 返回 true，否则返回 false。

6	
def filter(p: (A) => Boolean): Option[A]

如果选项包含有值，而且传递给 filter 的条件函数返回 true， filter 会返回 Some 实例。 否则，返回值为 None 。

7	
def filterNot(p: (A) => Boolean): Option[A]

如果选项包含有值，而且传递给 filter 的条件函数返回 false， filter 会返回 Some 实例。 否则，返回值为 None 。

8	
def flatMap[B](f: (A) => Option[B]): Option[B]

如果选项包含有值，则传递给函数 f 处理后返回，否则返回 None

9	
def foreach[U](f: (A) => U): Unit

如果选项包含有值，则将每个值传递给函数 f， 否则不处理。

10	
def getOrElse[B >: A](default: => B): B

如果选项包含有值，返回选项值，否则返回设定的默认值。

11	
def isDefined: Boolean

如果可选值是 Some 的实例返回 true，否则返回 false。

12	
def iterator: Iterator[A]

如果选项包含有值，迭代出可选值。如果可选值为空则返回空迭代器。

13	
def map[B](f: (A) => B): Option[B]

如果选项包含有值， 返回由函数 f 处理后的 Some，否则返回 None

14	
def orElse[B >: A](alternative: => Option[B]): Option[B]

如果一个 Option 是 None ， orElse 方法会返回传名参数的值，否则，就直接返回这个 Option。

15	
def orNull

如果选项包含有值返回选项值，否则返回 null。