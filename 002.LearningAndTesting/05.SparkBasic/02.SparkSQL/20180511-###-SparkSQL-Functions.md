# Spark 2.3

```scala

/**
 * Functions available for DataFrame operations.
 *
 * @groupname udf_funcs UDF functions
 * @groupname agg_funcs Aggregate functions
 * @groupname datetime_funcs Date time functions
 * @groupname sort_funcs Sorting functions
 * @groupname normal_funcs Non-aggregate functions
 * @groupname math_funcs Math functions
 * @groupname misc_funcs Misc functions
 * @groupname window_funcs Window functions
 * @groupname string_funcs String functions
 * @groupname collection_funcs Collection functions
 * @groupname Ungrouped Support functions for DataFrames
 * @since 1.3.0
 */
```

- normal_funcs基本功能
  - def col(colName: String): Column = Column(colName)
  - def column(colName: String): Column = Column(colName)
  - def lit(literal: Any): Column = typedLit(literal)
  - def typedLit[T : TypeTag](literal: T): Column

- Sort functions
  - def asc(columnName: String): Column = Column(columnName).asc
  - def asc_nulls_first(columnName: String): Column = Column(columnName).asc_nulls_first
  - def asc_nulls_last(columnName: String): Column = Column(columnName).asc_nulls_last
  - def desc(columnName: String): Column = Column(columnName).desc
  - def desc_nulls_first(columnName: String): Column = Column(columnName).desc_nulls_first
  - def desc_nulls_last(columnName: String): Column = Column(columnName).desc_nulls_last

- Aggregate functions
  - 废弃的旧API不再列出
  - def approx_count_distinct(e: Column): Column
  - def approx_count_distinct(columnName: String): Column = approx_count_distinct(column(columnName))
  - def approx_count_distinct(e: Column, rsd: Double): Column
  - def approx_count_distinct(columnName: String, rsd: Double): Column
  - def avg(e: Column): Column = withAggregateFunction { Average(e.expr) }
  - def avg(columnName: String): Column = avg(Column(columnName))
  - def collect_list(e: Column): Column = withAggregateFunction { CollectList(e.expr) }
  - def collect_list(columnName: String): Column = collect_list(Column(columnName))
  - def collect_set(e: Column): Column = withAggregateFunction { CollectSet(e.expr) }
  - def collect_set(columnName: String): Column = collect_set(Column(columnName))
  - def corr(column1: Column, column2: Column): Column = withAggregateFunction {Corr(column1.expr, column2.expr)}
  - def corr(columnName1: String, columnName2: String): Column = {  corr(Column(columnName1), Column(columnName2))}
  - def count(e: Column): Column
  - def count(columnName: String): TypedColumn[Any, Long]
  - def countDistinct(expr: Column, exprs: Column*): Column
  - def countDistinct(columnName: String, columnNames: String*): Column
  - def covar_pop(column1: Column, column2: Column): Column
  - def covar_pop(columnName1: String, columnName2: String): Column
  - def covar_samp(column1: Column, column2: Column): Column
  - def covar_samp(columnName1: String, columnName2: String): Column
  - def first(e: Column, ignoreNulls: Boolean): Column
  - def first(columnName: String, ignoreNulls: Boolean): Column
  - def first(e: Column): Column = first(e, ignoreNulls = false)
  - def first(columnName: String): Column = first(Column(columnName))
  -   def grouping(e: Column): Column = Column(Grouping(e.expr))
  - def grouping(columnName: String): Column = grouping(Column(columnName))
  - def grouping_id(cols: Column*): Column = Column(GroupingID(cols.map(_.expr)))
  - def grouping_id(colName: String, colNames: String*): Column
  - def kurtosis(e: Column): Column = withAggregateFunction { Kurtosis(e.expr) }
  - def kurtosis(columnName: String): Column = kurtosis(Column(columnName))
  - def last(e: Column, ignoreNulls: Boolean): Column
  - def last(columnName: String, ignoreNulls: Boolean): Column 
  - def last(e: Column): Column = last(e, ignoreNulls = false)
  - def last(columnName: String): Column = last(Column(columnName), ignoreNulls = false)
  - def max(e: Column): Column = withAggregateFunction { Max(e.expr) }
  - def max(columnName: String): Column = max(Column(columnName))
  - def mean(e: Column): Column = avg(e)
  - def mean(columnName: String): Column = avg(columnName)
  - def min(e: Column): Column = withAggregateFunction { Min(e.expr) }
  - def min(columnName: String): Column = min(Column(columnName))
  - def skewness(e: Column): Column = withAggregateFunction { Skewness(e.expr) }
  - def skewness(columnName: String): Column = skewness(Column(columnName))
  - def stddev(e: Column): Column = withAggregateFunction { StddevSamp(e.expr) }
  - def stddev(columnName: String): Column = stddev(Column(columnName))
  - def stddev_samp(e: Column): Column = withAggregateFunction { StddevSamp(e.expr) }
  - def stddev_samp(columnName: String): Column = stddev_samp(Column(columnName))
  - def stddev_pop(e: Column): Column = withAggregateFunction { StddevPop(e.expr) }
  - def stddev_pop(columnName: String): Column = stddev_pop(Column(columnName))
  - def sum(e: Column): Column = withAggregateFunction { Sum(e.expr) } 
  - def sum(columnName: String): Column = sum(Column(columnName))
  - def sumDistinct(e: Column): Column = withAggregateFunction(Sum(e.expr), isDistinct = true)
  - def sumDistinct(columnName: String): Column = sumDistinct(Column(columnName))
  - def variance(e: Column): Column = withAggregateFunction { VarianceSamp(e.expr) }
  - def variance(columnName: String): Column = variance(Column(columnName))
  - def var_samp(e: Column): Column = withAggregateFunction { VarianceSamp(e.expr) }
  - def var_samp(columnName: String): Column = var_samp(Column(columnName))
  - def var_pop(e: Column): Column = withAggregateFunction { VariancePop(e.expr) }
  - def var_pop(columnName: String): Column = var_pop(Column(columnName))
- window functions 暂不加入
- Non-aggreagate functions
  - def abs(e: Column): Column = withExpr { Abs(e.expr) }
  - def array(cols: Column*): Column = withExpr { CreateArray(cols.map(_.expr)) }
  - def array(colName: String, colNames: String*): Column
  - def map(cols: Column*): Column = withExpr { CreateMap(cols.map(_.expr)) }
  - def broadcast[T](df: Dataset[T]): Dataset[T]
  - def coalesce(e: Column*): Column = withExpr { Coalesce(e.map(_.expr)) }
  - def input_file_name(): Column = withExpr { InputFileName() }
  - def isnan(e: Column): Column = withExpr { IsNaN(e.expr) }
  - def isnull(e: Column): Column = withExpr { IsNull(e.expr) }
  - def monotonicallyIncreasingId(): Column = monotonically_increasing_id()
  - def monotonically_increasing_id(): Column = withExpr { MonotonicallyIncreasingID() }
  - def nanvl(col1: Column, col2: Column): Column = withExpr { NaNvl(col1.expr, col2.expr) }
  - def negate(e: Column): Column = -e
  - def not(e: Column): Column = !e
  - def rand(seed: Long): Column = withExpr { Rand(seed) }
  - def rand(): Column = rand(Utils.random.nextLong)
  - def randn(seed: Long): Column = withExpr { Randn(seed) }
  - def randn(): Column = randn(Utils.random.nextLong)
  - def spark_partition_id(): Column = withExpr { SparkPartitionID() }
  - def sqrt(e: Column): Column = withExpr { Sqrt(e.expr) }
  - def sqrt(colName: String): Column = sqrt(Column(colName))
  - def struct(cols: Column*): Column = withExpr { CreateStruct(cols.map(_.expr)) }
  - def struct(colName: String, colNames: String*): Column
  - def when(condition: Column, value: Any): Column
  - def bitwiseNOT(e: Column): Column = withExpr { BitwiseNot(e.expr) } 
  - def expr(expr: String): Column
- Math Function
- Misc functions
  - def md5(e: Column): Column = withExpr { Md5(e.expr) }
  - def sha1(e: Column): Column = withExpr { Sha1(e.expr) }
  - def sha2(e: Column, numBits: Int): Column
  - def crc32(e: Column): Column = withExpr { Crc32(e.expr) }
  - def hash(cols: Column*): Column
- String functions
  - def ascii(e: Column): Column = withExpr { Ascii(e.expr) }
  - def base64(e: Column): Column = withExpr { Base64(e.expr) }
  - def concat(exprs: Column*): Column = withExpr { Concat(exprs.map(_.expr)) }
  - def concat_ws(sep: String, exprs: Column*): Column
  - def decode(value: Column, charset: String): Column
  - def encode(value: Column, charset: String): Column
  - def format_number(x: Column, d: Int): Column
  - def format_string(format: String, arguments: Column*): Column
  - def initcap(e: Column): Column = withExpr { InitCap(e.expr) }
  - def instr(str: Column, substring: String): Column
  - def length(e: Column): Column = withExpr { Length(e.expr) }
  - def lower(e: Column): Column = withExpr { Lower(e.expr) }
  - def levenshtein(l: Column, r: Column): Column = withExpr { Levenshtein(l.expr, r.expr) }
  - def locate(substr: String, str: Column): Column
  - def locate(substr: String, str: Column, pos: Int): Column
  - def lpad(str: Column, len: Int, pad: String): Column
  - def ltrim(e: Column): Column = withExpr {StringTrimLeft(e.expr) }
  - def ltrim(e: Column, trimString: String): Column
  - def regexp_extract(e: Column, exp: String, groupIdx: Int): Column
  - def regexp_replace(e: Column, pattern: String, replacement: String): Column
  - def regexp_replace(e: Column, pattern: Column, replacement: Column): Column
  - def unbase64(e: Column): Column = withExpr { UnBase64(e.expr) }
  - def rpad(str: Column, len: Int, pad: String): Column
  - def repeat(str: Column, n: Int): Column
  - def reverse(str: Column): Column = withExpr { StringReverse(str.expr) }
  - def rtrim(e: Column): Column = withExpr { StringTrimRight(e.expr) }
  - def rtrim(e: Column, trimString: String): Column
  - def soundex(e: Column): Column = withExpr { SoundEx(e.expr) }
  - def split(str: Column, pattern: String): Column
  - def substring(str: Column, pos: Int, len: Int): Column
  - def substring_index(str: Column, delim: String, count: Int): Column
  - def translate(src: Column, matchingString: String, replaceString: String): Column
  - def trim(e: Column): Column = withExpr { StringTrim(e.expr) }
  - def trim(e: Column, trimString: String): Column
  - def upper(e: Column): Column = withExpr { Upper(e.expr) }
- DateTime functions
  - def add_months(startDate: Column, numMonths: Int): Column
  - def current_date(): Column = withExpr { CurrentDate() }
  - def current_timestamp(): Column = withExpr { CurrentTimestamp() }
  - def date_format(dateExpr: Column, format: String): Column
  - def date_add(start: Column, days: Int): Column = withExpr { DateAdd(start.expr, Literal(days)) }
  - def date_sub(start: Column, days: Int): Column = withExpr { DateSub(start.expr, Literal(days)) }
  - def datediff(end: Column, start: Column): Column = withExpr { DateDiff(end.expr, start.expr) }
  - def year(e: Column): Column = withExpr { Year(e.expr) }
  - def quarter(e: Column): Column = withExpr { Quarter(e.expr) }
  - def month(e: Column): Column = withExpr { Month(e.expr) }
  - def dayofweek(e: Column): Column = withExpr { DayOfWeek(e.expr) }
  - def dayofmonth(e: Column): Column = withExpr { DayOfMonth(e.expr) }
  - def dayofyear(e: Column): Column = withExpr { DayOfYear(e.expr) }
  - def hour(e: Column): Column = withExpr { Hour(e.expr) }
  - def last_day(e: Column): Column = withExpr { LastDay(e.expr) }
  - def minute(e: Column): Column = withExpr { Minute(e.expr) }
  - def months_between(date1: Column, date2: Column): Column
  - def next_day(date: Column, dayOfWeek: String): Column
  - def second(e: Column): Column = withExpr { Second(e.expr) }
  - def weekofyear(e: Column): Column = withExpr { WeekOfYear(e.expr) }
  - def from_unixtime(ut: Column): Column
  - def from_unixtime(ut: Column, f: String): Column
  - def unix_timestamp(): Column
  - def unix_timestamp(s: Column): Column
  - def unix_timestamp(s: Column, p: String): Column = withExpr { UnixTimestamp(s.expr, Literal(p)) }
  - def to_timestamp(s: Column): Column
  - def to_timestamp(s: Column, fmt: String): Column
  - def to_date(e: Column): Column = withExpr { new ParseToDate(e.expr) }
  - def to_date(e: Column, fmt: String): Column
  - def trunc(date: Column, format: String): Column
  - def date_trunc(format: String, timestamp: Column): Column
  - def from_utc_timestamp(ts: Column, tz: String): Column
  - def to_utc_timestamp(ts: Column, tz: String): Column
  - window
    - 源码
    ```scala
      def window(
          timeColumn: Column,
          windowDuration: String,
          slideDuration: String,
          startTime: String): Column = {
        withExpr {
          TimeWindow(timeColumn.expr, windowDuration, slideDuration, startTime)
        }.as("window")
      }
    ```
- Collection functions
  - def array_contains(column: Column, value: Any): Column
  - def explode(e: Column): Column = withExpr { Explode(e.expr) }
  - def explode_outer(e: Column): Column = withExpr { GeneratorOuter(Explode(e.expr)) }
  - def posexplode(e: Column): Column = withExpr { PosExplode(e.expr) }
  - def posexplode_outer(e: Column): Column = withExpr { GeneratorOuter(PosExplode(e.expr)) }
  - def get_json_object(e: Column, path: String): Column
  - def json_tuple(json: Column, fields: String*): Column
  - def from_json(e: Column, schema: StructType, options: Map[String, String]): Column
  - from_json 有众多重载
  - def to_json(e: Column, options: Map[String, String]): Column
  - to_json有众多重载
  - def size(e: Column): Column = withExpr { Size(e.expr) }
  - def sort_array(e: Column): Column = sort_array(e, asc = true)
  - def sort_array(e: Column, asc: Boolean): Column = withExpr { SortArray(e.expr, lit(asc).expr) }
  - def map_keys(e: Column): Column = withExpr { MapKeys(e.expr) }
  - def map_values(e: Column): Column = withExpr { MapValues(e.expr) }
- scala udf functions
- Java UDF functions