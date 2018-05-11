# StringOps

```scala
// scala.collection.immutable.StringOps
var t : Long =1
"Hello".foreach(t *= _.toLong)
println(t)
```

def
foreach[U](f: (Char) ⇒ U): Unit
Applies a function f to all elements of this string.

Note: this method underlies the implementation of most other bulk operations. Subclasses should re-implement this method if a more efficient implementation exists.

U
the type parameter describing the result of function f. This result will always be ignored. Typically U is Unit, but this is not necessary.

f
the function that is applied for its side-effect to every element. The result of function f is discarded.

Definition Classes
IndexedSeqOptimized → IterableLike → TraversableLike → GenTraversableLike → TraversableOnce → GenTraversableOnce → FilterMonadic