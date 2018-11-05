# [源码中transient的用途](https://www.cnblogs.com/liang1101/p/6382765.html)



　　Java的serialization提供了一种持久化对象实例的机制。当持久化对象时，可能有一个特殊的对象数据成员，我们不想用serialization机制来保存它。为了在一个特定对象的一个域上关闭serialization，可以在这个域前加上关键字transient，transient是Java语言的关键字，用来表示一个域不是该对象串行化的一部分。当一个对象被串行化的时候，transient型变量的值不包括在串行化的表示中，然而非transient型的变量是被包括进去的。

那么，让我们看一下序列化的代码如下：

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```java
 1 public class LoggingInfo implements java.io.Serializable {   
 2     private Date loggingDate = new Date();   
 3     private String uid;   
 4     private transient String pwd;   
 5       
 6     LoggingInfo(String user, String password) {   
 7         uid = user;   
 8         pwd = password;   
 9     }   
10     public String toString() {   
11         String password=null;   
12         if(pwd == null) {   
13             password = "NOT SET";   
14         }   
15         else {   
16             password = pwd;   
17         }   
18         return "logon info: \n   " + "user: " + uid +   
19             "\n   logging date : " + loggingDate.toString() +   
20             "\n   password: " + password;
21     }
22 }
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

现在我们再创建一个这个类的实例，并且串行化(serialize)它 ,然后将这个串行化对象写如磁盘。

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```java
 1 LoggingInfo logInfo = new LoggingInfo("MIKE", "MECHANICS");
 2 System.out.println(logInfo.toString());
 3 try {
 4    ObjectOutputStream o = new ObjectOutputStream(new FileOutputStream("logInfo.out"));
 5    o.writeObject(logInfo)；
 6    o.close();
 7 }   
 8 catch(Exception e) {//deal with exception}
 9 To read the object back, we can write
10 try {
11    ObjectInputStream in =new ObjectInputStream(new FileInputStream("logInfo.out"));
12    LoggingInfo logInfo = (LoggingInfo)in.readObject();
13    System.out.println(logInfo.toString());
14 }
15 catch(Exception e) {//deal with exception}
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

　　运行这段代码，我们会注意到从磁盘中读回(read——back (de-serializing))的对象打印password为"NOT SET"，此时是我们定义pwd域为transient时，所期望的正确结果。

　　如果将pwd域前修饰符transient去掉，再做一次发现password内容会打印出传入的参数内容，即：MECHANICS，也符合我们所期望的结果。

 

那到底什么时候使用这个关键字呢？处于什么考量呢，自己认为大概有以下两点可以做考虑：

- . HashMap中的table中存储的值数量是小于数组的大小的（数组扩容的原因），这个在元素越来越多的情况下更为明显。如果使用默认的序列化，那些没有元素的位置也会被存储，就会产生很多不必要的浪费。

- 对于HashMap来说（以及底层实现是利用HashMap的HashSet），由于不同的虚拟机对于相同hashCode产生的Code值可能是不一样的，如果你使用默认的序列化，那么反序列化后，元素的位置和之前的是保持一致的，可是由于hashCode的值不一样了，那么定位函数indexOf()返回的元素下标就会不同，这样不是我们所想要的结果