# HIVE 学习

## hive中的数据库

- hive为每个数据库创建一个目录,数据库所在的目录位于`hive.metastore.warehouse.dir`属性所制定的顶层目录
- 数据库目录为 db_name.db
- 可以自己修改位置 `create databases db01 location '/mydir';`
- 可以看看当前及群众hive的库的位置
    ```bash
    hive> describe database default;
    OK
    default
    Default Hive database hdfs://BigData-02:8020/user/hive/warehouse    public ROLE
    Time taken: 0.022 seconds, Fetched: 1 row(s)
    ```
    可以看到库是在hdfs上,创建这个表的`hive.metastore.warehouse.dir`属性为`/user/hive/warehouse`或者在`LOCATION`填写`/user/hive/warehouse`,效果一样的

# hive数据类型

- 基础数据类型
  - tingyint
  - smalint
  - int
  - bigint
  - boolean
  - float
  - double
  - string
  - timestanp [兼容java.sql.Timestamp]
  - binary
- 集合数据类型
  - struct
    - 语法: STRUCT{first STRING, last STRING}
    - 示例: struct('john','doe')

## 建表语句

```sql
CREATE TABLE tb_name  (
  col_name data_type COMMENT
)
```

## 集合类型

- 创建

```sql
create table test01(
    struct_ts struct<first:string,last:string>,
    map_ts map<string,int>,
    array_ts array<string>
);
```


## HiveQL数据操作

- `Hive没有行级别的数据插入,数据更新,删除`
- 装载数据
  - 把某一份数据文件,放在某个表的某个分区`如果分区当前不存在那么创建这个分区`,如果非分区表就不用指定分区了
  - `inpath`的路径通常不直接指向某个文件,而是指向某个文件夹,hive会读取目录中的所有文件,`这样,脚本也可以不用总是修改了`而且,文件会`拷贝`到目标表下,文件名不会改变
    ```sql
    LOAD DATA LOCAL INPATH '/PATH' OVERWRITE INTO TABLE tb_name PARITITON( a='' , b ='' )
    ```
  - 使用`LOCAL`关键字表示文件在本地,`不用`则表示`文件在HDFS等指定的文件系统`,如果在HDFS上,这条语句会执行`移动`而不是拷贝动作
  - 如果指定了`overwrite`,那么目标表内的文件会先被删除,不用这个关键词,则只会把新增文件放入
  - 注意:`inpath`路径下不可以包含任何文件夹
- 通过查询语句插入数据
  - 从其他地方`select`数据
  ```sql
  insert overwrite table tb_name1
  partition(a='',b='')
  select * from tb_name2 tb
  where tb.a='' and tb.b='';
  ```

  对于类似的情况,还有一种优化的写法

  ```sql
  from tb_resource tbre
  insert overwrite table tb_aim1
    partition()
    select * where tbre.a='' and tbre.b=''
  insert overwrite table tb_aim1
    partition()
    select * where tbre.a='' and tbre.b=''
  ```
  `同一个语句,用这种语法,调整不同条件,把数据写入不同分区`
- 动态分区插入`对上面这个语句的优化`
    ```sql
    insert overwrite table tb_aim
    partition(a,b)
    select ....,tbre.a,tbre.b
    from tb_resource tbre;
    ```
    这样的写法就是动态分区,同事partition的条件也可以动静结合,但是`动态分区默认是关闭的,开启时候默认是严格模式`要求分区字段至少一列是静态的
  - 除此之外还有一些属性用于限制资源`防止动态分区写错,导致严重错误`
  ```bash
  hive.exec.dynamic.partition[0/1]-动态分区功能开启
  hive.exec.dynamic.partition.mode[strict/nonstrict]严格情况下至少有一列分区条件为静态
  hive.exec.max.dynamic.partitions.pernode[int]每个mapper或reducer可以创建的最大动态分区数量
  hive.exec.max.dynamic.partitions[int]一个动态分区语句可以创建最大分区数量
  hive.exec.max.created.files[int]全局可以创建的最大文件个数
  ```
- 单个查询语句中创价表并加载数据`[用于从一个大宽表中提取需要的数据集]`
    ```sql
    create table tb_name
    as select a,b,c
    from tb_resource
    where ;
    ```
    `此功能不能用于外部表`
- 导出数据
  - 如果文件恰好是需要的格式,可以用hadoop fs -cp 命令直接拷贝,不用hive参与
  - 需要调整的情况
  ```sql
  insert overwrite local directory 'path'
  select a,c,c
  from tb_name
  where ;
  ```
  文件会被写入指定的路径中,这里的local和overwrite两个关键字和导入数据时候的作用相同
  `还有一些注意事项,没做深究`

## HiveQL:查询

- select .. from语句
  - 使用正则
  - 使用列值进行计算
  - 算术运算
  - 内置函数
    - 数学函数:round(),floor()等有很多
    - 聚合函数:count(),sum()等有很多
    - 表生成函数:`这里的函数并不懂,需要专门花时间看一看`
    - 其他内置函数:进制转换,编码解码什么的`也不懂`
  - LIMIT
  - 列别名 ... as new_col_name
  - select 潜逃
  - case .. when .. then .. end[hive中的if else 语句]
  - 关于减少mapreduce操作
    - hive.exec.mode.local.auto = true,在此条件下hive会尽量尝试本地操作
- where 语句
  - 比较条件 
    - A = / <=> / == / <> / != / > />= /< /<= B
    - A [NOT] BETWEEN B AND C
    - A IS NULL
    - A IS NOT NULL
    - A [NOT] LIKE B `其中B为SQL支持的简单正则`
    - A RLIKE B,A REGEXP B `其中B为JDK中的正则`
  - 浮点数比较,通病
  - LIKE 和 RLIKE
  - GROUP BY 按照结果分组
  - HAVING 
- JOIN 
  - INNER JOIN 内链接 `只有进行连接的两个表都存在于链接标准相匹配的数据,才会被保留下来`
    - 示例:
    ```sql
    select ... from tb_name1 join tb_name2 on tb_name1.a = tb_name2.a where ;
    ```
    `tb_name1 和 tb_name2 可以是一个表,如果一个表 就取个别名`
    - 示例:
    ```sql
    select ... from tb_name a join tb_name b on a.c = b.c where a.d='limingshun' and b.d='missinglee';
    ```
    - Hive不支持的情况:
      - MapReduce 很难实现的链接
      - on 子句中的谓词之间使用 or