# 使用方式
## 导引
当你使用这个包生成一批 HTML 时，需要待处理数据与文档设置配置。对于前者，您可以自行学习 Markdown 等文档格式。
如有疑问，可发布在仓库的 issue 处。

## 基于参数生成
`generate` 函数的核心方法接受三个参数：源目录 srcdir、目标目录 tardir、设置数据 pss
* 源目录：包含待处理的数据（Markdown、纯文本等）
* 目标目录：用于存放处理结果（HTML 等）
* 设置数据：一个 `PagesSetting` 实例

目录下的结构参照[规范 - 目录管理](guidelines.md#目录管理)。

`PagesSetting` 构造函数使用了大量 keyword 参数，以下是各键说明。若要查看更具体的功效，可在源代码中进行关键字搜索。

| 键名 | 描述 |
| --- | --- |
| buildmessage | 构建信息 |
| charset | 源文件的字符集 |
| default_alt | 图像的默认替换文字 |
| favicon_path | favicon 的路径，若无则为 `""` |
| filesuffix | 生成文件的后缀 |
| giscus | Giscus 设置 |
| lang | 使用语言（`en`、`zh` 等） |
| logo_path | logo 的路径，若无则为 `""` |
| main_script | `main.js` 的设置 |
| make404 | 是否创建 404 页面 |
| make_index | 是否创建索引页 |
| page_foot | 页面底端嵌入的 html |
| parser | CommonMark 解析器 |
| remove_origin | 生成前是否先移除过去生成的内容 |
| repo_branch | 仓库的分支名称 |
| repo_name | 仓库的名称 |
| repo_owner | 仓库的所有者名称 |
| repo_path | 到仓库默认分支的完整路径 |
| show_info | 是否在生成时调用 `@info` |
| src_assets | 参阅[guidelines](guidelines.md#目录管理) |
| src_script | 参阅[guidelines](guidelines.md#目录管理) |
| table_align | 表格对齐方式 |
| tar_assets | 生成的包含 `assets` 的目录名 |
| tar_css | 生成的包含 `css` 的目录名 |
| tar_extra | 生成的包含本包额外数据的目录名 |
| tar_script | 生成的包含脚本的目录名 |
| throwall | 是否抛出非致命错误 |
| title | 标题 |
| theme | 展示的 css 主题 |
| unfound | 404 错误时可显示的页面链接（若无文件则自动生成） |
| wrap_html | 是否对 html 文件进行包裹 |

1. 所有的键都提供了默认值
2. `unfound` 值表示的文件应在同一目录下
3. 以 `src_` 或 `tar_` 开头的对应值应只是目录名，不应含有 `/`（目录分隔符）
4. 如果源数据在仓库中，应提供 `repo_name` 与 `repo_owner`，它们用于填写“编辑”按钮的链接

## 配置文件
`generate` 函数的另一个方法的第三个参数为字符串，表示配置文件的路径，默认是 `DoctreeBuild.toml`。

配置文件应使用 TOML 格式 [^1]，其中
* `version` 项表明最低支持的 `DoctreePages` 版本，1.3 之后支持[像这样的更复杂的设置](https://pkgdocs.julialang.org/v1/compatibility/)
* `pages`、`giscus`、`mainscript` 表分别表示总设置、`giscus` 设置与 `main_script` 设置
* 除字符串与布尔值以外，不支持更高级的值配置

## Github Action
可以使用 Github Action 自动将更新的文档处理，再推送到 Github Pages 或其它服务器。
样例如下：
```yaml
name: Build Docs
on:
  push:
    branches: [master]
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    if: "!(contains(github.event.head_commit.message, '[nobuild]'))"
    steps:
      - uses: actions/checkout@v3
      - run: |
          julia -e '
            using Pkg
            Pkg.add(name="DoctreePages")
            using DoctreePages
            github_action()
          '
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: "./public"
```

它会在 commit message 不含 `[nobuild]` 时运行本包，并构建 Github Pages。

利用 `template()`，可以在当前目录生成一个用于文档自动构建的模板。

## 构建脚本
如果你想，你可以选择自己调用、重载提供的函数编写构建脚本。

[^1]: TOML 是一种配置文件格式，语法说明参考[此文](https://github.com/LongTengDao/TOML/blob/%E9%BE%99%E8%85%BE%E9%81%93-%E8%AF%91/toml-v1.0.0.md)
