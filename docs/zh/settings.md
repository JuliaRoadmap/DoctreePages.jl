# 设置
## 设置文件
`setting.toml` 应被置于各级目录下，用于存放各类设置信息。最常用的设置项是 `outline` 与 `names`。原则上，各个文件不应存在同名异后缀现象，否则生成器可能出现混乱。提及文件时，除特殊说明都应统一使用去后缀的名称。

## 设置项
`outline` 项对应一个列表，表示提纲。以 HTML 导出时，它会表现为侧边栏的各条目链接，且按照原顺序和层级排列。没有这个需求的文件/目录可以不写在该项中。写在设置文件中时，应省略各文件的文件后缀。

`names` 项对应一个字典，将非 markdown 文件的非后缀部分映射到它的标题，标题会显示在该页、侧边栏、索引页等处。

`ignore` 项表示应忽略的文件/目录列表，它们不会被构建成 HTML 等结构。写在设置文件中时，应**不省略**各文件的文件后缀。

`method` 项表示[单文件处理方式](files.md)，从去后缀文件名映射到字符串。

`foot_direct` 项表示脚链接硬设置，它会表现为文末的左右箭头链接。对于每个给定的去后缀文件名，它映射到一个字典，项可以是 `prev`、`next`，对应左、右的箭头。
