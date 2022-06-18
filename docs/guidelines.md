# 规范
## 命名规范
除去后缀后名称不应相同，且
- 仅由小写字母、数字、下划线组成
- 不能是`index`

## 格式规范
* 文档开头使用`h1`的标题，之后就不应有`h1`
* 对于到此项目中文档的链接
	* 使用相对路径
	* 允许使用`#标题名`表明md文件的对应标题
	* 允许使用`#Lx-Ly`表明txt文件的x~y行

## 代码块规范
* 不能留空（使用`plain`）
* Julia 代码和`REPL`均使用`jl`
* 命令行使用`shell`，可以选择以`$ `开头
* `insert-html`表示插入HTML
* `insert-fill`表示插入填空题，会使用`eval`解析其中内容，类型是`Tuple{String,String,Regex}`，分别表示描述、正确答案和正误判断（若省略，则按照与正确答案完全相同判定）
* `is-xxx`表示仅在`localStorage.getItem("is-xxx")`为`true`时显示的Markdown
