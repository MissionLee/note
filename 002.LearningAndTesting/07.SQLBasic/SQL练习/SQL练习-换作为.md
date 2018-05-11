```sql

```

Mary is a teacher in a middle school and she has a table seat storing students' names and their corresponding seat ids.

The column id is continuous increment.
Mary wants to change seats for the adjacent [əˈdʒeɪsnt]  students.
Can you write a SQL query to output the result for Mary?
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Abbot   |
|    2    | Doris   |
|    3    | Emerson |
|    4    | Green   |
|    5    | Jeames  |
+---------+---------+
For the sample input, the output is:
+---------+---------+
|    id   | student |
+---------+---------+
|    1    | Doris   |
|    2    | Abbot   |
|    3    | Green   |
|    4    | Emerson |
|    5    | Jeames  |
+---------+---------+
Note:
If the number of students is odd, there is no need to change the last one's seat.

## my

```sql
-- 奇数id 就 +1 偶数 id 就 -1 如果 当前是奇数，并且是最后一条，就不

select if(id = (select count(*) from seat)&& id%2=1,id,if(id%2,id+1,id-1)) as id ,student from seat order by id;

-- solution from leetcode
SELECT (CASE 
        WHEN (id % 2) != 0 AND counts != id THEN id + 1
        WHEN (id % 2) != 0 AND counts = id THEN id
        ELSE id - 1 END
       ) as id, student
FROM seat, (SELECT COUNT(*) AS counts FROM seat) AS seat_counts
ORDER BY id ASC;
```