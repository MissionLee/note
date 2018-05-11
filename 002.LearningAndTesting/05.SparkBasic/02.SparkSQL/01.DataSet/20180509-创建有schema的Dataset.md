#


- 以RDD形式读取数据
  - 1.在map里面提取数据，转换成case class
    - toDF
    - toDF
  - 2.创建 StructType ，rdd用map转为 Row形式
    - SparkSession.createDataFrame(RDD,StructType)
  - 3.map提取数据，转换成case class
    - SparkSession.createDataSet(RDD)
- 以SparkSession.read.format.option 这一套读取出 DataFrame （ .read方法返回的是DataFrameReader）
  - 对于没有自带schema的数据，读出来 列名称为 _c0 , _c1这样的形式，可以 用 .withColumaRenamed() 重命名为需要的形式
    - 最后可以用 .as[Case class] 转换为 DataSet
    - 如果有些字段不是String，添加 option("inferSchema","true") 的形式
      - 多数情况，用String 是合理的，有些情况用其他数据类型
      - 但是诸如 string 转 int 这种操作，都是不被允许的
  - 在读取的时候用 DDL 添加schema
    - .schema("id Int,name String,age Int")



