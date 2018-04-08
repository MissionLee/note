Create table If Not Exists Person (Id int, Email varchar(255))
Truncate table Person
insert into Person (Id, Email) values ('1', 'a@b.com')
insert into Person (Id, Email) values ('2', 'c@d.com')
insert into Person (Id, Email) values ('3', 'a@b.com')

## 我的解答 很low

思路： join一下 如果 id 不同 email 相同 就找出来

```SQL
select 
    distinct p1.Email 
FROM Person p1
JOIN Person p2
ON p1.Email = p2.Email
where p1.Id <> p2.Id;
```

## 另外的思路 

count + group
```SQL
select
    Email
FROM (
    SELECT 
        COUNT(*) as num,
        Email
    from Person
    group by Email
) t
where num>1;
```

## 更牛逼的方法 !!! 这个超级快 ！！！

```sql
SELECT Email
FROM Person
GROUP BY Email 
HAVING COUNT(Email)>1;
```