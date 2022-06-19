mutable struct Node
	par::Union{Node, Nothing}
	name::String
	toml::Dict
	dirs::Dict{String, Tuple{Node, String}} # data name
	files::Dict{String, Tuple{String, String, String}} # data name suffix
end
Node(par::Union{Node,Nothing}, name::String, toml::Dict=Dict())=Node(par, name, toml, Dict{String, Pair{Node, String}}(), Dict{String, Pair{String, String}}())

function generate(srcdir::AbstractString, tardir::AbstractString, pss::PagesSetting)
	# 支持相对路径
	pwds=pwd()
	if srcdir[1]=='.'
		srcdir=joinpath(pwds,srcdir)
	end
	if !endswith(srcdir,"/")
		srcdir*="/"
	end
	if tardir[1]=='.'
		tardir=joinpath(pwds,tardir)
	end
	if !endswith(tardir,"/")
		tardir*="/"
	end
	# 复制本项目
	cd(@__DIR__)
	cd("..")
	cp("css", tardir*"css"; force=true)
	cp("js", tardir*"js"; force=true)
	# 复制来源
	cd(srcdir)
	if isdir("assets")
		cp("assets", tardir*"assets"; force=true)
	end
	if isdir("script")
		v=readdir("script"; sort=false)
		for file in v
			cp("script/"*file, tardir*"js/"*file; force=true)
		end
	end
	cp(pss.favicon_path, tardir*"favicon.ico"; force=true)
	# docs
	root=Node(nothing, lw(pss, 5))
	cd(srcdir*"docs")
	gen_rec(;
		current=root,
		outline=true,
		path="docs/",
		pathv=["docs"],
		pss=pss,
		srcdir=srcdir,
		tardir=tardir
	)
	cd(srcdir*"docs")
	make_rec(;
		current=root,
		path="docs/",
		pathv=["docs"],
		pss=pss,
		tardir=tardir
	)
	# menu.js
	io=open(tardir*"js/menu.js", "w")
	print(io, "const menu=`", makemenu(root; path="docs/"), "`")
	close(io)
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
			@info it
			dot=findlast('.', it)
			pre=it[1:dot-1]
			suf=it[dot+1:end]
			sym=Symbol(suf)
			if hasmethod(file2node, Tuple{Val{sym}}, (:it, :node, :pre, :pss, :spath))
				file2node(Val(sym); it=it, node=current, pre=pre, pss=pss, spath=spath)
			else
				cp(spath*it, tpath*it; force=true)
			end
		else # isdir
			@info it*"/"
			if !haskey(current.toml,"names")
				@error "TOML: " path current.toml
				throw("KEY [NAMES] UNFOUND")
			end
			ns=@inbounds current.toml["names"]
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
			vec=@inbounds toml["outline"]
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
		writehtml(tpath*pa.first, html)
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
	writehtml(tpath*"index", makeindexhtml(current, path, pathv; pss=pss))
	# 消除影响
	current=current.par
	path=path[1:end-1-length(last(pathv))]
	pop!(pathv)
	cd("..")
end

function makemenu(rt::Node; path::String)
	html=""
	if haskey(rt.toml, "outline")
		outline=@inbounds rt.toml["outline"]
		for id in outline
			expath=path*id
			if haskey(rt.dirs, id)
				pair=@inbounds rt.dirs[id]
				html*="<li><a class=\"tocitem\" href=\"\$$(expath)/index$(pss.filesuffix)\">$(pair[2])</a><ul>$(makemenu(pair[1];path=expath*"/"))</ul><li>"
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
		mds*="<li><a href=\"$(d.first)/index$(pss.filesuffix)\" target=\"_blank\">$(d.second[2])/</a></li>"
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

function writehtml(path::String,html::String)
	io=open(path*pss.filesuffix, "w")
	print(io, html)
	close(io)
end

function file2node(::Val{:md}; it::String, node::Node, pre::String, pss::PagesSetting, spath::String)
	io=open(spath*it, "r")
	pair=md_withtitle(read(io, String), pss)
	close(io)
	node.files[pre]=(pair.first, pair.second, "md")
end
function file2node(::Val{:jl}; it::String, node::Node, pre::String, ::PagesSetting, spath::String)
	io=open(spath*it, "r")
	str=replace(read(io, String), "\r"=>"")
	close(io)
	node.files[pre]=("<pre class=\"language\">$(highlight(Val(:jl), str))</pre>", pre, "jl")
end
function file2node(::Val{:txt}; it::String, node::Node, pre::String, ::PagesSetting, spath::String)
	str="<pre class=\"language\">"
	io=open(spath*it, "r")
	num=1
	for l in eachline(io)
		str*="<span id=\"line-$num\">$(html_safe(l))</span><br />"
		num+=1
	end
	close(io)
	node.files[pre]=(str*"</pre>", pre, "txt")
end
