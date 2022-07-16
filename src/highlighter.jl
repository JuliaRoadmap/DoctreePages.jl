function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, typeof(code)})
		return highlight(Val(sym), code)
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

function buildcodeblock(language::AbstractString, str::AbstractString)
	return "<div class='data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language nohighlight'><code>$str</code></pre></div><br />"
end
#= function buildcodeblock(language::AbstractString, lines::HighlightLines)
	return buildcodeblock(language, html(lines))
end =#

function buildhljsblock(language::AbstractString, str::AbstractString)
	return "<div data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language'><code>$str</code></pre></div><br />"
end

function highlight(::Val{Symbol("insert-html")}, content::AbstractString)
	return content
end
function highlight(::Val{Symbol("insert-fill")}, content::AbstractString)
	dict=TOML.parse(content)
	con=dict["content"]::String
	con=ify_md(des, pss)
	esc=escape_string(dict["ans"])
	usereg=haskey(dict, "ans_regex")
	reg=usereg ? dict["ans_regex"] : esc
	return string(
		"<div class='fill-area'>", con, "<input type='text' placeholder='ans'",
		"<button class='submit-fill' data-ans='$reg' data-isreg='$usereg'>📤</button>",
		"<button class='ans-fill' data-ans='$esc'>🔑</button>",
		haskey(dict, "instruction") ? "<button class='instruction-fill' data-con='$(escape_string(dict["instruction"]))'>💡</button>" : "",
		"</div>"
	)
end
function highlight(::Val{Symbol("insert-highlight")}, content::AbstractString)
	toml = TOML.parse(content)
end
