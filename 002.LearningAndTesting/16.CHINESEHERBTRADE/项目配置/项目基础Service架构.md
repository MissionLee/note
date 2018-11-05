# 与具体项目无关， 实际上每个项目都有相关的设置

- UserService + RoleService + FunctionService
  - 用户 - 角色 -功能的基础框架体系，用于配置用户权限相关问题

- RedisService
  - 进一步封装 redis的操作

- BaseService
  - 对用方便调用的通用数据库查询（使用了Spring 框架搭配MyBatis）
  - 实际上就是吧 mybatis mapper的参数： FullSql 根据业务做了规划
    - 让 mapper中的namespace + sqlId 与 RequestMapping的 PathVariable对应，然后sqlSession拿到 PathVariable后就可以用通用方法调用通用SQL