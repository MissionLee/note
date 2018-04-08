-- 创建一个函数，传入 编号与数值 返回 得分
CREATE TABLE `goal_formula_2` (
  `id` varchar(32) NOT NULL COMMENT '主键',
  `dictionary_code` varchar(50) DEFAULT NULL COMMENT '健康指标编码',
  `index_lower` varchar(32) DEFAULT NULL COMMENT '指标取值下限',
  `index_upper` varchar(32) DEFAULT NULL COMMENT '指标取值上限',
  `formula` varchar(200) DEFAULT NULL COMMENT '得分公式',
  `fml_a` double DEFAULT NULL,
  `fml_b` double DEFAULT NULL,
  `fml_c` double DEFAULT NULL,
  `fml_d` double DEFAULT NULL,
  `fml_e` double DEFAULT NULL,
  `weight` varchar(32) DEFAULT NULL COMMENT '权重',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='存放计算用户健康得分情况的公式';

select * from goal_formula_2 limit 10;
--+-----+-----------------+-------------+-------------+---------------------+-------+-------+-------+-------+-------+--------+
--| id  | dictionary_code | index_lower | index_upper | formula             | fml_a | fml_b | fml_c | fml_d | fml_e | weight |
--+-----+-----------------+-------------+-------------+---------------------+-------+-------+-------+-------+-------+--------+
--| 1   | BZZB_RC_STEP    | 8000        | 20000       | 100                 |   100 |     0 |     1 |     1 |     1 | 0.05   |
--| 10  | BZZB_YL_BMI     | 22.1        | 23.9        | 100-(x0-22.0)/0.095 |   100 |    -1 |     1 |   -22 | 0.095 | 0.06   |
--| 100 | BZZB_RC_SMSJ    | 7           | 8           | 100                 |   100 |     0 |     1 |     1 |     1 | 0.07   |
--| 101 | BZZB_RC_SMSJ    | 5           | 6           | 100-(7-x0)/0.1      |   100 |    -1 |    -1 |     7 |   0.1 | 0.07   |
--| 102 | BZZB_RC_SMSJ    | 1           | 4           | 79-(4-x0)/(0.4/7)   |    79 |    -1 |    -1 |     4 |  0.47 | 0.07   |
--| 103 | BZZB_RC_SMSJ    | 9           | 9           | 95                  |    95 |     0 |     1 |     1 |     1 | 0.07   |
--| 104 | BZZB_RC_SMSJ    | 10          | 18          | 79-(x0-10)/(0.9/7)  |    79 |    -1 |     1 |   -10 |  0.97 | 0.07   |
--| 105 | BZZB_RC_SMSJ    | 19          | 24          | 5                   |     5 |     0 |     1 |     1 |     1 | 0.07   |
--| 106 | BZZB_RC_WXSJ    | 15          | 20          | 100                 |   100 |     0 |     1 |     1 |     1 | 0.02   |
--| 107 | BZZB_RC_WXSJ    | 10          | 14          | 100-(15-x0)/0.25    |   100 |    -1 |    -1 |    15 |  0.25 | 0.02   |
--+-----+-----------------+-------------+-------------+---------------------+-------+-------+-------+-------+-------+--------+

DROP FUNCTION IF EXISTS GET_GOAL;
DELIMITER &&
CREATE FUNCTION GET_GOAL(code varchar(32),val double) 
RETURNS double
BEGIN
    DECLARE mark double default 0;
    select (fml_a+fml_b*(fml_c*val+fml_d)/fml_e)*weight 
    from goal_formula_2 
    where dictionary_code=code 
        and val > index_lower 
        and val <= index_upper
    INTO mark;
    RETURN mark;
END &&
DELIMITER ;
