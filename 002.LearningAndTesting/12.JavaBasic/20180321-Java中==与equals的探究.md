# 1

## 回答1

作者：leeon
链接：https://www.zhihu.com/question/26872848/answer/34364603
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

又是这个问题哈， @金波 的回答是我看到最喜欢的，一句话很清晰的比较了两个方法。Java 语言里的 equals方法其实是交给开发者去覆写的，让开发者自己去定义满足什么条件的两个Object是equal的。所以我们不能单纯的说equals到底比较的是什么。你想知道一个类的equals方法是什么意思就是要去看定义。Java中默认的 equals方法实现如下：public boolean equals(Object obj) {
    return (this == obj);
}
而String类则覆写了这个方法,直观的讲就是比较字符是不是都相同。
```java
public boolean equals(Object anObject) {
    if (this == anObject) {
        return true;
    }
    if (anObject instanceof String) {
        String anotherString = (String)anObject;
        int n = count;
        if (n == anotherString.count) {
            char v1[] = value;
            char v2[] = anotherString.value;
            int i = offset;
            int j = anotherString.offset;
            while (n-- != 0) {
                if (v1[i++] != v2[j++])
                    return false;
            }
            return true;
        }
    }
    return false;
}
```

## 回答2

- 1.使用==比较原生类型如：boolean、int、char等等，使用equals()比较对象
- 2.==返回true如果两个引用指向相同的对象，equals()的返回结果依赖于具体业务实现
- 3.字符串的对比使用equals()代替==操作符


## String 类 的 equals 方法
```java
 public boolean equals(Object anObject) {
        if (this == anObject) {
            return true;
        }
        if (anObject instanceof String) {
            String anotherString = (String)anObject;
            int n = value.length;
            if (n == anotherString.value.length) {
                char v1[] = value;
                char v2[] = anotherString.value;
                int i = 0;
                while (n-- != 0) {
                    if (v1[i] != v2[i])
                        return false;
                    i++;
                }
                return true;
            }
        }
        return false;
    }
```