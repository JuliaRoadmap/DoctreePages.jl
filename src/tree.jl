mutable struct Node
	par::Union{Node, Nothing}
	name::String
	toml::Dict
	dirs::Dict{String, Tuple{Node, String}} # data name
	files::Dict{String, Tuple{String, String, String}} # data name suffix
end
Node(par::Union{Node,Nothing}, name::String, toml::Dict=Dict{String, Any}())=Node(par, name, toml, Dict{String, Pair{Node, String}}(), Dict{String, Pair{String, String}}())

function generate(srcdir::AbstractString, tardir::AbstractString, pss::PagesSetting)
	# 支持相对路径
	pwds=pwd()
	if srcdir[1]=='.'
		srcdir=joinpath(pwds,srcdir)
	end
	if !endswith(srcdir, '/')
		srcdir*="/"
	end
	if tardir[1]=='.'
		tardir=joinpath(pwds, tardir)
	end
	if !endswith(tardir, '/')
		tardir*="/"
	end
	realtardir=joinpath(tardir, pss.use_subdir)
	mkpath(realtardir)
	if !endswith(realtardir, '/')
		realtardir*="/"
	end
	# 复制本项目
	cd(@__DIR__)
	cd("..")
	cp("css", realtardir*pss.tar_css; force=true)
	cp("extra", realtardir*pss.tar_extra; force=true)
	# 复制来源
	cd(srcdir)
	if isdir(pss.src_assets)
		cp(pss.src_assets, realtardir*pss.tar_assets; force=true)
		# cp(joinpath(@__DIR__, "../svg"), tardir*"assets/extra"; force=true)
	end
	if isdir("script")
		cp("script", realtardir*pss.tar_script; force=true)
	end
	if pss.move_favicon && pss.favicon_path!=""
		cp(pss.favicon_path, tardir*"favicon.ico"; force=true)
	end
	# docs
	root=Node(nothing, lw(pss, 5))
	cd(srcdir*"docs")
	if pss.remove_original && isdir(realtardir*"docs")
		rm(realtardir*"docs"; force=true, recursive=true)
	end
	gen_rec(;
		current=root,
		outline=true,
		path="docs/",
		pathv=["docs"],
		pss=pss,
		srcdir=srcdir,
		tardir=realtardir
	)
	cd(srcdir*"docs")
	make_rec(;
		current=root,
		path="docs/",
		pathv=["docs"],
		pss=pss,
		tardir=realtardir
	)
	# 404.html
	tarundef=joinpath(tardir, pss.unfound)
	if isfile(pss.unfound)
		if pss.wrap_html
			io=open(pss.unfound, "r")
			str=read(io, String)
			close(io)
			writehtml(tarundef, make404html(str, pss), pss)
		else
			cp(pss.unfound, tarundef; force=true)
		end
	else
		writehtml(tarundef, make404html(lw(pss, 10), pss), pss)
	end
	# info.js
	makeinfo_js(realtardir*"$(pss.tar_extra)/info.js", root, pss)
	# 消除影响
	cd(pwds)
end
function gen_rec(;
	current::Node,
	outline::Bool,
	path::String,
	pathv::Vector{String},
	pss::PagesSetting,
	srcdir::String,
	tardir::String)
	# 准备
	spath=srcdir*path
	tpath=tardir*path
	mkpath(tpath)
	# TOML
	vec=readdir("."; sort=false)
	toml = in("setting.toml", vec) ? TOML.parsefile("setting.toml") : Dict()
	current.toml=toml
	# 遍历
	for it in vec
		if it=="setting.toml"
			continue
		elseif isfile(it)
			pss.show_info && @info it
			dot=findlast('.', it)
			pre=it[1:dot-1]
			suf=it[dot+1:end]
			file2node(Val(Symbol(suf)); it=it, node=current, path=path, pathv=pathv, pre=pre, pss=pss, spath=spath, tpath=tpath)
		else # isdir
			pss.show_info && @info it*"/"
			ns=current.toml["names"]
			ns::Dict
			node=Node(current,it)
			current.dirs[it]=(node,ns[it])
			push!(pathv,it)
			cd(it)
			o=outline || (haskey(toml,"outline") && in(it, @inbounds(toml["outline"])))
			gen_rec(
				current=node,
				outline=o,
				path="$(path)$(it)/",
				pathv=pathv,
				pss=pss,
				srcdir=srcdir,
				tardir=tardir
			)
		end
	end
	# 消除影响
	current=current.par
	path=path[1:end-1-length(last(pathv))]
	pop!(pathv)
	cd("..")
end
function make_rec(;
	current::Node,
	path::String,
	pathv::Vector{String},
	pss::PagesSetting,
	tardir::String)
	tpath=tardir*path
	toml=current.toml
	for pa in current.files
		id=pa.first
		title=pa.second[2]
		prevpage=""
		nextpage=""
		if haskey(toml, "outline")
			vec=toml["outline"]
			len=length(vec)
			for i in 1:len
				if vec[i]==id
					if i!=1
						previd=@inbounds vec[i-1]
						ptitle=current.files[previd][2]
						prevpage="<a class=\"docs-footer-prevpage\" href=\"$(previd)$(pss.filesuffix)\">« $ptitle</a>"
					else
						prevpage="<a class=\"docs-footer-prevpage\" href=\"index$(pss.filesuffix)\">« $(lw(pss, 6))</a>"
					end
					if i!=len
						nextid=@inbounds vec[i+1]
						ntitle=current.files[nextid][2]
						nextpage="<a class=\"docs-footer-nextpage\" href=\"$(nextid)$(pss.filesuffix)\">$ntitle »</a>"
					end
				end
			end
		else
			prevpage="<a class=\"docs-footer-prevpage\" href=\"index$(pss.filesuffix)\">« $(lw(pss, 6))</a>"
		end
		ps=PageSetting(
			description="$(current.par.dirs[current.name][2])/$title - $(pss.title)",
			editpath="$(pss.repo_path*path)$id.$(pa.second[3])",
			mds=pa.second[1],
			navbar_title="$(current.par.dirs[current.name][2]) / $title",
			nextpage=nextpage,
			prevpage=prevpage,
			tURL="../"^length(pathv)
		)
		html=makehtml(pss, ps)
		writehtml(tpath*pa.first, html, pss)
	end
	for pa in current.dirs
		name=pa.first
		cd(name)
		push!(pathv, name)
		make_rec(;
			current=pa.second[1],
			path=path*name*"/",
			pathv=pathv,
			pss=pss,
			tardir=tardir
		)
	end
	if pss.make_index
		writehtml(tpath*"index", makeindexhtml(current, path, pathv; pss=pss), pss)
	end
	# 消除影响
	current=current.par
	path=path[1:end-1-length(last(pathv))]
	pop!(pathv)
	cd("..")
end

function makemenu(rt::Node, pss::PagesSetting; path::String)
	html=""
	if haskey(rt.toml, "outline")
		outline=@inbounds rt.toml["outline"]
		for id in outline
			expath=path*id
			if haskey(rt.dirs, id)
				pair=rt.dirs[id]
				html*="<li><a class=\"tocitem\" href=\"\$$(expath)/index$(pss.filesuffix)\">$(pair[2])</a><ul>$(makemenu(pair[1], pss; path=expath*"/"))</ul><li>"
			else
				name=rt.files[id][2]
				html*="<li><a class=\"tocitem\" href=\"\$$(expath)$(pss.filesuffix)\">$name</a></li>"
			end
		end
		return html
	end
end

function makeindexhtml(node::Node, path::String, pathv::Vector{String}; pss::PagesSetting)
	mds="<ul>"
	for d in node.dirs
		mds*="<li><a href=\"$(d.first)/index$(pss.filesuffix)\" target=\"_blank\">📁$(d.second[2])</a></li>"
	end
	for d in node.files
		mds*="<li><a href=\"$(d.first)$(pss.filesuffix)\">$(d.second[2])</a></li>"
	end
	mds*="</ul>"
	title = (node.par===nothing ? lw(pss, 7) : node.par.dirs[node.name][2])*lw(pss, 8)
	ps=PageSetting(
		description="$title - $(pss.title)",
		editpath=pss.repo_path*path,
		mds=mds,
		navbar_title=title,
		nextpage="",
		prevpage=node.par===nothing ? "" : "<a class='docs-footer-prevpage' href='../index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
		tURL="../"^length(pathv)
	)
	return makehtml(pss, ps)
end

function make404html(mds::String, pss::PagesSetting)
	return makehtml(pss, PageSetting(
		description="404 ($(pss.title))",
		editpath="",
		mds=mds,
		navbar_title="404",
		nextpage="",
		prevpage="<a class='docs-footer-prevpage' href='../index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
		tURL="../",
	))
end
function makeinfo_js(path::String, root::Node, pss::PagesSetting)
	io=open(path, "w")
	rep=str -> replace(str, '`' => "\\`")
	try
		println(io, "const menu=`", makemenu(root, pss; path="docs/"), "`")
		println(io, "const buildmessage=`$(rep(pss.buildmessage))`")
		println(io, "const page_foot=`$(rep(pss.page_foot))`")
		println(io, "const tar_css=`$(rep(pss.tar_css))`")
		ms=pss.main_script
		println(io, "const configpaths=`$(rep(ms.requirejs.configpaths))`")
		println(io, "const configshim=`$(rep(ms.requirejs.configshim))`")
		println(io, "const hljs_languages=`$(rep(ms.hljs_languages))`")
		println(io, "const main_requirement=$(rep(ms.main_requirement))")
	finally
		close(io)
	end
end

function writehtml(path::String, html::String, pss::PagesSetting)
	io=open(path*pss.filesuffix, "w")
	print(io, html)
	close(io)
end

function file2node(::Val; it::String, node::Node, path::String, pathv::Vector{String}, pre::String, pss::PagesSetting, spath::String, tpath::String)
	cp(spath*it, tpath*it; force=true)
end

function file2node(::Val{:md}; it::String, node::Node, path::String, pathv::Vector{String}, pre::String, pss::PagesSetting, spath::String, tpath::String)
	io=open(spath*it, "r")
	try
		pair=md_withtitle(read(io, String), pss)
		node.files[pre]=(pair.first, pair.second, "md")
	finally
		close(io)
	end
end

function file2node(::Union{Val{:html}, Val{:htm}}; it::String, node::Node, path::String, pathv::Vector{String}, pre::String, pss::PagesSetting, spath::String, tpath::String)
	io=open(spath*it, "r")
	str=read(io, String)
	close(io)
	if pss.wrap_html
		title=node.toml["names"][pre]
		# todo: parameters
		str=makehtml(pss, PageSetting(
			description="$title - $(pss.title)",
			editpath=pss.repo_path*path*it,
			mds=str,
			navbar_title=title,
			nextpage="",
			prevpage=node.par===nothing ? "" : "<a class='docs-footer-prevpage' href='../index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
			tURL="../"^length(pathv)
		))
	end
	writehtml(tpath*it, str, pss)
end

function file2node(::Val{:jl}; it::String, node::Node, path::String, pathv::Vector{String}, pre::String, pss::PagesSetting, spath::String, tpath::String)
	io=open(spath*it, "r")
	str=read(io, String)
	close(io)
	node.files[pre]=(highlight("julia", str, pss), pre, "jl")
end

function file2node(::Val{:txt}; it::String, node::Node, path::String, pathv::Vector{String}, pre::String, pss::PagesSetting, spath::String, tpath::String)
	io=open(spath*it, "r")
	str=read(io, String)
	close(io)
	node.files[pre]=(highlight("plain", str, pss), pre, "txt")
end
