# Simple Program

## Entering the Program

- main class的名称，必须和filename 相同=》 Java is case sensitive
- Java 程序从main开始执行

```java
public class helloworld {
    public static void main(String[] args){
    // public => 程序其他部分访问权限
    // static => 允许 main（）在此class的object创建之前就可以被嗲用
    // vode => 没有返回
        System.out.print("hello world 220171211");
        // system 是与定义好的与系统交互的接口
        //out是这个接口下的输出流

    }
}
```