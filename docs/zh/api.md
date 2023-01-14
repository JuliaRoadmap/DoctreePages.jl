# API 参考
除特殊注明外，除非改变主版本号，以下功能均会被维护。

## 设置结构
`GiscusSetting`、`MainScriptSetting`、`PageSetting`、`PageSetting` 设置结构主要用于传参。

`default_parser()` 可生成支持恰当多功能的 Markdown 解析器，该解析器来自 CommonMark 包。

## 文档树结构

## Markdown 处理
`ify_md` 原型 `ify_md(s::AbstractString, pss::PagesSetting, accept_crlf::Bool = true)`，直接将 Markdown 格式的文本 `s` 转为 HTML。

`childrenhtml` 原型 `childrenhtml(node::CommonMark.Node, pss::PagesSetting)` 用于辅助，对 `node` 所有子节点应用 `mkhtml` 并合并。

`mkhtml` 原型 `mkhtml(node::CommonMark.Node, c::CommonMark.AbstractContainer, pss::PagesSetting)`，用于对 `node` 数据（递归地）生成 HTML。其中 `c` 等于 `node.t`，用于派发。

### 代码块处理
`highlight` 一个原型是 `highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)`，对于一个代码块，`code` 为内部内容，`language` 为标题，调用此函数转为 HTML。
另一个原型是 `highlight(::Val, code::AbstractString, pss::PagesSetting, args)` 用于对于指定类型的代码块生成 HTML。第一个参数用于派发，等于 `args[1]`，`args` 是原标题解析后得到的。

`highlight_directly` 原型 `highlight_directly(language, code::AbstractString, pss::PagesSetting)`，用于对无需解析标题的代码块调用恰当的 `highlight`（Ⅱ）方法。

## 生成单个文档 HTML
`makehtml` 原型 `makehtml(pss::PagesSetting, ps::PageSetting)`，用于生成单个文档 HTML。嵌入模板中的 HTML 作为 `ps.mds` 传参。

## 主流程
`generate` 是文档生成的最顶级功能函数，原型是 `generate(srcdir::AbstractString, tardir::AbstractString, build_setting::AbstractString = "DoctreeBuild.toml")` 与 `generate(srcdir::AbstractString, tardir::AbstractString, pss::PagesSetting)`：将 `srcdir` 目录下文档的生成结果置于 `tardir` 下。

`scan_rec` 是文档生成时的递归扫描函数，会将信息载入 `Doctree` 结构，并调用 `filedeal` 进行预处理。原型是 `scan_rec(tree::Doctree, pss::PagesSetting; outlined::Bool, path::String, pathv::Vector{String})`。

`make_rec` 是文档生成时的递归处理函数，会读取 `Doctree` 内容，递归地给预处理得到的 HTML 套壳（包括生成前后篇箭头）。原型是 `make_rec(tree::Doctree, pss::PagesSetting; path::String, pathv::Vector{String})`。

## 单文件生成
`filedeal` 是单个文件的处理函数，原型是 `filedeal(::Val; fbase::FileBase, pss::PagesSetting)`。第一个参数是文件后缀，函数借此进行派发。若函数自身只是进行预处理，需把数据置于 `fbase.data` 中并设置 `fbase.target`，若进行了完全处理，应设置 `fbase.generated = true`。

## 操作辅助
`github_action` 原型 `github_action(setting::Union{AbstractString, PagesSetting} = "DoctreeBuild.toml")`，用于配合 `peaceiris/actions-gh-pages` 直接在 Github Action 脚本中调用生成功能。

`template` 原型 `template(;print_help::Bool = true)`，用于生成文档模板（包含 Github Action 脚本）。
