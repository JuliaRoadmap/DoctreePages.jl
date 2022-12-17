"""
Transforms source file to target file according to the type of the file.
"""
function file2node(::Val; it, node::Node, path, pathv, pre, pss::PagesSetting, spath, tpath)
	cp(spath*it, tpath*it; force=true)
end

function file2node(::Val{:md}; it, node::Node, path, pathv, pre, pss::PagesSetting, spath, tpath)
	pair = md_withtitle(read(spath*it, String), pss)
	node.files[pre] = (pair.first, pair.second, "md")
end

function file2node(::Union{Val{:html}, Val{:htm}}; it, node::Node, path, pathv, pre, pss::PagesSetting, spath, tpath)
	str=read(spath*it, String)
	if pss.wrap_html
		title=node.toml["names"][pre]
		str=makehtml(pss, PageSetting(
			description="$title - $(pss.title)",
			editpath=pss.repo_path=="" ? "" : pss.repo_path*path*it,
			mds=str,
			navbar_title=title,
			nextpage="",
			prevpage=node.par===nothing ? "" : "<a class='docs-footer-prevpage' href='../index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
			tURL="../"^length(pathv)
		))
	end
	write(tpath*it*pss.filesuffix, str)
end

function file2node(::Val{:jl}; it, node::Node, path, pathv, pre, pss::PagesSetting, spath, tpath)
	str=read(spath*it, String)
	node.files[pre]=(highlight_directly(:julia, str, pss), pre, "jl")
end

function file2node(::Val{:txt}; it, node::Node, path, pathv, pre, pss::PagesSetting, spath, tpath)
	str=read(spath*it, String)
	node.files[pre]=(highlight_directly(:plain, str, pss), pre, "txt")
end
