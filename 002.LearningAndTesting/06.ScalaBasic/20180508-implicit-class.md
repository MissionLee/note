官方文档

https://docs.scala-lang.org/overviews/core/implicit-classes.html

Scala 2.10 introduced a new feature called implicit classes. An implicit class is a class marked with the implicit keyword. This keyword makes the class’s primary constructor available for implicit conversions when the class is in scope.

Scala 2.10 版本引入了一个新特性 implicits classes

与implicits classes在同一个 scope内的时候，可以触发implicit conversion，调用这个类的 primary constructor

Usage
To create an implicit class, simply place the implicit keyword in front of an appropriate class. Here’s an example:
```scala
object Helpers {
  implicit class IntWithTimes(x: Int) {
    def times[A](f: => A): Unit = {
      def loop(current: Int): Unit =
        if(current > 0) {
          f
          loop(current - 1)
        }
      loop(x)
    }
  }
}
```
This example creates the implicit class IntWithTimes. This class wraps an Int value and provides a new method, times. To use this class, just import it into scope and call the times method. Here’s an example:
```scala
scala> import Helpers._
import Helpers._

scala> 5 times println("HI")

// 这里！！！， 5 本身没有 times 方法，所以编译器会寻找又合适的隐式转换没有，发现可以把 5 转换成一个 class（调用这个class的主构造），这个class里 由 times方法
HI
HI
HI
HI
HI
```
For an implicit class to work, its name must be in scope and unambiguous, like any other implicit value or conversion.

Restrictions
Implicit classes have the following restrictions:

1. They must be defined inside of another trait/class/object.

object Helpers {
   implicit class RichInt(x: Int) // OK!
}
implicit class RichDouble(x: Double) // BAD!
2. They may only take one non-implicit argument in their constructor.

implicit class RichDate(date: java.util.Date) // OK!
implicit class Indexer[T](collecton: Seq[T], index: Int) // BAD!
implicit class Indexer[T](collecton: Seq[T])(implicit index: Index) // OK!
While it’s possible to create an implicit class with more than one non-implicit argument, such classes aren’t used during implicit lookup.

3. There may not be any method, member or object in scope with the same name as the implicit class.

Note: This means an implicit class cannot be a case class.

object Bar
implicit class Bar(x: Int) // BAD!

val x = 5
implicit class x(y: Int) // BAD!

implicit case class Baz(x: Int) // BAD!