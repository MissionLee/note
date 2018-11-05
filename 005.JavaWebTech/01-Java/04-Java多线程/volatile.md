昨天我介绍了原子性、可见性、有序性的概念，那么今天就来见识下这些概念的主角-volatile关键字。



> **volatile基本介绍**



volatile可以看成是synchronized的一种轻量级的实现，但volatile并不能完全代替synchronized，volatile有synchronized可见性的特性，但没有synchronized原子性的特性。可见性即用volatile关键字修饰的成员变量表明该变量不存在工作线程的副本，线程每次直接都从主内存中读取，每次读取的都是最新的值，这也就保证了变量对其他线程的可见性。另外，使用volatile还能确保变量不能被重排序，保证了有序性。



volatile只用修饰一个成员变量，如：private volatile balance;



volatile比synchronized编程更容易且开销更小，但具有一点的使用局限性，使用要相当小心，不能当锁使用。volatile不会像synchronized一样阻塞程序，如果是读操作远多于写操作的情况可以建议使用volatile，它会有更好的性能。



> **volatile使用场景**



如果正确使用volatile的话，必须依赖下以下种条件：

1、对变量的写操作不依赖当前变量的值；

2、该变量没有包含在其他变量的不变式中。



第1个条件就说明了volatile不是原子性的操作，不能使用n++类似的计数器，它不是线程安全的。



1、状态的改变



有些场景肯定会有状态的改变，完成一个主线程的停止等。首先我们开启了一个无限循环的主线程，判断变量isStop变量是否为true，如果true的话就退出程序，否则就一直循环，所以这个isStop的值是别的线程改变的。



![img](http://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpQsOtibTaY5Sgia2Yx4If9CdLiaFpMejYfGZopz6yVxytmPAeUXDOP1kEp58gujLuemQ39ibIM2MFia5xw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)

上面这段程序如果不加volatile的话会一直卡在循环，此时的线程拿到的值永远为false，加了volatile3秒后就输出stop，所以这段程序很好的解释了可见性的特点。



2、读多写少的情况



假设这样一种场景，有N个线程在读取变量的值，只有一个线程写变量的值，这时候就能保证读线程的可见性，又能保证写线程的线程安全问题。



像n++不是原子类的操作，其实可以通过synchronized对写方法锁住，再用volatile修饰变量，这样就保证了读线程对变量的可见性，又保证了变量的原子性。



![img](http://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpQsOtibTaY5Sgia2Yx4If9CdLBoWjBJojBCz6zG1ViaPotBwo1mQcLd7OvLFoY2SfOUj8nODRsXQEryw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



如果n不加volatile，程序将一直循环，不能输出stop，也就是此时的线程拿到的值永远为0。当然不加volatile，对获取n的方法进行synchronized修饰也是能及时获取最新值的，但是性能会远低于volatile。