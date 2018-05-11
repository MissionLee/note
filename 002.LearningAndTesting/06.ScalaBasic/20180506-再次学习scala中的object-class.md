#

- 先说之前的理解：
  - 1. object想当与 class的静态部分

- 后来在 看 Spark Dataset源码的时候，突然发现，object部分有一个 apply方法，而class 部分有 this方法

- 关于apply
  - 对于scala的 方法来说， 方法.apply相当于 调用这个方法
  - 对于一个 类，通过 Dataset类 和 在产生一些疑问之后看了以下List类之后，我坐了如下分析


>分析

- 1. 关于main方法
  - 我们知道 java中的main方法，是static的，所以才可以直接调用
  - scala中没有static方法，object中的main方法满足了调用需求
- 2. 关于集合类型，
  - 在scala中，一定是需要一中方法，新建一个list的，我们可以new 一个，也可以直接创建一个给定了元素的
  - 以下代码
  ```scala
    val l1 = List(1,2,3)
    val l2:List[Int] = List();
    val a1 = new Array[Int](10);
    val a2=Array(1,2,3,4);
  ```
  - l1 的创建，相当于 
  ```scala
  val l1 = List.apply(1,2,3)
  ```
  - l2 的创建，相当于 Java语言当中的 new

- 为了验证关于集合的猜想，我坐了下面的测试
  - 1.在没有object的情况下
  ```scala
  class Person(var name:String,var age:Int){
  
  }
  object AboutObjectClassApply {
  def main(args: Array[String]): Unit = {
    val x = new Person1("li",2)
    // val y = Person1("wang",3) can not resolve symbol
  }
  }

  ```
  - 2.我们按照套路，添加object
  ```scala
    object Person1 {
      def apply(name:String,age:Int): Person1 ={
        val person = new Person1(name,age)
        person
      }
    }
    class Person1(var name:String,var age:Int){

    }
    object AboutObjectClassApply {
      def main(args: Array[String]): Unit = {
        val x = new Person1("li",2)
        val y = Person1.apply("a",2)
        val z = Person1("c",3)
      }
    }
  ```
  - 3.有object但是没有apply会怎么样？
    - apply实际上就是为了让代码在书写起来更加方便
    - 为了看看效果，我们改动以下代码
    ```scala
    object Person1 {
      def apply(name: String, age: Int): Person1 = {
        println("apply")
        val person = new Person1(name, age)
        person
      }
    }

    class Person1(name: String) {
      var age: Int=0

      def this(name: String, age: Int)={
        this(name);
        println("constructor")
        this.age=age
      }
    }
    object AboutObjectClassApply {
      def main(args: Array[String]): Unit = {
        println("------new person1")
        val x = new Person1("li",2)
        print("-----apply")
        val y = Person1.apply("a",2)
        val z = Person1("c",3)
      }
    }
    //    ------new person1
    //    constructor
    //    -----applyapply
    //    constructor
    //    apply
    //    constructor
    ```
    - 下面两次创建对象，可以看出来，为了能够最简化代码书写，如果这个对象总是要用到，那么我们用object+apply套路，能帮助我们减少代码量

