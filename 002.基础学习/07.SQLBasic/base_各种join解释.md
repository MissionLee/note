SQL中的连接可以分为内连接，外连接，以及交叉连接 。

- 1. 交叉连接CROSS JOIN

如果不带WHERE条件子句，它将会返回被连接的两个表的笛卡尔积，返回结果的行数等于两个表行数的乘积；

举例,下列A、B、C 执行结果相同，但是效率不一样：

A:SELECT * FROM table1 CROSS JOIN table2

B:SELECT * FROM table1,table2


C:select * from table1 a inner join table2 b

A:select a.*,b.* from table1 a,table2 b where a.id=b.id

B:select * from table1 a cross join table2 b where a.id=b.id (注：cross join后加条件只能用where,不能用on)

C:select * from table1 a inner join table2 b on a.id=b.id

`一般不建议使用方法A和B，因为如果有WHERE子句的话，往往会先生成两个表行数乘积的行的数据表然后才根据WHERE条件从中选择。 `

因此，如果两个需要求交际的表太大，将会非常非常慢，不建议使用。

- 2. 内连接INNER JOIN

两边表同时符合条件的组合

如果仅仅使用

SELECT * FROM table1 INNER JOIN table2

内连接如果没有指定连接条件的话，和笛卡尔积的交叉连接结果一样，但是不同于笛卡尔积的地方是，没有笛卡尔积那么复杂要先生成行数乘积的数据表，内连接的效率要高于笛卡尔积的交叉连接。

但是通常情况下，使用INNER JOIN需要指定连接条件。

 

***************关于等值连接和自然连接

等值连接(=号应用于连接条件, 不会去除重复的列)

自然连接(会去除重复的列)

数据库的连接运算都是自然连接，因为不允许有重复的行（元组）存在。

例如：

SELECT * FROM table1 AS a INNER JOIN table2 AS b on a.column=b.column

- 3. 外连接OUTER JOIN

指定条件的内连接，仅仅返回符合连接条件的条目。

外连接则不同，返回的结果不仅包含符合连接条件的行，而且包括左表(左外连接时), 右表(右连接时)或者两边连接(全外连接时)的所有数据行。

1)左外连接LEFT [OUTER] JOIN

显示符合条件的数据行，同时显示左边数据表不符合条件的数据行，右边没有对应的条目显示NULL

例如

SELECT * FROM table1 AS a LEFT [OUTER] JOIN ON a.column=b.column

2)右外连接RIGHT [OUTER] JOIN

显示符合条件的数据行，同时显示右边数据表不符合条件的数据行，左边没有对应的条目显示NULL

例如

SELECT * FROM table1 AS a RIGHT [OUTER] JOIN ON a.column=b.column

3)全外连接full [outer] join

显示符合条件的数据行，同时显示左右不符合条件的数据行，相应的左右两边显示NULL，即显示左连接、右连接和内连接的并集