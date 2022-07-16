# 规范
## 目录管理
* `assets`存放图片等数据（由`src_assets`键决定）
* `docs`存放文本数据
* `script`存放脚本（由`src_script`键决定）

## 命名规范
除去后缀后名称不应相同，且
- 仅由小写字母、数字、下划线组成
- 不能是`index`，因为会自动生成
- `setting.toml`有特殊用途，参见[设置](settings.md)

## 格式规范
* 文档开头使用`h1`的标题，之后就不应有`h1`
* 对于到此项目中文档的链接
	* 使用相对路径
	* 允许使用`#标题名`表明md文件的对应标题（构建为HTML时，会被转为`#header-标题名`）
	* 允许使用`#Lx-Ly`表明文件首个代码块的x~y行

## 代码块规范
* 不建议留空（使用`plain`）
* `insert-html`表示插入HTML
* `is-xxx`表示仅在`localStorage.getItem("is-xxx")`为`true`时显示的Markdown

`insert-fill`表示插入填空题，使用TOML格式配置
```toml
content = "题目描述，**使用 Markdown**"
ans = "标准答案"
ans_regex = "答案判定，若无此项则以“与标准答案完全相同”判定"
instruction = "提示（可选，不支持Markdown）"
```
