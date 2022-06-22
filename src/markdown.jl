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

@inline function childrenhtml(node::CommonMark.Node, pss::PagesSetting, wrap::String="")
	current=node.first_child
	if !isdefined(current, :t)
		return ""
	end
	str=""
	while true
		str*=wrap=="" ? mkhtml(current, current.t, pss) : "<$wrap>$(mkhtml(current, current.t, pss))</$wrap>"
		if current===node.last_child
			break
		end
		current=current.nxt
	end
	return str
end

function mkhtml(node::CommonMark.Node, ::CommonMark.AbstractContainer, ::PagesSetting)
	return html(node)
end

# block
function mkhtml(node::CommonMark.Node, ::CommonMark.Document, pss::PagesSetting)
	return childrenhtml(node, pss)
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Paragraph, pss::PagesSetting)
	return "<p>$(childrenhtml(node, pss))</p>"
end

# block
function mkhtml(node::CommonMark.Node, h::CommonMark.Heading, pss::PagesSetting)
	lv=h.level
	return "<h$lv>$(childrenhtml(node, pss))</h$lv>"
end
function mkhtml(node::CommonMark.Node, c::CommonMark.CodeBlock, pss::PagesSetting)
	lang=c.info
	code=node.literal
	return highlight(lang, code, pss)
end
function mkhtml(::CommonMark.Node, ::CommonMark.ThematicBreak, ::PagesSetting)
	return "<hr />"
end
function mkhtml(node::CommonMark.Node, f::CommonMark.FootnoteDefinition, pss::PagesSetting)
	ch=node.first_child
	return "<p id='footnote-$(f.id)'>$(f.id). $(mkhtml(ch, ch.t, pss))</p>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.BlockQuote, pss::PagesSetting)
	ch=node.first_child
	return "<blockquote>$(mkhtml(ch, ch.t, pss))</blockquote>"
end
function mkhtml(node::CommonMark.Node, l::CommonMark.List, pss::PagesSetting)
	return l.list_data.type==:ordered ? childrenhtml(node, pss, "ol") : childrenhtml(node, pss, "ul")
end
function mkhtml(node::CommonMark.Node, ad::CommonMark.Admonition, pss::PagesSetting)
	title=ad.title
	cat=ad.category
	if cat=="note" || cat=="tips"
		cat="info"
	elseif cat=="warn"
		cat="warning"
	end
	return "<div class='admonition is-$cat'><header class='admonition-header'>$title</header><div class='admonition-body'>$(childrenhtml(node, pss))</div></div>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Table, pss::PagesSetting)
	return "<table>$(childrenhtml(node, pss))</table>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableHeader, pss::PagesSetting)
	return "<tr>$(childrenhtml(node, pss, "th"))</tr>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableBody, pss::PagesSetting)
	return "<tr>$(childrenhtml(node, pss, "td"))</tr>"
end

# inline
function mkhtml(node::CommonMark.Node, ::CommonMark.Text, ::PagesSetting)
	return html_safe(node.literal)
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Emph, pss::PagesSetting)
	return "<em>$(childrenhtml(node, pss))</em>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Strong, pss::PagesSetting)
	return "<strong>$(childrenhtml(node, pss))</strong>"
end
function mkhtml(node::CommonMark.Node, link::CommonMark.Link, pss::PagesSetting)
	htm=childrenhtml(node, pss)
	url=link.destination
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
function mkhtml(::CommonMark.Node, ::Union{CommonMark.Backslash, CommonMark.LineBreak}, ::PagesSetting)
	return "<br />"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Code, pss::PagesSetting)
	return "<code>$(childrenhtml(node, pss))</code>"
end
function mkhtml(::CommonMark.Node, l::CommonMark.FootnoteLink, ::PagesSetting)
	return "<sup><a href=\"#footnote-$(l.id)\">[$(l.id)]</a></sup>"
end
