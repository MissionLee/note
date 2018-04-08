源码
/** Composes two instances of Function1 in a new Function1, with this function applied last.

   *

   *  @tparam   A   the type to which function `g` can be applied

   *  @param    g   a function A => T1

   *  @return       a new function `f` such that `f(x) == apply(g(x))`

   */

  @annotation.unspecialized def compose[A](g: A => T1): A => R = { x => apply(g(x)) }
  // TODO : missingli  我的一些
  // scala.annotation.unspecialized
  // A method annotation which suppresses the creation of additional 
  // specialized forms based on enclosing（围住，把。。当作信封，附入） specialized type parameters
  // 一个方法注解，抑制 一种特殊格式的创建（函数声明），=>加入了专业的（专攻？专用？）类型作为参数，的创建

  // 入参 未 A ，返回 一个



  /** Composes two instances of Function1 in a new Function1, with this function applied first.

   *

   *  @tparam   A   the result type of function `g`

   *  @param    g   a function R => A

   *  @return       a new function `f` such that `f(x) == g(apply(x))`

   */

  @annotation.unspecialized def andThen[A](g: R => A): T1 => A = { x => g(apply(x)) }


// 源码中compose是说实现一个新的函数f(x) == apply(g(x))的函数，本质就是 
// 构造一个新的函数为先运行f再运行g 
// 而andThen则是实现新的函数f(x) ==g(apply(x))，二这个本质就是先运行g再运行f

/**
  * 传入Int,结果翻倍
  */
val doubleNum :Int => Int  = {num =>
  val numDouble = num * 2
  println(s"double Num ($num * 2 = $numDouble)")
  numDouble
}

/**
  *传入Int,结果加一
  */
val addOne:Int => Int = {num=>
  val sumNum = num + 1
  println(s"add One ($num + 1 = $sumNum)")
  sumNum
}

/**
  *
  * @param g
  * @param f
  * @tparam A
  * @tparam B
  * @tparam C
  * @return
  */
def myAndThen[A, B, C](g: A => B, f: B => C): A => C = x => f(g(x))



/**
  *
  * @param g
  * @param f
  * @tparam A
  * @tparam B
  * @tparam C
  * @return
  */
def myCompose[A, B, C](g: A => B, f: C => A): C => B = x => g(f(x))

//compose： 
//期待一个C类型转化为B类型，也就是是说compose则是将先执行靠里面的函数，再将结果传给外层函数，所以先执行f将C类型的x转化为一个A类型，再作为参数传给g，得到一个B类型。 
//andThen： 
//期待一个A类型转化成一个C类型，x是一个A类型，将x传给g，作为g的参数得到一个一个B类型，再将结果作为参数传给f，f在是将B类型转化为一个C类型，最终实现A类型的x转化为C类型。 
//测试用例：

val myComposeTest = myCompose[Int, Int, Int](addOne, doubleNum)
myComposeTest(2)
val composeDoubleNumInAddOne = addOne compose doubleNum
val composeAddOneInDoubleNum = doubleNum compose addOne
composeDoubleNumInAddOne(2)
composeAddOneInDoubleNum(2)
assert(myComposeTest(2)==composeDoubleNumInAddOne(2))
val myAndThenTest = myAndThen[Int,Int,Int](addOne,doubleNum)
myAndThenTest(2)
val addOneAndThenDoubleNum = addOne andThen doubleNum
val doubleNumAndThenAddOne = doubleNum andThen addOne
addOneAndThenDoubleNum(2)
doubleNumAndThenAddOne(2)
assert(myAndThenTest(2)==addOneAndThenDoubleNum(2))