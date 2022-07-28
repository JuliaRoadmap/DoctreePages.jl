"""
A lightweight interactive document generator.

Read `generate` `PagesSetting`
"""
module DoctreePages
export GiscusSetting, MainScriptSetting, PagesSetting
export generate
export github_action

# 用于自行编写脚本的用户
export PageSetting, default_parser
export ify_md, md_withtitle, childrenhtml, mkhtml
export highlight, buildcodeblock, buildhljsblock
export makehtml
export makescript
export Node, readbuildsetting, gen_rec, make_rec, makemenu, makeindex, make404, makeinfo_js, file2node

function html_safe(s::AbstractString; br=true)
	t=replace(s, "&"=>"&amp;")
	t=replace(t, "<"=>"&lt;")
	t=replace(t, ">"=>"&gt;")
	if br
		t=replace(t, "\n"=>"<br />")
	end
	return t
end
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

const DTP_VERSION = v"1.3.0"

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

include("highlighter.jl")
include("tohtml.jl")
include("scripts.jl")

using TOML
using Pkg
include("tree.jl")
include("git.jl")

end
