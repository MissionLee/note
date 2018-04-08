Write a SQL query to 
    1. delete all duplicate email entries in a table named Person, 
    2. keeping only unique emails based on its smallest Id.

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+

Id is the primary key column for this table.


## My

```sql
-- 1 find the duplicate email
-- 2 delete
    -- in chosen items , if id > (min(id)) than delete

    delete  from Person p1,Person p2
    where p1.Email = p2.Email
    and p1.Id > p2.Id


-- check whether right/wrong
DELETE FROM Person
    WHERE Id IN
    (SELECT P1.Id FROM Person AS P1, Person AS P2 
	     WHERE P1.Id > P2.Id AND P1.Email = P2.Email);
-- a simple solution
create table t1 as select min(id) as id from Person group by Email;
delete from Person where id not in (select id from t1);
drop table t1;
```


where we try this clause :
```sql
delete from Person where id not in(select min(id) as id from Person group by email)
```
you will be noted " You can’t specify target table ‘Person’ for update in FROM clause ",
The solution is using a middle table with select clause:
```sql
delete from Person where id not in( 
    select t.id from (
        select min(id) as id from Person group by email
    ) t
)
```


```sql
delete from Person where Id not in 
(select min_id from 
(select min(Id) as min_id from Person group by Email) 
as Cid) ;
```