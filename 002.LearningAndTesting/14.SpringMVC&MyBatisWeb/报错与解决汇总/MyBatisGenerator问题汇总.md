# 12

- 不支持SSL
  - 数据库默认不支持ssl
  - 在配置文件 mysqld位置  加上 ssl  三个字母就行了

- 找不到jdbc
  -  <classPathEntry location="/usr/java/jdk1.8.0_151/jre/lib/mariadb-java-client-2.2.1.jar"/>
  - 这个参数要写完整的本地路径！！！！！


- 运行时候报错： Could not connect to localhost:3306 : Received fatal alert: handshake_failure -> [Help 1]
  - 按照教程，数据库参数是这样的：connectionURL="jdbc:mysql://localhost:3306/test?characterEncoding=UTF-8&amp;useSSL=true&amp;serverTimezone=GMT%2B8"
  - 我把后面的内容 去掉就没有这个问题了
  - connectionURL="jdbc:mysql://localhost:3306/test?characterEncoding=UTF-8"

- 警告：  一些 目录 或者 文件 没找到之类的
  - 例子：

  ```xml
          <sqlMapGenerator targetPackage="com.lms.dao.xml"
                        targetProject="/home/missingli/IdeaProjects/SpringWebLearn/src/main/java"
        >
  ```
  - 主要就是  这里的 targetProject 里面的目录 也要写成本地的完全路径！！！！