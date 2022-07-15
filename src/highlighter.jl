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
	tup=eval(Meta.parse(content))::Tuple
	des=tup[1]::String
	des=html_safe(des)
	des=replace(des,"\n"=>"<br />")
	esc=escape_string(tup[2])
	noreg=length(tup)!=3
	reg=noreg ? esc : tup[3].pattern
	return """<div class="fill-area"><p>$des</p><input type="text" placeholder="ans"><button class="submit-fill" data-ans="$reg" data-isreg="$(!noreg)">📤</button><button class="ans-fill" data-ans="$esc">🔑</button></div>"""
	# 💡
end
function highlight(::Val{Symbol("insert-highlight")}, content::AbstractString)
	toml = TOML.parse(content)
end
