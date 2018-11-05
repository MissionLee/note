###  初始化ArrayList

#### 初始化ArrayList我们一般这样写：
```java
	ArrayList<String> places = new ArrayList<String>();
	places.add("Buenos Aires");
	places.add("Córdoba");
	places.add("La Plata");
```

我重构代码做：

```
ArrayList<String> places = new ArrayList<String>(Arrays.asList("Buenos Aires", "Córdoba", "La Plata"));
```

有这样做的更好的方法吗？

#### 解决方法 1:

其实，可能要初始化的"最佳"方式，`ArrayList` 是你写的方法，因为它不需要创建一个新的 `List` 以任何方式：

```
ArrayList<String> list = new ArrayList<String>();
    list.add("A");
    list.add("B");
    list.add("C");
```

渔获是相当多的键入所需，请参阅 `list` 实例。

有如使一个匿名的内部类的一个实例初始值设定项 （也称为一种"双大括号初始化"） 的方法：

```
ArrayList<String> list = new ArrayList<String>() {{
    add("A");
    add("B");
    add("C");
}}
```

不过，我不太喜欢该方法，因为什么你最终是一个类的子类 `ArrayList` 有一个实例初始值设定项和这类只是为了创建一个对象 — — 只是看起来像我有点大材小用。

有何好是如果接受 项目硬币 收集文本的建议，我们可以有 Java 7 中的列表中文字：

```
List<String> list = ["A", "B", "C"];
```

不幸的是它不会帮助您在这里，因为它将初始化一个 `List`，而不是 `ArrayList`，此外，它尚未提供，如果它以往任何时候都将和。

#### 解决方法 2:

如果你，只是将它声明为列表中没有要 ArrayList，它会更简单呢？

```
List<String> places = Arrays.asList("Buenos Aires", "Córdoba", "La Plata");
```

#### 解决方法 3:

```
import com.google.common.collect.ImmutableList;

....

List<String> places = ImmutableList.of("Buenos Aires", "Córdoba", "La Plata");
```

#### 解决方法 4:

漂亮的很多，最简单的方法就是 `List<String> strings = new ArrayList<String>(asList("foo", "bar", "baz"))`，如果您必须有一个 `ArrayList`，否则您应该在大多数情况下只是使用`List<String> strings = asList("foo", "bar", "baz")`

你说你已宣布作为列表一个 `ArrayList` 在您的代码中，但您不应该做的除非您正在使用的一些成员 `ArrayList` 在这并不是 `List`，例如 `ArrayList.ensureCapacity()`。

通常您应该只是声明变量，您要使用，它的列表通常是最通用接口的 `List`，和初始化它们在具体的实施，例如 `ArrayList` 或 `LinkedList`。

使用不实现，否则为你会发现您要在多个位置更改，当您想要使用另一种实现的接口。

另一个例子将总是声明变量，一个 `InputStream` 即使它通常是一个 `FileInputStream`，这是因为一天很快就您或其他人会想要使用一些另类的 `InputStream`。

#### 解决方法 5:

您可以创建一个工厂方法：

```
public static ArrayList<String> createArrayList(String ... elements) {
  ArrayList<String> list = new ArrayList<String>(); 
  for (String element : elements) {
    list.add(element);
  }
  return list;
}

....

ArrayList<String> places = createArrayList(
  "São Paulo", "Rio de Janeiro", "Brasília"); 
```

但并不比你第一次的重构。

**更新：** 更大的灵活性，它可以是一种通用：

```
public static <T> ArrayList<T> createArrayList(T ... elements) { 
  ArrayList<T> list = new ArrayList<T>();  
  for (T element : elements) { 
    list.add(element); 
  } 
  return list; 
} 
```

#### 解决方法 6:

只是注意到它在一个很简单的工作方法，如下所示：

```
 ArrayList arrList = new ArrayList() {"1",2,3,"4" };

List<Customer> listCustomer = new List<Customer>() { new Customer(), new Customer(), new Customer() };
```

这 C# 3.0 不双支撑所需的工作。希望这有助于。

#### 解决方法 7:

若要设置列表填充 N 的默认对象的副本：

```
ArrayList<Object> list = new ArrayList<Object>(
Collections.nCopies(1000, new Object()));

```

```

```