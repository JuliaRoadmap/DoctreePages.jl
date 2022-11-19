# 规范
## 目录管理
* `assets` 存放图片等数据（由 `src_assets` 键决定）
* `docs` 存放文本数据
* `script` 存放脚本（由 `src_script` 键决定）

## 命名规范
除去后缀后名称不应相同，且
- 仅由小写字母、数字、下划线组成
- 不能是 `index`，因为会自动生成
- `setting.toml` 有特殊用途，参见[设置](settings.md)

## 格式规范
* 文档开头使用 `h1` 的标题，之后就不应有 `h1`
* 对于到此项目中文档的链接
	* 使用相对路径
	* 允许使用 `#标题名` 表明md文件的对应标题（构建为HTML时，会被转为 `#header-标题名`）
	* 允许使用 `#Lx-Ly` 表明文件首个代码块的 x~y 行

## 代码块规范
* 不建议留空（使用 `plain`）
* `insert-html` 表示插入HTML
* `hide` 表示点击按钮后才会显示
* `encoded` 标注该部分内容已被加密，仍使用 Markdown 解析
* `is-xxx` 表示仅在 `localStorage.getItem("is-xxx")` 为 `true` 时显示的 Markdown 内容

`insert-fill` 表示插入填空题，使用 TOML 格式配置
```toml
content = "题目描述，**使用 Markdown**"
ans = "标准答案"
ans_regex = "答案判定，若无此项则以“与标准答案完全相同”判定"
instruction = "提示（可选，不支持Markdown）"
```

## 插入设置
`insert-setting` 代码块表示插入设置，使用 TOML 格式配置，其中 `type` 项表示设置类型

### select-is
`type = "select-is"` 是当前唯一支持的设置模式
* 文字内容在 `content` 项中，不支持 Markdown
* `choices` 项为字典，表示 `value` 到显示文字的映射
* `default` 项定义默认 `value`
* `store` 项为字典，表示 `value` 到 `localStorage key` 的映射，若 key 名前有 `!`，表示将指代的键存为 `false`

## 插入测试
`insert-test` 代码块表示插入测试，使用 TOML 格式配置

### 结构
设置包含两个主要项：`global` 表示全局设置，`parts` 是一个表数组

全局设置中，可以使用 `name` 表示测试名称，`time_limit` 表示总时间限制（单位为秒），`full_score` 为总分（**不会影响**各题分值的分配）

`q_pre` 键表明题面的前缀模式，仅支持 `none` 与 `number`（默认）。

对于每个 `part`，有一个 `type` 参数表明类型

### 文字
`type = "text"` 时，表明插入文字，文字内容在 `content` 项中，支持 Markdown

### 选择题
`type = "choose"` 时，表明插入选择题
* 文字内容在 `content` 项中，支持 Markdown
* 编号分配方式由 `index_char`，`index_suffix` 项决定，前者允许 `Aa1`（默认为`A`） ，后者允许任意字符串（默认为`. `）
* `choices` 项表明各选项内容，不支持 Markdown
* `ans` 表明正确答案（形如`AC`而不允许`CA`、`ab`）
* `score`表明分值
* `ans_dict` 是一个字典，表明各选项及对应得分，会覆盖`ans`与`score`

### 填空题
`type = "fill"` 时，表明插入填空题
* 文字内容在 `content` 项中，支持 Markdown
* `ans` 表明正确答案
* `ans_regex` 表明判断答案的正则表达式（覆盖`ans`）
* `score`表明分值

### 组
`type = "group"` 时，表明插入组，文字内容在 `content` 项中，支持 Markdown；`type = "group-end"` 标记组结束

* 组不会嵌套，因此不必在每个组后添加 `group-end`
* `ch_type` 给组中无 `type` 键的项目提供默认类型

### 作用域
`index_char`、`index_suffix`、`score` 项均有作用域：即可以在全局或组中设置，同时遵循局部覆盖原则
