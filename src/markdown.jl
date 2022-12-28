function ify_md(s::AbstractString, pss::PagesSetting, accept_crlf::Bool = true)
	if accept_crlf s = replace(s, "\r"=>"") end
	md = pss.parser(s)
	return mkhtml(md, md.t, pss)
end

#= @inline =# function childrenhtml(node::CommonMark.Node, pss::PagesSetting)
	current = node.first_child
	if !isdefined(current, :t)
		return ""
	end
	str = ""
	while true
		str *= mkhtml(current, current.t, pss)
		if current===node.last_child
			break
		end
		current = current.nxt
	end
	return str
end

function mkhtml(node::CommonMark.Node, c::CommonMark.AbstractContainer, pss::PagesSetting)
	str = "no method for Markdown Container ($(typeof(c)))"
	if pss.throwall
		error(str)
	end
	@warn str
	return html(node)
end

# block
function mkhtml(node::CommonMark.Node, ::CommonMark.Document, pss::PagesSetting)
	pss.footnote_region_start = false
	str = childrenhtml(node, pss)
	if pss.footnote_region_start
		pss.footnote_region_start = false
		str*="</ul></section>"
	end
	return str
end
function mkhtml(node::CommonMark.Node, ::CommonMark.HtmlBlock, ::PagesSetting)
	return node.literal
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Paragraph, pss::PagesSetting; inline=false)
	return inline ? "<span>$(childrenhtml(node, pss))</span>" : "<p>$(childrenhtml(node, pss))</p>"
end
function mkhtml(node::CommonMark.Node, h::CommonMark.Heading, pss::PagesSetting)
	lv = h.level
	orgtext = childrenhtml(node, pss)
	text = replace(lowercase(orgtext), ' ' => '-')
	return "<h$lv id='header-$text'>$orgtext<a class='docs-heading-anchor-permalink'></a></h$lv>"
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
	foot = "<li id='footnote-$(f.id)' class='footnote'><a class='tag is-link' href='#citeref-$(f.id)'>$(f.id)</a>\n$(childrenhtml(node, pss))</li>"
	if !pss.footnote_region_start
		pss.footnote_region_start = true
		foot = "\n<section class='footnotes is-size-7'><ul>"*foot
	end
	return foot
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
	return "<table>$(childrenhtml(node, pss))</table>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableHeader, pss::PagesSetting)
	if !pss.table_tight
		return "<thead>$(childrenhtml(node, pss))</thead>"
	end
	pss.header_region_start = true
	str = childrenhtml(node, pss)
	pss.header_region_start = false
	return str
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableBody, pss::PagesSetting)
	str = childrenhtml(node, pss)
	return pss.table_tight ? str : "<tbody>$str</tbody>"
end
function mkhtml(node::CommonMark.Node, ::CommonMark.TableRow, pss::PagesSetting)
	str = childrenhtml(node, pss)
	return pss.header_region_start ? "<th>$str</th>" : "<tr>$str</tr>"
end
function mkhtml(node::CommonMark.Node, cell::CommonMark.TableCell, pss::PagesSetting)
	ta = pss.table_align
	chtml = childrenhtml(node, pss)
	ta == "inherit" && return "<td>$chtml</td>"
	al = pss.table_align=="auto" ? cell.align : pss.table_align
	return "<td style='float:$al'>$chtml</td>"
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
	return "<br />\n"
end
mkhtml(::CommonMark.Node, ::CommonMark.SoftBreak, ::PagesSetting)=""
function mkhtml(node::CommonMark.Node, ::CommonMark.Code, ::PagesSetting)
	return "<code>$(html_safe(node.literal))</code>"
end
function mkhtml(::CommonMark.Node, l::CommonMark.FootnoteLink, ::PagesSetting)
	return """<sup><a id="citeref-$(l.id)" href="#footnote-$(l.id)">[$(l.id)]</a></sup>"""
end
function mkhtml(node::CommonMark.Node, ::CommonMark.Math, ::PagesSetting)
	return "<span class='math tex'>$(html_safe(node.literal))</span>"
end
