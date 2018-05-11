# 这里实际上发生了很多奇妙的问题，因为不知道，所以闹了很多笑话（自己）

# SourceRoot ResourceRoot

- idea 右键一个文件夹 有 设置为source root的选项，这就意味着里面放的都是源代码了
- 还有一个ResourceRoot的选项，里面放的都是配置文件（这里面的配置文件可以通过 反射拿到）

# 我的问题所在

- 刚开始 我把 com.lms.etl.sprak设置为 sourceRoot，这就到这，本身这应该是个 四层的包的，但是在这个项目里面被当成了一个 根文件夹，再里面的包都被视为顶层包了。

# 还有一个重要的关于 maven 的问题！！！！

```xml
    </build>
       <resources>
            <resource>
                <directory>src/main/resources4lmsetlspark</directory>
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                    <include>**/*.tld</include>
                </includes>
                <!-- 是否替换资源中的属性 -->
                <filtering>true</filtering>

            </resource>
            <resource>
                <directory>/src/main/aSparkETL/com.lms.etl.spark</directory>
                <includes>
                    <include>**/*.properties</include>
                    <include>**/*.xml</include>
                    <include>**/*.tld</include>
                </includes>
                <filtering>false</filtering>
            </resource>
        </resources>
    </build>
```

- 有些时候为了让 放在包路径里面的xml文件被打包进到项目里面，要指定 resources 这个属性，里面有一个重要的属性 `<filtering>true</filtering>` 如果设置为true，那么这个路径下的内容就会被修改为resource root，这就直接导致里面的所有代码不能运行（实际没有问题，需要改回去 source root）。 之前能运行的东西，点击再次运行的时候，会提示 class not found，如果在某个文件爱你里面，就会发现，右键没有run了