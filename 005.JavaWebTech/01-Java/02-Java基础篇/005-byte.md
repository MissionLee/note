java设计byte类型为1个字节，1个字节占8位，即8bit，这是常识。



另外，计算机系统中是用补码来存储的，首位为0表示正数，首位为1表示负数，所以有以下结论：



最大的补码用二进制表示为：**01111111** = 127



最小的补码用二进制表示为：**10000000** = -128



关于补码、原码、反码的计算原理可以百度。



Byte的源码：



> /**
>
>  \* A constant holding the minimum value a {@code byte} can
>
>  \* have, -2<sup>7</sup>.
>
>  */
>
> public static final byte   MIN_VALUE = -128;
>
>
>
> /**
>
>  \* A constant holding the maximum value a {@code byte} can
>
>  \* have, 2<sup>7</sup>-1.
>
>  */
>
> public static final byte   MAX_VALUE = 127;



7是最高位，总共8bit，可以看出byte占1个字节，即8/8=1。



Integer源码：



> /**
>
>  \* A constant holding the minimum value an {@code int} can
>
>  \* have, -2<sup>31</sup>.
>
>  */
>
> public static final int   MIN_VALUE = 0x80000000;
>
>
>
> /**
>
>  \* A constant holding the maximum value an {@code int} can
>
>  \* have, 2<sup>31</sup>-1.
>
>  */
>
> public static final int   MAX_VALUE = 0x7fffffff;



31是最高位，总共32bit，可以看出int占4个字节，即32/8=4。



其他Short、Long的设计原理也一样。