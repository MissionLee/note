#

- 1. 关于Create table

```scala
val schema = StructType.fromDDL("create table order (\n  \"name\" String,\n  \"produce\" String,\n  \"number\" String\n)")
```
```note
Exception in thread "main" java.lang.ExceptionInInitializerError
	at com.missionlee.spark.structuredstreamingtest.withkafkajson.TestConsumer.main(TestConsumer.scala)
Caused by: org.apache.spark.sql.catalyst.parser.ParseException: 
mismatched input 'order' expecting <EOF>(line 1, pos 13)

== SQL ==
create table order (
-------------^^^
  "name" String,
  "produce" String,
  "number" String
)

	at org.apache.spark.sql.catalyst.parser.ParseException.withCommand(ParseDriver.scala:239)
	at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parse(ParseDriver.scala:115)
	at org.apache.spark.sql.catalyst.parser.AbstractSqlParser.parseTableSchema(ParseDriver.scala:64)
	at org.apache.spark.sql.types.StructType$.fromDDL(StructType.scala:425)
	at com.missionlee.spark.structuredstreamingtest.withkafkajson.TestConsumer$.<init>(TestConsumer.scala:24)
	at com.missionlee.spark.structuredstreamingtest.withkafkajson.TestConsumer$.<clinit>(TestConsumer.scala)
	... 1 more
```