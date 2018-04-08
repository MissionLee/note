最近在Java7高级编程中，看到了@SafeVarargs的使用，其调用过程大致如下：

```java
package safeVar;  
  
import java.util.ArrayList;  
  
public class VarargsWaring {  
    @SafeVarargs  
    public static<T> T useVarargs(T... args){  
        System.out.println(args.length);  
        return args.length > 0?args[0]:null;  
    }  
}  
```

然后调用如下：
```java
package safeVar;  
  
import java.util.ArrayList;  
  
public class safe {  
  
    public static void main(String[] args) {  
        System.out.println(VarargsWaring.useVarargs(new ArrayList<String>()));  
    }  
  
}  
```
！！  下面这个讲解 水平不怎么样 ，可以再搜索以下

为什么会使用@SafeVarargs呢？
其大致原因如下：

     可变长度的方法参数的实际值是通过数组来传递的，而数组中存储的是不可具体化的泛型类对象，自身存在类型安全问题。因此编译器会给出相应的警告消息。



输出[]



记录下来，供以后使用