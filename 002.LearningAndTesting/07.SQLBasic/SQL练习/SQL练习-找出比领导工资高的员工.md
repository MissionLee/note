
```sql
Create table If Not Exists Employee (Id int, Name varchar(255), Salary int, ManagerId int);
Truncate table Employee;
insert into Employee (Id, Name, Salary, ManagerId) values ('1', 'Joe', '70000', '3');
insert into Employee (Id, Name, Salary, ManagerId) values ('2', 'Henry', '80000', '4');
insert into Employee (Id, Name, Salary, ManagerId) values ('3', 'Sam', '60000', 'None');
insert into Employee (Id, Name, Salary, ManagerId) values ('4', 'Max', '90000', 'None');
```

## 我的解答

思路： join + where 一下就可以了

```SQL

SELECT
    E1.Name as Employee
FROM Employee E1
JOIN Employee E2
on E1.ManagerId = E2.Id
where E1.Salary > E2.Salary;

```