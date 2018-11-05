# ExecutionException

```java
/**
 * Exception thrown when attempting to retrieve the result of a task
 * that aborted by throwing an exception. This exception can be
 * inspected using the {@link #getCause()} method.
 *
 * @see Future
 * @since 1.5
 * @author Doug Lea
 */
public class ExecutionException extends Exception {
    // 如果一个任务抛出异常终止了，而我们尝试去获取这个任务的结果，此时抛出这个异常
}
```

