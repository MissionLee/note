# scala 中 Array的描述

我最初产生了研究Array的相关内容的想法是因为Array 可以使用一个 toIterator 的方法,而Array自身没有这个方法,并且Array的类与父类也没有 哪一个 和  toIterator方法相关.在scala中很自然的会想到可能有一些隐式转换把Array转成其他类型然后调用了这个方法.但是并没发在源码中发现有直接定义,最后看了一下Arrays的说明:如下. 

- 结论提前
  - scala 有几个隐式引用,就向java会自动引用 java.long一样
  ```scala
  import java.lang._ // in JVM projects, or system namespace in .NET
  import scala._     // everything in the scala package
  import Predef._    // everything in the Predef object
  ```
  - 其中在Predef中有这么一段代码
  ```scala
    implicit def genericWrapArray[T](xs: Array[T]): WrappedArray[T] =
    if (xs eq null) null
    else WrappedArray.make(xs)

  // Since the JVM thinks arrays are covariant, one 0-length Array[AnyRef]
  // is as good as another for all T <: AnyRef.  Instead of creating 100,000,000
  // unique ones by way of this implicit, let's share one.
  implicit def wrapRefArray[T <: AnyRef](xs: Array[T]): WrappedArray[T] = {
    if (xs eq null) null
    else if (xs.length == 0) WrappedArray.empty[T]
    else new WrappedArray.ofRef[T](xs)
  }

  implicit def wrapIntArray(xs: Array[Int]): WrappedArray[Int] = if (xs ne null) new WrappedArray.ofInt(xs) else null
  implicit def wrapDoubleArray(xs: Array[Double]): WrappedArray[Double] = if (xs ne null) new WrappedArray.ofDouble(xs) else null
  implicit def wrapLongArray(xs: Array[Long]): WrappedArray[Long] = if (xs ne null) new WrappedArray.ofLong(xs) else null
  implicit def wrapFloatArray(xs: Array[Float]): WrappedArray[Float] = if (xs ne null) new WrappedArray.ofFloat(xs) else null
  implicit def wrapCharArray(xs: Array[Char]): WrappedArray[Char] = if (xs ne null) new WrappedArray.ofChar(xs) else null
  implicit def wrapByteArray(xs: Array[Byte]): WrappedArray[Byte] = if (xs ne null) new WrappedArray.ofByte(xs) else null
  implicit def wrapShortArray(xs: Array[Short]): WrappedArray[Short] = if (xs ne null) new WrappedArray.ofShort(xs) else null
  implicit def wrapBooleanArray(xs: Array[Boolean]): WrappedArray[Boolean] = if (xs ne null) new WrappedArray.ofBoolean(xs) else null
  implicit def wrapUnitArray(xs: Array[Unit]): WrappedArray[Unit] = if (xs ne null) new WrappedArray.ofUnit(xs) else null

  implicit def wrapString(s: String): WrappedString = if (s ne null) new WrappedString(s) else null
  implicit def unwrapString(ws: WrappedString): String = if (ws ne null) ws.self else null

  implicit def fallbackStringCanBuildFrom[T]: CanBuildFrom[String, T, immutable.IndexedSeq[T]] =
    new CanBuildFrom[String, T, immutable.IndexedSeq[T]] {
      def apply(from: String) = immutable.IndexedSeq.newBuilder[T]
      def apply() = immutable.IndexedSeq.newBuilder[T]
    }
  ```
  - 这里实际上就是基本就可以确定是因为有这一层 Array 到 WrappedArray的隐式转换所以可以用toIterator方法
  - 不过本着严谨的态度,还是稍加探索一下
    - toIterator 定义在 iterableLike.scala中
    - 实现了 iterableLike - trait的有
      - iterator
      - SetLike
      - MapLike
      - SeqLike
      - 等等
    - 这里其实已经找到了,就不再继续查看了


```scala
/** Arrays are mutable, indexed collections of values. `Array[T]` is Scala's representation
 *  for Java's `T[]`.
 *  数组是可变的,有序的值的容器(集合)
 *  {{{
 *  val numbers = Array(1, 2, 3, 4)
 *  val first = numbers(0) // read the first element
 *  numbers(3) = 100 // replace the 4th array element with 100
 *  val biggerNumbers = numbers.map(_ * 2) // multiply all numbers by two
 *  }}}
 *
 *  Arrays make use of two common pieces of Scala syntactic sugar, shown on lines 2 and 3 of the above
 数组应用了scala中两个常用的语法塘, 获取值的apply 和 更新值的 update
 *  example code.
 *  Line 2 is translated into a call to `apply(Int)`, while line 3 is translated into a call to
 *  `update(Int, T)`.
 *    


 两个常用的隐式转换在 Predef中中定义好了
 一个是 转为  ArrayOps    ,一个是 转为 WrappedArray
 *  Two implicit conversions exist in [[scala.Predef]] that are frequently applied to arrays: a conversion
 *  to [[scala.collection.mutable.ArrayOps]] (shown on line 4 of the example above) and a conversion
 *  to [[scala.collection.mutable.WrappedArray]] (a subtype of [[scala.collection.Seq]]).
 *  Both types make available many of the standard operations found in the Scala collections API.
 *  The conversion to `ArrayOps` is temporary, as all operations defined on `ArrayOps` return an `Array`,
 *  while the conversion to `WrappedArray` is permanent as all operations return a `WrappedArray`.
 *
 *  The conversion to `ArrayOps` takes priority over the conversion to `WrappedArray`. For instance,
 *  consider the following code:
 *
 *  {{{
 *  val arr = Array(1, 2, 3)
 *  val arrReversed = arr.reverse
 *  val seqReversed : Seq[Int] = arr.reverse
 *  }}}
 *
 *  Value `arrReversed` will be of type `Array[Int]`, with an implicit conversion to `ArrayOps` occurring
 *  to perform the `reverse` operation. The value of `seqReversed`, on the other hand, will be computed
 *  by converting to `WrappedArray` first and invoking the variant of `reverse` that returns another
 *  `WrappedArray`.
 *
 *  @author Martin Odersky
 *  @version 1.0
 *  @see [[http://www.scala-lang.org/files/archive/spec/2.11/ Scala Language Specification]], for in-depth information on the transformations the Scala compiler makes on Arrays (Sections 6.6 and 6.15 respectively.)
 *  @see [[http://docs.scala-lang.org/sips/completed/scala-2-8-arrays.html "Scala 2.8 Arrays"]] the Scala Improvement Document detailing arrays since Scala 2.8.
 *  @see [[http://docs.scala-lang.org/overviews/collections/arrays.html "The Scala 2.8 Collections' API"]] section on `Array` by Martin Odersky for more information.
 *  @define coll array
 *  @define Coll `Array`
 *  @define orderDependent
 *  @define orderDependentFold
 *  @define mayNotTerminateInf
 *  @define willNotTerminateInf
 *  @define collectExample
 *  @define undefinedorder
 *  @define thatinfo the class of the returned collection. In the standard library configuration,
 *    `That` is either `Array[B]` if an ClassTag is available for B or `ArraySeq[B]` otherwise.
 *  @define zipthatinfo $thatinfo
 *  @define bfinfo an implicit value of class `CanBuildFrom` which determines the result class `That` from the current
 *    representation type `Repr` and the new element type `B`.
 */
```