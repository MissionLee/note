Create table If Not Exists Employee (Id int, Salary int);
Truncate table Employee;
insert into Employee (Id, Salary) values ('1', '100');
insert into Employee (Id, Salary) values ('2', '200');
insert into Employee (Id, Salary) values ('3', '300');


```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  RETURN (
      -- # Write your MySQL query statement below.
      
  );
END
```

## 我没想到怎么处理这个情况

思路： 用limit 语句从  n-1位开始取 1位就是 第 n位
错误： limit里面不能使用 N-1，所以要 SET N=N-1

```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
  SET N = N-1;
  RETURN (
      -- 
      SELECT DISTINCT Salary FROM Employee ORDER BY Salary
      DESC LIMIT N,1
  );
END
```


## 参考答案：

```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
DECLARE M INT;
SET M=N-1;
  RETURN (
      # Write your MySQL query statement below.
      SELECT DISTINCT Salary FROM Employee ORDER BY Salary DESC LIMIT M, 1
  );
END
```

## 参考答案：

```sql
CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
    
  RETURN (
      --# Write your MySQL query statement below.
      SELECT e1.Salary
      FROM (
          SELECT DISTINCT Salary FROM Employee
        ) e1
      WHERE (
              SELECT COUNT(*) 
              FROM (
                  SELECT DISTINCT Salary 
                  FROM Employee
                ) e2 
              WHERE e2.Salary > e1.Salary
              -- 排除重复
              -- 最内层 找出比 第一高工资 高的数量
              --       找出比 第二高工资 高的书来嗯
              --        。。。。
      ) = N - 1     
      LIMIT 1
      -- 去重复
      -- 当  表中 可以选到 了一个 工资 ，可以在 这张表里面找到 N-1个比 这个工资数值 大的 时候 ，那么 这就是 要找的工资
  );
END