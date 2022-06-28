function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, AbstractString})
		middle=highlight(Val(sym), code)
		special=startswith(language, "insert-") || startswith(language, "is-")
		return special ? middle : "<div class='language language-$language'><div class='codeblock-header'></div><div class='codeblock-body'>$middle</div></div><br />"
	else
		return "<div class='language language-$language'><div class='codeblock-header'></div><div class='codeblock-body'>$(html_safe(code))</div></div><br />"
	end
end

safecol(content::AbstractString, co::AbstractString)="<span class=\"hl-$co\">$content</span>"
function col(content::AbstractString, co::String; br=true)
	if content=="" return "" end
	t=String(content)
	t=replace(t, "&"=>"&amp;")
	t=replace(t, "<"=>"&lt;")
	t=replace(t, ">"=>"&gt;")
	t=replace(t, " "=>"&nbsp;")
	return "<span class=\"hl-$co\">$(br ? replace(t,"\n"=>"<br />") : t)</span>"
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
