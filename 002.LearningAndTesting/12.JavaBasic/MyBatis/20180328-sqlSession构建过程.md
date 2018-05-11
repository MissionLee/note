# 构建 sqlSession（Factory）

SqlSessionFactory是MyBatis核心类之一，重要功能是提供SqlSession。

构建过程 
- 1.通过 org.apache.ibatis.builder.xml.XMLConfigBUilder解析配置的XML文件，读取参数，存入org.apache.ibatis.session.Configuration类中。
- 2.使用Configuration对象去创建SqlSessionFactory。SqlSessionFactory是个接口，mybatis为其提供一个默认的实现类DefaultSqlSessionFactory.

>值的学习的思路

上面用的是一种builder模式。对于复杂的对象，直接再构造方法中构建比较困难，导致大量逻辑放在构造方法中，由于对象的复杂性，我们希望更有序的一步步构建它，从而降低复杂性。这时候使用一个参数类Configuration，然后分布构建（再mybatis中就是 defaultSqlSessionFactory）。

## 构建Configuration

- 读取配置文件（包括映射器配置文件）
- 初始化基础配置，比如MyBatis的别名，一些重要的类对象，例如插件，映射器，ObjectFactory和typeHandler
- 提供单例，为后续创建SessionFactory服务提供配置的参数
- 执行一些重要的对象方法，初始化配置信息

>Configuration初始化
- properties全局参数
- settings设置
- typeAliases别名
- typeHandler类型处理器
- ObjectFactory
- plugin插件
- environment
- DatabaseIdProvider数据库表示
- Mapper映射器

## 映射器  的 内部组成

- MappedStatement，保存映射器的一个节点（select，insert，delete，update）包括SQL，SQLID，resultMap等等信息
- SqlSource，提供BoundSql对象的地方，是MappedStatement的的一个属性
- BonudSql 建立SQL和参数的地方。后面讲


>有了Configuration对象，构建SqlSessionFactory很简单了