# 特殊变量

Shell特殊变量：Shell $0, $#, $*, $@, $?, $$和命令行参数

特殊变量列表

变量含义
$0当前脚本的文件名
$n传递给脚本或函数的参数。n 是一个数字，表示第几个参数。例如，第一个参数是$1，第二个参数是$2。
$#传递给脚本或函数的参数个数。
$*传递给脚本或函数的所有参数。
$@传递给脚本或函数的所有参数。被双引号(" ")包含时，与 $* 稍有不同，下面将会讲到。
$?上个命令的退出状态，或函数的返回值。一般情况下，大部分命令执行成功会返回 0，失败返回 1。
$$当前Shell进程ID。对于 Shell 脚本，就是这些脚本所在的进程ID。


$* 和 $@ 的区别
$* 和 $@ 都表示传递给函数或脚本的所有参数，不被双引号(" ")包含时，都以"$1" "$2" … "$n" 的形式输出所有参数。
但是当它们被双引号(" ")包含时，"$*" 会将所有的参数作为一个整体，以"$1 $2 … $n"的形式输出所有参数；"$@" 会将各个参数分开，以"$1" "$2" … "$n" 的形式输出所有参数。

下面的例子可以清楚的看到 $* 和 $@ 的区别：

```bash
#!/bin/bash
echo "\$*=" $*
echo "\"\$*\"=" "$*"
echo "\$@=" $@
echo "\"\$@\"=" "$@"
echo "print each param from \$*"
for var in $*
do
echo "$var"
done
echo "print each param from \$@"
for var in $@
do
echo "$var"
done
echo "print each param from \"\$*\""
for var in "$*"
do
echo "$var"
done
echo "print each param from \"\$@\""
for var in "$@"
do
echo "$var"
done
```

执行 ./test.sh "a" "b" "c" "d"，看到下面的结果：
$*=a b c d
"$*"= a b c d
$@=a b c d
"$@"= a b c d
print each param from $*
a
b
c
d
print each param from $@
a
b
c
d
print each param from "$*"
a b c d
print each param from "$@"
a
b
c
d
说明：双引号包含时，"$*"的参数被当做一个整体，而"$@"还是遍历每一个参数