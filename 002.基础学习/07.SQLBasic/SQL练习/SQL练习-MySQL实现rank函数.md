
```sql
Create table If Not Exists Scores (Id int, Score DECIMAL(3,2));
Truncate table Scores;
insert into Scores (Id, Score) values ('1', '3.5');
insert into Scores (Id, Score) values ('2', '3.65');
insert into Scores (Id, Score) values ('3', '4.0');
insert into Scores (Id, Score) values ('4', '3.85');
insert into Scores (Id, Score) values ('5', '4.0');
insert into Scores (Id, Score) values ('6', '3.65');
```

## MySQL 中没有 rank()函数

oracle和 sql server里面有，所以这里要自己实现排序功能
hive里面是有这些函数的

### 个人尝试一下 -> 这是一个很垃圾的方法，浪费了很多计算资源

结合 之前那个 给工资排序的方法，得到 不重复的 结果

```sql
--  1. 得到 每个分数的排名
--  2. 按照排名/分数 排序
---------------------------------------实现 RANK() OVER(...)
SELECT
 Score,
 (select count(distinct Score) from Scores where Score >= s.Score )AS  Rank
FROM Scores s
ORDER BY Score desc;
-- 我出的错误：  条件 Score >= s.Score 最开始没写 = ，导致排名出现 0 的情况

-- 如果 要跳过 重复排名 去掉 distinct
-- 去掉distinct之后， 第一名 如果重复，不会被 记录成第一 
-- 所以 不能有 = 号
-- 如果没有等号，第一名会被记作 0 号
-- 所以要 + 1
---------------------------------------实现 RANK()变种 并列名次 不 排斥之后排名=> 应该是叫DENSE_RANK()
SELECT
 Score,
(select count(Score) from Scores where Score > s.Score )+1 AS Rank
FROM Scores s
ORDER BY Score desc;
```


### 大神的处理方法： 

思路-> 存一个变量，表示排名，通过判断当前行的值 ，和上一行的值是否相同来判断 这个值是否更新

```sql
-- mysql 中 可以使用 @var_name 的形式创建变量
--                  :=  用来赋值
--                   <> 和 != 是一个意思
---------------- 方法 1 ------------------
SELECT
    -- 本行的@rank 等于 当前 Rank + 0（如果 本行分数和前一行 一样）/1 （如果不一样）
  Score,
  @rank := @rank + (@prev <> (@prev := Score)) Rank
FROM
    -- 先用分数 排序 ，  @rank初始化为 0 ， @prev 初始化为 -1
  Scores,
  (SELECT @rank := 0, @prev := -1) init
ORDER BY Score desc
-- 改造一下方法 1 让 重复的排名会占用后续几个位置
-- 思路，需要加上一个参数 来表示 当前排名 重复了几次
---------------- 方法 2 -------------------
set  @rank = 0 ,@pre =-1;
select Score,
case
	when @pre = Score then @rank
	when (@pre := Score) is not NULL then @rank := @rank+1
end Rank
from Scores
order by Score desc
```