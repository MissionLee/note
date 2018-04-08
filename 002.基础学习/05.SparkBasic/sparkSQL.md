Spark2.1.1<SparkSQL中常用四大连接>
原创 2017年06月30日 18:42:33 标签：sparksql 548
环境：

Spark 2.1.1 
1
准备工作

persons.csv:
```bash
        +----+--------+---------+--------------+--------+
        |Id_P|LastName|FirstName|       Address|    City|
        +----+--------+---------+--------------+--------+
        |   1|   Adams|     John| Oxford Street|  London|
        |   2|    Bush|   George|  Fifth Avenue|New York|
        |   3|  Carter|   Thomas|Changan Street| Beijing|
        +----+--------+---------+--------------+--------+
```


orders.csv:

```bash
        +----+-------+----+
        |Id_O|OrderNo|Id_P|
        +----+-------+----+
        |   1|  77895|   3|
        |   2|  44678|   3|
        |   3|  22456|   1|
        |   4|  24562|   1|
        |   5|  34764|  65|
        +----+-------+----+
```
使用到的依赖：

  <dependencies>
        <!-- https://mvnrepository.com/artifact/org.apache.spark/spark-sql_2.10 -->
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-sql_2.11</artifactId>
            <version>2.1.1</version>
        </dependency>

    </dependencies>
1
2
3
4
5
6
7
8
9
创建SparkSession，读入文件：

    val session = SparkSession.builder().appName("SQL").master("local[2]").getOrCreate()
    val sqlcontext = session.sqlContext
    val orders: DataFrame = session
      .read.option("header", "true")
      .csv(Join.getClass.getResource("/") + "orders.csv")
    val persons: DataFrame = session
      .read.option("header", "true")
      .csv(Join.getClass.getResource("/") + "persons.csv")
       persons.createTempView("Persons")
    orders.createTempView("Orders")
1
2
3
4
5
6
7
8
9
10
这里写图片描述

1.自然连接（内连接）

作用：选出在两张表中都有的主键的对应的记录

The INNER JOIN keyword selects all rows from both tables as long as there is a match between the columns. If there are records in the "Orders" table that do not have matches in "persons", these orders will not show
1
1.1自然连接（不用指明要连接的列名）

 sqlcontext.sql("SELECT * FROM Persons NATURAL JOIN Orders").show()
1
得到的结果：

+----+--------+---------+--------------+-------+----+-------+
|Id_P|LastName|FirstName|       Address|   City|Id_O|OrderNo|
+----+--------+---------+--------------+-------+----+-------+
|   1|   Adams|     John| Oxford Street| London|   4|  24562|
|   1|   Adams|     John| Oxford Street| London|   3|  22456|
|   3|  Carter|   Thomas|Changan Street|Beijing|   2|  44678|
|   3|  Carter|   Thomas|Changan Street|Beijing|   1|  77895|
+----+--------+---------+--------------+-------+----+-------+
1
2
3
4
5
6
7
8
1.2 内连接

 sqlcontext.sql("SELECT * FROM Persons INNER JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
1
得到的结果：

+----+--------+---------+--------------+-------+----+-------+----+
|Id_P|LastName|FirstName|       Address|   City|Id_O|OrderNo|Id_P|
+----+--------+---------+--------------+-------+----+-------+----+
|   1|   Adams|     John| Oxford Street| London|   4|  24562|   1|
|   1|   Adams|     John| Oxford Street| London|   3|  22456|   1|
|   3|  Carter|   Thomas|Changan Street|Beijing|   2|  44678|   3|
|   3|  Carter|   Thomas|Changan Street|Beijing|   1|  77895|   3|
+----+--------+---------+--------------+-------+----+-------+----+
1
2
3
4
5
6
7
8
请注意： 
sqlcontext.sql("SELECT * FROM Persons JOIN Orders ON Persons.Id_P=Orders.Id_P").show() 
这句scala语句的执行结果和内连接是一样的，从写法上省略了Inner


从结果可以看出，内连接需要指明连接列名，而且结果比自然连接多了一列，有两列是相同的

2.左外连接

作用：LEFT JOIN 关键字会从左表 (Persons) 那里返回所有的行，即使在右表 (Orders) 中没有匹配的行。

The LEFT JOIN keyword returns all records from the left table (table1), and the matched records from the right table (table2). The result is NULL from the right side, if there is no match.
1
scala：

    sqlcontext.sql("SELECT * FROM Persons LEFT JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
    sqlcontext.sql("SELECT * FROM Persons LEFT OUTER JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
1
2
上面两句执行的结果都是一样的：

+----+--------+---------+--------------+--------+----+-------+----+
|Id_P|LastName|FirstName|       Address|    City|Id_O|OrderNo|Id_P|
+----+--------+---------+--------------+--------+----+-------+----+
|   1|   Adams|     John| Oxford Street|  London|   4|  24562|   1|
|   1|   Adams|     John| Oxford Street|  London|   3|  22456|   1|
|   2|    Bush|   George|  Fifth Avenue|New York|null|   null|null|
|   3|  Carter|   Thomas|Changan Street| Beijing|   2|  44678|   3|
|   3|  Carter|   Thomas|Changan Street| Beijing|   1|  77895|   3|
+----+--------+---------+--------------+--------+----+-------+----+
1
2
3
4
5
6
7
8
9
3.右外连接

作用：RIGHT JOIN 关键字会从右表 (Orders) 那里返回所有的行，即使在左表 (Persons) 中没有匹配的行。

The RIGHT JOIN keyword returns all records from the right table (table2), and the matched records from the left table (table1). The result is NULL from the left side, when there is no match.
1
scala：

    sqlcontext.sql("SELECT * FROM Persons RIGHT JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
    sqlcontext.sql("SELECT * FROM Persons RIGHT OUTER JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
1
2
以上两句执行结果相同：

+----+--------+---------+--------------+-------+----+-------+----+
|Id_P|LastName|FirstName|       Address|   City|Id_O|OrderNo|Id_P|
+----+--------+---------+--------------+-------+----+-------+----+
|   3|  Carter|   Thomas|Changan Street|Beijing|   1|  77895|   3|
|   3|  Carter|   Thomas|Changan Street|Beijing|   2|  44678|   3|
|   1|   Adams|     John| Oxford Street| London|   3|  22456|   1|
|   1|   Adams|     John| Oxford Street| London|   4|  24562|   1|
|null|    null|     null|          null|   null|   5|  34764|  65|
+----+--------+---------+--------------+-------+----+-------+----+
1
2
3
4
5
6
7
8
9
4.外连接

作用：FULL JOIN 关键字会从左表 (Persons) 和右表 (Orders) 那里返回所有的行。如果 “Persons” 中的行在表 “Orders” 中没有匹配，或者如果 “Orders” 中的行在表 “Persons” 中没有匹配，这些行同样会列出。

The FULL OUTER JOIN keyword return all records when there is a match in either left (table1) or right (table2) table records.
1
scala：

    sqlcontext.sql("SELECT * FROM Persons FULL JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
    sqlcontext.sql("SELECT * FROM Persons FULL OUTER JOIN Orders ON Persons.Id_P=Orders.Id_P").show()
1
2
以上两行代码执行结果相同：

+----+--------+---------+--------------+--------+----+-------+----+
|Id_P|LastName|FirstName|       Address|    City|Id_O|OrderNo|Id_P|
+----+--------+---------+--------------+--------+----+-------+----+
|   3|  Carter|   Thomas|Changan Street| Beijing|   1|  77895|   3|
|   3|  Carter|   Thomas|Changan Street| Beijing|   2|  44678|   3|
|   1|   Adams|     John| Oxford Street|  London|   3|  22456|   1|
|   1|   Adams|     John| Oxford Street|  London|   4|  24562|   1|
|null|    null|     null|          null|    null|   5|  34764|  65|
|   2|    Bush|   George|  Fifth Avenue|New York|null|   null|null|
+----+--------+---------+--------------+--------+----+-------+----+
1
2
3
4
5
6
7
8
9
10

版权声明：本文为博主原创文章，未经博主允许不得转载。