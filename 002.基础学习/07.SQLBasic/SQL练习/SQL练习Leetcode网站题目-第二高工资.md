# leetcode

## Second Highest Salary | 找出第二高的数值

我的错误答案1： 

SELECT Salary AS SecondHighestSalary FROM Employee ORDER BY Salary desc limit 1 offset 1;

问题： 最高的工资 如果同时有两个，拿到的其实还是 最高工资

### 提示答案：

SELECT max(Salary) AS SecondHighestSalary
FROM Employee
WHERE Salary < (SELECT max(Salary) FROM Employee)

分析： 找出最高工资，选择比最高工资小的最高工资=》 第二高工资
分析： 如果没有第二高的工资， max（）函数会返回 NULL

### 提示答案：

SELECT distinct(Salary) FROM Employee
Union select null
ORDER BY Salary DESC LIMIT 1,1

分析： 用distinct函数排除重复的情况，如果 distinct之后所有工资都一样（都是最高工资），limit 1，1 返回错误， 所以 Union select null

### 提示答案：

select 
    IFNULL( 
        (select distinct e1.salary from Employee e1
        where 
            (select count(distinct e2.salary ) 
            from Employee e2 where e2.salary > e1.salary) 
        = 1) 
    , null)

分析： ifnull函数 如果前一个表达是 不是null 返回前一个表达式 ， 否则返回后一个表达式

### 提示答案：

SELECT DISTINCT
    Salary AS SecondHighestSalary
FROM
    Employee
ORDER BY Salary DESC
LIMIT 1 OFFSET 1

分析： 这个答案没有考虑到 null的情况

### 提示答案

SELECT
    (SELECT DISTINCT
            Salary
        FROM
            Employee
        ORDER BY Salary DESC
        LIMIT 1 OFFSET 1) AS SecondHighestSalary
;

分析： 没考虑 null

### 提示答案

SELECT
    IFNULL(
      (SELECT DISTINCT Salary
       FROM Employee
       ORDER BY Salary DESC
        LIMIT 1 OFFSET 1),
    NULL) AS SecondHighestSalary