```sql
drop table Employee;
drop table Department;
Create table If Not Exists Employee (Id int, Name varchar(255), Salary int, DepartmentId int);
Create table If Not Exists Department (Id int, Name varchar(255));
Truncate table Employee;
insert into Employee (Id, Name, Salary, DepartmentId) values ('1', 'Joe', '70000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('2', 'Henry', '80000', '2');
insert into Employee (Id, Name, Salary, DepartmentId) values ('3', 'Sam', '60000', '2');
insert into Employee (Id, Name, Salary, DepartmentId) values ('4', 'Max', '90000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('5', 'Joe1', '270000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('6', 'Joe2', '370000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('7', 'Joe3', '470000', '1');
insert into Employee (Id, Name, Salary, DepartmentId) values ('8', 'Joe4', '570000', '1');
Truncate table Department;
insert into Department (Id, Name) values ('1', 'IT');
insert into Department (Id, Name) values ('2', 'Sales');
```

+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
+----+-------+--------+--------------+

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+

## my solution
  
Train of thought [ bad way ]：

1.sort by salary   and   group by departmentid
2.get top three in each department

3.key point: each department!!!
```sql
SELECT

```

## rcd

```sql
-- ------------------ solution 1 -------------
-- 1. convert all the data to the format we need
-- 2. limitation : the number of  distinct salary that larger than the chosen one  is less than 3
Select 
    dep.Name as Department, 
    emp.Name as Employee, 
    emp.Salary 
from Department dep, Employee emp 
where 
    emp.DepartmentId=dep.Id 
    and(
        Select count(distinct Salary) 
        From Employee 
        where DepartmentId=dep.Id 
        and Salary>emp.Salary
        )<3;
-- -------------- solution 2 -----------
-- same of solution 1  but join on is more efficient
select d.Name Department, e1.Name Employee, e1.Salary
from Employee e1 
join Department d
on e1.DepartmentId = d.Id
where 3 > (select count(distinct(e2.Salary)) 
                  from Employee e2 
                  where e2.Salary > e1.Salary 
                  and e1.DepartmentId = e2.DepartmentId
                  );
-- ------------- solution 3 ---------------
select D.Name as Department, E.Name as Employee, E.Salary as Salary 
  from Employee E, Department D
   where (select count(distinct(Salary)) from Employee 
           where DepartmentId = E.DepartmentId and Salary > E.Salary) in (0, 1, 2)
         and 
           E.DepartmentId = D.Id 
         order by E.DepartmentId, E.Salary DESC;
-- ----------------- solution 4 -------------
SELECT
    d.Name Department, e.Name Employee, e.Salary Salary
FROM
    (
        SELECT DepartmentId, Name, Salary 
        FROM Employee 
        WHERE 3 > (
            SELECT COUNT(e1.Salary)
            FROM (
                SELECT DISTINCT Salary, DepartmentId 
                FROM Employee 
            ) e1
            WHERE
                Employee.DepartmentId = e1.DepartmentId 
            AND
                Employee.Salary < e1.Salary
        )
        ORDER BY DepartmentId ASC, Salary DESC
    ) e 
    -- left join department =>  handle with the situation that there's not department corresponding to the id
LEFT JOIN
    Department d
ON 
    e.DepartmentId = d.Id
WHERE
    d.Name IS NOT NULL
----------------------------- solution 5 ---------------
-- in the file SQL练习-MySQL实现RANK函数 ： there is a way to give rank to the columns
SELECT d.Name AS Department, se.Name AS Employee, se.Salary 
FROM Department d,
 ( SELECT e.Name, e.DepartmentId, e.Salary,
          @Rank := (CASE 
					WHEN @PrevDept != e.DepartmentId THEN 1
                    WHEN @PrevSalary = e.Salary THEN @Rank
					ELSE @Rank + 1 END) AS Rank, 
		  @PrevDept := e.DepartmentId,
          @PrevSalary := e.Salary
	FROM Employee e, (SELECT @Rank := 0, @PrevDept := 0, @PrevSalary := 0) r
	ORDER BY DepartmentId ASC, Salary DESC
  ) se
WHERE d.Id = se.DepartmentId AND se.Rank <= 3
-- ---------------- solution 6 !! beats 99% --------------------------
select d.Name as Department, e.Name as Employee, computed.Salary as Salary
from Employee e, 
	(
		select Salary, DepartmentId, @row := IF(DepartmentId=@did, @row + 1,1) as Rank , @did:=DepartmentId
		from (
			select distinct Salary, DepartmentId
			from Employee
			order by DepartmentId, Salary desc
			) ordered, (select @row:=0, @did:=0) variables
	) computed,
	Department d
where e.Salary=computed.Salary 
and e.DepartmentId=computed.DepartmentId 
and computed.DepartmentId=d.Id
and computed.Rank<=3
order by computed.DepartmentId, Salary desc
---------------------  solution 7 --------------------------------------
select d.Name, r.Name, r.Salary 
from (
  select DepartmentId, Name, Salary,(
    select count(*)+1 from (
      select distinct salary, DepartmentId from Employee 
      ) as uniq
     where DepartmentId = e.DepartmentId and Salary > e.Salary   
    ) as rank
  from Employee e
  ) as r, Department d
where r.DepartmentId = d.Id and r.rank <= 3
-------------------- solution 8 beat 90% --------------------
SELECT D.Name as Department, E1.Name as Employee, E1.Salary
FROM Employee E1
INNER JOIN Employee E2 ON E1.DepartmentId = E2.DepartmentId
INNER JOIN Department D ON E1.DepartmentId = D.Id
WHERE E1.Salary <= E2.Salary
GROUP BY E1.Id
HAVING count(DISTINCT E2.Salary) < 4;
```