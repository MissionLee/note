https://www.cnblogs.com/sparkbj/articles/6208328.html

https://www.jianshu.com/p/7601ba434ff4

https://blog.csdn.net/wsscy2004/article/details/41723749

https://segmentfault.com/a/1190000012895516

https://www.2cto.com/kf/201712/705494.html

## ServiceLoader使用及原理分析
简介

我们都听说过SPI,SPI即Service Provider Interfaces.

试想，早先我们的app在图片加载的时候使用的是Volley,Volley的调用分散在项目中的各处。当我们想把Volley改为Glide的时候，就需要耗费巨大的人力成本。

那怎么解决上面的问题呢，`依赖倒置`，依赖接口而不是依赖具体的实现。Java提供了一种方式, 让我们可以对接口的实现进行动态替换, `这就是SPI机制`. SPI可以降低依赖。尤其在Android项目模块化中极为有用。比如美团和猫眼的项目中都用到了ServiceLoader。可以实现模块之间不会基于具体实现类硬编码，可插拔。

`ServiceLoader是实现SPI一个重要的类`。是jdk6里面引进的一个特性。在资源目录`META-INF/services`中放置提供者配置文件，然后在app运行时，遇到Serviceloader.load(XxxInterface.class)时，会到META-INF/services的配置文件中寻找这个接口对应的实现类全路径名，然后使用反射去生成一个无参的实例。

主要作用及使用场景
主要的使用场景是和第三方库解耦，解依赖。比如模块化的时候。比如接触第三方库依赖的时候。

使用
步骤如下:

- 定义接口 定义接口的实现

创建`resources/META-INF/services`目录 在上一步创建的目录下创建一个以接口名(类的全名) 命名的文件, 文件的内容是实现类的类名 (类的全名), 如:
在services目录下创建的文件是`com.stone.imageloader.ImageLoader` 文件中的内容为ImageLoader接口的实现类, 可能是com.stone.imageloader.impl.FrescoImageLoader 使用ServiceLoader查找接口的实现.
原理简单分析
>1.final，实现了Iterable

不能被继承，可以被迭代

>2.重点关注load方法
```java
public static  ServiceLoader load(Class service,
                                            ClassLoader loader)
    {
        return new ServiceLoader<>(service, loader);
    }
```
直接new一个新的ServiceLoader类，在实例化时会调reload方法实例化LazyIterator迭代类。

>3.关注LazyIterator的next方法
接口实现类的查找是在ServiceLoader迭代
时通过调用next和hasNext方法去完成。
```java
public boolean hasNext() {
            if (nextName != null) {
                return true;
            }
            if (configs == null) {
                try {
                    String fullName = PREFIX + service.getName();
                    if (loader == null)
                        configs = ClassLoader.getSystemResources(fullName);
                    else
                        configs = loader.getResources(fullName);
                } catch (IOException x) {
                    fail(service, "Error locating configuration files", x);
                }
            }
            while ((pending == null) || !pending.hasNext()) {
                if (!configs.hasMoreElements()) {
                    return false;
                }
                pending = parse(service, configs.nextElement());
            }
            nextName = pending.next();
            return true;
        }
 
        public S next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }
            String cn = nextName;
            nextName = null;
            Class<!--?--> c = null;
            try {
                c = Class.forName(cn, false, loader);
            } catch (ClassNotFoundException x) {
                fail(service,
                     "Provider " + cn + " not found", x);
            }
            if (!service.isAssignableFrom(c)) {
                ClassCastException cce = new ClassCastException(
                        service.getCanonicalName() + " is not assignable from " + c.getCanonicalName());
                fail(service,
                     "Provider " + cn  + " not a subtype", cce);
            }
            try {
                S p = service.cast(c.newInstance());
                providers.put(cn, p);
                return p;
            } catch (Throwable x) {
                fail(service,
                     "Provider " + cn + " could not be instantiated: " + x,
                     x);
            }
            throw new Error();          // This cannot happen
        }
```
`hasnext`

我们注意到：String PREFIX = “META-INF/services/”;service.getName()得到接口的全名（包名+接口名）。调用getResources(fullName)得到配置文件的URL集合（可能有多个配置文件）。通过这个方法parse(service, configs.nextElement());，参数是接口的Class对象和配置文件的URL来解析配置文件，返回值是配置文件里面的内容，也就是实现类的全名（包名+类名）。

`parse`

是解析配置文件，注意：返回值是一个数组，里面就是names，实现类的全名。
之后
利用Java的反射机制，根据类的全名类创建对象。
这个c = Class.forName(cn, false, loader);，第一个参数是实现类的全名，第三个是类加载器，返回值是实现类的Class对象。再看下面的S p = service.cast(c.newInstance());作用是创建实例并强转成接口的类型，最后返回。

缺点及改进
- 1.ServiceLoader也算是使用的延迟加载，但是基本只能通过遍历全部获取，也就是接口的实现类全部加载并实例化一遍。如果你并不想用某些实现类，它也被加载并实例化了，这就造成了浪费。
- 2.获取某个实现类的方式不够灵活，只能通过Iterator形式获取，不能根据某个参数来获取对应的实现类。
- 3.不是单例。

与classloader的区别
JVM利用ClassLoader将类载入内存，这是一个类声明周期的第一步（一个java类的完整的生命周期会经历加载、连接、初始化、使用、和卸载五个阶段。