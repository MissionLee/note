# 
- 首先，是将 Seq 转为，Dataset 这是前提

- 1.获取 Seq内容类型的 encoder
- 2.将encoder的schema 取为一个 attribute的集合（因为LocalRelation要求是个集合）
- 3.将 Seq里面的数据，转为 SparkSQL row
- 4.把attirbutes 和 3.步骤的到的 encoded数据传给 LocalRelation 的到 plan
- 5.用plan 获取 Dataset

- 总结： 创建一个 Dataset 需要两部分 1.是数据的attribute 类型信息，2.是与类型信息对应的row数据。这句话实际上应该反过来说，数据和对应的类型信息。其中类型信息是通过encoder从数据类型中推测的，这个类型可以是简单的类型，也可以是自定义类型，就像这里用到的case class

首先这是 dataset 里的一个 方法

```scala
 /**
   * :: Experimental ::
   * Creates a [[Dataset]] from a local Seq of data of a given type. This method requires an
   * encoder (to convert a JVM object of type `T` to and from the internal Spark SQL representation)
   * that is generally created automatically through implicits from a `SparkSession`, or can be
   * created explicitly by calling static methods on [[Encoders]].
   *
   * == Example ==
   *
   * {{{
   *
   *   import spark.implicits._
   *   case class Person(name: String, age: Long)
   *   val data = Seq(Person("Michael", 29), Person("Andy", 30), Person("Justin", 19))
   *   val ds = spark.createDataset(data)
   *
   *   ds.show()
   *   // +-------+---+
   *   // |   name|age|
   *   // +-------+---+
   *   // |Michael| 29|
   *   // |   Andy| 30|
   *   // | Justin| 19|
   *   // +-------+---+
   * }}}
   *
   * @since 2.0.0
   */
  @Experimental
  @InterfaceStability.Evolving
  def createDataset[T : Encoder](data: Seq[T]): Dataset[T] = {
    val enc = encoderFor[T]
    val attributes = enc.schema.toAttributes
    val encoded = data.map(d => enc.toRow(d).copy())
    val plan = new LocalRelation(attributes, encoded)
    Dataset[T](self, plan)
  }
```

我们先来尝试使用一些这个API

```scala
case class Person (name:String,age:Int,id:Int)
object CreateDataset {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession.builder().master("local").appName("test create dataset").getOrCreate();
    import spark.implicits._
    val sc = spark.sparkContext
    val peopleSeq = Seq(Person("zhangsan",10,1),Person("lisi",11,2))
    val df = spark.createDataset(peopleSeq)
    df.printSchema()
    df.select("name").where("age>10").show();
  }
}

```

输出的内容

```bash
root
 |-- name: string (nullable = true)
 |-- age: integer (nullable = false)
 |-- id: integer (nullable = false)

-- 

+----+
|name|
+----+
|lisi|
+----+
```

```scala
  def createDataset[T : Encoder](data: Seq[T]): Dataset[T] = {
      // 传入了一个Seq 类型是 case class Person
      // 所以 Encoder的类型 与 Dataset的类型 都是 T

    val enc = encoderFor[T]
        // encoderFor 方法，返回一个 internal encoder object 用于 在JVM-object和Spark-SQL 之间 序列化和反序列化
        // 返回的是一个 ExpressionEncoder （Encoder子类）
    val attributes = enc.schema.toAttributes
        // Encoder trait中有一个 成员 schema 要求所有实现类 实现用这个方法 返回 schema
        // 在 ExpressionEncoder中， 有这么两句：
        // val serializer = ScalaReflection.serializerFor[T](nullSafeInput)
        // val schema = serializer.dataType
        // 这边已经到了 catalyst 引擎级别的内容了，暂时不再往下看，
    val encoded = data.map(d => enc.toRow(d).copy())
        // 这里  用了 toRow 这个方法 Returns an encoded version of `t` as a Spark SQL row
        // 总之，这里把 T 类型的数据 转换成 Spark SQL 中的 row了
    val plan = new LocalRelation(attributes, encoded)
      //  这里 在 LocalRelation的定义中， 第一个参数称为 output  第二个参数称为 data
    Dataset[T](self, plan)
      // 我在此处特地了解了 Dataset[T](self,plan) 这种写法的细节是什么 
  }
```
[Scala与法的魅力-Dataset\[T\](self,plan) 这种写法的细节是什么](../../06.ScalaBasic/20180506-在此学习scala中的object-class.md)

```scala
case class LocalRelation(output: Seq[Attribute],
                         data: Seq[InternalRow] = Nil,
                         // Indicates whether this relation has data from a streaming source.
                         override val isStreaming: Boolean = false)
  extends LeafNode with analysis.MultiInstanceRelation 
```


```scala
// toRow 方法
  /**
   * Returns an encoded version of `t` as a Spark SQL row.  Note that multiple calls to
   * toRow are allowed to return the same actual [[InternalRow]] object.  Thus, the caller should
   * copy the result before making another call if required.
   */
  def toRow(t: T): InternalRow = try {
    inputRow(0) = t
    extractProjection(inputRow)
  } catch {
    case e: Exception =>
      throw new RuntimeException(
        s"Error while encoding: $e\n${serializer.map(_.simpleString).mkString("\n")}", e)
  }
  // 其中 inputRow 是在 上面定义的
  @transient
  private lazy val inputRow = new GenericInternalRow(1)
  // 想当与 每次嗲用到 inputRow 进行相关操作的时候，都会复用这一个 GenericInternalRow对象

  // 另外
  @transient
  private lazy val extractProjection = GenerateUnsafeProjection.generate(serializer)
  // 首先 这个 GenerateUnsafeProjection 的作用是 ：  
/**
 * Generates a [[Projection]] that returns an [[UnsafeRow]].
 *
 * It generates the code for all the expressions, computes the total length for all the columns
 * (can be accessed via variables), and then copies the data into a scratch buffer space in the
 * form of UnsafeRow (the scratch buffer will grow as needed).
 *
 * @note The returned UnsafeRow will be pointed to a scratch buffer inside the projection.
 */
   // .generate 方法，的作用是 /** Generates the requested evaluator given already bound expression(s). */
  def generate(
      expressions: Seq[Expression],
      subexpressionEliminationEnabled: Boolean): UnsafeProjection = {
    create(canonicalize(expressions), subexpressionEliminationEnabled)
  }

  //    
    private def create(
      expressions: Seq[Expression],
      subexpressionEliminationEnabled: Boolean): UnsafeProjection = {
    val ctx = newCodeGenContext()
    val eval = createCode(ctx, expressions, subexpressionEliminationEnabled)

    val codeBody = s"""
      public java.lang.Object generate(Object[] references) {
        return new SpecificUnsafeProjection(references);
      }

      class SpecificUnsafeProjection extends ${classOf[UnsafeProjection].getName} {

        private Object[] references;
        ${ctx.declareMutableStates()}

        public SpecificUnsafeProjection(Object[] references) {
          this.references = references;
          ${ctx.initMutableStates()}
        }

        public void initialize(int partitionIndex) {
          ${ctx.initPartition()}
        }

        // Scala.Function1 need this
        public java.lang.Object apply(java.lang.Object row) {
          return apply((InternalRow) row);
        }

        public UnsafeRow apply(InternalRow ${ctx.INPUT_ROW}) {
          ${eval.code.trim}
          return ${eval.value};
        }

        ${ctx.declareAddedFunctions()}
      }
      """

    val code = CodeFormatter.stripOverlappingComments(
      new CodeAndComment(codeBody, ctx.getPlaceHolderToComments()))
    logDebug(s"code for ${expressions.mkString(",")}:\n${CodeFormatter.format(code)}")

    val (clazz, _) = CodeGenerator.compile(code)


    // 最终返回这个东西
    clazz.generate(ctx.references.toArray).asInstanceOf[UnsafeProjection]
  }

```