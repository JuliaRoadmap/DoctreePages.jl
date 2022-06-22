"""
A lightweight interactive document generator.

Read [generate](@ref) [PagesSetting](@ref) [GiscusSetting](@ref)
"""
module DoctreePages
export GiscusSetting, PagesSetting
export generate

function html_safe(s::AbstractString)
	t=replace(s, "&"=>"&amp;")
	t=replace(t, "<"=>"&lt;")
	t=replace(t, ">"=>"&gt;")
	t=replace(t, "\n"=>"<br />")
	return t
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
]

using CommonMark
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
include("highlighter_jl.jl")
include("tohtml.jl")

using TOML
include("tree.jl")

end
