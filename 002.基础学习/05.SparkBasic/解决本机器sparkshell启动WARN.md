# 问题

```bash
WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
```

可能原因：

${JAVA_HOME}/jre/lib/amd64 之中 缺少 libhadoop.so

另外还有说 这个目录下 还缺少 libsnappy.so的，不过我这边没问题


解决方法：

```bash
## 缺少的这个文件在 hadoop 的目录下有 ${HADOOP_HOME/lib/native}
## 从底层可以看到 libhadoop.so 是一个指向 libhadoop.so.1.0.0的连接，所以 
cp ${HADOOP_HOME}/lib/native/libhadoop.so.1.0.0 ${JAVA_HOME}/jre/lib/amd64/libhadoop.so
## 把 libhadoop.so.1.0.0 复制为 libhadoop.so
```