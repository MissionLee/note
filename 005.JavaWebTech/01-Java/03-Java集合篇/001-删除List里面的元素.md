# 删除List里的元素

> MissionLee : 主要是 用remove删除，list的长度就会变化，如果还是引用了之前的size久会越界，如果用增强for循环，里面有一个 便利过程中是否发生改动的判断，会报错：ConcurrentModificationException。 用 while + iteratior 比较合适



首先看下下面的各种删除list元素的例子

```java


public static void main(String[] args) {



        List<String> list = new ArrayList<>(Arrays.asList("a1", "ab2", "a3", "ab4", "a5", "ab6", "a7", "ab8", "a9"));



​        /**

         \* 报错

         \* java.util.ConcurrentModificationException

         */

        for (String str : list) {

            if (str.contains("b")) {

                list.remove(str);

            }

        }



        /**

         \* 报错：下标越界

         \* java.lang.IndexOutOfBoundsException

         */

        int size = list.size();

        for (int i = 0; i < size; i++) {

            String str = list.get(i);

            if (str.contains("b")) {

                list.remove(i);

            }

        }



        /**

         \* 正常删除，每次调用size方法，损耗性能，不推荐

         */

        for (int i = 0; i < list.size(); i++) {

            String str = list.get(i);

            if (str.contains("b")) {

                list.remove(i);

            }

        }



        /**

         \* **正常删除，推荐使用**

         */

        for (Iterator<String> ite = list.iterator(); ite.hasNext();) {

            String str = ite.next();

            if (str.contains("b")) {

                ite.remove();

            }

        }



        /**

         \* 报错

         \* java.util.ConcurrentModificationException

         */

        for (Iterator<String> ite = list.iterator(); ite.hasNext();) {

            String str = ite.next();

            if (str.contains("b")) {

                list.remove(str);

            }

        }



    }
```


报异常IndexOutOfBoundsException我们很理解，是动态删除了元素导致数组下标越界了。



那ConcurrentModificationException呢？



其中,for(xx in xx)是增强的for循环，即迭代器Iterator的加强实现，其内部是调用的Iterator的方法，为什么会报ConcurrentModificationException错误，我们来看下源码





![img](http://mmbiz.qpic.cn/mmbiz_png/TNUwKhV0JpQmW1t6CdgQ044qE2uOf37bA2ib1iaHzTics4iae9LerFIjz0qElibZqHysxKRg6U8XKBCEnI5om7jgYxw/640?wx_fmt=png&tp=webp&wxfrom=5&wx_lazy=1&wx_co=1)



取下个元素的时候都会去判断要修改的数量和期待修改的数量是否一致，不一致则会报错，而通过迭代器本身调用remove方法则不会有这个问题，因为它删除的时候会把这两个数量同步。搞清楚它是增加的for循环就不难理解其中的奥秘了。