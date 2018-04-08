```sql
SELECT * FROM test01 
 INTO OUTFILE '/var/lib/mysql-files/test_all'
 FIELDS TERMINATED BY ','
 OPTIONALLY ENCLOSED BY '"'
 LINES TERMINATED BY '\n';
