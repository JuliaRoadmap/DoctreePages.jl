function ify_md(s::String, pss::PagesSetting)
	s=replace(s, "\r"=>"")
	md=Markdown.parse(s)
	return ify(md.content, pss)
end
function md_withtitle(s::String, pss::PagesSetting)
	s=replace(s, "\r"=>"")
	md=Markdown.parse(s)
	if isempty(md.content)
		str=lw(pss, 1)
		@error str
		return Pair("<p></p>", str)
	end
	ti=md.content[1]::Markdown.Header{1}
	con=""
	try
		con=ify(md.content, pss)
	catch er
		buf=IOBuffer()
		showerror(buf, er)
		str=String(take!(buf))
		con="<p>$(html_safe(str))</p>"
		@error str
	end
	return Pair(con,ti.text[1])
end

# global
ify(s::String, ::PagesSetting)="<p>$(html_safe(s))</p>"
function ify(content::Vector, pss::PagesSetting)
	s=""
	for el in content
		s*=ify(el, pss)
	end
	return s
end

# block
function ify(p::Paragraph, pss::PagesSetting)
	return ify(p.content, pss)
end
function ify(h::Header, ::PagesSetting)
	lv=typeof(h).parameters[1]
	text=h.text[1]
	return "<h$lv id=\"header-$text\">$text</h$lv>"
end
function ify(c::Code, pss::PagesSetting)
	return highlight(c.language, c.code, pss)
end
function ify(f::Footnote, pss::PagesSetting)
	if f.text === nothing
		return "<sup><a href=\"#footnote-$(f.id)\">$(f.id)</a></sup>"
	else
		text=f.text[1].content[1]
		html= startswith(text,"https://") ? "<a href=\"$text\" target=\"_blank\">$text</a>" : ify(f.text, pss)
		return (f.id=="1" ? "<br />" : "")*"<br /><p id=\"footnote-$(f.id)\">$(f.id). </p>"*html
	end
end
function ify(b::BlockQuote, pss::PagesSetting)
	return "<blockquote>$(ify(b.content, pss))</blockquote>"
end
function ify(a::Admonition, pss::PagesSetting)
	cat=a.category
	title=a.title
	if cat=="note" || cat=="tips"
		cat="info"
	elseif cat=="warn"
		cat="warning"
	end
	return "<div class=\"admonition is-$cat\"><header class=\"admonition-header\">$title</header><div class=\"admonition-body\"><p>$(ify(a.content, pss))</p></div></div>"
end
function ify(l::List, pss::PagesSetting)
	if l.ordered==-1
		s="<ul>"
		for el in l.items
			s*="<li>$(ify(el, pss))</li>"
		end
		return s*"</ul>"
	else
		s="<ol>"
		for el in l.items
			s*="<li>$(ify(el, pss))</li>"
		end
		return s*"</ol>"
	end
end
ify(::HorizontalRule, ::PagesSetting)="<hr />"

# inline
ify(b::Bold, ::PagesSetting)="<strong>$(html_safe(b.text[1]))</strong>"
ify(i::Italic, ::PagesSetting)="<em>$(html_safe(i.text[1]))</em>"
ify(i::Image, ::PagesSetting)="<img src=\"$(i.url)\" alt=\"$(i.alt)\" />"
function ify(l::Link, pss::PagesSetting)
	htm=ify(l.text, pss)
	url=l.url
	# 特殊处理
	if startswith(url,"#")
		return "<a href=\"#header-$(url[2:end])\">$htm</a>"
	end
	if !startswith(url,"https://")
		has=findlast('#',url)
		if has!==nothing
			ma=findfirst(r".md#.*$",url)
			if ma!==nothing
				url=url[1:ma.start-1]*pss.filesuffix*"#header-"*url[ma.start+4:ma.stop]
			else
				ma=findfirst(r".txt#.*$",url)
				if ma!==nothing
					url=url[1:ma.start-1]*pss.filesuffix*url[ma.start+4:ma.stop]
				end
			end
		else
			if findlast(".md",url)!==nothing
				url=url[1:sizeof(url)-3]*pss.filesuffix
			elseif findlast(".jl",url)!==nothing
				url=url[1:sizeof(url)-3]*pss.filesuffix
			elseif findlast(".txt",url)!==nothing
				url=url[1:sizeof(url)-4]*pss.filesuffix
			end
		end
	end
	return "<a href=\"$(url)\" target=\"_blank\">$htm</a>"
end
ify(::LineBreak, ::PagesSetting)="<br />"

# table
function ify(t::Table, pss::PagesSetting)
	s="<table>"
	fi=true
	for v in t.rows
		s*="<tr>"
		if fi
			fi=false
			for st in v
				s*="<th>$(ify(st, pss))</th>"
			end
		else
			for st in v
				s*="<td>$(ify(st, pss))</td>"
			end
		end
		s*="</tr>"
	end
	return s*"</table>"
end

# latex
function ify(l::LaTeX, ::PagesSetting)
	return "<p>$(l.formula)</p>"
end
