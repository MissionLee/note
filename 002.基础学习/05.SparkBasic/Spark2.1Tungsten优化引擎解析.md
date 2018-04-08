1.1      概述
Spark作为一个一体化多元化的大数据处理通用平台，性能一直是其根本性的追求之一，Spark基于内存迭代（部分基于磁盘迭代）的模型极大的满足了人们对分布式系统处理性能的渴望，Spark是采用Scala+ Java语言编写的，所以运行在JVM平台。当然JVM是一个绝对伟大的平台，因为JVM让整个离散的主机融为了一体（网络即OS），但是JVM的死穴GC反过来限制了Spark（也就是说平台限制了Spark），所以Tungsten聚焦于CPU和Memory使用，以达到对分布式硬件潜能的终极压榨！

对Memory的使用，Tungsten使用了Off-Heap，也就是在JVM之外的内存空间（这就好像C语言对内存的分配、使用和销毁），此时Spark实现了自己的独立的内存管理，就避免了JVM的GC引发的性能问题，其实也避免了序列化和反序列化。

对Memory的管理，Tungsten提出了Cache-awarecomputation，也就是说使用对缓存友好的算法和数据结构来完成数据的存储和复用；

对CPU的使用，Tungsten提出了CodeGeneration，其首先在Spark SQL使用，通过Tungsten要把该功能普及到Spark的所有功能中；（这里的CG就类似于Android的art模式）。

JAVA操作的数据一般是自己的对象，但像C,C++语言可以操作内存中的二进制数据一样，JAVA同样也可以。Tungsten的内存管理机制独立于JVM，所以Spark操作数据的时候具体操作的是Binary Data，而不是JVM Object！而且还免去了序列化和反序列化的过程！

(一)  内存管理和二进制处理（Memory Management and Binary Processing）：　　

1、避免使用非transient的Java对象（它们以二进制格式存储），这样可以减少GC的开销。

2、通过使用基于内存的密集数据格式，这样可以减少内存的使用情况。

3、更好的内存计算（字节的大小），而不是依赖启发式。

4、对于知道数据类型的操作（例如DataFrame和SQL），我们可以直接对二进制格式进行操作，这样我们就不需要进行系列化和反系列化的操作。

(二)  缓存感知计算（Cache-aware Computation）

对aggregations,joins和Shuffle操作进行快速排序和Hash操作。

(三)  代码生成（Code Generation）

1、更快的表达式求值和DataFrame/SQL操作。

2、快速系列化

Tungsten的实施已有2个阶段：1.6.X基于内存的优化，2.X基于CPU的优化。还优化Disk IO、Network IO，主要针对Shuffle。

Apache Spark已经非常快了，但是我们能不能让它再快10倍？这个问题使我们从根本上重新思考Spark物理执行层的设计。当调查一个现代数据引擎（例如Spark、其他的MPP数据库），会发现大部分的CPU周期都花费在无用的工作之上，例如虚函数的调用；或者读取/写入中间数据到CPU高速缓存或内存中。通过减少花在这些无用功的CPU周期一直是现代编译器长期性能优化的重点。

Apache Spark 2.0中附带了第二代Tungsten engine。这一代引擎是建立在现代编译器和MPP数据库的想法上，并且把它们应用于数据的处理过程中。主要想法是通过在运行期间优化那些拖慢整个查询的代码到一个单独的函数中，消除虚拟函数的调用以及利用CPU寄存器来存放那些中间数据。作为这种流线型策略的结果，我们显著提高CPU效率并且获得了性能提升，我们把这些技术统称为"整段代码生成"(whole-Stage code generation)。

1.2      内存管理与二进制处理
9.2.1概述
 Spark计算框架是基于Scala与Java语言开发的，其底层都使用了JVM（Java Virtual Machine，Java虚拟机）。而在JVM上运行的应用程序是依赖JVM的垃圾回收机制来管理内存的，随着Spark应用程序性能的不断提升，JVM对象和GC(Garbage Collection)开销产生的影响（包括内存不足、频繁GC或Full GC等）将非常致命。即引进新的Tungsten内存管理机制的主要原因在于JVM在内存方面和GC方面的开销。主要包含不必要的内存开销和GC的开销：

1.        JVM对象模型（JVM object model）的内存开销

可以通过Java Object Layout工具来查看在JVM上Java 对象所占用的内存空间（有兴趣可以参考http://openjdk.java.net/projects/code-tools/jol/），需要注意的是在32bit与64bit的操作系统，占用空间会有所差异，下面是在64bit操作系统上对String的分析结果：

1.          java.lang.String object internals:

2.           OFFSET  SIZE   TYPE DESCRIPTION                    VALUE

3.                0    12        (object header)                N/A

4.               12     4 char[] String.value                   N/A

5.               16     4    int String.hash                    N/A

6.               20     4    int String.hash32                  N/A

7.          Instance size: 24 bytes (estimated, the sample instance is not available)

8.          Space losses: 0 bytes internal + 0 bytes external = 0 bytes total

一个简单的String对象会额外占用一个12字节的header和8字节的hash信息。这是开启(-XX:+UseCompressedOops，默认)指针压缩的方式（-XX:+UseCompressedOops）的结果，如果不开启(-XX:+UseCompressedOops)指针压缩（-XX:+UseCompressedOops），则内存更大，如下所示：

1.          java.lang.String object internals:

2.           OFFSET  SIZE   TYPE DESCRIPTION                    VALUE

3.                0    16        (object header)                N/A

4.               16     8 char[] String.value                   N/A

5.               24     4    int String.hash                    N/A

6.               28     4    int String.hash32                  N/A

7.          Instance size: 32 bytes (estimated, the sample instance is not available)

8.          Space losses: 0 bytes internal + 0 bytes external = 0 bytes total

其中，Header会占用16个字节的大小，另外JVM内存模型会采用8字节对齐，因此也可能会再增加一部分的内存开销。

以上仅仅上String对象中JVM内存模型中占用的内存大小，实际计算时需要考虑其内部的引用对象所占的内存，通过分析，char[]中默认的指针压缩情况下会占用16bytes内存，因此仅仅是一个空字符串，也会占用24bytes + 16bytes =4 0bytes的内存。

另外在JVM内存模型中，为了更加通用，它重新定制了自己的储存机制，使用UTF-16方式编码每个字符（2字节）。参考http://www.javaworld.com/article/2077408/core-java/sizeof-for-java.html，java对象的内存占用大小如下所示：

1.         // java.lang.Object shell sizein bytes:

2.             public static final int OBJECT_SHELL_SIZE   = 8;

3.             public static final int OBJREF_SIZE         = 4;

4.             public static final intLONG_FIELD_SIZE     = 8;

5.             public static final int INT_FIELD_SIZE      = 4;

6.             public static final intSHORT_FIELD_SIZE    = 2;

7.             public static final intCHAR_FIELD_SIZE     = 2;

8.             public static final intBYTE_FIELD_SIZE     = 1;

9.             public static final intBOOLEAN_FIELD_SIZE  = 1;

10.          public static final intDOUBLE_FIELD_SIZE   = 8;

11.          public static final intFLOAT_FIELD_SIZE    = 4;

其中CHAR_FIELD_SIZE为2。即每个字符串在JVM中采用了UTF-16编码，一个字符会占用2个字节。

2.        垃圾回收机制（Garbage collection，GC）的开销。

JVM对象带来的另一个问题是GC。通常情况下JVM内存模型中Heap会分成两大块，Young Generation（年轻代）和Old Generation（年老代），其中年轻代会有很高的allocation/deallocation，通过利用年轻代对象的瞬时特性，垃圾收集器可以更有效率地对其进行管理。年老代的状态则非常稳定。GC的开销在所有基于JVM的应用程序中都是不可忽视的，而且对应的调优也非常烦琐，在类似Spark框架这样的基于内存迭代处理的框架中，通常直接在底层对内存进行管理可以极大提高效率。因此对应引入Project Tungsten也就很合情合理了。