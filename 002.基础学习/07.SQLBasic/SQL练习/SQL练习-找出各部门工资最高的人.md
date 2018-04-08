```sql
Create table If Not Exists Employee (Id int, Name varchar(255), Salary int, DepartmentId int)
Create table If Not Exists Department (Id int, Name varchar(255))
Truncate table Employee
insert into Employee (Id, Name, Salary, DepartmentId) values ('1', 'Joe', '70000', '1')
insert into Employee (Id, Name, Salary, DepartmentId) values ('2', 'Henry', '80000', '2')
insert into Employee (Id, Name, Salary, DepartmentId) values ('3', 'Sam', '60000', '2')
insert into Employee (Id, Name, Salary, DepartmentId) values ('4', 'Max', '90000', '1')
Truncate table Department
insert into Department (Id, Name) values ('1', 'IT')
insert into Department (Id, Name) values ('2', 'Sales')
```

## 我->的思路 就很不合适  所以弄起来很麻烦，还没弄出来

思路： group + max() 然后join一下 拿到名字

```SQL
---------------------这个没成功，看过答案根据自己的印象写了第二个
-- SELECT
--     D.Name,
--     E.Name,
--     E.Salary
-- FROM(
--     SELECT 
--     Salary,
--     Name,
--     DepartmentId
-- FROM Employee 
-- WHERE 
--     Salary = (

--        SELECT
--          max(salary)
--        GROUP BY DepartmentId
--     ) 
--     AND 

-- GROUP BY DepartmentId
-- ) E
-- JOIN Department D
-- ON E.DepartmentId = D.Id;
------------------------------- 第二版
-- 思路 根据 部门 区分 人员
-- 方法1 ： 找到的那个人 的 工资与部门选择出来的最高工资一样 那么就是这个人
-- 方法2 ： 找到的那个人，相同部门 中 找不到比 他的工资更高，那么就是这个人

-- ----------------- 方法1 
SELECT
    D.Name as Department,
    E.Name as Employee,
    E.Salary as Salary
FROM Department D
JOIN Employee E
ON D.Id = E.DepartmentId
WHERE(
    (E.Salary,E.DepartmentId) in(
        SELECT 
        MAX(Salary) AS Salary,
        DepartmentId
        FROM Employee
        GROUP BY DepartmentId
    )  
);





```

### 前辈们提供的三种不同的方法

```sql
-----------------  1   ----------------
SELECT 
    D.Name AS Department ,
    E.Name AS Employee ,
    E.Salary 
FROM
	Employee E,
	(
    SELECT 
        DepartmentId,max(Salary) as max 
    FROM Employee 
    GROUP BY DepartmentId
    -- 各个 部分的 最高工资
    ) T,
	Department D
WHERE E.DepartmentId = T.DepartmentId 
  AND E.Salary = T.max
  AND E.DepartmentId = D.id
  -- 直接从 三个表 找出 符合条件的内容
  -- 重点： 连续满足条件
  -- 重点： 这种连续语法挺有意思的  连接语法 会 生成  三个表字段数量相乘数量的 的总字段数量，然后在结果里面按照条件查找

---------------  2   -----------------------
SELECT D.Name,A.Name,A.Salary 
FROM 
	Employee A,
	Department D   
WHERE A.DepartmentId = D.Id 
  AND NOT EXISTS 
  (SELECT 1 FROM Employee B WHERE B.Salary > A.Salary AND A.DepartmentId = B.DepartmentId) 
  -- 如果 找不到其他人比这个更高了，那么他就是最高了
  -- 重点： NOT EXISTS 的用法

------------------   3  ----------------------------
SELECT D.Name AS Department ,E.Name AS Employee ,E.Salary 
from 
	Employee E,
	Department D 
WHERE E.DepartmentId = D.id 
  AND (DepartmentId,Salary) in 
  (SELECT DepartmentId,max(Salary) as max FROM Employee GROUP BY DepartmentId)
  -- 获取 部门-最高工资 的数据集， 查找到的用户的数据 如果 在这个数据集里面，就找出了最高了
  -- 重点：  in   关键字的用法
```