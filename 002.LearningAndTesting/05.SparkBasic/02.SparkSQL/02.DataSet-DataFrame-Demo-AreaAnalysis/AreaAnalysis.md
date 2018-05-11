#

用MySQL 与 SparkSQL 来实现 几个分析需求的全过程

## 首先是 SQL 源文件

```sql
DROP TABLE IF EXISTS `areas`;
CREATE TABLE `areas` (
  `id` int(11) NOT NULL auto_increment,
  `areaid` varchar(20) NOT NULL,
  `area` varchar(50) NOT NULL,
  `cityid` varchar(20) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='行政区域县区信息表';
insert into areas(id,areaid,area,cityid) values(1,'110101','东城区','110100');
-- 余下插入语句略

DROP TABLE IF EXISTS `cities`;
CREATE TABLE `cities` (
  `id` int(11) NOT NULL auto_increment,
  `cityid` varchar(20) NOT NULL,
  `city` varchar(50) NOT NULL,
  `provinceid` varchar(20) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='行政区域地州市信息表';

insert into cities(id,cityid,city,provinceid) values(1,'110100','市辖区','110000');
-- 余下插入语句略


DROP TABLE IF EXISTS `provinces`;
CREATE TABLE `provinces` (
  `id` int(11) NOT NULL auto_increment,
  `provinceid` varchar(20) NOT NULL,
  `province` varchar(50) NOT NULL,
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COMMENT='省份信息表';


insert into provinces(id,provinceid,province) values(1,'110000','北京市');
-- 余下插入语句略
```

## 数据处理

因为源数据找的就是SQL 文件，对于MySQL 来说，直接导入 数据库就可以了

Spark方向，为了更加贴近真实场景，我们直接把这三份SQL 文件作为源文件

- step-1 ： 通过Spark解析SQL里面的详细内容，存储为需要的形式（数据仓库）
- step-2 ： 以解析后的数据进行分析

## Spark-ETL

```scala
package com.missionlee.spark.datasettest.areaanalysis


import com.missionlee.hadoop.util.HdfsOperator
import com.missionlee.spark.datasettest.{City, Province}
import org.apache.spark.sql.{Dataset, Row, SparkSession}
import org.apache.spark.sql.types.{IntegerType, StringType, StructField, StructType}

/**
  * @author
  *
  *   the source data of this demo is in SQL like:
  *      insert into provinces(id,provinceid,province) values(1,'110000','北京市');
  *   so at first,we need to  extract the information from the data
  *   and than I decide to Save the in parquet (hive is also a good choice)
  *
  *   I have put two case class in package.scala
  */

object SaveDataAsParquet {
  

  def main(args: Array[String]): Unit = {
    System.setProperty("HADOOP_USER_NAME", "hadoop")
    val ss = SparkSession.builder().master("local[*]").appName("AreaAnalysis").getOrCreate()
    val sc = ss.sparkContext
    import ss.implicits._
    val rddArea = sc.textFile("/home/missingli/IdeaProjects/Spark-Learning-Testing/src/main/scala/com/missionlee/data/area.sql")
    val rddCity = sc.textFile("/home/missingli/IdeaProjects/Spark-Learning-Testing/src/main/scala/com/missionlee/data/city.sql")
    val rddProvince = sc.textFile("/home/missingli/IdeaProjects/Spark-Learning-Testing/src/main/scala/com/missionlee/data/province.sql")

    def save[T](hdfsPath:String, ds:Dataset[T]):Boolean={
      try {
        val ho = new HdfsOperator("localhost:9000")
        if(ho.checkHDFSFileExists(hdfsPath)){
          ho.deleteHDFSFile(hdfsPath)
        }
        ds.write.parquet(hdfsPath)
        return true
      }
      return false
    }


    def myfilter(line:String):Boolean={
      return line.startsWith("insert")
    }

    // get province
    def myProvinceExtractor(line:String):Province={
      val values = line.split(" ")(3)
      val attri = values.split("\\(|\\)")
      val attr =attri(1).split(",")
      val id = attr(0).toInt
      val pid = attr(1).replaceAll("'","")
      val name = attr(2).replaceAll("'","")
      Province(id,pid,name)
    }
    val province = rddProvince
      .filter(myfilter)
      .map(myProvinceExtractor)
      .toDS()
      .withColumnRenamed("name","ProvinceName")

    // get city and area
    val schemaArray = new Array[StructField](4);
    var i = 1;
    schemaArray(0) = StructField("id",IntegerType,nullable=false)
    for(x <- "administrativeCode,name,parentCode".split(",")){
      schemaArray(i)=StructField(x,StringType,nullable = false)
      i+=1
    }
    val schema = StructType(schemaArray);

    def myAreaExtractor(line:String)={
      val values = line.split(" ")(3)
      val attri = values.split("\\(|\\)")
      val attr =attri(1).split(",")
      val id = attr(0).toInt
      val pid = attr(1).replaceAll("'","")
      val name = attr(2).replaceAll("'","")
      val parentid = attr(3).replaceAll("'","")
      Row(id,pid,name,parentid)
    }
    val areaRi = rddArea.filter(myfilter).map(myAreaExtractor)
    val area = ss.createDataFrame(areaRi,schema);

    def myCityExtractor(line:String)={
      val values = line.split(" ")(3)
      val attri = values.split("\\(|\\)")
      val attr =attri(1).split(",")
      val id = attr(0).toInt
      val pid = attr(1).replaceAll("'","")
      val name = attr(2).replaceAll("'","")
      val parentid = attr(3).replaceAll("'","")
      City(id,pid,name,parentid)
    }
    val cityRi = rddCity.filter(myfilter).map(myCityExtractor)
    val city = ss.createDataset(cityRi)
      .withColumnRenamed("name","CityName")

    /***
      * now we have three dataset/dataframe
      *   province
      *   city
      *   area
      * */
    println(save("hdfs://localhost:9000/lms/spark/20180510_AreaAnalysis/city.parquet",city))
    println(save("hdfs://localhost:9000/lms/spark/20180510_AreaAnalysis/area.parquet",area))
    println(save("hdfs://localhost:9000/lms/spark/20180510_AreaAnalysis/province.parquet",province))
    
  }
}
class SaveDataAsParquet{

}
```

## 数据分析

MySQL中，已经可以开始分析了，Spark需要先读取数据然后分析

```scala
  def loadData(): Unit = {
    area = spark.read.parquet("hdfs://localhost:9000/lms/spark/20180510_AreaAnalysis/area.parquet")
    city = spark.read.parquet("hdfs://localhost:9000/lms/spark/20180510_AreaAnalysis/city.parquet")
    province = spark.read.parquet("hdfs://localhost:9000/lms/spark/20180510_AreaAnalysis/province.parquet")
    println("----------area----------------")
    area.printSchema()
    println("----------city----------------")
    city.printSchema()
    println("----------province--------------")
    province.printSchema()
  }
```
```note
----------area----------------
root
 |-- id: integer (nullable = true)
 |-- administrativeCode: string (nullable = true)
 |-- name: string (nullable = true)
 |-- parentCode: string (nullable = true)

----------city----------------
root
 |-- id: integer (nullable = true)
 |-- administrativeCode: string (nullable = true)
 |-- CityName: string (nullable = true)
 |-- parentCode: string (nullable = true)

----------province--------------
root
 |-- id: integer (nullable = true)
 |-- administrativeCode: string (nullable = true)
 |-- ProvinceName: string (nullable = true)
```


>中国总计有多少个市
- sql
```sql
select count(1) from provinces;
```
- Spark
```scala
  def countProvince(): Unit = {
    // solution 1
    province.selectExpr("count(1) as NumberOfProvince").show()
    // solution 2
    println("NumberOfProvince: " + province.count())
    // solution 3 : attention -> this solution need  import spark.implicits._
    println("NumberOfProvince: " + province.map(_ => 1).reduce(_ + _))
  }
```

>每个省有多少个城市
- sql
```sql
select p.province,count(c.id)
    from provinces p
    join cities c
    on p.provinceid=c.provinceid
    group by p.id;
```
- spark
```scala
  def countCitiesOfProvince(): Unit = {
    province
      .join(city, province("administrativeCode") === city("parentCode"))
      .groupBy(province("id"), province("ProvinceName"))
      .count().show()
  }
```

>某一个省份有多少城市

- sql
```sql
select p.province,count(c.id)
    from provinces p
    join cities c
    on p.provinceid=c.provinceid
    group by p.id
    where p.id="XXX";
```
- spark
```scala
  def countCitiesOfAProvince(_provinceId: Int): Unit = {
    var provinceId = 0;
    if (_provinceId < 1 || _provinceId > 34) {
      println("the provinceId show between 1~34 ")
      provinceId = 1;
    } else {
      provinceId = _provinceId
    }

    province.where($"id" === provinceId)
      .join(city, province("administrativeCode") === city("parentCode"))
      .groupBy(province("ProvinceName"))
      .count().withColumnRenamed("count", "numberOfCities")
  }
```

>计算每个省份拥有最多的区域的城市是哪一个
- sql
```sql
-- 1. 计算每个城市有多少个区域
-- 2. 在省份group的情况下，max 数量
-- 3. 小问题 t1 和 t3 是完全相同的，写个view好一些

SELECT
  t2.province,
  t3.city,
  t2.max
FROM
  (
    SELECT
      p.provinceid,
      p.province,
      max(t1.num) AS max
    FROM provinces p
      JOIN
      (
        SELECT
          c.provinceid,
          c.city,
          count(a.id) AS num
        FROM cities c
          JOIN areas a
            ON c.cityid = a.cityid
        GROUP BY c.provinceid, c.city
      ) t1
        ON p.provinceid = t1.provinceid
    GROUP BY p.id
  ) t2
  JOIN (
         SELECT
           c.provinceid,
           c.city,
           count(a.id) AS num
         FROM cities c
           JOIN areas a
             ON c.cityid = a.cityid
         GROUP BY c.provinceid, c.city
       ) t3
    ON t3.num = t2.max
where t3.provinceid=t2.provinceid;
    
-- 把上面的改称一个 - 存储过程 - 
DROP PROCEDURE IF EXISTS max_count_ca;
DELIMITER ^

CREATE PROCEDURE max_count_ca()
  BEGIN


    DROP VIEW IF EXISTS cityareanum;
    CREATE VIEW cityareanum AS
      SELECT
        c.provinceid,
        c.city,
        count(a.id) AS num
      FROM cities c
        JOIN areas a
          ON c.cityid = a.cityid
      GROUP BY c.provinceid, c.city;

    SELECT
      t2.province,
      t3.city,
      t2.max
    FROM
      (
        SELECT
          p.provinceid,
          p.province,
          max(t1.num) AS max
        FROM provinces p
          JOIN
          cityareanum t1
            ON p.provinceid = t1.provinceid
        GROUP BY p.id
      ) t2
      JOIN cityareanum t3
        ON t3.num = t2.max
    WHERE t3.provinceid = t2.provinceid;
    DROP VIEW cityareanum;

  END
^
DELIMITER ;

CALL max_count_ca;
```
- spark
```scala
    city.createTempView("city")
    area.createTempView("area")
    province.createTempView("province")
sql("SELECT\n  t2.ProvinceName,\n  t3.CityName,\n  t2.max\nFROM\n  (\n    SELECT\n      p.administrativeCode,\n      p.ProvinceName,\n      max(t1.num) AS max\n    FROM province p\n      JOIN\n      (\n        SELECT\n          c.parentCode,\n          c.CityName,\n          count(a.id) AS num\n        FROM city c\n          JOIN area a\n            ON c.administrativeCode = a.parentCode\n        GROUP BY c.parentCode, c.CityName\n      ) t1\n        ON p.administrativeCode = t1.parentCode\n    GROUP BY p.administrativeCode,p.ProvinceName\n  ) t2\n  JOIN (\n         SELECT\n           c.parentCode,\n           c.CityName,\n           count(a.id) AS num\n         FROM city c\n           JOIN area a\n             ON c.administrativeCode = a.parentCode\n         GROUP BY c.parentCode, c.CityName\n       ) t3\n    ON t3.num = t2.max\nWHERE t3.parentCode = t2.administrativeCode").show()

```