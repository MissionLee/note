1、环境：

Hadoop-2.6.0 + apache-hive-1.2.0-bin

2、使用Hive分析nginx日志，网站的访问日志部分内容为：

cat /home/hadoop/hivetestdata/nginx.txt
192.168.1.128 - - [09/Jan/2015:12:38:08 +0800] "GET /avatar/helloworld.png HTTP/1.1" 200 1521 "http://write.blog.linuxidc.net/postlist" "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/34.0.1847.131 Safari/537.36"
183.60.212.153 - - [19/Feb/2015:10:23:29 +0800] "GET /o2o/media.html?menu=3 HTTP/1.1" 200 16691 "-" "Mozilla/5.0 (compatible; baiduuSpider; +http://www.baiduu.com/search/spider.html)"

这条日志里面有九列，每列之间是用空格分割的，
每列的含义分别是客户端访问IP、用户标识、用户、访问时间、请求页面、请求状态、返回文件的大小、跳转来源、浏览器UA。


我们使用Hive中的正则表达式匹配这九列：
([^ ]*) ([^ ]*) ([^ ]*) (.∗) (\".*?\") (-|[0-9]*) (-|[0-9]*) (\".*?\") (\".*?\")
于此同时我们可以在Hive中指定解析文件的序列化和反序列化解析器(SerDe)，并且在Hive中内置了一个org.apache.hadoop.hive.serde2.RegexSerDe正则解析器，我们可以直接使用它。

3、建表语句
CREATE TABLE logs
(
host STRING,
identity STRING,
username STRING,
time STRING,
request STRING,
status STRING,
size STRING,
referer STRING,
agent STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.RegexSerDe'
WITH SERDEPROPERTIES (
"input.regex" = "([^ ]*) ([^ ]*) ([^ ]*) (\\[.*\\]) (\".*?\") (-|[0-9]*) (-|[0-9]*) (\".*?\") (\".*?\")",
"output.format.string" = "%1$s %2$s %3$s %4$s %5$s %6$s %7$s %8$s %9$s"
)
// java中 %1$s  %1表示 被格式化的参数所以 第一位占位符 第n占位符  $s 表示 string
STORED AS TEXTFILE;

4、加载数据：  
load data local inpath '/home/hadoop/hivetestdata/nginx.txt' into table logs;
  
查询每小时的访问量超过100的IP地址：  
select substring(time, 2, 14) datetime ,host, count(*) as count 
from logs 
group by substring(time, 2, 14), host 
having count > 100

sort by datetime, count;

Hive编程指南 PDF 中文高清版  http://www.linuxidc.com/Linux/2015-01/111837.htm

基于Hadoop集群的Hive安装 http://www.linuxidc.com/Linux/2013-07/87952.htm

Hive内表和外表的区别 http://www.linuxidc.com/Linux/2013-07/87313.htm

Hadoop + Hive + Map +reduce 集群安装部署 http://www.linuxidc.com/Linux/2013-07/86959.htm

Hive本地独立模式安装 http://www.linuxidc.com/Linux/2013-06/86104.htm

Hive学习之WordCount单词统计 http://www.linuxidc.com/Linux/2013-04/82874.htm

Hive运行架构及配置部署 http://www.linuxidc.com/Linux/2014-08/105508.htm