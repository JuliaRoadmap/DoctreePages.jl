# 使用方式
`generate`函数接受三个参数：源目录、目标目录、设置数据
* 源目录：包含待处理的数据（Markdown等）
* 目标目录：用于存放处理结果（HTML等）
* 设置数据：一个`PagesSetting`实例

`PagesSetting`构造函数使用keyword，以下是各键说明，类型与默认值参见docstring，更深入的信息应参照源代码

| 键名 | 描述 |
| --- | --- |
| buildmessage | 构建信息 |
| charset | 源文件的字符集 |
| default_alt | 图像的默认替换文字 |
| favicon_path | favicon的路径 |
| filesuffix | 生成文件的后缀 |
| giscus | Giscus设置 |
| highlighter | 高亮设置 |
| lang | 使用语言（`en`、`zh`等） |
| logo_path | logo的路径 |
| make_index | 是否创建索引页 |
| move_favicon | 是否把favicon移至`/favicon.ico` |
| page_foot | 页面底端嵌入的html |
| parser | CommonMark解析器 |
| remove_origin | 生成前是否先移除 |
| repo_branch | 仓库的默认branch名称 |
| repo_name | 仓库的名称 |
| repo_owner | 仓库的所有者名称 |
| repo_path | 到仓库默认分支的完整路径 |
| show_info | 是否在生成时调用`@info` |
| sort_file | 是否给文件排序 |
| sub_path | 若位于一个项目的子目录，给出从项目根目录到源目录的路径 |
| table_align | 表格对齐方式 |
| throwall | 是否抛出非致命错误 |
| title | 标题 |
| unfound | 404错误时重定向的页面（若无文件则自动生成） |
| wrap_html | 是否对html文件进行包裹 |

1. 未提供默认值的键包括`repo_name`，`repo_owner`和`title`
2. `unfound`值表示的文件应在同一目录下
