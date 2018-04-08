# JDBC全称为：Java DataBase Connectivity（java数据库连接）。

SUN公司为了简化、统一对数据库的操作，定义了一套Java操作数据库的规范，称之为JDBC。

简单的说，JDBC的意义在于在Java程序中执行SQL语句。

驱动程序的意义在于提供统一的接口并隐藏实现细节。驱动程序定义了数据库能做什么（what to do），比如上面提到的这四个步骤，数据库的制造商（例如Oracle）提供符合这些接口的实现（how to do），我们在编写Java程序中只需要调用驱动程序中的接口就可以操作数据库，完成这四个步骤。同计算机硬件的驱动程序类似，JDBC的驱动实现了”做什么“和”怎么做“的分离。与使用SQLPlus访问数据库类似，在操作数据库之前，需要先跟数据库建立连接。连接是一个虚拟的概念，并不一定对应着网络连接（例如一些小型的文件数据库），建立连接后，可以通过获得的连接对象来调用SQL语句。 操作数据基本的含义是执行SQL语句，包括DML,DDL,DCL均可，还可以调用数据库中已有的存储过程。

释放资源使用JDBC编程时，与数据库建立的连接以及通过这个连接创建的语句对象，都有可能需要调用相应的close方法来释放底层建立的网络连接，或者打开的文件。
 
## 加载数据库驱动：

DriverManager可用于加载驱动DriverManager.registerDriver(new Driver())；import com.mysql.jdbc.Driver;必须导入对应驱动的包，过于依赖。
 
注意：在实际开发中并不推荐采用registerDriver方法注册驱动。原因有二：

- 一、查看Driver的源代码可以看到，如果采用此种方式，会导致驱动程序注册两次，也就是在内存中会有两个Driver对象。
- 二、程序依赖mysql的api，脱离mysql的jar包，程序将无法编译，将来程序切换底层数据库将会非常麻烦。
 
- 推荐方式：Class.forName(“com.mysql.jdbc.Driver”);//加载驱动时，并不是真正使用数据库的驱动类，只是使用数据库驱动类名的字符串而已。

这里驱动类名是没有规律的，想知道只需要查看该驱动的文档即可。
 
采用此种方式不会导致驱动对象在内存中重复出现，并且采用此种方式，程序仅仅只需要一个字符串，不需要依赖具体的驱动，使程序的灵活性更高。
 
DriverManager:用于管理JDBC驱动的服务类。程序中使用该类主要是获得Connection对象。

DriverManager.getConnection(url, user, password)，获取URL对应的数据库的连接

URL用于标识数据库的位置，程序员通过URL地址告诉JDBC程序连接哪个数据库，URL的写法为：

jdbc:mysql://localhost:3306/test ?key=value

不同的数据库URL写法存在差异。如果想了解特定数据库的url写法，可以查阅该数据库驱动的文档。
 
常用属性：useUnicode=true&characterEncoding=UTF-8
 
 
Jdbc程序中的Connection，它用于代表数据库的链接，Connection是数据库编程中最重要的一个对象，客户端与数据库所有交互都是通过connection对象完成的，这个对象的常用方法：

createStatement()：创建向数据库发送sql的statement对象

prepareStatement(sql) ：创建向数据库发送预编译sql的PrepareSatement对象

prepareCall(sql)：创建执行存储过程的callableStatement对象。

--- 存储过程 

setAutoCommit(boolean autoCommit)：设置事务是否自动提交。 

commit() ：在链接上提交事务。 ---与事务相关！！

rollback() ：在此链接上回滚事务。

 
//注意我们使用JDBC接口规范，我们虽然在项目中加载了对应的数据库驱动实现包，但是在编程时，不需要引入import com.mysql.jdbc.Connection;因为这样虽然对程序没有影响，但是过去依赖驱动包。
我们在JDBC编程时，直接参考JDKAPI文档即可。
复制代码

```sql
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
public class JDBCDemo {
    public static void main(String[] args) throws SQLException, ClassNotFoundException
    {
        Class.forName("com.mysql.jdbc.Driver");
        Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test","root","123");
        Statement stmt = connection.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT A_NAME  FROM A"); 
        while (rs.next()) { 
            String name = rs.getString("A_NAME"); 
            System.out.println("name is:"+ name); 
        } 
        rs.close();
        stmt.close();
        connection.close();
    }
}  
```
 
Jdbc程序中的Statement对象用于向数据库发送SQL语句， Statement对象常用方法：

- executeQuery(String sql) ：用于向数据发送查询语句。
- executeUpdate(String sql)：用于向数据库发送insert、update或delete语句
- execute(String sql)：用于向数据库发送任意sql语句
 
- addBatch(String sql) ：把多条sql语句放到一个批处理中。
- executeBatch()：向数据库发送一批sql语句执行。
 
 
Jdbc程序中的ResultSet用于代表Sql语句的执行结果。Resultset封装执行结果时，采用的类似于表格的方式。ResultSet 对象维护了一个指向表格数据行的游标cursor，初始的时候，游标在第一行之前，调用ResultSet.next() 方法，可以使游标指向具体的数据行，进而调用方法获取该行的数据。

ResultSet既然用于封装执行结果的，所以该对象提供的大部分方法都是用于获取数据的get方法：

获取任意类型的数据

- getObject(int index)
- getObject(string columnName)

获取指定类型的数据，例如：

- getString(int index)
- getString(String columnName)

提问：数据库中列的类型是varchar，获取该列的数据调用什么方法？Int类型呢？bigInt类型呢？Boolean类型？
 
 
默认得到的ResultSet它只能向下遍历(next()),对于ResultSet它可以设置成是滚动的，可以向上遍历，
或者直接定位到一个指定的物理行号.
 
问题:怎样得到一个滚动结果集?
 
Statement st=con.createStatement();
ResultSet rs=st.executeQuery(sql);
 

这是一个默认结果集:只能向下执行，并且只能迭代一次。
 
 Statement stmt = con.createStatement(
                                      ResultSet.TYPE_SCROLL_INSENSITIVE,
                                      ResultSet.CONCUR_UPDATABLE);
ResultSet rs = stmt.executeQuery(sql);
 

这个就可以创建滚动结果集.
简单说，就是在创建Statement对象时，`不使用`createStatement();
而使用带参数的`createStatement(int,int)`
 
 
Statement createStatement(int resultSetType,
                          int resultSetConcurrency)
                          throws SQLException
  
resultSetType - 结果集类型，它是 ResultSet.TYPE_FORWARD_ONLY、ResultSet.TYPE_SCROLL_INSENSITIVE 或 ResultSet.TYPE_SCROLL_SENSITIVE 之一
resultSetConcurrency - 并发类型；它是 ResultSet.CONCUR_READ_ONLY 或 ResultSet.CONCUR_UPDATABLE 之一 
  
第一个参数值
ResultSet.TYPE_FORWARD_ONLY    该常量指示光标只能向前移动的 ResultSet 对象的类型。
ResultSet.TYPE_SCROLL_INSENSITIVE  该常量指示可滚动但通常不受 ResultSet 底层数据更改影响的 ResultSet 对象的类型。
ResultSet.TYPE_SCROLL_SENSITIVE  该常量指示可滚动并且通常受 ResultSet 底层数据更改影响的 ResultSet 对象的类型。
 
第二个参数值
ResultSet.CONCUR_READ_ONLY    该常量指示不可以更新的 ResultSet 对象的并发模式。
ResultSet.CONCUR_UPDATABLE    该常量指示可以更新的 ResultSet 对象的并发模式。
 
以上五个值，可以有三种搭配方式
ResultSet.TYPE_FORWARD_ONLY   ResultSet.CONCUR_READ_ONLY   默认
ResultSet.TYPE_SCROLL_INSENSITIVE   ResultSet.CONCUR_READ_ONLY 
ResultSet.TYPE_SCROLL_SENSITIVE  ResultSet.CONCUR_UPDATABLE 
 
 
常用API
next()：移动到下一行
previous()：移动到前一行
absolute(int row)：移动到指定行
beforeFirst()：移动resultSet的最前面
afterLast() ：移动到resultSet的最后面
updateRow() ：更新行数据
ResultSet还提供了对结果集进行滚动和更新的方法
Statement stmt = conn.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE,ResultSet.CONCUR_UPDATABLE);
next()：移动到下一行
previous()：移动到前一行
absolute(int row)：移动到指定行
beforeFirst()：移动resultSet的最前面
afterLast() ：移动到resultSet的最后面
updateRow() ：更新行数据
 
 
 
Jdbc程序运行完后，`切记要释放程序在运行过程中，创建的那些与数据库进行交互的对象`，这些对象通常是`ResultSet`, `Statement`和`Connection`对象。
 
`特别是Connection对象`，它是非常稀有的资源，用完后必须马上释放，如果Connection不能及时、正确的关闭，极易导致系统宕机。Connection的使用原则是尽量晚创建，尽量早的释放。
 
为确保资源释放代码能运行，资源释放代码也一定要放在finally语句中。
 
 
 
PreparedStatement是Statement的子接口，它的实例对象可以通过调用`Connection.preparedStatement(sql)`方法获得，相对于Statement对象而言：

PreperedStatement可以`避免SQL注入`的问题。

`Statement会使数据库频繁编译SQL`，可能造成数据库缓冲区溢出。PreparedStatement 可对SQL进行预编译，从而提高数据库的执行效率。

并且PreperedStatement对于sql中的参数，允许使用占位符的形式进行替换，简化sql语句的编写。
 

 ------------------------------------------------------------------------------------


通过JDBC操作数据库——步骤：

第1步：注册驱动 (只做一次)

第2步：建立连接(Connection)

第3步：创建执行SQL的语句(Statement)

第4步：执行语句

第5步：处理执行结果(ResultSet)

第6步：释放资源


使用JDBC第一步：加载驱动

注册驱动有三种方式：

1.      Class.forName(“com.mysql.jdbc.Driver”);

         推荐这种方式，不会对具体的驱动类产生依赖

2. DriverManager.registerDriver(com.mysql.jdbc.Driver);

         会对具体的驱动类产生依赖

3. System.setProperty(“jdbc.drivers”, “driver1:driver2”);

         虽然不会对具体的驱动类产生依赖；但注册不太方便，所以很少使用

使用JDBC第二步：建立连接

通过Connection建立连接，Connection是一个接口类，其功能是与数据库进行连接（会话）。

建立Connection接口类对象：

Connection conn =DriverManager.getConnection(url, user, password);

其中URL的格式要求为：

JDBC:子协议:子名称//主机名:端口/数据库名？属性名=属性值&…

如："jdbc:mysql://localhost:3306/test“

user即为登录数据库的用户名，如root

password即为登录数据库的密码，为空就填””

使用JDBC第三步：创建执行对象

执行对象Statement负责执行SQL语句，由Connection对象产生。

Statement接口类还派生出两个接口类PreparedStatement和CallableStatement，这两个接口类对象为我们提供了更加强大的数据访问功能。

创建Statement的语法为：

Statement st = conn.createStatement();

使用JDBC第四步：执行SQL语句

执行对象Statement提供两个常用的方法来执行SQL语句。

executeQuery(Stringsql),该方法用于执行实现查询功能的sql语句，返回类型为ResultSet（结果集）。

如：ResultSet  rs =st.executeQuery(sql);

executeUpdate(Stringsql),该方法用于执行实现增、删、改功能的sql语句，返回类型为int，即受影响的行数。

如：int flag = st.executeUpdate(sql);

使用JDBC第五步：处理执行结果

ResultSet对象

ResultSet对象负责保存Statement执行后所产生的查询结果。

结果集ResultSet是通过游标来操作的。

游标就是一个可控制的、可以指向任意一条记录的指针。有了这个指针我们就能轻易地指出我们要对结果集中的哪一条记录进行修改、删除，或者要在哪一条记录之前插入数据。一个结果集对象中只包含一个游标。

使用JDBC 第六步——释放资源

Connection对象的close方法用于关闭连接，并释放和连接相关的资源。


使用JDBC——模板




一些重要的接口----------------------------------------------------------------------------------------------------

PreperedStatement接口

PreperedStatement从Statement扩展而来。

需要多次执行SQL语句，可以使用PreparedStatement。

PreparedStatement可以对SQL语句进行预编译

并且可以存储在PreparedStatement对象中，当多次执行SQL语句时可以提高效率。

作为Statement的子类，PreparedStatement继承了Statement的所有函数。

 

创建PreperedStatement

PreparedStatementstr=con.prepareStatement("update user set id=? where username=?”);//此处?为通配符

其他的CRUD方法和Statement基本一致。

 

CallableStatement接口

CallableStatement类继承了PreparedStatement类，他主要用于执行SQL存储过程。

在JDBC中执行SQL存储过程需要转义。

JDBC API提供了一个SQL存储过程的转义语法：

{call<procedure-name>[<arg1>,<arg2>, ...]}

procedure-name：是所要执行的SQL存储过程的名字

[<arg1>,<arg2>, ...]：是相对应的SQL存储过程所需要的参数

 

ResultSetMeta接口

前面使用ResultSet接口类的对象来获取了查询结果集中的数据。

但ResultSet功能有限，如果我们想要得到诸如查询结果集中有多少列、列名称分别是什么就必须使用ResultSetMeta接口了。

ResultSetMeta是ResultSet的元数据。

元数据就是数据的数据， “有关数据的数据”或者“描述数据的数据”。

ResultSetMeta的使用

获得元数据对象

ResultSetMetaData rsmd=rst.getMetaData();

返回所有字段的数目

public int getColumCount() throwsSQLException

根据字段的索引值取得字段的名称

public String getColumName (int colum)throws SQLException

根据字段的索引值取得字段的类型

public String getColumType (int colum)throws SQLException

 

PreperedStatement接口和Statement的区别

(1) 使用Statement发送和执行sql语句

Statement stmt = con.creatStatement();//加载时，无参数，不编译sql语句

String sql = "selete * from emp";

ResultSet rs = stmt.executeQuery(sql);//执行时编译sql语句，返回查询结果集

(2) 使用PreparStatement发送和执行sql语句

String sql = "selete * from emp";

PreparStatement ps=con.prepareStatement(sql);//加载时就编译sql语句

ResultSet rs = ps.executeQuery();//此处执行时，不需要传参

还有就是

Statement stmt；支持可以通过字符串拼接(来传递参数)，如StringdeleteStu = "delete from student where id="+id;但容易ＳＱＬ注入

PreparedStatement   ps; 不支持字符串拼接，提供？通配符传递参数，更安全；如String deleteStu = "delete from student where id=?";

ps.setInt(1, id);  //设置第一个？通配值为id

 

JDBC事务

      何谓事务？

      所谓事务是指一组逻辑操作单元，使数据从一种状态变换到另一种状态。

      事务的ACID属性：

1.       原子性（Atomicity）：指事务是一个不可分割的工作单位，事务中的操作要么都发生，要么都不发生。

2.       一致性（Consistency）事务必须使数据库从一个一致性状态变换到另外一个一致性状态。

3.       隔离性（Isolation）事务的隔离性是指一个事务的执行不能被其他事务干扰。

4.       持久性（Durability）持久性是指一个事务一旦被提交，它对数据库中数据的改变就是永久性的，接下来的其他操作和数据库故障不应该对其有任何影响。

      JDBC中使用COMMIT 和 ROLLBACK语句来实现事务。

      COMMIT用于提交事务，ROLLBACK用于数据库回滚。

      通过这两个语句可以确保数据完整性；数据改变被提交之前预览；将逻辑上相关的操作分组。

      RollBack语句数据改变被取消使之再一次事务中的修改前的数据状态可以被恢复。

      为了让多个 SQL 语句作为一个事务执行，基本步骤为：

      先调用 Connection 对象的 setAutoCommit(false); 以取消自动提交事务。

      然后在所有的 SQL 语句都成功执行后，调用 commit();

      如果在出现异常时，可以调用 rollback();使方法回滚事务。

 

JTA事务

      在实际应用中经常会涉及到多个数据源的不同的连接，并且数据的操作要处于一个事务之中。

      如去银行进行转账，转账的两个账户是不同的银行，当然数据的操作就跨数据库了，或者叫处于不同的数据源之中。

      跨越多个数据源的事务，就要使用JTA容器实现事务。

      在分布式的情况下的JTA容指的是Web容器，大家非常熟悉的Tomcat不能实现JTA的操作。

      目前支持JTA的容器有非常著名的BEA公司的 Weblogic，IBM公司的WebSphere等企业级的Web应用服务器。

JTA分成两阶段提交

      第一步，通过JNDI在分布式的环境中查找相关资源。

                   javax.transaction.UserTransactiontx =                                        (UserTransaction)ctx.lookup(“jndiName");

                   tx.begin()

      第二步，提交

                   tx.commit();

