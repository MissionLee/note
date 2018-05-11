找出连续 出现3 次 和 以上的数字


```sql
Create table If Not Exists Logs (Id int, Num int);
Truncate table Logs;
insert into Logs (Id, Num) values ('1', '1');
insert into Logs (Id, Num) values ('2', '1');
insert into Logs (Id, Num) values ('3', '1');
insert into Logs (Id, Num) values ('4', '2');
insert into Logs (Id, Num) values ('5', '1');
insert into Logs (Id, Num) values ('6', '2');
insert into Logs (Id, Num) values ('7', '2');
```

## 我的处理

思路： 设置两个变量  @var1 记录 数值 @var 2 记录 出现次数
        在下一条记录 是 判断更新两个参数
        记录 达到3 的时候 就输出

```sql
SET @val = null,@nums = 0;
select
    distinct Num as ConsecutiveNums
FROM(
    SELECT
        Num,
        case 
            -- 如果 当前值和之前值相同，那么 @nums+1
            when @val = Num then @nums := @nums +1 
            -- 如果不同 @nums 设置为1 重新开始
            else  @nums := 1
        end as mynums,
        @val := Num as prevNum
    FROM
        Logs   
) T
where mynums =3;
-- 最初的设计： where mynums  >2 那么连续出现四个 1 判定是 2个符合条件
-- 如果条件 写的是  =3  那么 连续出现四个 1 的时候，判定 是 一个符合条件
-- 另外有问题： 最初没有加上 distinct
```

## 大神解答  连续join 但是要保证 id 连续

```sql
select distinct l1.num
from Logs l1 
    join Logs l2 on l1.id=l2.id-1 
    join Logs l3 on l1.id=l3.id-2
where l1.num=l2.num and l2.num=l3.num
```