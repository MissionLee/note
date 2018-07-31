# xml写法，mapper参数，动态sql

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="simple.demo">
	<!-- ******************************   样例demo功能管理【Kingleading】  begin  ******************************* -->
	<select id="query" parameterType="map" resultType="map">
		SELECT * FROM TB_DEMO
	</select>

	<update id="add" parameterType="map">
		INSERT INTO TB_DEMO(DEMO_NAME, CREATE_TIME, DEMO_DESC) VALUES(#{demoName}, CURRENT_TIMESTAMP(), #{demoDesc})
	</update>

	<update id="update" parameterType="map">
		UPDATE TB_DEMO SET
			DEMO_NAME = #{demoName},
			DEMO_DESC = #{demoDesc}
		WHERE ID = #{id}
	</update>

	<update id="delete" parameterType="map">
		DELETE FROM TB_DEMO WHERE ID = #{id}
	</update>
</mapper>
```

- mapper
  - namespace
    - 习惯上设置为包名+sql映射文件名，以确保namespcae唯一
- 常用标签
  - select
    - id ： 标识
    - parameterType="int" 
      - 入参的完全限定名或者别名，如果没有设置，MyBatis可以通过TypeHandler来推断
    - resultType
      - 返回的期望类型的完全限定名或别名。
      - 注意：如果是集合情形，那么应该是集合可以包含的类型，而不是集合本身。
      - 注意：不可与下面的resultMap 同时出现
    - resultMap
      - 外部resultMap的命名引用。
    - flushCache
      - 语句调用，触发本地缓存与二级缓存清空
      - 默认false
    - useCache
      - true：本条结果，二级缓存
    - timeout
    - fetchSize
      - 每次批量返回结果行数
    - statementType
      - STATEMENT 
      - PREPARED - 默认
      - CALLABLE
    - resultSetType
      - 结果集类型
      - FORWARD_ONLY
      - SCROLL_SENSITIVE
      - SCROLL_INSENSITIVE
      - 默认： unset
    - databaseId
      - 如果配置了databaseIdProvider，MyBatis会加载所有的不带databaseId或匹配当前databaseId的语句；
      - 如果带或者不带的语句都有，则不带的被忽略
    - resultOrdered
      - 仅针对嵌套结果select语句适用：
        - 如果为true，就是假设包含了嵌套结果集或者分组了，这样的话，当返回一个主结果行的时候，就不会发生对前面结果集引用的情况。这就使在获取嵌套的结果集时，不至于导致内存不够用。
        - 默认为false
    - resultSet
      - 仅对多结果集的情况适用，它将列出语句执行后返回的结果集，并给每个结果集要给名称，名称是逗号分隔的。
  - insert，update，delete
    - 都用来映射DML语句
    - 大多数元素属性和select一样，特有的如下
    - insert ， update
      - useGenerateKeys
        - 让MyBatis使用JDBC的getGeneratedKeys方法获取数据库内部生成的主键，默认为false
      - keyProperty
        - 唯一标记一个属性，Mybatis会通过getGeneratedKeys的返回值或者通过insert语句的selectKey子元素设置它的键值，默认为uset
        - 如果希望得到多个生成的列，也可以是逗号分隔的属性名称列表
      - keyColumn
        - 通过生成的键值设置表中的列名，仅对默写数据库是必须的（PostgreSQL），当逐渐不是表中的第一例的时候需要设置。多列以逗号分隔。
  - selectKey => insert 标签中用来对可能不支持自动生成逐渐的JDBC的主键生成方法
    - 例子
    ```xml
    <insert id ="insertUser">
      <selectKey keyProperty="id" resultType="int" order="BERORE">
        select SEQUENCE_TAB_USER.nextval as id from dual
      </selectKey>
      insert into TB_USER
        (ID,USERNAME,PASSWORD,EMAIL,ADDRESS)
      values
        (#{id},#{username},#{password},#{email},#{address})
    </insert>
    ```
  - sql
    - SQL语句片段，可以 用 include标签放入其他语句中
  - cache
  - cache-ref
  - resultMap
    - 用来满足简单的 某个 类 或者 Map，无法满足需求的情况，比如要给很复杂的关联查询之类的
- 动态sql
  - if 
    - <if test="">
  - choose(when,otherwise)
  - where
  - set
  - foreach
  - bind