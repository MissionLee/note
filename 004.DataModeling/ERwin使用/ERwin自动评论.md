# 自动评论

- [物理模型状态下] Database => Pre&Post Script =>Model-level
- New 取个名字
- 下方Codes框里面

```script
%ForEachTable()
{
    alter TABLE %TableName COMMENT = '%EntityName' ENGINE=InnoDB DEFAULT CHARSET=utf8;

    %ForEachColumn()
    {
        ALTER TABLE %TableName CHANGE COLUMN %ColName %ColName %AttDatatype %AttNullOption COMMENT '%AttName';
      }
}
```

- 生成sql脚本的时候 勾选 Post Script 选项,在sql脚本 `最下方` 会有相应的评论语句