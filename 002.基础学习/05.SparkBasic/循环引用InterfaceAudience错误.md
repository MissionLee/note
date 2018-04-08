# 关于这个问题

```note
18/03/19 20:52:10 INFO SparkContext: Created broadcast 0 from textFile at BasNewsDailyClfETL.scala:75
Exception in thread "main" scala.reflect.internal.Symbols$CyclicReference: illegal cyclic reference involving object InterfaceAudience
```

## 原因： case class 要写在 当前 object 之外


- 最早的时候，看到林子雨的教程，我是知道case class要写在外面的，所以在写这一份代码的时候，我最初肯定是写在外面，后来应该拿到里面了，然后尝试了一下，当时应该是可以执行？？？
- 这里实际上还有一个问题  case class 默认是 static的，我们知道 scala中，一个文件里面可以写多个class，但是在这里我发现，只要有一个class是静态的，那么都无法 用 new 方法 创建和 文件名同名的那个
- 这里还想记录以下找bug的相关实行，不要着急，慢慢排除！！