MySQL数据库中delimiter的作用概述
以下的文章主要是向大家描述的是MySQL数据库中delimiter的作用是什么?我们一般都认为这个命令和存储过程关系不大，到底是不是这样的呢？以下的文章将会给你相关的知识，望你会有所收获。

其实就是告诉MySQL解释器，该段命令是否已经结束了，MySQL数据库是否可以执行了。默认情况下，delimiter是分号;。在命令行客户端中，如果有一行命令以分号结束，那么回车后，MySQL将会执行该命令。如输入下面的语句

MySQL> select * from test_table; 
然后回车，那么MySQL将立即执行该语句。

但有时候，不希望MySQL这么做。在为可能输入较多的语句，且语句中包含有分号。如试图在命令行客户端中输入如下语句

MySQL> CREATE FUNCTION `SHORTEN`(S VARCHAR(255), N INT)  
MySQL> RETURNS varchar(255)  
MySQL> BEGIN  
MySQL> IF ISNULL(S) THEN  
MySQL> RETURN '';  
MySQL> ELSEIF N<15 THEN  
MySQL> RETURN LEFT(S, N);  
MySQL> ELSE  
MySQL> IF CHAR_LENGTH(S) <=N THEN  
MySQL> RETURN S;  
MySQL> ELSE  
MySQL> RETURN CONCAT(LEFT(S, N-10), '...', RIGHT(S, 5));  
MySQL> END IF;  
MySQL> END IF;  
MySQL> END; 
默认情况下，不可能等到用户把这些语句全部输入完之后，再执行整段语句。因为MySQL一遇到分号，它就要自动执行。即，在语句RETURN '';时，MySQL数据库解释器就要执行了。这种情况下，就需要事先把delimiter换成其它符号，如//或$$。

MySQL> delimiter //  
MySQL> CREATE FUNCTION `SHORTEN`(S VARCHAR(255), N INT)  
MySQL> RETURNS varchar(255)  
MySQL> BEGIN  
MySQL> IF ISNULL(S) THEN  
MySQL> RETURN '';  
MySQL> ELSEIF N<15 THEN  
MySQL> RETURN LEFT(S, N);  
MySQL> ELSE  
MySQL> IF CHAR_LENGTH(S) <=N THEN  
MySQL> RETURN S;  
MySQL> ELSE  
MySQL> RETURN CONCAT(LEFT(S, N-10), '...', RIGHT(S, 5));  
MySQL> END IF;  
MySQL> END IF;  
MySQL> END;//  
这样只有当//出现之后，MySQL解释器才会执行这段语句

例子：

MySQL> delimiter //   
MySQL> CREATE PROCEDURE simpleproc (OUT param1 INT)   
-> BEGIN   
-> SELECT COUNT(*) INTO param1 FROM t;   
-> END;   
-> //   
Query OK, 0 rows affected (0.00 sec)   
MySQL> delimiter ;   
MySQL> CALL simpleproc(@a);   
Query OK, 0 rows affected (0.00 sec)   
MySQL> SELECT @a;   
+------+   
| @a |   
+------+   
| 3 |   
+------+   
1 row in set (0.00 sec)   
本文代码在 MySQL 5.0.41-community-nt 下运行通过。

编写了个统计网站访问情况（user agent）的 MySQL 数据库存储过程。就是下面的这段 SQL 代码。

drop procedure if exists pr_stat_agent;  
-- call pr_stat_agent ('2008-07-17', '2008-07-18')  
create procedure pr_stat_agent  
(  
pi_date_from date  
,pi_date_to date  
)  
begin  
-- check input  
if (pi_date_from is null) then  
set pi_date_from = current_date();  
end if;  
if (pi_date_to is null) then  
set pi_date_to = pi_date_from;  
end if;  
set pi_date_to = date_add(pi_date_from, interval 1 day);  
-- stat  
select agent, count(*) as cnt  
from apache_log  
where request_time >= pi_date_from  
and request_time < pi_date_to 
group by agent  
order by cnt desc;  
end;  
我在 EMS SQL Manager 2005 for MySQL 这个 MySQL 图形客户端下可以顺利运行。但是在 SQLyog MySQL GUI v5.02 这个客户端就会出错。最后找到原因是没有设置好 delimiter 的问题。

默认情况下，delimiter “;” 用于向 MySQL 提交查询语句。在存储过程中每个 SQL 语句的结尾都有个 “;”，如果这时候，每逢 “;” 就向 MySQL 提交的话，当然会出问题了。于是更改 MySQL 的 delimiter，上面 MySQL 存储过程就编程这样子了：

delimiter //; -- 改变 MySQL delimiter 为：“//”

drop procedure if exists pr_stat_agent //  
-- call pr_stat_agent ('2008-07-17', '2008-07-18')  
create procedure pr_stat_agent  
(  
pi_date_from date  
,pi_date_to date  
)  
begin  
-- check input  
if (pi_date_from is null) then  
set pi_date_from = current_date();  
end if;  
if (pi_date_to is null) then  
set pi_date_to = pi_date_from;  
end if;  
set pi_date_to = date_add(pi_date_from, interval 1 day);  
-- stat  
select agent, count(*) as cnt  
from apache_log  
where request_time >= pi_date_from  
and request_time < pi_date_to 
group by agent  
order by cnt desc;  
end; //  
delimiter ;  
改回默认的 MySQL delimiter：“;”

当然，MySQL delimiter 符号是可以自由设定的，你可以用 “/” 或者“$$” 等。但是 MySQL数据库 存储过程中比较常见的用法是 “//” 和 “$$”。上面的这段在 SQLyog 中的代码搬到 MySQL 命令客户端（MySQL Command Line Client）却不能执行。

MySQL> delimiter //; -- 改变 MySQL delimiter 为：“//”

MySQL> 
MySQL> drop procedure if exists pr_stat_agent //  
-> 
-> -- call pr_stat_agent ('2008-07-17', '2008-07-18')  
-> 
-> create procedure pr_stat_agent  
-> (  
-> pi_date_from date  
-> ,pi_date_to date  
-> )  
-> begin  
-> -- check input  
-> if (pi_date_from is null) then  
-> set pi_date_from = current_date();  
-> end if;  
-> 
-> if (pi_date_to is null) then  
-> set pi_date_to = pi_date_from;  
-> end if;  
-> 
-> set pi_date_to = date_add(pi_date_from, interval 1 day);  
-> 
-> -- stat  
-> select agent, count(*) as cnt  
-> from apache_log  
-> where request_time >= pi_date_from  
-> and request_time < pi_date_to 
-> group by agent  
-> order by cnt desc;  
-> end; //  
-> 
-> delimiter ; 
改回默认的 MySQL delimiter：“;”

-> //  
-> //  
-> //  
-> ;  
-> ;  
-> 
真是奇怪了！最后终于发现问题了，在 MySQL 命令行下运行 “delimiter //; ” 则 MySQL 的 delimiter 实际上是 “//;”，而不是我们所预想的 “//”。其实只要运行指令 “delimiter //” 就 OK 了。

MySQL> delimiter // -- 末尾不要符号 “;”

MySQL> 
MySQL> drop procedure if exists pr_stat_agent //  
Query OK, 0 rows affected (0.00 sec)  
MySQL> 
MySQL> -- call pr_stat_agent ('2008-07-17', '2008-07-18')  
MySQL> 
MySQL> create procedure pr_stat_agent  
-> (  
-> pi_date_from date  
-> ,pi_date_to date  
-> )  
-> begin  
-> -- check input  
-> if (pi_date_from is null) then  
-> set pi_date_from = current_date();  
-> end if;  
-> 
-> if (pi_date_to is null) then  
-> set pi_date_to = pi_date_from;  
-> end if;  
-> 
-> set pi_date_to = date_add(pi_date_from, interval 1 day);  
-> 
-> -- stat  
-> select agent, count(*) as cnt  
-> from apache_log  
-> where request_time >= pi_date_from  
-> and request_time < pi_date_to 
-> group by agent  
-> order by cnt desc;  
-> end; //  
Query OK, 0 rows affected (0.00 sec)  
MySQL> 
MySQL> delimiter ;   
末尾不要符号 “//”

MySQL> 
顺带一提的是，我们可以在 MySQL 数据库中执行在文件中的 SQL 代码。例如，我把上面存储过程的代码放在文件 d:\pr_stat_agent.sql 中。可以运行下面的代码建立存储过程。

MySQL> source d:\pr_stat_agent.sql  
Query OK, 0 rows affected (0.00 sec)  
Query OK, 0 rows affected (0.00 sec)  
source 指令的缩写形式是：“\.”

MySQL> \. d:\pr_stat_agent.sql  
Query OK, 0 rows affected (0.00 sec)  
Query OK, 0 rows affected (0.00 sec)  
最后，可见 MySQL数据库的客户端工具在有些地方是各自为政，各有各的一套。