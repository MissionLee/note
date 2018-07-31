# JavaIO系统

```note
读书笔记
```



## I/O体系库类发生了不少变化

有许多历史库类，所以要了解一下发展的历史，从而知道什么时候使用哪些类

## File类

> 学习使用流之前，先学一下这个库类工具

- File：实际上用FilePath来代指这个类更贴切
  - File可以代表一个特定文件
  - 可以代表一个目录下的一组文件（此种情况下，调用 .list()方法，返回一个字符数组）

### 目录列表器-同时学习匿名内部类

```java
public class DirList(){
    public static void main(String[] args){
        File path = new File(".");
        String[] list;
        if(arg.length == 0)
            list=path.list();
        else 
            list = path.list(new DirFilter(args[0]));
        Arrays.sort(list,String.CASE_INSENSITIVE_ORDER);
        for(String dirItem:list){
            System.out.println(dirItem)
        }
    }
}
public class DirFilter implements FilenameFilter {
    private Pattern pattern;
    public DirFilter(String regex){
        pattern = Pattern.compile(regex);
    }

    public boolean accept(File dir, String name) {
        return pattern.matcher(name).matches();
    }

}
// 上面两个类完成了一个给定正则，匹配文件目录下的文件的方法，其中 FilenameFilter这个也可以用匿名内部类来实现
public class DirList(){
    public static FileNameFilter filter(final String regex){ //注意这个形参是final的
        return new FileFilter(){
            private Pattern pattern = Pattern.compile(regex);
            public boolean accept(File dir,String name){
                return pattern.matcher(name).matches();
            }
        }
    }
    public static void main(String[] args){
        File path = new File(".");
        String[] list;
        if(arg.length == 0)
            list=path.list();
        else 
            list = path.list(new DirFilter(args[0]));
        Arrays.sort(list,String.CASE_INSENSITIVE_ORDER);
        for(String dirItem:list){
            System.out.println(dirItem)
        }
    }
}
// 上面的匿名内部类，可以进一步的直接写在使用的地方
public class DirList(){
    public static void main(final String[] args){ //注意，这里我们把入参写成 final了
        File path = new File(".");
        String[] list;
        if(arg.length == 0)
            list=path.list();
        else 
            list = path.list(new FileFilter(){
            private Pattern pattern = Pattern.compile(args[0]);
            public boolean accept(File dir,String name){
                return pattern.matcher(name).matches();
            }
        });
        Arrays.sort(list,String.CASE_INSENSITIVE_ORDER);
        for(String dirItem:list){
            System.out.println(dirItem)
        }
    }
}
```

### 实用目录工具

> 书里面的一个DEMO

### 目录检查/创建

> 书里面一个DEMO

- 以上就是对FIle这个类的一些使用，可以查看File源码，学习相关内容

## 输入和输出 - 流

> Java中流库类让人迷惑的原因在于：创建单一的结果流，需要创建多个对象

- Java 1.0版本中，规定，所有流相关的始于两个类
  - InputStream
  - OutputStream
- InputStream的作用是表示从各种源产生的输入的类
  - 字节数组 - ByteArrayInputStream
  - String对象 - StringBufferInputStream
  - 文件 - FileInputStream
  - “管道” - PipedInputStream
  - 其他流组成的序列（流合并）- SequenceInputStream
  - 其他数据源（Internet连接等）
  - 每种数据源都有一个对应的子类
- OutputStream
  - 类似输入也有 字节数组，文件，管道，和一个装饰器

> 基于装饰器模式，可以组合 装饰器 + 对应的基础类 从而获得更便捷的方法。

- FilterInputStream
  - DataInputStream 可以与DataOutputStream配合，按照可移植的方式从流中读取基本类型数据
  - BufferedInputStream 
  - LineNumberInputStream 跟踪输入流中行号
    - getLineNumber
    - setLineNumber
  - PushbackInputStream
- FilterOutputStream
  - DataOutputStream
  - PrintStream
  - BufferedOutputStream

> Reader和Writer是 Java1.1中对IO的修改

- 提供兼容Unicode与面向字符的I/O功能
  - Java1.1向InputStream和OutputStream继承层次结构中添加了一些内容，以实现 “适配器”
    - InputStreamReader 把InputStream转为Reader
    - OutputStreamWriter 把OutputStream转为Writer
    - 几乎所有的原始IO都有对应的reader writer

> 缓冲输入文件

```java
// 功能： 打开一个文件用于字符输入，可以使用FileInputReader，其构造器接受String-路径，或者File
//        为了提升速度，我们希望带缓冲
public class BufferedInputFile{
    // filename 实际上是 fullFilePath
    public static String read(String filename) throws IOException{
        BufferedReader in = new BufferedReader(new FileReader(filename));
        //FileReader 内部使用了 FileInputStream
        // 然后再用它构造 BufferedReader
        // 从而获得 Buffer，提升效率，也可以使用其中 readLine 方法
        String s;
        StringBuilder sb = new StringBuilder();
        while((s=in.readLine())!=null)
            sb.append(s+"\n");
        in.close();
        return sb.toString();
            
    }
}

```

> 基本文件输出

```java
public class BasicFileOutput{
    static String file = "BasicFileOutputDemo";
    public static void main(String[] args) throws IOException{
        BufferedReader in = new BufferedReader(new StringReader(BufferedInputFile.read("filePath")));
        PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(file)));
        int lineCount = 1;
        String s;
        while((s=in.readLine())!=null)
            out.println(lineCount++ + ": " + s);
        out.close();
        System.out.println(BufferedInputFile.read(file));
    }
}
    
```

> PAGE 546 一个文件读写实用工具的代码

## 标准I/O

- System.in 
- System.out 
- System.err

out和err两个被包装成 printStream 队形

in没有包装

- 还有个重定向知识点

## 进程控制

## 新I/O

> JDK 1.4 java.nio.*  提高速度 - 在出现 nio的时候， 之前的io也用nio重新实现过了，也就是不直接使用nio也能获得 nio带来的升级

> 速度提升来自于结构更接近操作系统的I/O方式：通道+缓冲器

> 唯一直接与通道交互的缓冲器是 ByteBuffer ： java.nio.ByteBuffer是个非常基础的类，作用 -> 通过告知分配多少存储空间来创建 ByteBuffer对象，并且还有一个方法选择集，以原始的字节形式或基本数据类型输出和读取数据。但是没法输出读取对象，即使字符串也不可以。

