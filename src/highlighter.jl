function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, AbstractString})
		return highlight(Val(sym), code)
	else
		return buildcodeblock(language, highlight_lines(language, code))
	end
end

function buildcodeblock(language::AbstractString, str::AbstractString)
	return "<div class='language language-$language'><div class='codeblock-header'></div><div class='codeblock-body'><div class='codeblock-num'></div><div class='codeblock-code'>$str</div></div></div><br />"
end
function buildcodeblock(language::AbstractString, lines::HighlightLines)
	l=length(lines.lines)
	s=""
	for i in 1:l
		line=lines.lines[i]
		for pair in line
			typeassert(pair, Pair)
			s*="<span class='hl-$(pair.first)'>$(html_safe(pair.second))</span>"
		end
		s*="<br />"
	end
	return buildcodeblock(language, s)
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
