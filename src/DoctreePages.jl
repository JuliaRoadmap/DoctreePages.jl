"""
A lightweight interactive document generator.

Read [generate](@ref) [PagesSetting](@ref) [GiscusSetting](@ref)
"""
module DoctreePages
export GiscusSetting, PagesSetting
export generate

function html_safe(s::AbstractString)
	t=replace(s, "<"=>"&lt;")
	t=replace(t, ">"=>"&gt;")
	t=replace(t, "&"=>"&quot;")
	t=replace(t, "\n"=>"<br />")
	return t
end

include("setting.jl")
using Markdown
using Markdown: Paragraph,Header,Code,Footnote,BlockQuote,Admonition,List,HorizontalRule
using Markdown: Italic,Bold,Image,Link,LineBreak
using Markdown: Table
using Markdown: LaTeX
include("markdown.jl")
include("highlighter.jl")
include("highlighter_jl.jl")
include("tohtml.jl")

using TOML
include("tree.jl")

end
