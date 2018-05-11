# 

```sql
SELECT
     c.CityName  AS CityName,
     c.parentCode AS parentCode,
     count(a.id)         AS numbers
   FROM cities c
     JOIN areas a
       ON c.id = a.parentCode
   GROUP BY c.id
```

- 这个 在 MySQL 里面是没问题的，但是 在spark中会出问题
- sql("xxx")

先来看一个报错信息：
```scala
Exception in thread "main" org.apache.spark.sql.AnalysisException: expression 'c.`CityName`' is neither present in the group by, nor is it an aggregate function. Add to group by or wrap in first() (or first_value) if you don't care which value you get.;;
Aggregate [id#8], [CityName#10 AS CityName#48, parentCode#11 AS parentCode#49, count(id#0) AS numbers#50L]
+- Join Inner, (id#8 = cast(parentCode#3 as int))
   :- SubqueryAlias c
   :  +- SubqueryAlias cities
   :     +- Relation[id#8,administrativeCode#9,CityName#10,parentCode#11] parquet
   +- SubqueryAlias a
      +- SubqueryAlias areas
         +- Relation[id#0,administrativeCode#1,name#2,parentCode#3] parquet
```

- 翻译以下

SQL分析错误： c.CityName 既没有出现在group by的条件中，也不是一个 聚合函数。把他加到group by中或者在外面加一层 first() 或者 first_value (如果你不介意到底取到了什么)

- MySQL 在处理这种情况的时候会自动选择出现的第一个（即将验证）

- 出现问题的原因是，这一列可能会出现多个结果，spark不会像mysql那样做（不负责人的操作）

- 有另外一个函数也是处理这种情况 collect_set(xxx)


有一篇文章,原文：

[Spark中进行聚合时的特殊场景](http://zhangyi.farbox.com/post/framework/special-case-of-aggregation-in-spark)

在对数据进行统计分析时，如果对指标进行聚合运算，而待查询的字段中还包含了维度，则原则上我们还需要按照维度字段进行分组。倘若这个聚合运算为sum函数，分组之后就相当于分类汇总了。有一种特殊场景是我们对指标执行了sum聚合，查询字段也包含了维度，但我们不希望对维度分组。例如：
```sql
select name, role, sum(income) from employee
```
虽然返回的结果挺奇怪，因为它事实上是针对整张表的income进行了求和运算，与name、role无关。查询结果中返回的其实是第一条记录的name与role。但至少在MySQL中，这样的SQL语法是正确的。

但是在Spark中，执行这样的SQL语句，则会抛出org.apache.spark.sql.AnalysisException异常：
```scala
org.apache.spark.sql.AnalysisException: expression 'employee.`name`' is neither present in the group by, nor is it an aggregate function. Add to group by or wrap in first() (or first_value) if you don't care which value you get.
```
这是因为Spark SQL在执行SQL语句时，事先会调用CheckAnalysis的checkAnalysis方法对LogicalPlan进行检查：

```scala
def checkAnalysis(plan: LogicalPlan): Unit = {
    case e: Attribute if groupingExprs.isEmpty =>
        // Collect all [[AggregateExpressions]]s.
        val aggExprs = aggregateExprs.filter(_.collect {
                case a: AggregateExpression => a
            }.nonEmpty)
        failAnalysis(
           s"grouping expressions sequence is empty, " +
           s"and '${e.sql}' is not an aggregate function. " +
           s"Wrap '${aggExprs.map(_.sql).mkString("(", ", ", ")")}' in windowing " +
           s"function(s) or wrap '${e.sql}' in first() (or first_value) " +
           s"if you don't care which value you get."
         )
      case e: Attribute if !groupingExprs.exists(_.semanticEquals(e)) =>
         failAnalysis(
          s"expression '${e.sql}' is neither present in the group by, " +
          s"nor is it an aggregate function. " +
          "Add to group by or wrap in first() (or first_value) if you don't care " +
          "which value you get.")
}
```

奇怪的是，按照我这里给出的SQL语句，groupingExprs应该是Empty才对，然而根据抛出的错误提示，在对分析语句进行检查时，却是走的后一个模式匹配分支，即e: Attribute if !groupingExprs.exists(_.semanticEquals(e))。莫非，Spark SQL在对其进行执行计划优化时，自动添加了groupingExprs的内容？暂时不知具体原因。

无论如何，根据提示，在不增加group by的情况下，需要对select中的字段包裹一个first()或者first_value()函数，如下所示：

```scala
spark.sql("select first(name),first(role), sum(income) from employee")
```
这里的维度包含name和role。如果添加了group by，但只针对其中的一个维度进行了分组，那么对于缺少分组的维度，也当用first()函数来包裹才对。

