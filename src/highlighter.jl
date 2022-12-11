function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	langs = split(language, ' '; keepempty=false)
	if isempty(langs)
		@warn "No codeblock type information given."
		return buildhljsblock("plain", code)
	end
	if startswith(language, "is-") # 兼容旧版本
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	language = langs[1]
	sym = Symbol(language)
	return highlight(Val(sym), code, pss, langs)
end

function buildhljsblock(language::AbstractString, str::AbstractString)
	code = html_nobr_safe(str)
	return "<div data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language'><code>$code</code></pre></div><br />"
end

function highlight(::Val, code::AbstractString, pss::PagesSetting, args)
	language = args[1]
	if pss.hljs_all
		return buildhljsblock(language, code)
	else
		msg = "pss.hljs_all = false not yet supported"
		pss.throwall ? error(msg) : (@warn msg)
		return buildhljsblock(language, code)
	end
end

include("codeblocks/encoded.jl")
include("codeblocks/hide.jl")
include("codeblocks/insert_html.jl")
include("codeblocks/insert_fill.jl")
include("codeblocks/insert_setting.jl")
include("codeblocks/insert_test.jl")
include("codeblocks/random_word.jl")

# https://github.com/inkle/ink
# function highlight(::Val{Symbol("insert-ink")}, content::AbstractString, pss::PagesSetting)
# end
