# Java魔法类：sun.misc.Unsafe

Unsafe类在jdk 源码的多个类中用到，这个类的提供了一些绕开JVM的更底层功能，基于它的实现可以提高效率。但是，它是一把双刃剑：正如它的名字所预示的那样，它是Unsafe的，它所分配的内存需要手动free（不被GC回收）。Unsafe类，提供了JNI某些功能的简单替代：确保高效性的同时，使事情变得更简单。

这篇文章主要是以下文章的整理、翻译。

http://mishadoff.com/blog/java-magic-part-4-sun-dot-misc-dot-unsafe/

- 1. Unsafe API的大部分方法都是native实现，它由105个方法组成，主要包括以下几类：

  - （1）Info相关。主要返回某些低级别的内存信息：addressSize(), pageSize()

  - （2）Objects相关。主要提供Object和它的域操纵方法：allocateInstance(),objectFieldOffset()

  - （3）Class相关。主要提供Class和它的静态域操纵方法：staticFieldOffset(),defineClass(),defineAnonymousClass(),ensureClassInitialized()

  - （4）Arrays相关。数组操纵方法：arrayBaseOffset(),arrayIndexScale()

  - （5）Synchronization相关。主要提供低级别同步原语（如基于CPU的CAS（Compare-And-Swap）原语）：monitorEnter(),tryMonitorEnter(),monitorExit(),compareAndSwapIn(),  putOrderedInt()

  - （6）Memory相关。直接内存访问方法（绕过JVM堆直接操纵本地内存）：allocateMemory(),copyMemory(),freeMemory(),getAddress(),getInt(),putInt()

2. Unsafe类实例的获取

Unsafe类设计只提供给JVM信任的启动类加载器所使用，是一个典型的单例模式类。它的实例获取方法如下：
```java
public static Unsafe getUnsafe() {
    Class cc = sun.reflect.Reflection.getCallerClass(2);
    if (cc.getClassLoader() != null)
        throw new SecurityException("Unsafe");
    return theUnsafe;
}
```
`非启动类加载器直接调用Unsafe.getUnsafe()方法会抛出SecurityException`（具体原因涉及JVM类的双亲加载机制）。

解决办法有两个，其一是通过JVM参数-Xbootclasspath指定要使用的类为启动类，另外一个办法就是java反射了。

```java
Field f = Unsafe.class.getDeclaredField("theUnsafe");
f.setAccessible(true);
Unsafe unsafe = (Unsafe) f.get(null);
```

通过将private单例实例暴力设置accessible为true，然后通过Field的get方法，直接获取一个Object强制转换为Unsafe。在IDE中，这些方法会被标志为Error，可以通过以下设置解决：

Preferences -> Java -> Compiler -> Errors/Warnings ->
Deprecated and restricted API -> Forbidden reference -> Warning

3. Unsafe类“有趣”的应用场景

（1）绕过类初始化方法。当你想要绕过对象构造方法、安全检查器或者没有public的构造方法时，allocateInstance()方法变得非常有用。
```java
class A {
    private long a; // not initialized value
 
    public A() {
        this.a = 1; // initialization
    }
 
    public long a() { return this.a; }
}
```
以下是构造方法、反射方法和allocateInstance()的对照

A o1 = new A(); // constructor
o1.a(); // prints 1
 
A o2 = A.class.newInstance(); // reflection
o2.a(); // prints 1
 
A o3 = (A) unsafe.allocateInstance(A.class); // unsafe
o3.a(); // prints 0
allocateInstance()根本没有进入构造方法，在单例模式时，我们似乎看到了危机。

（2）内存修改

内存修改在c语言中是比较常见的，在Java中，可以用它绕过安全检查器。

考虑以下简单准入检查规则：

class Guard {
    private int ACCESS_ALLOWED = 1;
 
    public boolean giveAccess() {
        return 42 == ACCESS_ALLOWED;
    }
}
在正常情况下，giveAccess总会返回false，但事情不总是这样

Guard guard = new Guard();
guard.giveAccess();   // false, no access
 
// bypass
Unsafe unsafe = getUnsafe();
Field f = guard.getClass().getDeclaredField("ACCESS_ALLOWED");
unsafe.putInt(guard, unsafe.objectFieldOffset(f), 42); // memory corruption
 
guard.giveAccess(); // true, access granted
通过计算内存偏移，并使用putInt()方法，类的ACCESS_ALLOWED被修改。在已知类结构的时候，数据的偏移总是可以计算出来（与c++中的类中数据的偏移计算是一致的）。

（3）实现类似C语言的sizeOf()函数

通过结合Java反射和objectFieldOffset()函数实现一个C-like sizeOf()函数。

public static long sizeOf(Object o) {
    Unsafe u = getUnsafe();
    HashSet fields = new HashSet();
    Class c = o.getClass();
    while (c != Object.class) {
        for (Field f : c.getDeclaredFields()) {
            if ((f.getModifiers() & Modifier.STATIC) == 0) {
                fields.add(f);
            }
        }
        c = c.getSuperclass();
    }
 
    // get offset
    long maxSize = 0;
    for (Field f : fields) {
        long offset = u.objectFieldOffset(f);
        if (offset > maxSize) {
            maxSize = offset;
        }
    }
 
    return ((maxSize/8) + 1) * 8;   // padding
}
算法的思路非常清晰：从底层子类开始，依次取出它自己和它的所有超类的非静态域，放置到一个HashSet中（重复的只计算一次，Java是单继承），然后使用objectFieldOffset()获得一个最大偏移，最后还考虑了对齐。

在32位的JVM中，可以通过读取class文件偏移为12的long来获取size。

public static long sizeOf(Object object){
    return getUnsafe().getAddress(
        normalize(getUnsafe().getInt(object, 4L)) + 12L);
}
其中normalize()函数是一个将有符号int转为无符号long的方法

private static long normalize(int value) {
    if(value >= 0) return value;
    return (0L >>> 32) & value;
}
两个sizeOf()计算的类的尺寸是一致的。最标准的sizeOf()实现是使用java.lang.instrument，但是，它需要指定命令行参数-javaagent。

（4）实现Java浅复制

标准的浅复制方案是实现Cloneable接口或者自己实现的复制函数，它们都不是多用途的函数。通过结合sizeOf()方法，可以实现浅复制。

static Object shallowCopy(Object obj) {
    long size = sizeOf(obj);
    long start = toAddress(obj);
    long address = getUnsafe().allocateMemory(size);
    getUnsafe().copyMemory(start, address, size);
    return fromAddress(address);
}
以下的toAddress()和fromAddress()分别将对象转换到它的地址以及相反操作。

static long toAddress(Object obj) {
    Object[] array = new Object[] {obj};
    long baseOffset = getUnsafe().arrayBaseOffset(Object[].class);
    return normalize(getUnsafe().getInt(array, baseOffset));
}
 
static Object fromAddress(long address) {
    Object[] array = new Object[] {null};
    long baseOffset = getUnsafe().arrayBaseOffset(Object[].class);
    getUnsafe().putLong(array, baseOffset, address);
    return array[0];
}
以上的浅复制函数可以应用于任意java对象，它的尺寸是动态计算的。

（5）消去内存中的密码

密码字段存储在String中，但是，String的回收是受到JVM管理的。最安全的做法是，在密码字段使用完之后，将它的值覆盖。

Field stringValue = String.class.getDeclaredField("value");
stringValue.setAccessible(true);
char[] mem = (char[]) stringValue.get(password);
for (int i=0; i < mem.length; i++) {
  mem[i] = '?';
}
（6）动态加载类

标准的动态加载类的方法是Class.forName()(在编写jdbc程序时，记忆深刻)，使用Unsafe也可以动态加载java 的class文件。

byte[] classContents = getClassContent();
Class c = getUnsafe().defineClass(
              null, classContents, 0, classContents.length);
    c.getMethod("a").invoke(c.newInstance(), null); // 1
getClassContent()方法，将一个class文件，读取到一个byte数组。
 
private static byte[] getClassContent() throws Exception {
    File f = new File("/home/mishadoff/tmp/A.class");
    FileInputStream input = new FileInputStream(f);
    byte[] content = new byte[(int)f.length()];
    input.read(content);
    input.close();
    return content;
}
动态加载、代理、切片等功能中可以应用。

（7）包装受检异常为运行时异常。

    
getUnsafe().throwException(new IOException());
当你不希望捕获受检异常时，可以这样做（并不推荐）。

（8）快速序列化

标准的java Serializable速度很慢，它还限制类必须有public无参构造函数。Externalizable好些，它需要为要序列化的类指定模式。流行的高效序列化库，比如kryo依赖于第三方库，会增加内存的消耗。可以通过getInt(),getLong(),getObject()等方法获取类中的域的实际值，将类名称等信息一起持久化到文件。kryo有使用Unsafe的尝试，但是没有具体的性能提升的数据。（http://code.google.com/p/kryo/issues/detail?id=75）

（9）在非Java堆中分配内存

使用java 的new会在堆中为对象分配内存，并且对象的生命周期内，会被JVM GC管理。

class SuperArray {
    private final static int BYTE = 1;
 
    private long size;
    private long address;
 
    public SuperArray(long size) {
        this.size = size;
        address = getUnsafe().allocateMemory(size * BYTE);
    }
 
    public void set(long i, byte value) {
        getUnsafe().putByte(address + i * BYTE, value);
    }
 
    public int get(long idx) {
        return getUnsafe().getByte(address + idx * BYTE);
    }
 
    public long size() {
        return size;
    }
}
Unsafe分配的内存，不受Integer.MAX_VALUE的限制，并且分配在非堆内存，使用它时，需要非常谨慎：忘记手动回收时，会产生内存泄露；非法的地址访问时，会导致JVM崩溃。在需要分配大的连续区域、实时编程（不能容忍JVM延迟）时，可以使用它。java.nio使用这一技术。

（10）Java并发中的应用

通过使用Unsafe.compareAndSwap()可以用来实现高效的无锁数据结构。

class CASCounter implements Counter {
    private volatile long counter = 0;
    private Unsafe unsafe;
    private long offset;

    public CASCounter() throws Exception {
        unsafe = getUnsafe();
        offset = unsafe.objectFieldOffset(CASCounter.class.getDeclaredField("counter"));
    }

    @Override
    public void increment() {
        long before = counter;
        while (!unsafe.compareAndSwapLong(this, offset, before, before + 1)) {
            before = counter;
        }
    }

    @Override
    public long getCounter() {
        return counter;
    }
}
通过测试，以上数据结构与java的原子变量的效率基本一致，Java原子变量也使用Unsafe的compareAndSwap()方法，而这个方法最终会对应到cpu的对应原语，因此，它的效率非常高。这里有一个实现无锁HashMap的方案（http://www.azulsystems.com/about_us/presentations/lock-free-hash ，这个方案的思路是：分析各个状态，创建拷贝，修改拷贝，使用CAS原语，自旋锁），在普通的服务器机器（核心<32），使用ConcurrentHashMap（JDK8以前，默认16路分离锁实现，JDK8中ConcurrentHashMap已经使用无锁实现）明显已经够用。