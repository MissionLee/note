# `

```scala
  /** Returns an iterator over all the elements of this iterator that satisfy the predicate `p`.
   *  The order of the elements is preserved.
   *
   *  @param p the predicate used to test values.
   *  @return  an iterator which produces those values of this iterator which satisfy the predicate `p`.
   *  @note    Reuse: $consumesAndProducesIterator
   */
  def filter(p: A => Boolean): Iterator[A] = new AbstractIterator[A] {
    // TODO 2.12 - Make a full-fledged FilterImpl that will reverse sense of p
    private var hd: A = _
    private var hdDefined: Boolean = false

    def hasNext: Boolean = hdDefined || {
      do {
        if (!self.hasNext) return false
        hd = self.next()
      } while (!p(hd))
      hdDefined = true
      true
    }

    def next() = if (hasNext) { hdDefined = false; hd } else empty.next()
  }
```

- 这里有一些语法上的学习
  - private var hd: A=_   这里是 初始化 为 null
  - self.hasNext/self.next
    - filter是iterator里面的方法，iterator本是有 hasNext 和 next 两个方法。 在filter内部，我们又重新定义了这两个方法，self是用来调用外面的函数的

- 内部 do{}while()逻辑分析
  - 1.如果自身没有 下个元素了，就直接false
  - 2.如果自身有下个元素 ，hd 当前为下个元素
    - 此时判断 hd符合 判断条件吗，
      - 如果符合条件， hdDefined = ture 跳出
      - 如果不符合条件，就循环到 一个 符合条件的内容为止（或者循环到 外部iterator终结）