# 构造函数

构造函数与class同名，一般用来初始化参数，做一些预处理任务。

自己没定义，java提供默认构造函数，给所有变量赋初始值，自己定义了，就按照自己定义的来。

调用类的参数会传给构造函数。

# new 关键字

class-var = new  class-name(arg-list)

- 调用构造函数
- 把对象的引用，赋值给 class-var

内存空间有限，有可能 new的时候，没有内存可以用，如果出现这种情况=》 run-time exception

# garbage collection  垃圾回收

内存回收

不是实时回收

### 扩展问题

为什么 java的 内置类型不要用 new =》不是对象 =》 省事

### finalize（） method 

定义一个 method，当object 被 回收之前被调用，名为 =》 finalize() => 用来保证object 死的干干净净的 =》 比如让object打开的文件，观赏。

```java
protected void finalize(){
    //protected 外部不能引用这个
    //finalization code here
}
```