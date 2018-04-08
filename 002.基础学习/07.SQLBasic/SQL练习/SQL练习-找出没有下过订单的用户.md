```sql
Create table If Not Exists Customers (Id int, Name varchar(255))
Create table If Not Exists Orders (Id int, CustomerId int)
Truncate table Customers
insert into Customers (Id, Name) values ('1', 'Joe')
insert into Customers (Id, Name) values ('2', 'Henry')
insert into Customers (Id, Name) values ('3', 'Sam')
insert into Customers (Id, Name) values ('4', 'Max')
Truncate table Orders
insert into Orders (Id, CustomerId) values ('1', '3')
insert into Orders (Id, CustomerId) values ('2', '1')
```

## 我

思路： 对 customers 表 进行left join 找出 orders部分字段 为 null的

```sql
SELECT
    Name as Customers
FROM (
   SELECT
    C.Name,
    O.CustomerId
FROM Customers C
LEFT JOIN Orders O
ON C.Id = O.CustomerId 
)t
WHERE ISNULL(CustomerID);
```

## 牛逼的方法 ！！！

```sql
select name as 'Customers' from Customers where Customers.id not in (
    select customerid from orders
);
```