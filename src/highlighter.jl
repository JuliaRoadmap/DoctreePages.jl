function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	space = findfirst(' ', language)
	if space!==nothing
		language = language[1:space-1]
	end
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, typeof(code), PagesSetting})
		return highlight(Val(sym), code, pss)
	elseif pss.hljs_all
		return buildhljsblock(language, code)
	#=
	elseif hasmethod(highlight_lines, Tuple{Val{sym}, typeof(code), CommonHighlightSetting})
		return buildcodeblock(language, highlight_lines(sym, code, pss.highlighter))
	=#
	else
		msg = "pss.hljs_all = false not yet supported"
		pss.throwall ? error(msg) : (@warn msg)
		return buildhljsblock(language, code)
	end
end

function buildhljsblock(language::AbstractString, str::AbstractString)
	code = html_nobr_safe(str)
	return "<div data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language'><code>$code</code></pre></div><br />"
end

include("codeblocks/insert_html.jl")
include("codeblocks/insert_fill.jl")
include("codeblocks/insert_setting.jl")
include("codeblocks/insert_test.jl")
include("codeblocks/hide.jl")
include("codeblocks/encoded.jl")

# https://github.com/inkle/ink
# function highlight(::Val{Symbol("insert-ink")}, content::AbstractString, pss::PagesSetting)
# end
