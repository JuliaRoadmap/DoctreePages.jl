function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, AbstractString})
		return highlight(Val(sym), code)
	else
		lines=split(code, '\n'; keepempty=true)
		vec=map(x -> ("plain" => html_safe(x; br=false),), lines)
		return buildcodeblock(language, vec)
	end
end

function col(content::AbstractString, co::String; br=true)
	if content=="" return "" end
	t=String(content)
	t=replace(t, "&"=>"&amp;")
	t=replace(t, "<"=>"&lt;")
	t=replace(t, ">"=>"&gt;")
	t=replace(t, " "=>"&nbsp;")
	return co => (br ? replace(t,"\n"=>"<br />") : t)
end

function buildcodeblock(language::AbstractString, str::AbstractString)
	return "<div class='language language-$language'><div class='codeblock-header'></div><div class='codeblock-body'>$str</div></div><br />"
end
function buildcodeblock(language::AbstractString, vec::AbstractVector)
	l=length(vec)
	s=""
	for i in 1:l
		line=vec[i]
		for pair in line
			typeassert(pair, Pair)
			s*="<span class='hl-$(pair.first)'>$(pair.second)</span>"
		end
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
