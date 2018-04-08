# sqlsession下的四大队向

从运行过程1中，可以看到，映射器mapper就是一个ie动态代理对象，进入到mappermethod的excute方法。下面讲这个方法如何执行

Mapper执行过程通过

- Executor - 调度有下面三个
- Statementandler - 使用数据库的Statment（PreparedStatment）执行操作-核心
- ParameterHandler - 处理SQL参数
- ResultHandler - 封装结果集

完成操作，返回结果的。

## 1.Executer 执行器

执行器有三个
- SIMPLE 默认
- REUSE 重用预处理语句
- BATCH 重用语句+批量更新