function ify_md(s::AbstractString, pss::PagesSetting, accept_crlf::Bool = true)
	if accept_crlf s=replace(s, "\r"=>"") end
	md=pss.parser(s)
	return mkhtml(md, md.t, pss)
end
function md_withtitle(s::AbstractString, pss::PagesSetting, accept_crlf::Bool = true)
	if accept_crlf s=replace(s, "\r"=>"") end
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

#= @inline =# function childrenhtml(node::CommonMark.Node, pss::PagesSetting)
	current=node.first_child
	if !isdefined(current, :t)
		return ""
	end
	str=""
	while true
		str*=mkhtml(current, current.t, pss)
		if current===node.last_child
			break
		end
		current=current.nxt
	end
	return str
end

function mkhtml(node::CommonMark.Node, c::CommonMark.AbstractContainer, pss::PagesSetting)
	str="no method for Markdown Container ($(typeof(c)))"
	if pss.throwall
		error(str)
	else
		@warn str
	end
	return html(node)
end

# block
function mkhtml(node::CommonMark.Node, ::CommonMark.Document, pss::PagesSetting)
	return childrenhtml(node, pss)
end
function mkhtml(node::CommonMark.Node, ::CommonMark.HtmlBlock, ::PagesSetting)
	return node.literal
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Paragraph, pss::PagesSetting; inline=false)
	return inline ? "<span>$(childrenhtml(node, pss))</span>" : "<p>$(childrenhtml(node, pss))</p>"
end
function mkhtml(node::CommonMark.Node, h::CommonMark.Heading, pss::PagesSetting)
	lv = h.level
	text = childrenhtml(node, pss)
	text = replace(lowercase(text), ' ' => '-')
	return "<h$lv id='header-$text'>$text<a class='docs-heading-anchor-permalink'></a></h$lv>"
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
	return "<div id='footnote-$(f.id)' class='footnote'><span>$(f.id). </span>$(childrenhtml(node, pss))</div>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.BlockQuote, pss::PagesSetting)
	return "<blockquote>$(childrenhtml(node, pss))</blockquote>"
end
function mkhtml(node::CommonMark.Node, l::CommonMark.List, pss::PagesSetting)
	ch=childrenhtml(node, pss)
	return l.list_data.type==:ordered ? "<ol>$ch</ol>" : "<ul>$ch</ul>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Item, pss::PagesSetting)
	return "<li>$(childrenhtml(node, pss))</li>"
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
	return "<table style='float:center'>$(childrenhtml(node, pss))</table>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableHeader, pss::PagesSetting)
	return "<thead>$(childrenhtml(node, pss))</thead>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableBody, pss::PagesSetting)
	return "<tbody>$(childrenhtml(node, pss))</tbody>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableRow, pss::PagesSetting)
	return "<tr>$(childrenhtml(node, pss))</tr>"
end
function mkhtml(node::CommonMark.Node, cell::CommonMark.TableCell, pss::PagesSetting)
	ta=pss.table_align
	if ta=="inherit"
		return "<td>$(childrenhtml(node, pss))</td>"
	end
	align=pss.table_align=="auto" ? cell.align : pss.table_align
	return "<td style='float:$align'>$(childrenhtml(node, pss))</td>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.DisplayMath, ::PagesSetting)
	return "<div class='display-math tex'>$(html_safe(node.literal))</div>"
end
function mkhtml(node::CommonMark.Node, ::Union{CommonMark.HtmlInline, CommonMark.HtmlBlock}, ::PagesSetting)
	return node.literal
end

# inline
function mkhtml(node::CommonMark.Node, ::CommonMark.HtmlInline, ::PagesSetting)
	return node.literal
end
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
	if startswith(url, '#')
		return "<a href='#header-$(url[2:end])'>$htm</a>"
	elseif startswith(url, '/')
		url=joinpath(pss.server_prefix, url[2:end])
	elseif !startswith(url, "https://") && !startswith(url, "http://")
		dot=findlast('.', url)
		if dot !== nothing
			has=findlast('#', url)
			if has===nothing
				url=url[1:prevind(url, dot)]*pss.filesuffix
			elseif has > dot
				suf=url[dot+1:prevind(url, has)]
				if suf=="md"
					url=url[1:prevind(url, dot)]*pss.filesuffix*"#header-"*url[has+1:end]
				else
					url=url[1:prevind(url, dot)]*pss.filesuffix*url[has:end]
				end
			end
		end
	end
	return "<a href='$url' target='_blank'>$htm</a>"
end
function mkhtml(node::CommonMark.Node, img::CommonMark.Image, pss::PagesSetting)
	fc = node.first_child
	alt = isdefined(fc, :literal) ? fc.literal : pss.default_alt
	dest = img.destination
	if startswith(dest, "/")
		dest=joinpath(pss.server_prefix, dest[2:end])
	end
	return "<img src='$dest' alt='$alt'>"
end
function mkhtml(::CommonMark.Node, ::Union{CommonMark.Backslash, CommonMark.LineBreak}, ::PagesSetting)
	return "<br />"
end
mkhtml(::CommonMark.Node, ::CommonMark.SoftBreak, ::PagesSetting)=""
function mkhtml(node::CommonMark.Node, ::CommonMark.Code, ::PagesSetting)
	return "<code>$(html_safe(node.literal))</code>"
end
function mkhtml(::CommonMark.Node, l::CommonMark.FootnoteLink, ::PagesSetting)
	return "<sup><a href=\"#footnote-$(l.id)\">[$(l.id)]</a></sup>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Math, ::PagesSetting)
	return "<span class='math tex'>$(html_safe(node.literal))</span>"
end
