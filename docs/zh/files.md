# 非设置文件
非设置文件指 `docs/` 下所有不是 `setting.toml` 的文件，程序会调用 [filedeal](api.md#单文件生成) 进行处理。

对于这些文件，当前有 4 种处理方式。

在设置文件中，可以对指定文件设置处理方式。不设置或设置为 `default` 即调用 `default_filedealmethod` 获取默认处理方式。

## 复制
辨识符为 `copy`，即将原文件会被复制到对应的位置。

## 纯文本
辨识符为 `plain`，将文件文本内容不加更改地嵌入「标准单文档框架」中。

## 直接插入
辨识符为 `insert`，将文件文本内容嵌入「标准单文档框架」中，且不进行 HTML 实体安全转化（`<` => `&lt;` 等）。

## 代码块
辨识符为 `codeblock`，将文件文本内容作为代码块嵌入「标准单文档框架」中。

## 特别处理
辨识符为 `extra`，这一处理方式会调用 `filedeal_extra` 进行处理，包括以下类型：

### HTML
当设置项 `wrap_html` 为真时，HTML 内容会被保留，并在之后处理后将它作为「标准单文档框架」的嵌入内容；否则，它会被作为一个独立的 HTML 页面直接复制到对应的位置。

### Markdown
对于 Markdown 文件 [^1]，会使用设置项 `parser` 对应的解析器进行解析 [^2]（相关 API 参考 [Markdown 处理](api.md#markdown-处理)）。它始终是「标准单文档框架」的嵌入内容。
在 Markdown 文件解析失败时，若 `throwall` 为假，会调用 `@error` 同时将错误信息置于错误所在文件内；若为真则抛出错误。

[^1]: Markdown 是一种富文本格式，基本用法可以方便地搜索得到，标准化的规范可参见 [CommonMark](https://spec.commonmark.org/)
[^2]: 默认解析器使用了 [CommonMark](https://github.com/MichaelHatherly/CommonMark.jl)，当前存在含 unicode 字符时的表格解析错误等 bug
