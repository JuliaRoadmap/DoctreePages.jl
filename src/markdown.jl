function ify_md(s::String, pss::PagesSetting)
	s=replace(s, "\r"=>"")
	md=pss.parser(s)
	return mkhtml(md, md.t, pss)
end
function md_withtitle(s::String, pss::PagesSetting)
	s=replace(s, "\r"=>"")
	md=pss.parser(s)
	con=""
	try
		con=mkhtml(md, md.t, pss)
	catch er
		if pss.throwall
			throw(er)
		end
		buf=IOBuffer()
		showerror(buf, er)
		str=String(take!(buf))
		con="<p>$(html_safe(str))</p>"
		@error str
	end
	return Pair(con, md.first_child.first_child.literal)
end
# block
function mkhtml(node::CommonMark.Node, ::CommonMark.Document, pss::PagesSetting)
	str="<p>"
	current=node.first_child
	while true
		next=current.nxt
		if next==current
			break
		end
		str*=mkhtml(next, next.t, pss)
		current=next
	end
	return str*"</p>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Paragraph, pss::PagesSetting)
	str="<p>"
	current=node.first_child
	while true
		next=current.nxt
		if next==current
			break
		end
		str*=mkhtml(next, next.t, pss)
		current=next
	end
	return str*"</p>"
end

# block
function mkhtml(node::CommonMark.Node, h::CommonMark.Heading, ::PagesSetting)
	lv=h.level
	return "<h$lv>$(html_safe(node.first_child.literal))</h$lv>"
end
function mkhtml(node::CommonMark.Node, c::CommonMark.CodeBlock, pss::PagesSetting)
	lang=c.info
	code=node.literal
	return highlight(lang, code, pss)
end

# inline
function mkhtml(node::CommonMark.Node, ::CommonMark.Text, ::PagesSetting)
	return "<p>$(html_safe(node.literal))</p>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Emph, ::PagesSetting)
	return "<em>$(html_safe(node.first_child.literal))</em>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Strong, ::PagesSetting)
	return "<strong>$(html_safe(node.first_child.literal))</strong>"
end
function mkhtml(node::CommonMark.Node, link::CommonMark.Link, pss::PagesSetting)
	htm=mkhtml(node.first_child, node.first_child.t, pss)
	# 特殊处理
	if startswith(url,"#")
		return "<a href='#header-$(url[2:end])'>$htm</a>"
	end
	if !startswith(url, "https://") && !startswith(url, "http://")
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
			dot=findlast('.', url)
			if dot !== nothing
				url=url[1:dot-1]*pss.filesuffix
			end
		end
	end
	return "<a href='$url' target='_blank'>$htm</a>"
end
function mkhtml(node::CommonMark.Node, img::CommonMark.Image, ::PagesSetting)
	return "<img src='$(img.destination)' alt='$(node.first_child.literal)'>"
end
function mkhtml(::CommonMark.Node, ::CommonMark.Backslash, ::PagesSetting)
	return "<br />"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Code, ::PagesSetting)
	return "<code>$(html_safe(node.first_child.literal))</code>"
end

# block
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
