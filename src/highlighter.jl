function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, AbstractString})
		middle=highlight(Val(sym), code)
		return startswith(language, "insert") ? middle : "<div class='language language-$language'>$middle</div>"
	else
		return "<div class='language language-$language'>$(html_safe(code))</div>"
	end
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
	reg=length(tup)==3 ? tup[3].pattern : "^$esc\$"
	return """<div class="fill-area"><p>$des</p><br />
	<input type="text" placeholder="ans">
	<button class="submit-fill" data-ans="$reg">📤</button>
	<button class="ans-fill" data-ans="$esc">🔑</button>
	</div>"""
	# 💡
end
