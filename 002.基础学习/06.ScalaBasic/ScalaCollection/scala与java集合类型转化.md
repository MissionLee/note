 scala--java集合类型转换

```scala
一   scala  <==> java 
以下集合可以进行任意，转换。但在某些情况下引入的隐式转换不正确或未引入，仍然无法进行正确转换，如API的例子


scala.collection.Iterable <=> java.lang.Iterable
scala.collection.Iterable <=> java.util.Collection
scala.collection.Iterator <=> java.util.{ Iterator, Enumeration }
scala.collection.mutable.Buffer <=> java.util.List
scala.collection.mutable.Set <=> java.util.Set
scala.collection.mutable.Map <=> java.util.{ Map, Dictionary }
scala.collection.concurrent.Map <=> java.util.concurrent.ConcurrentMap


总结下来就是:collection:可以指定元素排序规则：sort方法或继承comparable
scala.collection.Iterable<=>java.lang.{iterable,collection}
scala.collection.Iterator<=>java.util.{Iterator,Enumeration}




scala的Buffer对应就是java.util.List,不可直接使用，使用ListBuffer
scala.collection.mutable.Buffer<=>java.util.List
scala.collection.mutable.Set<=>java.util.Set
scala.collection.mutable.Map<=>java.util.{Map,Dictionary}


并发安全集合


scala.collection.concurrent.Map<=>java.util.concurrent.ConcurrentMap




以下为scala.collection.mutable.ListBuffer<=>java.util.List
除要求引入相应的转换类JavaConversions._，还有引入ListBuffer=>java.util.List 具体转换方法


二  栗子
import scala.collection.JavaConversions._
import scala.collection.JavaConversions.bufferAsJavaList
import scala.collection.JavaConversions.asScalaBuffer


object Imliplicit{
          def main(args: Array[String]): Unit = {
              val sl = new  scala.collection.mutable.ListBuffer[Int] 
              val jl : java.util.List[Int] = sl
              val sl2 : scala.collection.mutable.Buffer[Int] = jl
        
              println("两者集合是否相等：   "+(sl eq sl2))
          } 
}



三  单向转换
补充介绍，下列可以进行单向转换


scala.collection.Seq =>java.util.List
scala.collection.mutable.Seq => java.util.List
scala.collection.Set =>java.util.Set
scala.collection.Map =>java.util.Map


操作参数/属性配置文件的类
java.util.Properties => scala.collection.mutable.Map[String,String]



具体转换方法

Scala 集合对象===>Java 集合对象
如果在进行java集合对象与scala集合对象的转换时，引入import scala.collection.JavaConversions._后仍然无法转换，
则尝试引入你要转换的集合类型对应的具体隐式转换方法，方法如下：



implicit def  asJavaCollection[A](it:iterable[A]):collection[A]
     隐式转换一个scala iterable 为  一个不可变的java.collection


implicit def  asJavaDictionary[A,B](m:mutable.Map[A,B]):Dictionary[A,B]
     隐式转换一个scala iterable 为一个java  Dictionary


implicit def  asJavaEnumeration[A](it:Iterator[A]):java.util.Enumeration
     隐式转换一个scala iterable 为一个java Enumeration
 
implicit def  asJavaIterable[A](i:iterable[A]):java.lang.Iterable[A]
     隐式转换一个scala iterable 为一个java Iterable
 
implicit def  asJavaIterator[A](it:Iterator[A]):java.lang.Iterator
     隐式转换一个scala iterator 为一个java iterator
 
implicit def  bufferAsJavaList[A](s:java.util.Set[A]):java.util.list
     隐式一个scalaBuffer（用其实现Buffer接口，AbstractBuffer抽象类的子类作为接受对象）为java.util.list
 
implicit def  mapAsJavaConcurrentMap[A,B](m:concurrent.Map[A,B]):ConcurrentMap[A,B]
     隐式转换一个Scala.mutable.concurrent.Map 转换为 java.concurrent.ConcurrentMap 
 
implicit def  mapAsJavaMap[A,B](m:Map[A,B]):java.util.Map[A,B]
     隐式转换一个scala.Map 转换为java map对象
 
implicit def  mutableMapAsJavaMap[A,B](m:mutable.Map[A,B]):java.util.Map[A,B]
     隐式转换一个 scala.mutable.Map转换为一个 java.util.Map对象
 
implicit def  mutableSeqAsJavaList[A,B](m:mutable.Seq[A,B]):java.util.List[A,B]
     隐式转换一个 scala.mutable.Seq 转换为一个 java.util.List对象


implicit def  mutableSetAsJavaSet[A,B](m:mutable.Set[A,B]):java.util.Set[A,B]
     隐式将一个 scala.mutable.Seq 转换为一个 java.util.Set对象
 
 
 
 
 
 
 
Java 集合对象 ==> Scala集合对象


implicit def  asScalaBuffer[A](l:java.util.List[A]):Buffer[A]
     隐式转换一个java.util.list对象为scalaBuffer（用其实现Buffer接口，AbstractBuffer抽象类的子类作为接受对象）
 
implicit def  asScalaIterator[A](it:java.util.Iterator[A]):Iterator[A]
     隐式转换一个java.util.iterator对象为scala.iterator
 
implicit def  asScalaSet[A](s:java.util.Set[A]):mutable.Set 
     隐式转换一个java.util.Set 为mutable.Set


implicit def  collectionAsScalaIterable[A](i:Collection[A]):Iterable[A]
     隐式转换一个java.collection对象为scala.iterable
 
implicit def  dictionaryAsScalaMap[A,B](p:Dictionary[A,B]):mutable.Map[A,B]
     隐式转换一个java.Dictionary 对象转换为Scala.mutable.Map[String,String]
 
implicit def  enumerationAsScalaIterator[A](i:java.lang.Enumeration[A]):Iterator[A]
     隐式将一个java.Enumeration 对象转换为Scala.iterator对象
 
implicit def  iterableAsScalaIterable[A](i:java.lang.Iterable[A]):Iterable[A]
     隐式将一个java.Iterable对象转换为Scala.iterable对象

implicit def  mapAsScalaConcurrentMap[A,B](m:ConcurrentMap[A,B]):concurrent.Map[A,B]
     隐式将一个java concurrentMap 转换为一个scala.concurrentMap对象
 
implicit def  mapAsScalaMap[A,B](m:java.util.Map[A,B]):mutable.Map[A,B]
     隐式将一个java.util.Map 转换为一个scala.Map 对象
 
implicit def  propertiesAsScalaMap(p:Properties):mutable.Map[String,String]
     隐式将一个 java Properties 转换为一个 mutable.Map对象  
 
implicit def  seqAsJavaList[A](seq:Seq[A]):java.util.List[A]
     隐式将一个scala.Seq  转换为一个 java.util.List 对象


implicit def  setAsJavaSet[A](set:Set[A]):java.util.Set[A]
     隐式将一个scala.Set  转换为一个 java.util.Set 对象   
