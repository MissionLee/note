# 纵表 变成 横标

```sql
create table testtabletrans
(
year int,
Quarter varchar(30),
amount float
);
insert into testtabletrans values(2000,'1',1.1);
insert into testtabletrans values(2000,'2',1.2);
insert into testtabletrans values(2000,'3',1.3);
insert into testtabletrans values(2000,'4',1.4);
insert into testtabletrans values(2001,'1',2.1);
insert into testtabletrans values(2001,'2',2.2);
insert into testtabletrans values(2001,'3',2.3);
insert into testtabletrans values(2001,'4',2.4);
```


如果处理表A中的数据，得到如下的结果。
Year Quarter1 Quarter2 Quarter3 Quarter4
2000   1.1      1.2     1.3     1.4
2001   2.1      2.2     2.3     2.4
请用SQL写一段代码实现。

## 方法

```sql
-- 这里是百度到的一种 不需要笛卡尔积 计算的一种方法，但是实际的运算量可能也不少
-- sum 这个方法 适用于 数字
-- 如果是字符串的情况，可能还是需要用 join
-- convert(value,type)这个是因为 double 计算问题  1.3+0 = 1.2999999..... 
-- 这个也是为什么 能用 decimal  就用 decimal 的原因
SELECT
    year,
    convert(sum(case Quarter when '1' then amount else 0 end),decimal(10,1)) as Quarter1,
    convert(sum(case Quarter when '2' then amount else 0 end),decimal(10,1)) as Quarter2,
    convert(sum(case Quarter when '3' then amount else 0 end),decimal(10,1)) as Quarter3,
    convert(sum(case Quarter when '4' then amount else 0 end),decimal(10,1)) as Quarter4
    from testtabletrans
    group by year;

-- 连续join的方法
SELECT
    t1.year,
    t1.amount as q1,
    t2.amount as q2,
    t3.amount as q3,
    t4.amount as q1
    from
    testtabletrans t1,
    testtabletrans t2,
    testtabletrans t3,
    testtabletrans t4
where 
-- t1.year = t2.year and t2.year= t3.year and t3.year=t4.year and 
t1.Quarter = '1' and t2.Quarter = '2' and t3.Quarter = '3' and t4.Quarter = '4'
group by year;
```