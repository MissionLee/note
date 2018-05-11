# 映射方法

- Tool => name => model naming option => name mapping
  - `[Entity to Table]` 写入  `%Decl(test,_)%=(test,%Lookup(%substitute(%currentfile,.erwin,_TABLE.txt),%EntityName))%If(%==(%Substr(%:test,1,1),_)){%Substr(%:test,2)}%else{%:test}`
  - `[Attribute to Column]`写入 `%Decl(test,_)%=(test,%Lookup(%substitute(%currentfile,.erwin,_FIELD.txt),%AttName))%If(%==(%Substr(%:test,1,1),_)){%Substr(%:test,2)}%else{%:test}`
- Erwin模型所在文件夹下增加两个映射文件
  - 假设模型文件名为`123.erwin`
  - 表名映射文件名为`123_TABLE.txt`
  - 字段名映射文件为`123_FIELD.txt`
- 两个映射文件内容制作方法参考本攻略同目录下excel文件`建模标准名称.xlsx`
  - B列是汉字
  - C列是对应要换成的英文
  - D列使用字符串连接函数`=CONCATENATE(B1,",",C1)`
  - A列使用函数 `=LEN(B1)*-1` 取出,B列汉字内容的长度
  - 使用排序,主排序`A列数值降序`,辅排序`B列数值降序`(实际上是按照汉语拼音首字母)
  - 排序好了之后把`D列内容`复制到上个大步骤的两个`txt文件里面`