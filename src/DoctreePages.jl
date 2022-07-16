"""
A lightweight interactive document generator.

Read `generate` `PagesSetting` `GiscusSetting`
"""
module DoctreePages
export GiscusSetting, PagesSetting
export generate

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
include("tree.jl")

end
