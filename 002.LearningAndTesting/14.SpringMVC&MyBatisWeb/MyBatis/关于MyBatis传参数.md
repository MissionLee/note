# 

- 关于 String类型参数:又一个说法时必须 写成 _parameter如下，实际上我测试的时候 #{} 里面写成任何内容，在 sqlSession.selectOne/selectList 里面传的参数都能正确接收到

```xml
<?xml version="1.0" encoding="UTF-8" ?>  
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >  
<mapper namespace="com.stu.mapper.UserMapper">  
  
    <select id="logconfirm" parameterType="String" resultType="String">  
        select password from user where username=#{_parameter}  
    </select>  
  
</mapper> 
```