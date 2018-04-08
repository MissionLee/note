# HBase 中文实战

## 基础

### 一些基本信息

- 配置信息: `hbase-env.sh`和`hbase-site.xml`
- HBase自带的简单管理界面 localhostr:60010
- HBase Shell是一个封装了Java客户端的JRuby应用软件: 支持 交互模式 和 批处理模式

### 存储数据

- 无模式存储 schema-less
- HBase存储多个时间版本,可以`调整为只存储一个版本,但不要禁用这个特性`

## Java HBase

### 一些基本内容

```java
Configuration myConf = HBaseConfiguration.create();
// 从类路径里面的hbase-site.xml获取配置信息
HTableInterface userTbale = new HTable(myConf,"user");
// 构造函数HTable读取默认配置信息定位HBase,然后创建user表
```

也可以手动设置参数

```java
myConf.set("kew","value");
// 手动设置配置信息
```

- HBase客户端应用需要有一份HBase配置信息来访问HBase:`Zookeeper quorum`地址,可以使用 手工配置

```java
MyConf.set("hbase.zookeeper.quorum","serverip");
// 如果没有指定,客户端会使用默认配置信息,把localhost作为Zookeeper quorum地址
```

`使用连接池`是更常见的方法

```java
HTable pool = new HTablePool();
HTableInterface userTable= pool.getTable("user");
//某些操作
userTable.close();
```

### 数据操作

Hbase表的行有唯一标识符,叫做行键rowkey,其他部分用来存储HBase表里的数据
和数据操作有关的HBase API成为(command).有五个基本命令来访问HBase.`Get,Put,Delete,Scan,Increment`

```java
Put p = nwe Put(Bytes.toBytes("MissingLee"))
//!!! Bytes.toBytes() 属于 org.apache.hadoop.hbase.util.Bytes
// HBase中所有数据都是作为原始数据(raw data)使用字节数组的性质存储的,行键也是如此.Java中公用类Bytes用来转换各种Java数据类型
// 注意此时Put实例还没有插入到表中,重视创建了对象
```

下面给`MissingLee`添加一些信息

```java
p.add(Bytes.toBytes("info"),Bytes.toBytes("name"),Bytes.toBytes("MissingLee"));
//给 info:name 单元存入 MissingLee p在上一步制订了行键为MissingLee 然后在这里 第一个参数:列簇,第二个参数:列,第三参数:值
```

一个单元的存储坐标为`[rowkey,column family,column qualifier]`

最后把这条数据提交给Hbase

```java
userTable.put(p);
userTable.close();
```

工作机制:HBase写路径

    默认情况下,执行写入会写到两个地方:遇写式日志 write-ahead log (也称HLog/WAL)和MemStore.Hbase默认写入动作记录到这两个地方,以保证数据持久化,只有当这两个地方的变化信息都写入并确认后,才认为写动作完成.
    MemStore是内存里的写入缓冲区,Hbase中数据在永久写入硬盘前在这里积累,MemStore填满后,数据写入硬盘,生成一个HFile.HFile是HBase使用的底层存储格式.HFile对应于列族,一个列族何以有多个HFile,单一个HFile不能存储多个列族.集群每个节点的每个列族有一个MenStore
    作为MenStore的保障,HBase在写动作完成之前先写入WAL,集群中每台服务器维护一个WAL来记录发生的变化.WAL是底层文件系统上的一个文件.知道WAL新纪录成功写入后,写动作才被认为成功完成.

如果Hbase宕机,没有从MenStore写到HFile的数据可以通过WAL`自动恢复`

为了提升性能可以禁用,但是`不推荐`

```java
Put p = new Put();
p.setWriteToWAL(false);
```

读数据

```java
Get g = new Get(Bytes.toBytes("MissingLee"));
Result r = usersTable.get(g);
// 此时的结果 r 可能包含太多不需要的数据
// 同样 addColumn() / addFamily()可以定位数据
g.addColumn(Bytes.toBytes("info"),Bytes.toBytes("password"))
Resutl r = usersTable.get(g);
// 检索特定值，从字节转换会字符串，如图所示
Get g = new Get(Bytes.toBytes("MissingLee"));
g.addFamily(Bytes.toBytes("info"));
Resutl r = usersTable.get(g);
byte[] b = r.getValue(Bytes.toBytes("info"),Bytes.toBytes("email"));
String email = Bytes.toString(b);
```

读数据工作机制： Hbase 读路径

最快读数据，通用原则是数据保持有序，并尽可能保存在内存里。HBase实现这两个目标，多数情况读操作可以做到毫秒级。Hbase读动作必须重新衔接持久化到硬盘的HFile和内存中MemStore里的数据。Hbase在读操作上使用LRU`最近最少使用算法`缓存技术。这种缓存也叫BlockCache，和MemStore在一个JVM堆里。BlockCache设计用来保存从HFile里读入内存的频繁访问的数据，避免硬盘读。每个列族都有自己的BlockCache。
`掌握BlockCache是优化HBase性能的一个重要部分。`BlockCache中的Block是Hbase从硬盘完成一次读取的数据单位，`HFile物理存放形式是一个Block序列外加这些Block的索引`。这一位置，`从HBase读取一个Block需要现在索引上超找一次该Block，然后从硬盘读出`。Block是建立索引的最小数据单位，也是从硬盘读取数据的最小数据单位。Block大小按烈祖设定，默认64KB。根据使用场景你可能会调大或者调小该值.`如果主要用于随机查询,你可能需要细粒度的Block索引,小一点的Block更好,Block变小会导致索引变大,进而消耗更多内存,如果你经常执行顺序扫描,一次读多个Block,更大一些的Block更好一些.Block变大一位置索引项变少,索引变小,因此更节省内存.
从HBase中读出一行,首先检车MemStore等待修改的队列,然后检查BlockCache看包含该行的Block是否最近被访问过,最后访问硬盘上对应的HFile.(HBase内部做了很多事情,这里是概括).

删除数据

```java
Delete d = new Delete(Bytes.toBytes("MissingLi"));
userTable.delete(d);
//指定更详细位置同上
d.deleteColumns(Bytes.toBytes("info"),Bytes.toBytes("email"));
```

deleteColumn()方法从行中删除一个单元.和deleteColumn()方法不同.后者删除单元的内容.

合并:Hbase后台工作.
Delete命令并不立即删除内容.实际上,只是打上删除标记.就是说,针对那个内容的一条新"墓碑",tombstone记录写入进来,作为删除的标记.墓碑记录用来删除标志的内容不能再Get/Scan命令中返回结果.因为HIFle文件是不能改变的,知道执行一次大合并(major compaction),这些墓碑记录才会被处理,被删除数据占用的空间才会被释放.
合并分为两种:`大合并(major conpaction)和小合并(minorco mpaction)`.两者将会重整存储在HFile里面的数据.小合并把多个HFile合并成一个大HFile.`因为都一条完整的行,可能引用很多文件,系那只HFile的数将对于读性能很重要`.
执行合并时,Hbase读出已有的多个HFile内容,把记录写入一个新的文件.然后把新文件设置为激活状态,删除构成这个新文件的所有老文件.HBase根据文件的号码和大小决定合并哪些文件.小合并设计出发点是轻微影响HBase性能,所涉及的HIFle数量有上线.这些都可以设置.
大合并将处理给定region的一个列族的所有HFile.大合并完成后,这个列族的所有HFile合并成一个文件.可以从Shell中手工出发整个表(或者特定region)的大合并.这个动作相当耗费资源,不要经常使用.另一方面,小合并是轻量级的,可以频繁发生,大合并是HBase清理被删除记录的唯一机会.因为我们不能保证被删除的记录和墓碑标记记录在一个HFile里面.大合并是唯一的机会,HBase可以确保同时访问到两种记录.

有时间版本的数据

HBase除了无模式数据库意外,还有时间版本的概念(versioned).如
```java
List<KeyValue> passwords = r.getColumn(Bytes.toBytes("info"),Bytes.toBytes("password"));
b = passwords.get(0).getValue();
String currentPassword = Bytes.toString(b);
//当前版本密码
b = passwords.get(1).getValues();
String prevPassword = Bytes.toString(b);
//前一个版本密码
```

每次你在单元上执行操作,HBase都隐式的存储一个新时间版本.单元的信件,修改,删除同样如此.Get请求根据提供的参数调出相应版本.时间版本是访问特定单元的最后一个坐标.当没有设定时间版本时,HBase以毫秒为单位使用当前时间,所以版本数字用长整型long表示.HBase默认只存储3个版本,这可以给予列族来设置.单元数据里的每个版本提交一个KeyValue实力给Result.可以使用

```java
long version = passwords.get(0).getTimestamp();
```

如果一个单元的版本超过最大数量,多出的记录在下一次大合并时会扔掉.
删除的时候,deleteColumns()[带s]处理小于制定时间版本的所有KeyValue,不指定时间版本是,默认使用now.deleteColumn()[不带s]只删除一个指定版本.

- 数据坐标

使用:行健,列族,列限定符,时间版本 四个坐标确定一个值

使用HbaseAPI检索数据,不需要提供全部坐标.
如果省略了时间版本, HBase返回数据值多个版本的映射集合.HBase允许你在一次操作中的到多个数据,按照坐标的降序排列.那么你可以把HBase看做一个键值数据库,打的数据值是映射集合或者映射集合的集合.

- 处理方法

```java
//创建一个数据模型
package HBaseIA.TwitBase.model;

public abstract class User{
    public String user;
    public String name;
    public String email;
    public String password;

    @Override
    //@Override是伪代码,表示重写
    //System.Object是所有类型的基类,这个基类里面有个toString方法,
    //public virtual string ToString(){
    //  return this.GetType().FullName.ToString();
    //}
    //我们希望 toString 返回自定义的值,所以这里重写一下这个方法
    public String toString(){
        return String.format("<User: %s,%s,%s>",user,name,email);
    }
}
//在一个类中封装Hbase访问操作
package HBaseIA.TwitBase.hbase;
// . 省略一些

public class UsersDAO {
    public static final byte[] TABLE_NAME = Bytes.toBytes("users");
    public static final byte[] INFO_FAM = Bytes.toBytes("info");
    private static final byte[] USER_COL = Bytes.toBYTES("user");
    //等等其他需要用的也先准备好
    // NAME_COL EMAIL_COL PASS_COL TWEETS_COL

    private HTablePool pool;
    //连接池
    //-查到资料HTablePool在新版本中已经不被使用了,改用统一的开发api
    //HConnection connection = HConnectionManager.createConnection(Configuration);
    //HTableInterface table = connection.getTable("")

    public UserDAO(HTable pool){//- 和类名相同的叫构造方法
        this.pool = pool;
        //让调用环境来管理连接池
        //-把参数复制给成员变量
    }

    private static Get mkGet(String user){
        Get g = new Get(Bytes.toBytes(user));
        g.addFamily(INFO_FAM);
        return g;
        //使用辅助方法来封装常规工作
    }

    private static Put mkPut(User u){
        Put p = new Put(Bytes.toBytes(u.user));
        p.add(INFO_FAM,USER_COL,Bytes.toBytes(u.user));
        p.add(INFO_FAM,USER_COL,Bytes.toBytes(u.name));
        p.add(INFO_FAM,USER_COL,Bytes.toBytes(u.email));
        p.add(INFO_FAM,USER_COL,Bytes.toBytes(u.password));
        return p;
        //使用辅助方法来封装常规工作
    }

    private static Delete mkDel(String user){
        Delete d = new Delete(Bytes.toBytes(user));
        return d;
        //使用辅助方法来封装常规工作
    }

    public void addUser(String user, String name , String email, String password)
        throws IOException {
            HTableInterface users = pool.getTable(TABLE_NAME);
            // HTableInterface 用来连接某个表
            Put p = mkPut(new user(user,name,email,password));
            // user 是之前的一个
            users.put(p);
            users.close();
    }
    public Hbase.TwitBase.model.User getUser(String user) throws IOException {
            HTableInterface users = pool.getTable(TABLE_NAME);
            //创建制定表的实例 名为users ,用于数据操作
            Get g = mkGet(user);
            //mkGet是封装了的Get=>把user转成二进制作为rowkey,并添加默认的列族为查询条件
            Result result = users.get(g);
            if(result.isEmpty()){
                return null;
            }
            User u = new User(result);
            //调用 User -> 代码在下方,智能识别传入的是Result的实例,还是byte[],或者String
            users.close();
            return u;
    }
    public void deleteUser(String user) throws IOException{
        HTableInterface user = pool.getTable(TABLE_NAME);
        Delete d = mkDel(user);
        user.delete(d);
        user.close();
    }
    // page 60
    private static class User extends HBaseIA.TwitBase.model.User{
        // 注意这个User集成了最上面的那个名为 HBaseIA.TwitBase.model的包里面的User
        //- 注意这里是个类中类
        //根据Result构造model.user实例
        private User(Result r){
            //传入 Result 示例的时候 转而调用 其他构造方法
            //this() 在构造方法的第一句 - 这个知识点 和 super()一起看
            //用户不能再同一个方法内调用多次this()或super()，同时为了避免对对象本身进行操作时，对象本身还未构建成功(也就找不到对应对象),所以对this()或super()的调用只能在构造方法中的第一行实现，防止异常
            //在普通成员方法中不能使用,防止重创建一个对象
            this(
                //通过 this调用另一个构造方法
                r.getValue(INFO_FAM,USER_COL),
                r.getValue(INFO_FAM,NAME_COL),
                r.getValue(INFO_FAM,EMAIL_COL)
                r.getValue(INFO_FAM,PASS_COL),
                r.getValue(INFO_FAM,TWEETS_COL) == NULL
                    ? Bytes.toBytes(0L)
                    : r.getValue(INFO_FAM,TWEETS_COL)
            );
        }
        private User(byte[] user,byte[] name,byte[] email, byte[] password,byte[] tweetCount){
            //传入二进制的时候 的构造方法->转而调用其它构造方法
            this(Bytes.toString(user),
                Bytes.toString(name),
                Bytes.toString(email),
                Bytes.toString(password)
            );
            this.tweetCount = Bytes.toLong(tweetCount);
        }
        private User(String user,String name,String email,String password){
            //其他构造方法,最终都是用的这个
            this.user = user;
            this.name = name;
            this.email = email;
            this.password = password;
        }
    }
}
//最后一部分是 main()方法
package HBaseIA.TwitBase;
// 导入其他必要的库
public class UserTool{
    public static final String usage = "[程序说明书]";
    public static void main(String[] args) throw IOException{
        if(args.length == 0 || "help".equals(args[0])){
            //如果没有传入参数,或者传入help,那么打印 usage
            //usage 就是程序的说明书
            System.out.println(usage);
            System.exit(0);
        }
        HTablePool pool = new HTablePool();
        //创建一个连接池
        UserDAO dao = new UserDAO(pool);
        //使用这个连接池建立连接
        if("get".equals(args[0])){
            //如果参数0 为get,那么调用 dao.getUser
            System.out.println("Getting user "+args[1]);
            User u = dao.getUser(args[1]);
            System.out.println(u);
            //打印对象默认调用该对象的toString方法,User的toString是自己重写过的,见最上面
        }
        if("add".equals(args[0])){

        }
        if("list".equals(args[0])){

        }
        pool.closeTablePool(UsersDAO.TABLE_NAME);
    }
}
```

- 数据模型

正如你看到的那样,HBase进行数据建模的方式和关系型数据库有些不同.关系型数据库围绕表,列,和数据类型.[数据的形态使用严格的规则]
HBase设计上没有严格的形态的数据.数据记录可能包含一致的列,不确定大小等.这种数据称为`半结构化数据`(senistructured data)
在逻辑模型里针对结构化或半结构化数据的导向影响了数据系统物理模型的设计.关系型数据库假定表中的记录都是结构化和高度有规律的.因此在物理实现时,利用这一点相应优化硬盘上的存放格式和内存里的结构.同样,HBase也会利用所有存储数据是半结构化的特定.随着系统发展,物理模型上的不同也会影响逻辑模型.因为这种双向紧密的联系,优化数据系统必须深入理解逻辑模型和物理模型.Hbase的物理模型设计上适合于物理分散存放,这一点也影响了逻辑模型.此外,这种物理模型设计迫使HBase放弃一些特性,特别是,不能实施关系约束(constraint)并且不支持多行事务(multirow transaction).

逻辑模型:有序映射的映射集合

HBase中使用的逻辑数据模型有许多有效的描述,如:键值数据库.我们考虑一种描述:`有序映射的映射`

物理模型:面向列族

HBase中列族是物理模型中一个层次.每个列族在硬盘上有自己的HFile集合.这种物理上的隔离,允许在列族底层HFile层面上分别进行管理,进一步考虑到合并,每个列族的HFile都是独立管理的.
`列族的存储是面向列的,一行中,一个列族的数据不一定存放在同一个HFile里面.唯一的要求是,一行中列族的数据需要物理存放在一起.`

- 扫描表

HBase没有查询命令(query),查找某个特定值的记录的唯一办法是,使用扫描(scan),读出表的某些部分,再使用过滤(filter)来得到有关记录.可以想到,扫描返回的几率是排序好的.

```java
Scan s = new Scan();
```

例子:查询T开头的ID的用户

```java
Scan s = new Scan(Bytes.toBytes("T"),Bytes.toBytes("U"));
```

设计用于扫描的表

就像设计关系模式一样,为HBase表设计模式(Schema)也需要考虑数据形态和访问模式.推贴数据访问模型不同于用户,因此我们为他们建立自己的表.

```java
// 使用HBaseAdmin对象的一个实例来执行表操作
Configuration conf = HBaseConfiguration.create();
HBaseAdmin admin = new HBaseAdmin(conf);
//默认HTable和HTablePool构造函数帮我们隐藏了一些细节,下面开始创建一个表
HTableDescriptor desc = new HtableDescriptor("twits");
HColumnDescriptor c = new HColumnDescriptor("twits");
c.setMaxVersions(1);
desc.addFamily(c);
admin.createTable(desc);
//建立名为 twits 列族 twits 坂本数为1的表
//我们选择用户名+时间戳作为行键
Put put = new Put(Bytes.toBytes("Missingli" + 112334645646567L));//这个时间是我瞎打的
put.add(Bytes.toBytes("twits"),Bytes.toBytes("dt"),Bytes.toBytes(13456345624L));
put.add(Bytes.toBytes("twits"),Bytes.toBytes("twit"),Bytes.toBytes("Hello everybody!"));
```

注意:用户ID是个变长字符串,当你使用符合行键时,这会带来一些麻烦,因为你需要某种字符来切分出用户ID.`一种变通的办法是对行键的变成类型部分做散列(hash)处理,选择一种散列算法,生成固定长度的值.`因为想要基于用户分组存储不同的推贴,MD5算法是种好选择.不过`这种情况下记得要把原本的ID存到一个字段里面,防止有时候需要用到.`

```java
int longLength = Long.SIZE / 8;
//一个字节八位 => 8
byte[] userHash = Md5Utils.md5sum("Missingli");
// !!! 看起来这个 Md5加密是 自己封装的东西
byte[] timestamp = Bytes.toBytes(-1*112334645646567L);
byte[] rowKey = new byte[Md5Utils.MD5_LENGTH + longLength];
//MD5_LENGTH + longLength 长度的 byte[]数组
int offset = 0;
offset = Bytes.putBytes(rowKey,offset,userHash,0,userHash.length);
Bytes.putBytes(rowKey,offset,timestamp,0,timestamp.length);
//public static int putBytes(byte[] tgtBytes,
//                           int tgtOffset,
//                           byte[] srcBytes,
//                           int srcOffset,
//                           int srcLength)
//Put bytes at the specified byte array position.
//Parameters:
//tgtBytes - the byte array
//tgtOffset - position in the array
//srcBytes - array to write out
//srcOffset - source offset
//srcLength - source length
//Returns:
//incremented offset
Put put = new Put(rowKey);
put.add(Bytes.toBytes("twits"),Bytes.toBytes("user"),Bytes.toBytes("Missingli"));
put.add(Bytes.toBytes("twits"),Bytes.toBytes("twit"),Bytes.toBytes("Hello everyone"))
```

一般来说,你会先用到最新推贴,HBase在物理模型里,按照行键顺序存储行.你可以利用这个特性,在行键里包括推贴的时间戳,并诚意-1,就可以得到最新的推贴.

扫描执行

使用用户ID作为twits表行键的第一部分证明是好办法.可以基于用户已自然行的顺序有效地生成数据桶bucket.
在这种行键设计情况下,scan的使用:

```java
byte[] userHash = Md5Utils.md5sum(user);
byte[] startRow = Bytes.padTail(userHash,longLength);
byte[] stopRow = Bytes.padTail(userHash,longLength);
//public static byte[] padTail(byte[] a,
//                             int length)
//Parameters:
//a - array
//length - new array size
//Returns:
//Value in a plus length appended 0 bytes
stopRow[Md5Utils.MD5_LENGTH-1]++;
Scan s = new Scan(startRow,stopRow);
ResultScanner rs = twits.getScanner(s)
```

本例中,通过对行键中用户ID部分的最后一个字符加1来禅城停止键.扫描器返回包括起始键但是不包括停止键的记录.因此匹配到推贴.然后通过一个循环获得内容

```java
for(Result r:rs){
    //extract the username
    byte[] b = r.getValue(
        Bytes.toBytes("twits"),
        Bytes.toBytes("user")
    );
    String user = Bytes.toString(b);
    //extract the twit
    b = r.getValue(
        Bytes.toBytes("twits"),
        Bytes.toBytes("twits")
    );
    String message = Bytes.toString(b);
    //extract the timestamp
    b = Array.copyOfRange(
        r.getRow();
        Md5Utils.MD5_LENGTH,
        Md5Utils.MD5_LENGTH + longLength
    );
    DateTime dt = new DataTime(-1*Bytes.toLong(b));
}
```

循环中唯一需要处理的是分离出时间戳,并把字节数组byte[]转换成合适的数据类型.

扫描器缓存

在Hbase的设置里,每次扫描RPC调用得到一批行数据.这可以在扫描对象上使用setCaching(int)在每个扫描器(scanner)层次上设置,也可以在hbasesite.xml配置文件里使用`HBase.client.scanner.caching`属性来设置.如果缓存值设置为n,每次RPC调用扫描器返回n行,然后这些数据还存在客户端.这个设置的`默认值是1`,这意味着客户端对HBase的每次RPC调用在扫描整张表后仅仅返回一行.这个数字很保守,`可以调整它,获得更好的性能`.但是该值`设置过高意味着客户端和HBase的交互会出现较长暂停,会导致HBase端超时.`
ResultScanner接口也有一个nest(int)调用,可以用来要求返回扫描的虾米那n行.这是API层面提供的便利,与为了获得那n行数据,客户端对HBase的RPC调用次数无关.
在内部机制中,ResultScanner使用了多次RPC调用来满足这个请求,每次RPC调用返回的行数`只取决于扫描器设置的缓存值`

使用过滤器

并不总能设计一个行键来完美的匹配你的访问模式.有时你的使用场景需要扫描HBase的一组数据,但是只返回他的子集给客户端.这时使用`过滤器(filter)`.为你的Scan对象增加过滤器,如下所示:

```java
Filter f = ..
Scan s = new Scan();
s.setFilter(f);
```

`过滤器实在HBase服务器端上面而不是客户端执行判断动作`.当你在Scan里设定Filter时,HBase使用它来决定一个记录是否返回.这样避免许多不必要的数据传输.这个特性在服务器上执行过滤动作而不是把负担放在客户端.
使用过滤器需要实现`org.apache.hadoop.hbase.filter.filter`接口.HBase提供许多过滤器,自己实现过滤器也很容易.

为了过滤所有提到 `TwitBase` 的推贴,你可以结合 RegexStringComparator使用ValueFilter;

```java
Scan s = new Scan();
s.addColumn(Bytes.toBytes("twits"),Bytes.toBytes("twit"));
Filter f = new ValueFilter(
    CompareOp.EQUAL,
    new RegexStringComparator(".*TwitBase.*")
);
s.setFilter(f);
```

HBase也提供一个过滤器构造类.ParseFilter对象实现了一种查询语言,可以用来构造Filter实例.可以用一个表达式构造同样的TwitBase过滤器;

```java
Scan s = new Scan();
s.addColumn(TWITS_FAM,TWIT_COL);
String expression = "ValueFilter(=,'regxString:.*TwitBase.*)";
ParseFilter p = new ParseFilter();
Filter f = p.parseSimpleFilterExpression(Bytes.toBytes(expression));
s.setFilter(f);
```

在这两个例子中,数据在到达客户端之前在region中编译使用了正则表达式.
HBase中过滤器可以应用到行键,列限定符或者数据值.也可以使用FilterList和WhileMatchFilter对象组合多个过滤器.过滤器允许对数据分页处理,限制扫描器返回的行数.

- 原子操作

HBase操作库里的最后一个命令是列值递增(Increment Column Value).他有两种使用方式.像其他命令那样使用Increment命令对象,或者作为HTableInterface的一个方法是用.我们使用HTableInterface的方式,因为语义更加直观.我们使用它来保存每个用户发布推贴总数

```java
long ret = userTable.incrementColumnValue(
    Bytes.toBytes("Missingli"),
    Bytes.toBytes("info"),
    Bytes.toBytes("tweet_count"),
    1L
);
```

该命令不先读出HBase单元就可以改变存储其中的值.`数据操作在HBase服务器上`,而不是客户端,所以速度快.当其他客户端也访问同一个单元时,这样避免了出现紊乱状态.你可以把ICV(increment column value)等同于Java的AtomicLong.addAndGet()方法.递增值可以使任何Java.Long类型值,无论正负.
`注意,这个暑假不是存储在twits表,而是users表中.`存在users表的原因是不希望这个信息成为扫描的一部分.存在twits表里会让常用的访问模式很不方便.
就像java的原子类族,HTableInterface也提供checkAndPut()和checkAndDelete()方法.他们可以维持原子语义的同时提供更精确的控制.
`可以用checkAndPut()来实现incrementColumnValue()方法`:

```java
Get g = new Get(Bytes.toBytes("Missingli"));
Result r = usersTable.get(g);
long curVal = Bytes.toLong(
    r.getColumnLatest(
        Bytes.toBytes("info"),
        Bytes.toBytes("tweet_count")
    ).getValue()
);
long inVal = curVal + 1;
Put p = new Put(Bytes.toBytes("Missingli"));
p.add(
    Bytes.toBytes("info"),
    Bytes.toBytes("tweet_count"),
    Bytes.toBytes(incVal);
)
userTable.checkAndPut(
    Bytes.toBytes("missingli"),
    Bytes.toBytes("info"),
    Bytes.toBYtes("tweet_count"),
    Bytes.toBytes(curVal),
    p
)
```

该实现有点长但是可以试试.checkAndDelete()方式与此类似.

- ACID语义
  - Atomicity 原子性 - 要么全都完成,要么全都不完成.操作成功则整个成功
  - Consistency 一致性 - 把系统从一个有效状态带入另一个有效状态的操作属性,如果操作是系统出现不一致,操作不会被执行或者被退回
  - Isolation 隔离性 两个操作执行互不干扰
  - Durability 持久性 - 一旦数据写入,确保可以读回并且不会在系统正常操作一段时间后丢失.

- 总结

HBase是一种专门为半结构化数据(semistructured)和水平可扩展性(horizontal scalability)设计的数据库.他把数据存储在表里.在表里,数据按照思维坐标系统来组织;HBase是无模式数据库,只需要提前订一列族.他也是无类型数据库,把所有数据不加解释的按照自己数组存储.有五个基本命令`Get,Put,Delete,Scan,Increment`.基于非行键值查询HBase的唯一办法是通过`带过滤器`的扫描.

- Hbase Java API 通过HTableInterface来使用表
- 表链接可以直接通过构造HTable实例来建立,但是开销大
- 优选HTablePool,因为可以重复使用链接
- 表通过HbaseAdmin,HTableDescriptor,HColumnDescriptor类的实例来新建和操作
- 五个命令通过相应的命令对象来使用:Get,Put,Delete,Scan,Increment.命令送到HTableInterface实例来执行
- 递增Increment有另外一种方法,是用HTableInterface.incrementVolumnValue()方法.
- 执行Get,Scan和Increment命令的结果返回到Result和ResultScanner对象的实例.
- 一个KeyValue实例代表一条返回记录

- 预期的数据访问模式对HBase的模式设计有很大影响,行键是HBase中唯一的全局索引坐标,因此查询经常通过行键扫描来实现,符合行键是支持这种扫描的常见做法.行键值经常是均衡分布的.诸如`MD5或SHAI`等散列算法通常来实现这种均衡分布.