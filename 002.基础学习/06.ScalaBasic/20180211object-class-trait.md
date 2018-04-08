# Scala中object、class与trait的区别

原创 2016年08月08日 15:49:26 标签：Scala 2459
今天在学习Scala时，突然想用Idea来创建一个学习类（cmd撸代码太痛苦），直接创建了一个class：
```scala
class Test {  
  def main(args: Array[String]) {  
     print("Hello World!")  
  }  
} 
``` 
当我要运行这个main函数时，缺无法执行，当时就郁闷了，再次查看新建时，才知道，Scala class的分类：

那这三中类型：class，Object，Trait有什么区别嘛？

- class

在scala中，类名可以和对象名为同一个名字，该对象称为该类的伴生对象，类和伴生对象可以相互访问他们的私有属性，但是他们必须在同一个源文件内。`类只会被编译，不能直接被执行`，类的申明和主构造器在一起被申明，在一个类中，主构造器只有一个所有必须在内部申明主构造器或者是其他申明主构造器的辅构造器，主构造器会执行类定义中的所有语句。`scala对每个字段都会提供getter和setter方法`，同时也可以显示的申明，但是针对val类型，只提供getter方法，默认情况下，字段为公有类型，可以在setter方法中增加限制条件来限定变量的变化范围，在scala中方法可以访问改类所有对象的私有字段

- object

在scala中没有静态方法和静态字段，所以在scala中可以用object来实现这些功能，`直接用对象名调用的方法都是采用这种实现方式`，例如`Array.toString`。对象的构造器在第一次使用的时候会被调用，如果一个对象从未被使用，那么他的构造器也不会被执行；对象本质上拥有类（scala中）的所有特性，除此之外，object还可以一扩展类以及一个或者多个特质：例如，

```scala
abstract class ClassName（val parameter）{}
object Test extends ClassName(val parameter){}
```

注意：object不能提供构造器参数，也就是说object必须是无参的

- trait

在java中可以通过interface实现多重继承，在Scala中可以通过特征（trait）实现多重继承，不过与java不同的是，它可以定义自己的属性和实现方法体，在没有自己的实现方法体时可以认为它时java interface是等价的，在Scala中也是一般只能继承一个父类，可以通过多个with进行多重继承。
```scala
trait TraitA{}
trait TraitB{}
trait TraitC{}
object Test1 extends TraitA with TraitB with TraitC{}
```