---------------------  基础新闻分类表

CREATE TABLE bas_news_clf(
news_clf_id STRING COMMENT 'News Classify id',
clf_name STRING COMMENT 'Classify name',
is_use STRING COMMENT 'Use' ,
crt_dtm STRING COMMENT 'Create Time',
up_dtm STRING COMMENT 'Update Time',
cud_tag STRING COMMENT 'create update delete tag ',
load_dtm STRING COMMENT 'load time'
)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;


  case class case_bas_news_clf(
                                news_clf_id: String,
                                clf_name: String,
                                is_use: String,
                                stt_dtm: String,
                                end_dtm: String,
                                up_dtm：String,
                                load_dtm: String
                              )

--- history


insert overwrite table dw_test.bas_news_clf
select * from(
select A.news_clf_id,
      A.clf_name,
      A.is_use,
      A.stt_dtm,
      CASE 
        WHEN A.end_dtm ='9999-12-31' AND B.news_clf_id IS NOT NULL THEN '$DATE_STR'
        ELSE A.end_dtm
      END AS end_dtm,
      A.up_dtm,
      A.load_dtm
      FROM dw_test.bas_news_clf A
      LEFT JOIN bas_news_clf B
      ON A.news_clf_id = B.news_clf_id
union
SELECT 
 C.news_clf_id,
 C.clf_name,
 C.is_use,
 '$DATE_STR' AS stt_dtm,
 '9999-12-31' AS end_dtm,
 C.up_dtm,
 C.load_dtm
 FROM bas_news_clf AS C
)AS T

---------------------------- 用户关注新闻分类表 -------------
CREATE TABLE fact_user_news_clf  -- linshi 
(
user_id              STRING COMMENT 'USser id',
news_clf_id          STRING COMMENT 'News classify id',
cud_tag STRING COMMENT 'create update delete tag ',
up_dtm              STRING COMMENT 'up Time',
load_dtm              STRING COMMENT 'load Time'
)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

CREATE TABLE fact_user_news_clf  -- cangku
(
user_id              STRING COMMENT 'USser id',
news_clf_id          STRING COMMENT 'News classify id',
stt_dtm              STRING COMMENT 'Start Time',
end_dtm              STRING COMMENT 'Eed Time',
up_dtm              STRING COMMENT  'update Time',
load_dtm STRING COMMENT 'Storage Time'
)
row format delimited
fields terminated by ','
lines terminated by '\n'
stored as textfile;

insert overwrite table dw_test.fact_user_news_clf
select * from (
    select 
    A.user_id ,
    A.news_clf_id,
    A.stt_dtm,
    case 
     WHEN A.end_dtm='9999-12-31' AND B.user_id IS NOT NULL 
      THEN 'TODAY'
     ELSE A.end_dtm
    end as end_dtm,
    A.up_dtm,
    A.load_dtm
    from dw_test.fact_user_news_clf as A
    left join tmp_fact_user_news_clf as B
    on A.user_id = B.user_id
union
   select 
    C.user_id,
    C.news_clf_id,
    'today' as stt_dtm,
    '9999-12-31' as end_dtm,
    C.up_dtm,
    C.load_dtm
    from tmp_fact_user_news_clf as C
)as 



-------------------- dw   fact_user_news_tag  最新的那张表，要更新的
insert overwrite table $dw_name.fact_user_news_tag
select * from (
    select A.user_id,
    A.user_hot_news_tag,
    A.user_his_news_tag,
    A.up_dtm,
    A.load_dtm
    from tmp_fact_user_news_clf A
 union (
        select B.user_id,
          B.user_hot_news_tag,
    B.user_his_news_tag,
    B.up_dtm,
    B.load_dtm
    from $dw_name.fact_user_news_tag B
    where B.user_id not in (
        select A.user_id from A
    ) 
 )

)as T