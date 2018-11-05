# 



http://www.cnblogs.com/huangfox/archive/2012/07/06/2579614.html

从这篇文章里面，学习负载因子的相关内容



HashMap以<key，value>的方式存放数据，存储在数组中。通过开散列方法解决冲突，数组中存放的Entry作为单向链表的表头。

Entry的源码如下：

```java
`static` `class` `Entry<K,V> ``implements` `Map.Entry<K,V> {``        ``final` `K key;``        ``V value;``        ``Entry<K,V> next;``        ``final` `int` `hash;` `        ``//构造、get、set等方法省略` `        ``public` `final` `boolean` `equals(Object o) {``            ``if` `(!(o ``instanceof` `Map.Entry))``                ``return` `false``;``            ``Map.Entry e = (Map.Entry)o;``            ``Object k1 = getKey();``            ``Object k2 = e.getKey();``            ``if` `(k1 == k2 || (k1 != ``null` `&& k1.equals(k2))) {``                ``Object v1 = getValue();``                ``Object v2 = e.getValue();``                ``if` `(v1 == v2 || (v1 != ``null` `&& v1.equals(v2)))``                    ``return` `true``;``            ``}``            ``return` `false``;``        ``}` `        ``public` `final` `int` `hashCode() {``            ``return` `(key==``null`   `? ``0` `: key.hashCode()) ^``                   ``(value==``null` `? ``0` `: value.hashCode());``        ``}` `    ``}`
```

　　

下面我们通过走读源码来逐步探索HashMap的奥秘！！！

**一）“发现问题，存有疑问！”**

**1）构造HashMap中的capacity**

capacity为当前HashMap的Entry数组的大小，**为什么Entry数组的大小是2的N次方？**

```java
`// Find a power of 2 >= initialCapacity``int` `capacity = ``1``;``while` `(capacity < initialCapacity)``      ``capacity <<= ``1``;`
```

 

**2）构造HashMap中的loadFactor（装填因子）**

```java
`threshold = (``int``)(capacity * loadFactor);`
```

threshold为HashMap的size最大值，注意不是HashMap内部数组的大小。

**为什么需要loadFactor，怎么合理的设置loadFactor？**

 

**3）HashMap的put**

```
`public` `V put(K key, V value) {``    ``if` `(key == ``null``)``        ``return` `putForNullKey(value);``//当key为null时，将其存放在数组的首部:table[0]``    ``int` `hash = hash(key.hashCode());``    ``int` `i = indexFor(hash, table.length);``    ``for` `(Entry<K,V> e = table[i]; e != ``null``; e = e.next) {``        ``Object k;``        ``if` `(e.hash == hash && ((k = e.key) == key || key.equals(k))) {``            ``V oldValue = e.value;``            ``e.value = value;``            ``e.recordAccess(``this``);``            ``return` `oldValue;``        ``}``    ``}` `    ``modCount++;``    ``addEntry(hash, key, value, i);``    ``return` `null``;``}`
```

这里我们关注两个地方：

1）hash

```
`static` `int` `hash(``int` `h) {``        ``// This function ensures that hashCodes that differ only by``        ``// constant multiples at each bit position have a bounded``        ``// number of collisions (approximately 8 at default load factor).``        ``h ^= (h >>> ``20``) ^ (h >>> ``12``);``        ``return` `h ^ (h >>> ``7``) ^ (h >>> ``4``);``    ``}`
```

**hash的作用是什么？**

 

2）indexFor

```
`static` `int` `indexFor(``int` `h, ``int` `length) {``        ``return` `h & (length-``1``);``    ``}`
```

**indexFor的作用是什么？**

 

**二）“解惑，拨云见日！”**

key的hashCode经过hash后，为了让其在table（table为hashMap的entry[]）的范围内，需要再hash一次。这里实际上是采用的“除余法”（h%length）。

源于一个数学规律，就是如果length是2的N次方，那么数h对length的模运算结果等价于a和(length-1)的按位**与**运算，也就是 **h%length <=> h&(length-1)**。

位运算当然比取余效率高，因此这就解释了：**为什么Entry数组的大小是2的N次方？**

 

我们为什么不直接对key的hashCode进行indexFor运算，还要再hash一次呢？

我做了个简单实验，如下：

```
`int``[] hashcode = ``new` `int``[] { ``100000001``, ``100000011``, ``100000111``,``100001111``, ``100011111``, ``100111111``, ``101111111``, ``111111111` `};``for` `(``int` `c : hashcode)``    ``System.out.println(hash(c));`
```

数组hashcode中假定了8个hashcode，若对他们除以10取余，余数都为1，全部冲突！

但是通过hash后，对应的值为：

94441116; 94441110; 94441204; 94440071; 94558923; 94592891; 107664244; 117165177

对上面的值除以10取余分别是：6、0、4、1、3、1、4、7，冲突为2。

可见hash能够对hashCode分布更均匀，防止一些蹩脚的hash函数！

从上面我们也可以看出取余的时候，高位的影响比较小，例如：1048592、1048832、1052672、1114112、2097152都可以被16整除（余数为0）！

那么我们得想个办法让高位也要影响到取余的结果，如是便有了Hash。

详情参考：<http://marystone.iteye.com/blog/709945>

 

对于loadFactor，我也做了个简单实验，如下：

```java
`public` `static` `void` `main(String[] args) {``        ``String s = ``"a aa aaa b bb bbb c cc ccc d dd ddd e ee eee f ff fff g gg ggg h hh hhh abc bcd cde def efg fgh ghi hij ijk "``;``        ``String[] ss = s.split(``" "``);``        ``int` `size = ss.length;``//``        ``Set<Integer> indexS = ``new` `HashSet<Integer>();``        ``int` `conflict = ``0``;``        ``for` `(``int` `i = ``0``; i < ss.length; i++) {``            ``int` `index = hash(ss[i].hashCode()) % size;``            ``if` `(indexS.contains(index))``                ``conflict++;``            ``else``                ``indexS.add(index);``        ``}``        ``System.out.println(``"冲突数："``+conflict);``    ``}`
```

当参与取余的除数为size时，冲突数为13

当参与取余的除数为2*size时，冲突数为9

当参与取余的除数为3*size时，冲突数为6

在hashMap中，size受loadFactor的影响。

极端的想，

如果loadFactor很小很小，那么map中的table需要不断的扩容，导致除数越来越大，冲突越来越小！

如果loadFactor很大很大，那么当map中table放满了也不要求扩容，导致冲突越来越多，解决冲突而起的链表越来越长！

 