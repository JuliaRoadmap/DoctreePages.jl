# 使用方式
## 基于参数生成
`generate`函数的一个方法接受三个参数：源目录srcdir、目标目录tardir、设置数据pss
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
| hljs_all | 是否全部高亮均使用[highlight.js](https://github.com/highlightjs/highlight.js)（当前不支持`false`） |
| lang | 使用语言（`en`、`zh`等） |
| logo_path | logo的路径 |
| main_script | `main.js`的设置 |
| make404 | 是否创建404页面 |
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
| src_assets | 参阅[guidelines](guidelines.md#目录管理) |
| src_script | 参阅[guidelines](guidelines.md#目录管理) |
| sub_path | 若位于一个项目的子目录，给出从项目根目录到源目录的路径 |
| table_align | 表格对齐方式 |
| tar_assets | 生成的包含`assets`的目录名 |
| tar_css | 生成的包含`css`的目录名 |
| tar_extra | 生成的包含本包额外数据的目录名 |
| tar_script | 生成的包含脚本的目录名 |
| throwall | 是否抛出非致命错误 |
| title | 标题 |
| unfound | 404错误时重定向的页面（若无文件则自动生成） |
| use_subdir | 在构建独立部分时使用`joinpath(tardir, pss.use_subdir)` |
| wrap_html | 是否对html文件进行包裹 |

1. 未提供默认值的键包括`repo_name`，`repo_owner`和`title`
2. `unfound`值表示的文件应在同一目录下
3. 以`src_`或`tar_`开头的对应值应只是目录名，不应含有`/`（目录分隔符）

## 配置文件
`generate`函数的另一个方法的第三个参数为字符串，表示配置文件的路径，默认是`DoctreeBuild.toml`\
配置文件应使用TOML格式，其中
* `version` 项表明最低支持的`DoctreePages`版本
* `pages`、`giscus`、`mainscript`表分别表示总设置、`giscus`设置与`main_script`设置
* 除字符串与布尔值以外，不支持更高级的值配置

## 构建脚本
如果你想，你可以选择自己调用提供的函数编写构建脚本