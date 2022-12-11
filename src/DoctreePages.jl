"""
A lightweight interactive document generator.

Please read docs on https://juliaroadmap.github.io/DoctreePages.jl/docs
"""
module DoctreePages
export GiscusSetting, MainScriptSetting, PagesSetting
export generate
export github_action

# 用于自行编写脚本的用户
export PageSetting, default_parser
export ify_md, md_withtitle, childrenhtml, mkhtml
export highlight, buildhljsblock
export makehtml
export makescript
export Node, readbuildsetting, gen_rec, make_rec, makemenu, makeindex, make404, makeinfo_script, file2node

include("htmlmanage.jl")
function rep(str::AbstractString)
	return replace(str, '`' => "\\`")
end

const language_tags=[
	(en="content empty", zh="内容为空"),
	(en="edit this", zh="编辑此页面"),
	(en="setting", zh="设置"),
	(en="pick theme", zh="选择主题"),
	(en="docs", zh="文档"),
	(en="index", zh="索引"),
	(en="main", zh="主页"),
	(en=" index", zh="索引"),
	(en="parent index", zh="上层索引"),
	(en="Requested source unfound :(", zh="请求的资源未找到"),
]

const DTP_VERSION = v"1.4.3"

using CommonMark
# using CommonHighlight
include("setting.jl")

function lw(pss::PagesSetting, id::Integer)
	sym=Symbol(pss.lang)
	named=language_tags[id]
	if haskey(named, sym)
		return getproperty(named, sym)
	else
		return named.en
	end
end

include("markdown.jl")

using JSON3
using TOML
include("highlighter.jl")
include("tohtml.jl")
include("scripts.jl")

using Pkg
include("tree.jl")
include("file2node.jl")
include("git.jl")

include("template.jl")

end
