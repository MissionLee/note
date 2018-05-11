# 存储过程

## 存储过程生成测试数据

```sql
-- 创建测试的test表
DROP TABLE IF EXISTS test;
CREATE TABLE test(
    ID INT(10) NOT NULL,
    `Name` VARCHAR(20) DEFAULT '' NOT NULL,
    PRIMARY KEY( ID )
)ENGINE=INNODB DEFAULT CHARSET utf8;
--创建生成测试数据的存储过程
DROP PROCEDURE IF EXISTS pre_test;
--例行drop
DELIMITER //
-- 将结束标志换成 // 防止遇到分号自动执行
CREATE PROCEDURE pre_test()    --创建存储过程
BEGIN                          -- 开始
DECLARE i INT DEFAULT 0;       --变量 i
SET autocommit = 0;            -- 取消autoaommit
WHILE i<10000000 DO            -- 循环开始
INSERT INTO test ( ID,`Name` ) VALUES( i, CONCAT( 'Carl', i ) ); -- CONCAT 链接
SET i = i+1;                   -- 变量递增
IF i%2000 = 0 THEN             -- 每2000条commit 一次
COMMIT;
END IF;
END WHILE;                     -- 循环结束
END; //                        --存储过程结束
DELIMITER ;                    -- 结束标志换回来

#执行存储过程生成测试数据 
CALL pre_test();
```