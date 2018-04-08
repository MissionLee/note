# hello

## <？ extends E>

<? extends E> 是 Upper Bound（上限） 的通配符，用来限制元素的类型的上限，比如

```java
List<? extends Fruit> fruits;
```

表示集合中的元素类型上限为Fruit类型，即只能是Fruit或者Fruit的子类，因此对于下面的赋值是合理的

```java
fruits = new ArrayList<Fruit>();  
fruits = new ArrayList<Apple>();  
```

如果集合中元素类型为Fruit的父类则会编译出错，比如

```java
fruits = new ArrayList<Object>();//编译不通过  
```
           有了上面的基础，接着来看看 <? extends E>限定的集合的读写操作

## 1、写入

因为集合fruits中装的元素类型为Fruit或Fruit子类，直觉告诉我们，往fruits中添加一个Fruit类型对象或其子类对象是可行的

```java
fruits.add(new Fruit());//编译不通过  
fruits.add(new Apple());//编译不通过 
``` 
结果是编译都不通过，为什么？因为<? extends Fruit>只是告诉编译器集合中元素的类型上限，但它具体是什么类型编译器是不知道的，fruits可以指向ArrayList<Fruit>，也可以指向ArrayList<Apple>、ArrayList<Banana>，也就是说它的类型是不确定的，既然是不确定的，`为了类型安全，编译器只能阻止添加元素了`。举个例子，当你添加一个Apple时，但fruits此时指向ArrayList<Banana>，显然类型就不兼容了。当然null除外，因为它可以表示任何类型。

2、读取 

无论fruits指向什么，编译器都可以确定获取的元素是Fruit类型，所有读取集合中的元素是允许的

```java
Fruit fruit = fruits.get(0);//编译通过  
```

补充：<?>是<? extends Object>的简写

## <？ super E>
      <? super E> 是 Lower Bound（下限） 的通配符 ，用来限制元素的类型下限，比如

```java
List<? super Apple> apples;  
```

表示集合中元素类型下限为Apple类型，即只能是Apple或Apple的父类，因此对于下面的赋值是合理的

```java
apples = new ArrayList<Apple>();  
apples = new ArrayList<Fruit>();  
apples = new ArrayList<Object>();  
```

如果元素类型为Apple的子类，则编译不同过

```java
apples = new ArrayList<RedApple>();//编译不通过  
```

同样看看<? super E>限定的集合的读写操作


1、写入

因为apples中装的元素是Apple或Apple的某个父类，我们无法确定是哪个具体类型，但是可以确定的是Apple和Apple的子类是和这个“不确定的类”兼容的，因为它肯定是这个“不确定类型”的子类，也就是说我们可以往集合中添加Apple或者Apple子类的对象，所以对于下面的添加是允许的

```java
apples.add(new Apple());  
apples.add(new RedApple());  
```

它无法添加Fruit的任何父类对象，举个例子，当你往apples中添加一个Fruit类型对象时，但此时apples指向ArrayList<Apple>，显然类型就不兼容了，Fruit不是Apple的子类

```java
apples.add(new Fruit());//编译不通过  
```

2、读取

编译器允许从apples中获取元素的，但是无法确定的获取的元素具体是什么类型，只能确定一定是Object类型的子类，因此我们想获得存储进去的对应类型的元素就只能进行强制类型转换了

```java
Apple apple = (Apple)apples.get(0);//获取的元素为Object类型  
```

问题来了，JDK1.5引入泛型的目的是为了避免强制类型转换的繁琐操作，那么使用泛型<? super E>干嘛呢？这里就得谈到泛型PECS法则了

## PECS法则

PECS法则：生产者（Producer）使用extends，消费者（Consumer）使用super

1、生产者
       如果你需要一个提供E类型元素的集合，使用泛型通配符<? extends E>。它好比一个生产者，可以提供数据。

2、消费者
       如果你需要一个只能装入E类型元素的集合，使用泛型通配符<? super E>。它好比一个消费者，可以消费你提供的数据。

3、既是生产者也是消费者
       既要存储又要读取，那就别使用泛型通配符。

## PECS例子

JDK集合操作帮助类Collections中的例子

```java
/** 
 * Copies all of the elements from one list into another.  After the 
 * operation, the index of each copied element in the destination list 
 * will be identical to its index in the source list.  The destination 
 * list must be at least as long as the source list.  If it is longer, the 
 * remaining elements in the destination list are unaffected. <p> 
 * 
 * This method runs in linear time. 
 * 
 * @param  dest The destination list. 
 * @param  src The source list. 
 * @throws IndexOutOfBoundsException if the destination list is too small 
 *         to contain the entire source List. 
 * @throws UnsupportedOperationException if the destination list's 
 *         list-iterator does not support the <tt>set</tt> operation. 
 */  
public static <T> void copy(List<? super T> dest, List<? extends T> src) {  
    int srcSize = src.size();  
    if (srcSize > dest.size())  
        throw new IndexOutOfBoundsException("Source does not fit in dest");  
  
    if (srcSize < COPY_THRESHOLD ||  
        (src instanceof RandomAccess && dest instanceof RandomAccess)) {  
        for (int i=0; i<srcSize; i++)  
            dest.set(i, src.get(i));  
    } else {  
        ListIterator<? super T> di=dest.listIterator();  
 ListIterator<? extends T> si=src.listIterator();  
        for (int i=0; i<srcSize; i++) {  
            di.next();  
            di.set(si.next());  
        }  
    }  
}  
```

## 总结
        为什么要引入泛型通配符？一句话：为了保证类型安全。