Scala比较器：Ordered与Ordering

 
在项目中，我们常常会遇到排序（或比较）需求，比如：对一个Person类
```scala
case class Person(name: String, age: Int) {
  override def toString = {
    "name: " + name + ", age: " + age
  }
}
```

按name逆词典序、age值升序做排序；在Scala中应如何实现呢？

1. 两个特质

Scala提供两个特质（trait）Ordered与Ordering用于比较。其中，Ordered混入（mix）Java的Comparable接口，而Ordering则混入Comparator接口。众所周知，

- 实现Comparable接口的类，其对象具有了可比较性；
- 实现comparator接口的类，则提供一个外部比较器，用于比较两个对象。

Ordered与Ordering的区别与之相类似：

Ordered特质定义了相同类型间的比较方式，但这种内部比较方式是单一的；
Ordered则是提供比较器模板，可以自定义多种比较方式。
以下分析基于Scala 2.10.5。

Ordered
Ordered特质更像是rich版的Comparable接口，除了compare方法外，更丰富了比较操作（<, >, <=, >=）：

trait Ordered[T] extends Comparable[T] {
  def compare(that: A): Int
  def <  (that: A): Boolean = (this compare that) <  0
  def >  (that: A): Boolean = (this compare that) >  0
  def <= (that: A): Boolean = (this compare that) <= 0
  def >= (that: A): Boolean = (this compare that) >= 0
  def compareTo(that: A): Int = compare(that)
}
此外，Ordered对象提供了从T到Ordered[T]的隐式转换（隐式参数为Ordering[T]）：

object Ordered {
  /** Lens from `Ordering[T]` to `Ordered[T]` */
  implicit def orderingToOrdered[T](x: T)(implicit ord: Ordering[T]): Ordered[T] =
    new Ordered[T] { def compare(that: T): Int = ord.compare(x, that) }
}
Ordering
Ordering，内置函数Ordering.by与Ordering.on进行自定义排序：

import scala.util.Sorting
val pairs = Array(("a", 5, 2), ("c", 3, 1), ("b", 1, 3))

// sort by 2nd element
Sorting.quickSort(pairs)(Ordering.by[(String, Int, Int), Int](_._2))

// sort by the 3rd element, then 1st
Sorting.quickSort(pairs)(Ordering[(Int, String)].on(x => (x._3, x._1)))
2. 实战
比较
对于Person类，如何做让其对象具有可比较性呢？我们可使用Ordered对象的函数orderingToOrdered做隐式转换，但还需要组织一个Ordering[Person]的隐式参数：

implicit object PersonOrdering extends Ordering[Person] {
  override def compare(p1: Person, p2: Person): Int = {
    p1.name == p2.name match {
      case false => -p1.name.compareTo(p2.name)
      case _ => p1.age - p2.age
    }
  }
}

val p1 = new Person("rain", 13)
val p2 = new Person("rain", 14)
import Ordered._
p1 < p2 // True
Collection Sort
在实际项目中，我们常常需要对集合进行排序。回到开篇的问题——如何对Person类的集合做指定排序呢？下面用List集合作为demo，探讨在scala集合排序。首先，我们来看看List的sort函数：

// scala.collection.SeqLike

def sortWith(lt: (A, A) => Boolean): Repr = sorted(Ordering fromLessThan lt)

def sortBy[B](f: A => B)(implicit ord: Ordering[B]): Repr = sorted(ord on f)

def sorted[B >: A](implicit ord: Ordering[B]): Repr = {
...
}
若调用sorted函数做排序，则需要指定Ordering隐式参数：

val p1 = new Person("rain", 24)
val p2 = new Person("rain", 22)
val p3 = new Person("Lily", 15)
val list = List(p1, p2, p3)

implicit object PersonOrdering extends Ordering[Person] {
  override def compare(p1: Person, p2: Person): Int = {
    p1.name == p2.name match {
      case false => -p1.name.compareTo(p2.name)
      case _ => p1.age - p2.age
    }
  }
}
list.sorted 
// res3: List[Person] = List(name: rain, age: 22, name: rain, age: 24, name: Lily, age: 15)
若使用sortWith，则需要定义返回值为Boolean的比较函数：

list.sortWith { (p1: Person, p2: Person) =>
   p1.name == p2.name match {
     case false => -p1.name.compareTo(p2.name) < 0
     case _ => p1.age - p2.age < 0
   }
}
// res4: List[Person] = List(name: rain, age: 22, name: rain, age: 24, name: Lily, age: 15)
若使用sortBy，也需要指定Ordering隐式参数：

implicit object PersonOrdering extends Ordering[Person] {
  override def compare(p1: Person, p2: Person): Int = {
    p1.name == p2.name match {
      case false => -p1.name.compareTo(p2.name)
      case _ => p1.age - p2.age
    }
  }
}

list.sortBy[Person](t => t)
RDD sort
RDD的sortBy函数，提供根据指定的key对RDD做全局的排序。sortBy定义如下：

def sortBy[K](
  f: (T) => K,
  ascending: Boolean = true,
  numPartitions: Int = this.partitions.length)
  (implicit ord: Ordering[K], ctag: ClassTag[K]): RDD[T] 
仅需定义key的隐式转换即可：

scala> val rdd = sc.parallelize(Array(new Person("rain", 24),
      new Person("rain", 22), new Person("Lily", 15)))

scala> implicit object PersonOrdering extends Ordering[Person] {
        override def compare(p1: Person, p2: Person): Int = {
          p1.name == p2.name match {
            case false => -p1.name.compareTo(p2.name)
            case _ => p1.age - p2.age
          }
        }
      }

scala> rdd.sortBy[Person](t => t).collect()
// res1: Array[Person] = Array(name: rain, age: 22, name: rain, age: 24, name: Lily, age: 15)
3. 参考资料
[1] Alvin Alexander, How to sort a sequence (Seq, List, Array, Vector) in Scala.