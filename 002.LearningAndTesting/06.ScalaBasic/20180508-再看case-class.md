#

- 我的总结
  - 就像我之前遇到的序列化问题（必须可序列化，才能再Spark的operator中方便的使用）
  - case class 是自动被添加上了
    - Product
    - Serializable  => 这就是为什么直接用case class没有问题
- 下面是原文总结，提到前面看
  - 1、case 类在编译的时候会自动增加一个 单列对象（single object）。
  - 2、产生了一个apply的方法，那么我们可以直接把对象当作方法来用，比如 Person(12,Tom),就代表已经创建一个Person的对象，同时调用了這个对象的apply方法
  - 3、产生了一个upapply的方法，也就是说在模式匹配的时候可以用case class Person来作为 age和name的提取器
  - 4、继承了Product和Serializable（implements Product, Serializable），也就是说已经序列化和可以应用Product的方法
  - 5、age和name字段都是由final 修饰，也就是说是不可改变的，那么用scala的语言来阐述，那么就是 case class 的参数默认是  immutable类型的。
  - 6、也包含了toString,hashCode,copy,equals方法。
  - 关于case class的疑问，还是来自于Spark的相关内容。因为再看  SparkSQL中StructType的时候，发现 StructType本身也是个case class。然后自己回想相关内容已经积得不太清楚。所以这里重新测试以下
- 关于case class 与 case object 的总结
  - 可以這么总结一句话，当Person有参数的时候，用case class ，当Person没有参数的时候那么用case object。這一样意义在于区分 有参和无参

  


原文地址 ：  https://blog.csdn.net/legotime/article/details/52328288

首先我们我们对case class 和case object类型对象进行反编译

首先来编译 case class,有如下编译内容：

```scala
case class Person(age:Int,name:String)  
```

它会产生两个文件如下：

```note
Person$.class
Person.class
```
Person.class的编译内容如下：

```java
import scala.Function1;  
import scala.Option;  
import scala.Product;  
import scala.Product.class;  
import scala.Serializable;  
import scala.Tuple2;  
import scala.collection.Iterator;  
import scala.reflect.ScalaSignature;  
import scala.runtime.BoxesRunTime;  
import scala.runtime.ScalaRunTime.;  
import scala.runtime.Statics;  
  
@ScalaSignature(bytes="\6\1\5-b\1B\1\3\1\22\17a\1U3sg>t'\"A\2\2\15q*W\14\29;z}\r\11\3\2\1\7\25=\1\"a\2\6\14\3!Q\17!C\1\6g\14\fG.Y\5\3\23!\17a!\178z%\224\7CA\4\14\19\tq\1BA\4Qe>$Wo\25;\17\5\29\1\18BA\t\t\51\25VM]5bY&T\24M\257f\17!\25\2A!f\1\n\3!\18aA1hKV\tQ\3\5\2\b-%\17q\3\3\2\4\19:$\b\2C\r\1\5#\5\11\17B\11\2\t\5<W\r\t\5\t7\1\17)\26!C\19\5!a.Y7f+\5i\2C\1\16\"\29\t9q$\3\2!\17\51\1K]3eK\26L!AI\18\3\rM#(/\278h\21\t\1\3\2\3\5&\1\tE\t\21!\3\30\3\21q\23-\\3!\17\219\3\1\"\1)\3\25a\20N\\5u}Q\25\17f\11\23\17\5)\2Q\"\1\2\t\11M1\3\25A\11\t\11m1\3\25A\15\t\159\2\17\17!C\1_\5!1m\289z)\rI\3'\r\5\b'5\2\n\171\1\22\17\29YR\6%AA\2uAqa\r\1\18\2\19\5A'\1\bd_BLH\5Z3gCVdG\15J\25\22\3UR#!\6\28,\3]\2\"\1O\31\14\3eR!AO\30\2\19Ut7\r[3dW\22$'B\1\31\t\3)\tgN\\8uCRLwN\\\5\3}e\18\17#\308dQ\22\287.\263WCJL\23M\\2f\17\29\1\5!%A\5\2\5\11abY8qs\18\"WMZ1vYR$#'F\1CU\tib\7C\4E\1\5\5I\17I#\2\27A\20x\14Z;diB\19XMZ5y+\51\5CA$M\27\5A%BA%K\3\17a\23M\\4\11\3-\11AA[1wC&\17!\5\19\5\b\29\2\t\t\17\"\1\21\31\1(o\283vGR\f%/\27;z\17\29\1\6!!A\5\2E\11a\2\29:pIV\28G/\187f[\22tG\15\6\2S+B\17qaU\5\3)\"\171!\178z\17\291v*!AA\2U\t1\1\31\192\17\29A\6!!A\5Be\11q\2\29:pIV\28G/\19;fe\6$xN]\11\25B\251L\24*\14\3qS!!\24\5\2\21\r|G\14\\3di&|g.\3\2`9\nA\17\n^3sCR|'\15C\4b\1\5\5I\17\12\2\17\r\fg.R9vC2$\"a\254\17\5\29!\23BA3\t\5\29\17un\287fC:DqA\221\2\2\3\7!\11C\4i\1\5\5I\17I5\2\17!\f7\15[\"pI\22$\18!\6\5\bW\2\t\t\17\"\17m\3!!xn\21;sS:<G#\1$\t\159\4\17\17!C!_\61Q-];bYN$\"a\259\t\15Yk\23\17!a\1%\309!OAA\1\18\3\25\24A\2)feN|g\14\5\2+i\269\17AAA\1\18\3)8c\1;w\31A)qO_\11\30S5\t\1P\3\2z\17\59!/\308uS6,\23BA>y\5E\t%m\29;sC\14$h)\308di&|gN\r\5\6OQ$\t! \11\2g\"91\14^A\1\n\11b\7\"CA\1i\6\5I\17QA\2\3\21\t\7\15\297z)\21I\19QAA\4\17\21\25r\161\1\22\17\21Yr\161\1\30\17%\tY\1^A\1\n\3\11i!A\4v]\6\4\b\15\\=\21\t\5=\171\4\t\6\15\5E\17QC\5\4\3'A!AB(qi&|g\14E\3\b\3/)R$C\2\2\26!\17a\1V;qY\22\20\4\"CA\15\3\19\t\t\171\1*\3\rAH\5\r\5\n\3C!\24\17!C\5\3G\t1B]3bIJ+7o\287wKR\17\17Q\5\t\4\15\6\29\18bAA\21\17\n1qJ\256fGR\4")  
public class Person  
  implements Product, Serializable  
{  
  private final int age;  
  private final String name;  
  
  public static Option<Tuple2<Object, String>> unapply(Person paramPerson)  
  {  
    return Person..MODULE$.unapply(paramPerson);  
  }  
  
  public static Person apply(int paramInt, String paramString)  
  {  
    return Person..MODULE$.apply(paramInt, paramString);  
  }  
  
  public static Function1<Tuple2<Object, String>, Person> tupled()  
  {  
    return Person..MODULE$.tupled();  
  }  
  
  public static Function1<Object, Function1<String, Person>> curried()  
  {  
    return Person..MODULE$.curried();  
  }  
  
  public int age(){return this.age; }   
  public String name() { return this.name; }   
  public Person copy(int age, String name) { return new Person(age, name); }   
  public int copy$default$1() { return age(); }   
  public String copy$default$2() { return name(); }   
  public String productPrefix() { return "Person"; }   
  public int productArity() { return 2; }   
  public Object productElement(int x$1) { int i = x$1; switch (i) { default:  
      throw new IndexOutOfBoundsException(BoxesRunTime.boxToInteger(x$1).toString());  
    case 1:  
    case 0: } return BoxesRunTime.boxToInteger(age()); }   
  public Iterator<Object> productIterator() { return ScalaRunTime..MODULE$.typedProductIterator(this); }   
  public boolean canEqual(Object x$1) { return x$1 instanceof Person; }   
  public int hashCode() { int i = -889275714; i = Statics.mix(i, age()); i = Statics.mix(i, Statics.anyHash(name())); return Statics.finalizeHash(i, 2); }   
  public String toString() { return ScalaRunTime..MODULE$._toString(this); }   
  public boolean equals(Object x$1) { int i;  
    if (this == x$1) break label92; Object localObject = x$1; if (localObject instanceof Person) i = 1; else i = 0; if (i == 0) break label96; Person localPerson = (Person)x$1; if (age() != localPerson.age()) break label88; str = localPerson.name();  
    String tmp54_44 = name(); if (tmp54_44 != null) break label67; tmp54_44; if (str == null) break label75; label67: label75: label88: label92: label96: break label88: }   
  public Person(int age, String name) { Product.class.$init$(this);  
  }  
}  
//Person$.class的编译内容如下：
import scala.Option;  
import scala.Serializable;  
import scala.Some;  
import scala.Tuple2;  
import scala.runtime.AbstractFunction2;  
import scala.runtime.BoxesRunTime;  
  
public final class  extends AbstractFunction2<Object, String, Person>  
  implements Serializable  
{  
  public static final  MODULE$;  
  
  static  
  {  
    new ();  
  }  
  
  public final String toString()  
  {  
    return "Person"; }   
  public Person apply(, String name) { return new Person(age, name); }   
  public Option<Tuple2<Object, String>> unapply() { return new Some(new Tuple2(BoxesRunTime.boxToInteger(x$0.age()), x$0.name())); }   
  private Object readResolve() { return MODULE$; }   
  private () { MODULE$ = this;  
  }  
}  
```
分析：
- 1、case 类在编译的时候会自动增加一个 单列对象（single object）。
- 2、产生了一个apply的方法，那么我们可以直接把对象当作方法来用，比如 Person(12,Tom),就代表已经创建一个Person的对象，同时调用了這个对象的apply方法
- 3、产生了一个upapply的方法，也就是说在模式匹配的时候可以用case class Person来作为 age和name的提取器
- 4、继承了Product和Serializable（implements Product, Serializable），也就是说已经序列化和可以应用Product的方法
- 5、age和name字段都是由final 修饰，也就是说是不可改变的，那么用scala的语言来阐述，那么就是 case class 的参数默认是  immutable类型的。
- 6、也包含了toString,hashCode,copy,equals方法。

下面是《learning scala 》[1]展示的一个列表
<table>
    <thead>
        <tr>
            <td>
                Name</td>
            <td>
                Location</td>
            <td>
                Description</td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <p>
                    <code>apply</code>
                </p>
            </td>
            <td>
                <p>
                    Object</p>
            </td>
            <td>
                <p>
                    A factory method for instantiating the case class.</p>
            </td>
        </tr>
        <tr>
            <td>
                <p>
                    <code>copy</code>
                </p>
            </td>
            <td>
                <p>
                    Class</p>
            </td>
            <td>
                <p>
                    Returns a copy of the instance with any requested changes. The parameters are the class’s fields with the default values
                    set to the current field values.</p>
            </td>
        </tr>
        <tr>
            <td>
                <p>
                    <code>equals</code>
                </p>
            </td>
            <td>
                <p>
                    Class</p>
            </td>
            <td>
                <p>
                    Returns true if every field in another instance match every field in this instance. Also invocable by the operator&nbsp;
                    <code>==</code>.</p>
            </td>
        </tr>
        <tr>
            <td>
                <p>
                    <code>hashCode</code>
                </p>
            </td>
            <td>
                <p>
                    Class</p>
            </td>
            <td>
                <p>
                    Returns a hash code of the instance’s fields, useful for hash-based collections.</p>
            </td>
        </tr>
        <tr>
            <td>
                <p>
                    <code>toString</code>
                </p>
            </td>
            <td>
                <p>
                    Class</p>
            </td>
            <td>
                <p>
                    Renders the class’s name and fields to a&nbsp;
                    <code>String</code>.</p>
            </td>
        </tr>
        <tr>
            <td>
                <p>
                    <code>unapply</code>
                </p>
            </td>
            <td>
                <p>
                    Object</p>
            </td>
            <td>
                <p>
                    Extracts the instance into a tuple of its fields, making it possible to use case class instances for pattern matching.</p>
            </td>
        </tr>
    </tbody>
</table>

我们再对case object person进行编译

```scala
case object Person  
```
结果如下：




Person.class的编译内容
```java
import scala.collection.Iterator;  
import scala.reflect.ScalaSignature;  
  
@ScalaSignature(bytes="\6\19;Q!\1\2\t\2\22\ta\1U3sg>t'\"A\2\2\15q*W\14\29;z}\r\1\1C\1\4\b\27\5\17a!\2\5\3\17\3K!A\2)feN|gn\5\3\b\21A\25\2CA\6\15\27\5a!\"A\7\2\11M\28\23\r\\1\n\5=a!AB!osJ+g\r\5\2\f#%\17!\3\4\2\b!J|G-^2u!\tYA#\3\2\22\25\ta1+\26:jC2L'0\252mK\")qc\2C\11\51A(\278jiz\"\18!\2\5\b5\29\t\t\17\"\17\28\35\1(o\283vGR\4&/\264jqV\tA\4\5\2\30E5\taD\3\2 A\5!A.\258h\21\5\t\19\1\26bm\6L!a\t\16\3\rM#(/\278h\17\29)s!!A\5\2\25\nA\2\29:pIV\28G/\17:jif,\18a\n\t\3\23!J!!\11\7\3\7%sG\15C\4,\15\5\5I\17\1\23\2\29A\20x\14Z;di\22cW-\\3oiR\17Q\6\r\t\3\239J!a\f\7\3\7\5s\23\16C\42U\5\5\t\25A\20\2\7a$\19\7C\44\15\5\5I\17\t\27\2\31A\20x\14Z;di&#XM]1u_J,\18!\14\t\4mejS\"A\28\11\5ab\17AC2pY2,7\r^5p]&\17!h\14\2\t\19R,'/\25;pe\"9AhBA\1\n\3i\20\1C2b]\22\11X/\257\21\5y\n\5CA\6@\19\t\1EBA\4C_>dW-\258\t\15EZ\20\17!a\1[!91iBA\1\n\3\"\21\1\35bg\"\28u\14Z3\21\3\29BqAR\4\2\2\19\5s)\1\5u_N#(/\278h)\5a\2bB%\b\3\3%IAS\1\fe\22\fGMU3t_24X\rF\1L!\tiB*\3\2N=\t1qJ\256fGR\4")  
public final class Person  
{  
  public static String toString()  
  {  
    return Person..MODULE$.toString();  
  }  
  
  public static int hashCode()  
  {  
    return Person..MODULE$.hashCode();  
  }  
  
  public static boolean canEqual(Object paramObject)  
  {  
    return Person..MODULE$.canEqual(paramObject);  
  }  
  
  public static Iterator<Object> productIterator()  
  {  
    return Person..MODULE$.productIterator();  
  }  
  
  public static Object productElement(int paramInt)  
  {  
    return Person..MODULE$.productElement(paramInt);  
  }  
  
  public static int productArity()  
  {  
    return Person..MODULE$.productArity();  
  }  
  
  public static String productPrefix()  
  {  
    return Person..MODULE$.productPrefix();  
  }  
}  


//Person$.class的编译内容

import scala.Product;  
import scala.Product.class;  
import scala.Serializable;  
import scala.collection.Iterator;  
import scala.runtime.BoxesRunTime;  
import scala.runtime.ScalaRunTime.;  
  
public final class   
  implements Product, Serializable  
{  
  public static final  MODULE$;  
  
  static  
  {  
    new ();  
  }  
  
  public String productPrefix()  
  {  
    return "Person"; }   
  public int productArity() { return 0; }   
  public Object productElement() { int i = x$1; throw new IndexOutOfBoundsException(BoxesRunTime.boxToInteger(x$1).toString()); }   
  public Iterator<Object> productIterator() { return ScalaRunTime..MODULE$.typedProductIterator(this); }   
  public boolean canEqual() { return x$1 instanceof ; }   
  public int hashCode() { return -1907849355; }   
  public String toString() { return "Person"; }   
  private Object readResolve() { return MODULE$; }   
  private () { MODULE$ = this; Product.class.$init$(this);  
  }  
}  
```
分析
- 1、case object Person相比于case class Person(age:Int,name:String)缺少了apply、unapply方法，因为case object

是没有参数输入的，所以对于apply 和unapply的方法也自然失去。

- 2、因为class 和 object 在编译的时候，object是只有一个编译文件，而当两者加上case之后发现两者都是有2个编译文件，也就是说case object 不在像object那样仅仅是一个单列对象，而是有像类（class）一样的特性。

- 3、都有toString,hashCode,copy,equals方法和继承了Product和Serializable（implements Product, Serializable）



因为前面是case class Person(age:Int,name:String)和case object Person，因为class和object特征导致前者有参数，而后者无参数。而导致一些本质上的区别，下面再来编译一下 case class Person，此刻是不带参数的。发现和

case object Person 编译的结果一模一样。那么此刻是否认为case object 這个修饰這个是多余的。

从功能上来说是yes，

我们可以看看Mark Lewis,对此的阐述[2]


```note
Functionally, the difference is the same as between a class and an object. The former creates a blueprint for making objects and the latter defines a singleton object in the scope in which it is declared. In both situations, adding the "case" keyword causes some syntactic sugar to be included. Less of that is needed for the objects than the classes.  
  
Starting with Scala 2.10, you should always use case objects instead of case classes with no arguments. The primary use case here is that you have values you want to pattern match on and some of those need arguments and others don't. The ones that don't take arguments should be declared as case objects while the ones that do should be case classes. This makes sense given that you really don't need multiple instances of an immutable type where the instances would all have identical values.  
```

可以這么总结一句话，当Person有参数的时候，用case class ，当Person没有参数的时候那么用case object。這一样意义在于区分 有参和无参


总结



- 1、case 关键词只用来修饰  class 和object，也就是说只有case class 和case object的存在 ，

而没有case trait 或者class **这一说

- 2、case object /class A 这个A 是经过序列化，而且继承了Product特性同时有toString,hashCode,copy,equals方法

- 3、case class 经常可以用于解析和提取

- 4、有参用case class ,无参用case object





参考文献

1、https://www.safaribooksonline.com/library/view/learning-scala/9781449368814/ch09.htm

2、https://www.quora.com/Whats-the-difference-between-case-class-and-case-object-in-Scala

