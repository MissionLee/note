本节主要内容
模式匹配入门
Case Class简介
Case Class进阶
1. 模式匹配入门
在java语言中存在switch语句，例如：
```java
//下面的代码演示了java中switch语句的使用
public class SwitchDemo {
    public static void main(String[] args) {
        for(int i = 0; i < 100; i++) { 
            switch (i) {
            case 10:System.out.println("10");
                break;
            //在实际编码时，程序员很容易忽略break语句
            //这容易导致意外掉入另外一个分支
            case 50:System.out.println("50");
            case 80:System.out.println("80");
            default:
                break;
            }
        }
    }
}
```
scala解决了java语言中存在的这个问题，scala解决这一问题的利器就是模式匹配，上面的java代码可以利用scala语言的模式匹配来避免，代码如下：

```scala
object PatternMatching extends App{
  for(i<- 1 to 100){
    i  match {
      case 10 => println(10)
      case 50 => println(50)
      case 80 => println(80)
      case _ => 
    }
  }
}
```
上述scala代码展示了如何使用scala中的模式匹配，它的实现方式是通过match关键字与 case X=>的方式实现的，其中case _表示除了 case 10,case 50,case 80的其余匹配，类似于java中的default。但scala语言中提供了更为灵活的匹配方式，如：
```scala
object PatternMatching extends App{
  for(i<- 1 to 100){
    i  match {
      case 10 => println(10)
      case 50 => println(50)
      case 80 => println(80)
      //增加守卫条件
      case _ if(i%4==0)=> println(i+":能被4整除")
      case _ if(i%3==0)=> println(i+":能被3整除")
      case _ =>
    }
  }
}
```
case语言中还可以加相应的表达式，例如：
```scala
object PatternMatching extends App{
  var list=new ArrayBuffer[Int]()
  var x=0
  for(i<- 1 to 100){
    i  match {
      //后面可以跟表达式
      case 10 => x=10
      case 50 => println(50)
      case 80 => println(80)
      case _ if(i%4==0)=> list.append(i)
      case _ if(i%3==0)=> println(i+":能被3整除")
      case _ =>
    }
  }
  println(x)
}
```
2 Case Class简介
Case Class一般被翻译成样例类，它是一种特殊的类，能够被优化以用于模式匹配，下面的代码定义了一个样例类：
```scala
//抽象类Person
abstract class Person

//case class Student
case class Student(name:String,age:Int,studentNo:Int) extends Person
//case class Teacher
case class Teacher(name:String,age:Int,teacherNo:Int) extends Person
//case class Nobody
case class Nobody(name:String) extends Person

object CaseClassDemo{
  def main(args: Array[String]): Unit = {
    //case class 会自动生成apply方法，从而省去new操作
    val p:Person=Student("john",18,1024)  
    //match case 匹配语法  
    p  match {
      case Student(name,age,studentNo)=>println(name+":"+age+":"+studentNo)
      case Teacher(name,age,teacherNo)=>println(name+":"+age+":"+teacherNo)
      case Nobody(name)=>println(name)
    }
  }
}
```
当一个类被声名为case class的时候，scala会帮助我们做下面几件事情： 
- 1 构造器中的参数如果不被声明为var的话，它默认的话是val类型的，但一般不推荐将构造器中的参数声明为var 
- 2 自动创建伴生对象，同时在里面给我们实现子apply方法，`使得我们在使用的时候可以不直接显示地new对象` 
- 3 `伴生对象中同样会帮我们实现unapply方法，从而可以将case class应用于模式匹配`，关于unapply方法我们在后面的“`提取器`”那一节会重点讲解 
- 4 实现自己的toString、hashCode、copy、equals方法 
除此之此，case class与其它普通的scala类没有区别

下面给出case class Student字节码文件内容，以验证我们上述所讲的内容:
```java
//下面的代码是自动生成的伴生对象中的字节码内容
D:\ScalaWorkspace\ScalaChapter13\bin\cn\scala\xtwy>javap -private Student$.class

Compiled from "CaseClass.scala"
public final class cn.scala.xtwy.Student$ extends scala.runtime.AbstractFunction
3<java.lang.String, java.lang.Object, java.lang.Object, cn.scala.xtwy.Student> i
mplements scala.Serializable {
  public static final cn.scala.xtwy.Student$ MODULE$;
  public static {};
  public final java.lang.String toString();
  public cn.scala.xtwy.Student apply(java.lang.String, int, int);
  public scala.Option<scala.Tuple3<java.lang.String, java.lang.Object, java.lang
.Object>> unapply(cn.scala.xtwy.Student);
  private java.lang.Object readResolve();
  public java.lang.Object apply(java.lang.Object, java.lang.Object, java.lang.Ob
ject);
  private cn.scala.xtwy.Student$();
}

//下面的代码是Student类自身的字节码内容
D:\ScalaWorkspace\ScalaChapter13\bin\cn\scala\xtwy>javap -private Student.class
Compiled from "CaseClass.scala"
public class cn.scala.xtwy.Student extends cn.scala.xtwy.Person implements scala
.Product,scala.Serializable {
  private final java.lang.String name;
  private final int age;
  private final int studentNo;
  public static scala.Function1<scala.Tuple3<java.lang.String, java.lang.Object,
 java.lang.Object>, cn.scala.xtwy.Student> tupled();
  public static scala.Function1<java.lang.String, scala.Function1<java.lang.Obje
ct, scala.Function1<java.lang.Object, cn.scala.xtwy.Student>>> curried();
  public java.lang.String name();
  public int age();
  public int studentNo();
  public cn.scala.xtwy.Student copy(java.lang.String, int, int);
  public java.lang.String copy$default$1();
  public int copy$default$2();
  public int copy$default$3();
  public java.lang.String productPrefix();
  public int productArity();
  public java.lang.Object productElement(int);
  public scala.collection.Iterator<java.lang.Object> productIterator();
  public boolean canEqual(java.lang.Object);
  public int hashCode();
  public java.lang.String toString();
  public boolean equals(java.lang.Object);
  public cn.scala.xtwy.Student(java.lang.String, int, int);
}
```
3. case class应用实战
- 1 case class常用方法 
前面我们提到，定义case class便会自动生成对应的toString,hashCode,equals,copy等方法，
```scala
//toString方法演示
scala> val s=Teacher("john",38,1024)
s: Teacher = Teacher(john,38,1024)

//无参copy方法演示
scala> val s1=s.copy()
s1: Teacher = Teacher(john,38,1024)

//copy方法是深度拷贝
scala> println(s eq s1)
false

//equal方法根据对象内容进行比较
scala> println(s equals s1)
true

scala> println(s == s1)
true

//hashcode方法
scala> s1.hashCode
res45: Int = 567742485

//toString方法
scala> s1.toString
res46: String = Teacher(john,38,1024)

//带一个参数的copy方法
scala> s1.copy(name="stephen")
res47: Teacher = Teacher(stephen,38,1024)
//带二个参数的copy方法
scala> s1.copy(name="stephen",age=58)
res49: Teacher = Teacher(stephen,58,1024)
//带三个参数的copy方法
scala> s1.copy(name="stephen",age=58,teacherNo=2015)
res50: Teacher = Teacher(stephen,58,2015)
```
- 2 多个参数的case class
```scala
abstract class Person

case class Student( name:String, age:Int, studentNo:Int) extends Person

case class Teacher( name:String, age:Int, teacherNo:Int) extends Person

case class Nobody( name:String) extends Person

//SchoolClass为接受多个Person类型参数的类
case class SchoolClass(classDescription:String,persons:Person*)

//下列代码给出的是其模式匹配应用示例
object CaseClassDemo{
  def main(args: Array[String]): Unit = {
     val sc=SchoolClass("清华大学",Teacher("摇摆少年梦",27,2015),Student("摇摆少年梦",27,2015))
     sc match{
       case SchoolClass(_,_,Student(name,age,studetNo))=>println(name)
       case _ => println("Nobody")
     }
  }
}
```
3 sealed case class

在进行模式匹配的时候，有些时候需要确`保所有的可能情况都被列出`，此时常常会将case class的超类定义为sealed（密封的) case class，如：（`主要解释在注释里面，另外还有一个作用，就是，不能在类定义的文件之外定义新的子类-》用于防止继承的滥用`）
```scala
//Person最前面加了个关键字sealed
sealed abstract class Person

case class Student( name:String, age:Int, studentNo:Int) extends Person

case class Teacher( name:String, age:Int, teacherNo:Int) extends Person

case class Nobody( name:String) extends Person

case class SchoolClass(classDescription:String,persons:Person*)

object CaseClassDemo{
  def main(args: Array[String]): Unit = {
     val s:Person=Student("john",18,1024)
     //这边仅仅给出了匹配Student的情况，在编译时
     //编译器会提示
     //match may not be exhaustive. It would fail on the following inputs: Nobody(_), Teacher(_, _, _)
     s match{
       case Student(name,age,studentNo)=>println("Student")
     }
  }
}
```
编译器给出的提示可以通过下列语句进行消除，

另外一个解释： https://www.jianshu.com/p/3dd9b53801b0
```scala
//下面的语句达到了sealed class的要求
 val s:Person=Student("john",18,1024)
     s match{
       case Student(name,age,studentNo)=>println("Student")
       case Teacher(name,age,studentNo)=>println("Teacher")
       case Nobody(name)=>println("Nobody")
     }
```
4 case class在实用应用中的其它用途 
某个类一旦被定义为case class，则编译器会自动生成该类的伴生对象，伴生对象中包括了apply方法及unapply方法，apply方法使得我们可以不需要new关键字就可以创建对象，而unapply方法，则使得可以方便地应用在模式匹配当中，另外编译器还自动地帮我们实现对应的toString、equals、copy等方法。在实际中，case class除了在模式匹配时能发挥其强大的威力之外，在进行其它应用时，也显示出了其强大的功能，下面给出case class在SparkSQL中的应用，旨在说明case class在实际应用中的重要地位。

