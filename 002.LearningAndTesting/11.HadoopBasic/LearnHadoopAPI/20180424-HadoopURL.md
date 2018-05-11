

```java
package com.lms.spark.test;

import org.apache.hadoop.fs.FsUrlStreamHandlerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * @author: MissingLi
 * @date: 24/04/18 09:38
 * @Description:
 * @Modified by:
 */
public class aboutHadoopFileSystemAPi {
    static{
        System.setProperty("HADOOP_USER_NAME","hdfs");
        URL.setURLStreamHandlerFactory(new FsUrlStreamHandlerFactory());
        //这里需要提供 FsUrlStreamHadnlerFactory才能让 java.net.URL正确识别 hdfs:// 
        // 但是！！！ 在一个JVM中，这个 set。。。 方法只能调用一次
    }
    public static void main(String[] args) {
        InputStream in = null;
        try {
            in = new URL("hdfs://localhost:9000/lms/apitest/testworkcount").openStream();
            // 这里端口号 其实有一点小问题的  8020  和 9000   这部分基本上是历史遗留问题
            org.apache.hadoop.io.IOUtils.copyBytes(in,System.out,4096,false);
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

这个方法 了解一下就好： 重点是看 FileSystem类