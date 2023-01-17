# 特殊代码块
## encoded 已加密标记
`encoded` 标注该部分内容已被加密，仍使用 Markdown 解析而不加其它特殊操作。

## hide 点击显示
`hide` 的代码块标题后可以加一项参数，表示按钮文字。代码块内内容（按照 Markdown 解析）会在按钮被按下后显示。

样例：
```hide "点我展开"
这是内容 ^_^
```

## insert-fill 插入填空题
`insert-fill` 表示插入填空题，使用 TOML 格式配置
```toml
content = "题目描述，**使用 Markdown**"
ans = "标准答案"
ans_regex = "答案判定，若无此项则以“与标准答案完全相同”判定"
instruction = "提示（可选，不支持Markdown）"
```

## insert-html 插入 HTML
代码块内的 HTML 会被不加修改地直接并入生成的 HTML 中。

## insert-setting 插入设置
`insert-setting` 代码块表示插入设置，使用 TOML 格式配置，其中 `type` 项表示设置类型

### select-is
`type = "select-is"` 是当前唯一支持的设置模式
* 文字内容在 `content` 项中，不支持 Markdown
* `choices` 项为字典，表示 `value` 到显示文字的映射
* `default` 项定义默认 `value`
* `store` 项为字典，表示 `value` 到 `localStorage key` 的映射，若 key 名前有 `!`，表示将指代的键存为 `false`

## insert-test 插入测试
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
* 编号分配方式由 `index_char`，`index_suffix` 项决定，前者允许 `Aa1`（默认为 `A`） ，后者允许任意字符串（默认为 `. `）
* `choices` 项表明各选项内容，不支持 Markdown
* `ans` 表明正确答案（形如 `AC` 而不允许 `CA`、`ab`）
* `score` 表明分值
* `ans_dict` 是一个字典，表明各选项及对应得分，会覆盖 `ans` 与 `score`

### 填空题
`type = "fill"` 时，表明插入填空题
* 文字内容在 `content` 项中，支持 Markdown
* `ans` 表明正确答案
* `ans_regex` 表明判断答案的正则表达式（覆盖 `ans`）
* `score` 表明分值

### 组
`type = "group"` 时，表明插入组，文字内容在 `content` 项中，支持 Markdown；`type = "group-end"` 标记组结束

* 组不会嵌套，因此不必在每个组后添加 `group-end`
* `ch_type` 给组中无 `type` 键的项目提供默认类型

### 作用域
`index_char`、`index_suffix`、`score` 项均有作用域：即可以在全局或组中设置，同时遵循局部覆盖原则

## is-xxx 条件激发
代码块内是仅在 `localStorage.getItem("is-xxx")` 为 `true` 时显示的 Markdown 内容

## random-word 插入随机句子
`random-word` 表示插入随机句子，使用 TOML 格式配置。
`id` 表示辨识编号，`pool` 是一个表数组，其中每个 `text` 项表示文字内容，不会被 html-unescape 处理。

样例：
```random-word
id = "rwzh"

[[pool]]
text = "猫猫！"
source = "我"

[[pool]]
text = "<em>这是斜体字</em>"
original = "&lt;em&gt;这是斜体字&lt;/em&gt;"
```
