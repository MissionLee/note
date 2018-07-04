# mapper.xml 写法  - 后面的内容也很重要，看下去

#  xml里  < > 时标签，所以需要用 的时候要用 &lt; 这样来代替

#  参数引用#与$的区别： 

在Mybatis的Mapper.xml文件中为了构建动态的SQL，我们通常需要通过引用传递的参数来达到对应的效果。在引用传递的参数的时候有两种方式，一种是通过“#{var}”的形式引用，一种是通过“${var}”的形式引用。前者会被以预编译的方式传递，即会生成PreparedStatement来处理，对应的参数在SQL中会以“?”占位，然后调用PreparedStatement的相应API设值；而后者则会先处理好变量再执行相应的SQL，即对应的变量会先被替换，再执行替换了变量的SQL。在一个Mapper映射语句中我们可以同时使用“#”和“$”处理变量。

3     采用#{var}的形式处理变量
       采用#{var}的形式来引用变量时，其中的变量会在解析Mapper.xml文件中的语句时就被替换为占位符“?”，同时通过ParameterMapping类记录对应的变量信息。在真正执行对应的语句时会用传递的真实参数根据ParameterMapping信息给PreparedStatement设置参数，具体可参考PreparedStatementHandler的parameterize()方法实现。对应的变量在解析的时候都是以传递进来的参数为基础来解析的，根据前面的介绍我们知道，传递进来的参数只有两种情况，一种是原始类型的单参数，一种是被Mybatis封装过的Map。那对应的参数Mybatis的如何解析的呢？有三种情况。

       第一种，如果真实传递进来的是原始类型，那么对应的属性解析就是就是基于原始类型的属性。比如我们真是传递进来的一个User类型的对象，User对象有id、name等属性，那么我们在Mapper语句中采用#{var}形式访问变量的时候就可以使用#{id}和#{name}。这跟使用${var}形式访问变量是不同的，使用${var}形式时我们需要使用${_parameter.id}和${_parameter.name}。

   <insert id="insert"parameterType="com.elim.learn.mybatis.model.User"useGeneratedKeys="true" keyColumn="id" keyProperty="id">

      insert into t_user(name,username,email,mobile) values(#{name},#{username},#{email},#{mobile})

   </insert>

 

       第二种，如果真实传递进来的是一个Map，那么对应的变量则可以是这个Map里面的Key。比如下面示例中我们的接口方法对应的是两个参数，那最终到执行Mapper语句时会被封装成一个Map，Map里面的Key包含name、1、param1和param2，那么我们在使用的时候就可以使用这些变量。

   List<User> findByNameAndMobile(@Param("name") String name, Stringmobile);

 

   <select id="findByNameAndMobile"resultType="com.elim.learn.mybatis.model.User">

      select id,name,username,email,mobile from t_user where name=#{name} and mobile=#{1}

   </select>

 

       第三种，真实传递进来的参数是可以被已经注册了的TypeHandler进行处理的，则直接使用真实传递进来的参数作为真实的变量值。这也是为什么我们经常可以在Mapper接口里面写delete(Integer id)，然后在Mapper语句中直接写#{id}的原因，因为这个时候传递进来的参数是Integer类型，是可以直接被处理的，Mybatis将直接拿它的值作为当前变量id的值，而不会去取传递进来的值的id属性。换句话说，这个时候我们在Mapper语句中定义的变量可以随便命名，随便怎么命名都可以被Mybatis正确的处理。但是通常我们会把它命名为与接口方法参数名称一致，方便阅读。

   void delete(Long id);

 

   <insert id="delete" parameterType="java.lang.Long">

      delete t_user where id=#{id}

   </insert>

 

       关于预编译的参数处理是由DefaultParameterHandler类的setParameters()方法处理，核心代码如下，欲了解更多，可以参考DefaultParameterHandler的完整代码。

  public void setParameters(PreparedStatement ps) {

    ErrorContext.instance().activity("setting parameters").object(mappedStatement.getParameterMap().getId());

    List<ParameterMapping> parameterMappings =boundSql.getParameterMappings();

    if (parameterMappings != null) {

      for (inti = 0; i < parameterMappings.size(); i++) {

        ParameterMapping parameterMapping = parameterMappings.get(i);

        if (parameterMapping.getMode() != ParameterMode.OUT) {

          Object value;

          String propertyName = parameterMapping.getProperty();

          if (boundSql.hasAdditionalParameter(propertyName)) { // issue #448 ask first for additional params

            value = boundSql.getAdditionalParameter(propertyName);

          } else if (parameterObject == null) {

            value = null;

          } else if(typeHandlerRegistry.hasTypeHandler(parameterObject.getClass())) {

            value = parameterObject;

          } else {

            MetaObject metaObject =configuration.newMetaObject(parameterObject);

            value = metaObject.getValue(propertyName);

          }

          TypeHandler typeHandler = parameterMapping.getTypeHandler();

          JdbcType jdbcType = parameterMapping.getJdbcType();

          if (value == null && jdbcType == null) {

            jdbcType = configuration.getJdbcTypeForNull();

          }

          try {

            typeHandler.setParameter(ps, i + 1, value, jdbcType);

          } catch (TypeException e) {

            throw new TypeException("Could not set parameters for mapping: " + parameterMapping + ". Cause: " + e, e);

          } catch (SQLException e) {

            throw new TypeException("Could not set parameters for mapping: " + parameterMapping + ". Cause: " + e, e);

          }

        }

      }

    }

  }

 

4     采用${var}的形式处理变量
       采用“${var}”的形式来引用变量时，其中的变量会在MappedStatement调用getBoundSql()方法获取对应的BoundSql时被替换。${var}中的var可以是如下取值：

1、内置的_parameter变量，对应转换后的传递参数，在只传递单参数且是没有使用@Param注解对参数命名的时候如果我们需要通过${var}的形式来访问传递的单参数，则可以使用${_parameter}；

2、如果对应的Mapper接口方法是多参数或者拥有@Param命名的参数时可以使用param1、paramN的形式；

3、如果对应的Mapper接口方法参数是@Param命名的方法参数，则可以使用@Param指定的名称；

4、如果对应的Mapper接口方法拥有多个参数，且拥有没有使用@Param命名的参数，那没有使用@Param命名的参数可以通过0、1、N形式访问。

 

       根据上述规则如我们有一个findById的方法其接收一个Long类型的参数作为ID，当使用${var}的形式引用变量时则可以写成如下这样：

   <select id="findById"resultType="com.elim.learn.mybatis.model.User"parameterType="java.lang.Long" >

      select id,name,username,email,mobile from t_user where id=${_parameter}

   </select>

 

       当我们的Mapper接口方法参数使用了@Param命名的时候，我们还可以使用@Param指定的参数名。

public interface UserMapper {

   User findById(@Param("id") Long id);

}

 

   <select id="findById"resultType="com.elim.learn.mybatis.model.User"parameterType="java.lang.Long" >

      select id,name,username,email,mobile from t_user where id=${id}

   </select>

       注意，但是使用了@Param对单参数命名后我们就不能再在Mapper语句中通过${_parameter}来引用接口方法参数传递过来的单参数了，因为此时其已经被包装为一个Map了，如果要通过_parameter来引用的话，我们应该使用${_parameter.param1}或${_parameter.varName}，对于上面的示例来说就是${_parameter.param1}或${_parameter.id}。

 

       下面我们来看一个传递多参数的，假设我们有如下这样的一个Mapper语句及对应的Mapper接口方法，这个Mapper接口方法接收两个参数，第一个参数是用@Param注解指定了参数名为name，第二个参数是没有使用注解的，具体如下。

   <!-- 当对应的接口方法传递多个参数时，可以不指定parameterType参数，就算指定了也没用，因为这个时候默认是Map -->

   <select id="findByNameAndMobile"resultType="com.elim.learn.mybatis.model.User">

      select id,name,username,email,mobile from t_user where name='${name}' and mobile='${1}'

   </select>

 

   List<User> findByNameAndMobile(@Param("name") String name, Stringmobile);

 

     那我们的Mapper.xml文件中的对应语句需要Mapper接口方法参数时有哪几种方式呢？按照之前的规则，对于第一个方法参数name而言，因为使用了@Param指定了参数名name，所以我们可以在Mapper.xml文件中通过变量name和param1来引用它，而第二个参数mobile是没有使用@Param指定参数名的，则我们可以使用param2和参数相对位置“1”来引用它。如上面的示例中，我们就是通过第二个参数的相对位置“1”来引用的。如果我们把第二个参数改为${mobile}是引用不到，且系统会报如下错误，有兴趣的朋友可以试一下。

org.apache.ibatis.binding.BindingException: Parameter 'mobile' not found. Available parameters are [1, name, param1, param2]

 

       一般情况下为了防止SQL注入问题，是不建议直接在where条件中使用${var}的形式访问变量的，通常会用预编译形式的#{var}。而${var}往往是用来传递一些非where条件的内容，比如排序信息，具体用法请根据实际情况决定。 

## 这是一个我写的 Mybatis文件，常用的内容已经算是用上了,学而时习吧

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="auct.common">
    <!-- 拍卖表 浏览权限可暴露信息 -->
    <sql id="auctCommonContent">
          `AUCT_ID` AS auctId ,
          `AUCT_START_DATM` AS auctStartDatm ,
          `AUCT_END_DATM` AS auctEndDatm ,
          `AUCT_MODE` AS auctMode ,
          `AUCT_STAT` AS auctStat ,
          `AUCT_NAME` AS auctName ,
          `START_PRICE` AS startPrice ,
          `KEEP_PRICE` AS keepPrice ,
          `AUCT_MONY` AS auctMony ,
          `FIX_PRICE` AS fixPrice ,
          `AMNT` AS amnt ,
          `UNIT_DESC` AS unitDesc ,
          `UNIT` AS unit ,
          `GDIT_PRICE` AS gditPrice ,
          `CH_ID` AS CHId ,
          `CHT_ID` AS CHTId ,
          `STATUS` AS status
    </sql>
    <!-- 拍卖表 标准权限可暴露信息 -->
    <sql id="auctUserContent">
          `AUCT_ID` AS auctId ,
          `USER_ID` AS userId ,
          `WHR_ID` AS WHRId ,
          `AUCT_START_DATM` AS auctStartDatm ,
          `AUCT_END_DATM` AS auctEndDatm ,
          `AUCT_MODE` AS auctMode ,
          `AUCT_STAT` AS auctStat ,
          `USER_NAME` AS userName ,
          `AUCT_NAME` AS auctName ,
          `START_PRICE` AS startPrice ,
          `KEEP_PRICE` AS keepPrice ,
          `AUCT_MONY` AS auctMony ,
          `FIX_PRICE` AS fixPrice ,
          `AMNT` AS amnt ,
          `AUCT_APLI_ID` AS auctApliId ,
          `UNIT_DESC` AS unitDesc ,
          `UNIT` AS unit ,
          `GDIT_PRICE` AS gditPrice ,
          `CH_ID` AS CHId ,
          `CHT_ID` AS CHTId ,
          `STATUS` AS status,
          `USER_UNDO` AS userUndo,
          `UNDO` AS undo
    </sql>
    <!-- 拍卖表 管理员权限可暴露信息 -->
    <sql id="auctAdminContent">
          `AUCT_ID` AS auctId ,
          `USER_ID` AS userId ,
          `WHR_ID` AS WHRId ,
          `AUCT_START_DATM` AS auctStartDatm ,
          `AUCT_END_DATM` AS auctEndDatm ,
          `AUCT_MODE` AS auctMode ,
          `AUCT_STAT` AS auctStat ,
          `USER_NAME` AS userName ,
          `AUCT_NAME` AS auctName ,
          `START_PRICE` AS startPrice ,
          `KEEP_PRICE` AS keepPrice ,
          `AUCT_MONY` AS auctMony ,
          `FIX_PRICE` AS fixPrice ,
          `AMNT` AS amnt ,
          `AUCT_APLI_ID` AS auctApliId ,
          `UNIT_DESC` AS unitDesc ,
          `UNIT` AS unit ,
          `GDIT_PRICE` AS gditPrice ,
          `CH_ID` AS CHId ,
          `CHT_ID` AS CHTId ,
          `CREATE_DATM` AS createDatm ,
          `UPDATE_DATM` AS updateDatm ,
          `STATUS` AS status ,
          `TOTAL_CMSN` AS totalCmsn ,
          `FIX_CMSN` AS fixCmsn ,
          `VARY_CMSN` AS varyCmsn,
          `USER_UNDO` AS userUndo,
          `UNDO` AS undo
    </sql>
    <!-- 拍卖表-筛选条件 -->
    <sql id="auctFilter">
      <if test="_parameter.containsKey('CHId')">
        AND CH_ID=#{CHId}
      </if>
      <if test="_parameter.containsKey('CHTId')">
         AND CHT_ID=#{CHTId}
      </if>
      <if test="_parameter.containsKey('auctStat')">
          <choose>
              <when test="_parameter.auctStat == '11'">
                  AND AUCT_STAT &lt; 2
              </when>
              <otherwise>
                  AND AUCT_STAT=#{auctStat}
              </otherwise>
          </choose>
      </if>
    </sql>
    <!-- 浏览权限返回数据，可附带 药材品类，药材，拍卖状态 三个查询条件。锁定  -->
    <select id="auctCommonQuery" parameterType="map" resultType="map">
        SELECT
          <include refid="auctCommonContent" ></include>
        FROM TB_AUCT
        WHERE STATUS = 0
       <include refid="auctFilter"></include>
    </select>
  <select id="auctUserQuery" parameterType="map" resultType="map">
    SELECT
    <include refid="auctUserContent" ></include>
    FROM TB_AUCT
    WHERE  USER_ID=#{userId}
    <include refid="auctFilter"></include>
  </select>
  <select id="auctAdminQuery" parameterType="map" resultType="map">
    SELECT
    <include refid="auctAdminContent" ></include>
    FROM TB_AUCT
    WHERE 1=1
    <if test="_parameter.containsKey('userId')">
      AND USER_ID=#{userId}
    </if>
    <include refid="auctFilter"></include>
  </select>
    <select id="queryOne" parameterType="String" resultType="map">
        SELECT
        <include refid="auctCommonContent" ></include>
        FROM TB_AUCT
        WHERE AUCT_ID =#{_paramter}
    </select>
  <!-- 判断某个拍卖ID是否存在 -->
  <select id="auctCheckExist" resultType="Integer">
    SELECT IFNULL((SELECT COUNT(AUCT_ID) FROM TB_AUCT WHERE AUCT_ID=#{auctId}),0)
  </select>
  <!-- 判断拍卖ID与用户ID的关系 -->
  <select id="auctCheckAuth"  resultType="Integer">
    SELECT IFNULL((SELECT COUNT(AUCT_ID) FROM TB_AUCT WHERE AUCT_ID=#{auctId} AND USER_ID = #{userId}),0)
  </select>
  <select id="auctCheckActive"  resultType="Integer">
    SELECT IFNULL((SELECT COUNT(AUCT_ID) FROM TB_AUCT WHERE AUCT_ID=#{auctId} AND AUCT_STAT=0),0)
  </select>
    <update id="passByAdmin" parameterType="map">

    </update>
</mapper>
```





- mybatis在项目中扮演什么角色？以什么形式存在？mybatis的事物管理机制是怎样的？
  - 1）mybatis是一个ORM框架，属于DAO层，负责和数据库进行交互；
  - 2）DAO层文件夹中分别存放了mapper.Java 和 mapper.xml ；
  - 3）mapper.xml 是对 mapper.java 接口的实现。他们之间的关联通过mapper.xml 中的<mapper ></mapper> 标签中的namespace属性实现绑定
  - 
  ```xml
  <?xml version="1.0" encoding="UTF-8" ?>  
  <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >  
  <mapper namespace="mapper.OrderitemMapper" >  
  </mapper> 
  ```
  - 4）检验是否绑定成功：如果按住ctrl键点击namespace中的值，可以直接跳转到对应的接口，则表示跳转成功
  - 5）mybatis框架独立运行时，需要手动控制事物，进行打开、提交、回滚、关闭操作。若集成了spring框架，则可以将其托管到Spring中自动管理
  -
  ```java
  // 手动管理
  SqlSession session= MyBatisSessionFactory.getSession(); //获取数据库连接  
  session.commit(); //提交  
  session.rollback(); //回滚  
  session.close(); //关闭连接  
  ```
- mapper 示例与其中参数详解

  - 几个顶级元素
    - cache
    - cache-ref
    - resultMap
    - sql
    - insert
    - update
    - delete
    - select
     - 
     ```xml
     <select
    id="selectPerson"  
      //命名空间中的唯一标识符
    parameterType="int"
      // 入参
    parameterMap="deprecated"
      // 废弃
    resultType="hashmap"
      // 返回类型  如果是一个对象，可以写对象的全类名，如果是List，可以写 List<person>,也可以是map->返回值用 Map<String,Object> 来接收
    resultMap="personResultMap" , 在resultType=“map”情况下，返回多条记录，会被封装成 一个 ArrayList里面放着N个map
      // 和 resultMap 二者取一个 resultType是直接表示返回类型的，而resultMap则是对外部ResultMap的引用，但是resultType跟resultMap不能同时存在。
    flushCache="false"
      // 如果true，任何时候只要语句被调用，都对导致本地缓存和二级缓存清空，默认false
    useCache="true"
      //
    timeout="10000"
      //
    fetchSize="256"
      // 每次批量返回的结果行数
    statementType="PREPARED"
    resultSetType="FORWARD_ONLY">
    ```
    - insert, update 和 delete
      - 
      ```xml
      <insert
        id="insertAuthor"
        parameterType="domain.blog.Author"
        flushCache="true"
        statementType="PREPARED"
        keyProperty=""
        keyColumn=""
        useGeneratedKeys=""
        timeout="20">
      
      <update
        id="updateAuthor"
        parameterType="domain.blog.Author"
        flushCache="true"
        statementType="PREPARED"
        timeout="20">
      
      <delete
        id="deleteAuthor"
        parameterType="domain.blog.Author"
        flushCache="true"
        statementType="PREPARED"
        timeout="20">
      ```
    - 一些强化用法
      - foreach
      ```xml
      <insert id="insertAuthor" useGeneratedKeys="true"
          keyProperty="id">
        insert into Author (username, password, email, bio) values
        <foreach item="item" collection="list" separator=",">
          (#{item.username}, #{item.password}, #{item.email}, #{item.bio})
        </foreach>
      </insert>
      ```
      - selectKey
      ```xml
      <insert id="insertAuthor">
        <selectKey keyProperty="id" resultType="int" order="BEFORE">
          select CAST(RANDOM()*1000000 as INTEGER) a from SYSIBM.SYSDUMMY1
        </selectKey>
        insert into Author
          (id, username, password, email,bio, favourite_section)
        values
          (#{id}, #{username}, #{password}, #{email}, #{bio}, #{favouriteSection,jdbcType=VARCHAR})
      </insert>
      ```
    - sql -这个元素可以被用来定义可重用的 SQL 代码段，可以包含在其他语句中。它可以被静态地(在加载参数) 参数化. 不同的属性值通过包含的实例变化. 比如：
      - sql片段
      ```xml
      <sql id="userColumns"> ${alias}.id,${alias}.username,${alias}.password </sql>
      ```
      - 使用sql片段
      ```xml
      <select id="selectUsers" resultType="map">
        select
          <include refid="userColumns"><property name="alias" value="t1"/></include>,
          <include refid="userColumns"><property name="alias" value="t2"/></include>
        from some_table t1
          cross join some_table t2
      </select>
      ```
      - 另一个完整例子
      ```xml
      <sql id="sometable">
        ${prefix}Table
      </sql>

      <sql id="someinclude">
        from
          <include refid="${include_target}"/>
      </sql>

      <select id="select" resultType="map">
        select
          field1, field2, field3
        <include refid="someinclude">
          <property name="prefix" value="Some"/>
          <property name="include_target" value="sometable"/>
        </include>
      </select>
      ```
    - 一个很好用的判断标签 <if test="id != null and id != '' ">
## 例子
```xml
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >  
<mapper namespace="mapper.CustomerMapperOrder" >  
    <!-- 此mapper.xml 是作为一对一的关系表结果的映射管理 -->  
    <sql id="cusAndOrder">  
        c.*,  
        o.order_id as orderId,  
        o.create_date as createDate  
    </sql>  
      
    <select id="findCusAndOrderByCid"  resultType="pojo.CustomerAndOrder">  
        select  
        <include refid="cusAndOrder"/>  
        from  
        customer c,ordertable o  
        WHERE  
        c.cid = o.cid  
        </select>  
</mapper> 
```

  - 入参的属性
    - parameterType=“”
    -  例子
    ```xml
    <select id="selectByPrimaryKey" resultMap="BaseResultMap" parameterType="java.lang.String" >    
    select   
    <include refid="Base_Column_List" />  
    from product  
    where product_id = #{productId,jdbcType=VARCHAR}  
    </select>  
    ```
    - 可以是基本数据类型
      - 可以是类（JavaBean->#{属性名}  Map->#{key} ）
    - 有比较复杂的写法
    ```xml
    <select id="queryCarMakerList" resultMap="BaseResultMap" parameterType="java.util.Map">  
        select  
        <include refid="Base_Column_List" />  
        from common_car_make cm  
        where 1=1  
        <if test="id != null">  
            and  cm.id = #{id,jdbcType=DECIMAL}  
        </if>  
        <if test="carDeptName != null">  
            and  cm.car_dept_name = #{carDeptName,jdbcType=VARCHAR}  
        </if>  
        <if test="carMakerName != null">  
            and  cm.car_maker_name = #{carMakerName,jdbcType=VARCHAR}  
        </if>  
        <if test="hotType != null" >  
           and  cm.hot_type = #{hotType,jdbcType=BIGINT}  
        </if>  
        ORDER BY cm.id  
    </select>
    ```


## 关于 ResultType ResultMap

一、概述
MyBatis中在查询进行select映射的时候，返回类型可以用resultType，也可以用resultMap，resultType是直接表示返回类型的，而resultMap则是对外部ResultMap的引用，但是resultType跟resultMap不能同时存在。
在MyBatis进行查询映射时，其实查询出来的每一个属性都是放在一个对应的Map里面的，其中键是属性名，值则是其对应的值。
①当提供的返回类型属性是resultType时，MyBatis会将Map里面的键值对取出赋给resultType所指定的对象对应的属性。所以其实MyBatis的每一个查询映射的返回类型都是ResultMap，只是当提供的返回类型属性是resultType的时候，MyBatis对自动的给把对应的值赋给resultType所指定对象的属性。
②当提供的返回类型是resultMap时，因为Map不能很好表示领域模型，就需要自己再进一步的把它转化为对应的对象，这常常在复杂查询中很有作用。
二、ResultType
Blog.java
public class Blog {
private int id;
private String title;
private String content;
private String owner;
private List<Comment> comments;
}
其所对应的数据库表中存储有id、title、Content、Owner属性。
<typeAlias alias="Blog" type="com.tiantian.mybatis.model.Blog"/>
<select id="selectBlog" parameterType="int" resultType="Blog">
select * from t_blog where id = #{id}
</select>
MyBatis会自动创建一个ResultMap对象，然后基于查找出来的属性名进行键值对封装，然后再看到返回类型是Blog对象，再从ResultMap中取出与Blog对象对应的键值对进行赋值。
三、ResultMap
当返回类型直接是一个ResultMap的时候也是非常有用的，这主要用在进行复杂联合查询上，因为进行简单查询是没有什么必要的。先看看一个返回类型为ResultMap的简单查询，再看看复杂查询的用法。
①简单查询的写法
<resultMap type="Blog" id="BlogResult">
<id column="id" property="id"/>
<result column="title" property="title"/>
<result column="content" property="content"/>
<result column="owner" property="owner"/>
</resultMap>
<select id="selectBlog" parameterType="int" resultMap="BlogResult">
select * from t_blog where id = #{id}
</select>
select映射中resultMap的值是一个外部resultMap的id，表示返回结果映射到哪一个resultMap上，外部resultMap的type属性表示该resultMap的结果是一个什么样的类型，这里是Blog类型，那么MyBatis就会把它当作一个Blog对象取出。resultMap节点的子节点id是用于标识该对象的id的，而result子节点则是用于标识一些简单属性的，其中的Column属性表示从数据库中查询的属性，Property则表示查询出来的属性对应的值赋给实体对象的哪个属性。简单查询的resultMap的写法就是这样的。
②复杂查询
有一个Comment类，其中有一个Blog的引用，表示是对哪个Blog的Comment，那么在查询Comment的时候把其对应的Blog也要查出来赋给其blog属性。
public class Comment {
private int id;
private String content;
private Date commentDate = new Date();
private Blog blog;
}
<!--来自CommentMapper.xml文件-->
<resultMap type="Comment" id="CommentResult">
<association property="blog" select="selectBlog" column="blog" javaType="Blog"/>
</resultMap>
<select id="selectComment" parameterType="int" resultMap="CommentResult">
select * from t_Comment where id = #{id}
</select>
<select id="selectBlog" parameterType="int" resultType="Blog">
select * from t_Blog where id = #{id}
</select>