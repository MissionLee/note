# ABOUT DATE

## MY TEST 

### 两个 日期 直接 相减 -》  被转化成了连续字符串 -》 又被转化成了 数字 -》 然后计算
### 使用 TO_DAYS() 之后 会  把日期转换成 从 0000-00-00 到这个日期有多少天 然后计算

MariaDB [learning]> select d1.mydate,d2.mydate,d1.mydate-d2.mydate,TO_DAYS(d1.mydate)-TO_DAYS(d2.mydate) from date_test d1,date_test d2 where d1.id=5 and d2.id=3;
+------------+------------+---------------------+---------------------------------------+
| mydate     | mydate     | d1.mydate-d2.mydate | TO_DAYS(d1.mydate)-TO_DAYS(d2.mydate) |
+------------+------------+---------------------+---------------------------------------+
| 2017-02-09 | 2017-01-08 |                 101 |                                    32 |
+------------+------------+---------------------+---------------------------------------+




Given a Weather table, write a SQL query to find all dates' Ids with higher temperature compared to its previous (yesterday's) dates.

+---------+------------+------------------+
| Id(INT) | Date(DATE) | Temperature(INT) |
+---------+------------+------------------+
|       1 | 2015-01-01 |               10 |
|       2 | 2015-01-02 |               25 |
|       3 | 2015-01-03 |               20 |
|       4 | 2015-01-04 |               30 |
+---------+------------+------------------+
For example, return the following Ids for the above Weather table:
+----+
| Id |
+----+
|  2 |
|  4 |
+----+
Seen this question in a real interview before?

## my

```sql
-- weather
select w1.id from weather w1,weather w2
where w1.date - w2.date = 1 and w1.temperature > w2.temperature;

-- solution 1 online  with TO_DAY()
SELECT wt1.Id 
FROM Weather wt1, Weather wt2
WHERE wt1.Temperature > wt2.Temperature AND 
      TO_DAYS(wt1.DATE)-TO_DAYS(wt2.DATE)=1;
-- EXPLANATION:
-- 
-- TO_DAYS(wt1.DATE) return the number of days between from year 0 to date DATE
-- TO_DAYS(wt1.DATE)-TO_DAYS(wt2.DATE)=1 check if wt2.DATE is yesterday respect to wt1.DATE
-- We select from the joined tables the rows that have
-- wt1.Temperature > wt2.Temperature
-- and difference between dates in days of 1 (yesterday):
-- TO_DAYS(wt1.DATE)-TO_DAYS(wt2.DATE)=1;



-- solution 2 online   with  subdate()/DATE_SUB()
SELECT w1.Id FROM Weather w1, Weather w2
WHERE subdate(w1.Date, 1)=w2.Date AND w1.Temperature>w2.Temperature

    -- similar solution with DATE_ADD()
    SELECT w2.Id  FROM Weather w1,Weather w2 
    WHERE w2.Date = DATE_ADD(w1.Date, INTERVAL 1 DAY) 
    AND w2.Temperature > w1.Temperature;

-- solution with   exists
select Id
from Weather w
where exists (select 1 from Weather iw where TO_DAYS(w.DATE)-TO_DAYS(iw.DATE)=1 and iw.Temperature < w.Temperature)

-- solution with  datediff  
select w1.Id Id from Weather w1, Weather w2 where datediff(w1.Date,w2.Date)=1 and w1.Temperature>w2.Temperature
```

