# Scala 提取器(Extractor) - 后面有另外一个关于提取器的攻略

提取器是从`传递给它的对象中提取出构造该对象的参数`。

Scala 标准库包含了一些预定义的提取器，我们会大致的了解一下它们。

Scala 提取器是一个带有`unapply`方法的对象。unapply方法算是`apply方法的反向操作`：unapply接受一个对象，然后从对象中提取值，提取的值通常是用来构造该对象的值。

以下实例演示了邮件地址的提取器对象：
```scala
object Test {
   def main(args: Array[String]) {
      
      println ("Apply 方法 : " + apply("Zara", "gmail.com"));
      println ("Unapply 方法 : " + unapply("Zara@gmail.com"));
      println ("Unapply 方法 : " + unapply("Zara Ali"));

   }
   // 注入方法 (可选)
   def apply(user: String, domain: String) = {
      user +"@"+ domain
   }

   // 提取方法（必选）
   def unapply(str: String): Option[(String, String)] = {
      val parts = str split "@"
      if (parts.length == 2){
         Some(parts(0), parts(1)) 
      }else{
         None
      }
   }
}
```

执行以上代码，输出结果为：

```sh
$ scalac Test.scala 
$ scala Test
Apply 方法 : Zara@gmail.com
Unapply 方法 : Some((Zara,gmail.com))
Unapply 方法 : None
```

以上对象定义了两个方法： apply 和 unapply 方法。通过 apply 方法我们无需使用 new 操作就可以创建对象。所以你可以通过语句 Test("Zara", "gmail.com") 来构造一个字符串 "Zara@gmail.com"。

unapply方法算是apply方法的反向操作：unapply接受一个对象，然后从对象中提取值，提取的值通常是用来构造该对象的值。实例中我们使用 Unapply 方法从对象中提取用户名和邮件地址的后缀。

实例中 unapply 方法在传入的字符串不是邮箱地址时返回 None。代码演示如下：
```sh
unapply("Zara@gmail.com") 相等于 Some("Zara", "gmail.com")
unapply("Zara Ali") 相等于 None
```

## 提取器使用模式匹配
在我们实例化一个类的时，可以带上0个或者多个的参数，`编译器在实例化的时会调用 apply 方法`。我们可以在类和对象中都定义 apply 方法。

就像我们之前提到过的，unapply 用于提取我们指定查找的值，它与 apply 的操作相反。 当我们在提取器对象中使用 match 语句是，unapply 将自动执行，如下所示：
```scala
object Test {
   def main(args: Array[String]) {
      
      val x = Test(5)
      println(x)

      x match
      {
         case Test(num) => println(x + " 是 " + num + " 的两倍！")
         //unapply 被调用
         case _ => println("无法计算")
      }

   }
   def apply(x: Int) = x*2
   def unapply(z: Int): Option[Int] = if (z%2==0) Some(z/2) else None
}
```
执行以上代码，输出结果为：
```sh
$ scalac Test.scala 
$ scala Test
10
10 是 5 的两倍！
```

## ------------- 另一个提取器 攻略 --------------------

Scala入门到精通——第二十五节 提取器（Extractor）

http://blog.csdn.net/lovehuangjiaju/article/details/47612699

本节主要内容
apply与unapply方法
零变量或变量的模式匹配
提取器与序列模式
scala中的占位符使用总结
1. apply与unapply方法
apply方法我们已经非常熟悉了，它帮助我们无需new操作就可以创建对象，而unapply方法则用于析构出对象，在模式匹配中特别提到，如果一个类要能够应用于模式匹配当中，必须将类声明为case class，因为一旦被定义为case class，scala会自动帮我们生成相应的方法，这些方法中就包括apply方法及unapply方法。本节将从提取器（也称析构器）的角度对unapply方法进行介绍。先看下面的这个例子（来源于programmin in scala）

object EMail{
  //apply方法用于无new构造对象
  def apply(user: String, domain: String) = user + "@" + domain
  //unapply方法用于在模式匹配中充当extractor
  def unapply(str: String): Option[(String, String)] = {
    val parts = str split "@"
    if (parts.length == 2) Some(parts(0), parts(1)) else None
  }
}
object ApplyAndUnapply {
  val email=EMail("zhouzhihubeyond","sina.com")

    //下面的匹配会导致调用EMail.unapply(email)
    case EMail(user,domain) => println("user="+user+" domain="+domain)
  }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
在上述的代码中，我们将unapply方法定义为： 
def unapply(str: String): Option[(String, String)] = { 
val parts = str split "@" 
if (parts.length == 2) Some(parts(0), parts(1)) else None 
}

这是有道理的，原因在于可能会有不合法的email用于模式匹配，例如：

object ApplyAndUnapply extends App{
  def patternMatching(x:String)=x match {
    //下面的匹配会导致调用EMail.unapply(email)
    case EMail(user,domain) => println("user="+user+" domain="+domain)
    //匹配非法邮箱
    case _ => println("non illegal email")
  }
  val email=EMail("zhouzhihubeyond","sina.com")
  patternMatching(email) 
  patternMatching("摇摆少年梦") 
}
1
2
3
4
5
6
7
8
9
10
11
从构造与析构的角度来看，apply方法也被称为injection（注入），unapply方法也被称为提取器，这两个方法就像孪生兄弟一样，经常在类或对象中被定义。以前我们在用类进行模式匹配的时候都必须要将类声明为case class，今天我们将不通过case class，而是定义一个普通的类实现自己的apply和unapply方法来实现模式匹配，代码如下：

//定义一个普通类
class Person(val firstName:String,val secondName:String)

//在伴生对象中定义apply方法和unapply方法
object Person{
  def apply(firstName: String, secondName: String) = new Person(firstName,secondName)

 def unapply(person: Person):Option[(String,String)]={
    if(person!=null) Some(person.firstName,person.secondName)
    else None
  }
}


val p=Person("摇摆少年梦","周")
  p match {
    //析构出firstName，secondeName
    case Person(firstName,secondName) => println("firstName="+firstName+" secondName="+secondName)
    case _ => println("null object")
  }
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
2. 零变量或单变量绑定的模式匹配
上一节讲的模式模式匹配绑定的是两个变量，它可以扩展到任意变量维度，这一节中我们对零变量和单个变量绑定的特殊情况进行介绍，我们来看下面的这个例子，该例子来源于 programmin in scala

//Twice用于匹配重复出现的字符串，它绑定的是一个变量
//即返回的类型是Option[String]
object Twice {
  def apply(s: String): String = s + s
  def unapply(s: String): Option[String] = {
    val length = s.length / 2
    val half = s.substring(0, length)
    if (half == s.substring(length)) Some(half) else None
  }
}
//未绑定任何变量，仅仅返回Boolean类型
object UpperCase {
  def unapply(s: String): Boolean = s.toUpperCase == s
}

object NonAndOneVariablePattern extends App{
  def userTwiceUpper(s: String) = s match {
    //下面的代码相当于执行了下面这条语句
    //UpperCase.unapply(Twich.unapply(EMail.unapply(s)))
    case EMail(Twice(x @ UpperCase()), domain) =>
      "match: " + x + " in domain " + domain
    case _ =>
      "no match"
  }
  val email=EMail("摇摆少年梦摇摆少年梦","sina.com")
  println(userTwiceUpper(email))
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
代码中的EMail(Twice(x @ UpperCase())，其执行顺序是先调用EMail的unapply方法，然后再调用Twice中的unapply方法，最后调用UpperCase的unapply方法，如果返回true，则将Twice 中返回的字符串赋值给x。

3. 提取器与序列模式
List伴生对象具有下列定义形式：

object List {
def apply[T](elems: T*) = elems.toList
def unapplySeq[T](x: List[T]): Option[Seq[T]] = Some(x)
...
}
1
2
3
4
5
从上面的代码来看，与一般的提取器不同的是，序列模式采用unapplySeq代替unapply方法，并且返回的类型是Option[Seq[T]] ，在讲模式匹配的时候我们提到过，序列模式中的匹配经常会使用占位符_或_*的方式匹配序列中的其它元素，这种方式为序列模式所独有，例如：

object ExtractorSequence extends App{
  val list=List(List(1,2,3),List(2,3,4))
  list match {
    //_*表示匹配列表中的其它元素
    case List(List(one,two,three),_*) => 
      println("one="+one+" two="+two+" three="+three)
    case _ => println("Other")
  }
  list match {
    //_表示匹配列表中的第一个元素
    //_*表示匹配List中的其它多个元素
    //这里采用的变量绑定的方式
    case List(_,x@List(_*),_*) => println(x)
    case _ => println("other list")
  }
}
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
4. scala中的占位符使用总结
scala作为一种函数式编程语言，有很多地方会让初学者觉得困惑，其中占位符_的使用理解有一定的难度，本节将对其使用进行总结，本小节内容来源http://my.oschina.net/leejun2005/blog/405305，感谢作者的无私奉献。

1、存在性类型：Existential types
def foo(l: List[Option[_]]) = ...

2、高阶类型参数：Higher kinded type parameters
case class A[K[_],T](a: K[T])

3、临时变量：Ignored variables
val _ = 5

4、临时参数：Ignored parameters
List(1, 2, 3) foreach { _ => println("Hi") }

5、通配模式：Wildcard patterns
Some(5) match { case Some(_) => println("Yes") }
match {
     case List(1,_,_) => " a list with three element and the first element is 1"
     case List(_*)  => " a list with zero or more elements "
     case Map[_,_] => " matches a map with any key type and any value type "
     case _ =>
 }
val (a, _) = (1, 2)
for (_ <- 1 to 10)

6、通配导入：Wildcard imports
import java.util._

7、隐藏导入：Hiding imports
// Imports all the members of the object Fun but renames Foo to Bar
import com.test.Fun.{ Foo => Bar , _ }

// Imports all the members except Foo. To exclude a member rename it to _
import com.test.Fun.{ Foo => _ , _ }

8、连接字母和标点符号：Joining letters to punctuation
def bang_!(x: Int) = 5

9、占位符语法：Placeholder syntax
List(1, 2, 3) map (_ + 2)
_ + _   
( (_: Int) + (_: Int) )(2,3)

val nums = List(1,2,3,4,5,6,7,8,9,10)

nums map (_ + 2)
nums sortWith(_>_)
nums filter (_ % 2 == 0)
nums reduceLeft(_+_)
nums reduce (_ + _)
nums reduceLeft(_ max _)
nums.exists(_ > 5)
nums.takeWhile(_ < 8)

10、偏应用函数：Partially applied functions
def fun = {
    // Some code
}
val funLike = fun _

List(1, 2, 3) foreach println _

1 to 5 map (10 * _)

//List("foo", "bar", "baz").map(_.toUpperCase())
List("foo", "bar", "baz").map(n => n.toUpperCase())

11、初始化默认值：default value
var i: Int = _

12、作为参数名：
//访问map
var m3 = Map((1,100), (2,200))
for(e<-m3) println(e._1 + ": " + e._2)
m3 filter (e=>e._1>1)
m3 filterKeys (_>1)
m3.map(e=>(e._1*10, e._2))
m3 map (e=>e._2)

//访问元组：tuple getters
(1,2)._2

13、参数序列：parameters Sequence 
_*作为一个整体，告诉编译器你希望将某个参数当作参数序列处理。例如val s = sum(1 to 5:_*)就是将1 to 5当作参数序列处理。
//Range转换为List
List(1 to 5:_*)

//Range转换为Vector
Vector(1 to 5: _*)

//可变参数中
def capitalizeAll(args: String*) = {
  args.map { arg =>
    arg.capitalize
  }
}

val arr = Array("what's", "up", "doc?")
capitalizeAll(arr: _*)