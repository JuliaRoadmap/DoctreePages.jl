mutable struct Node
	par::Union{Node, Nothing}
	name::String
	toml::Dict
	dirs::Dict{String, Tuple{Node, String}} # data name
	files::Dict{String, Tuple{String, String, String}} # data name suffix
end
Node(par::Union{Node,Nothing}, name::String, toml::Dict=Dict{String, Any}())=Node(par, name, toml, Dict{String, Pair{Node, String}}(), Dict{String, Pair{String, String}}())
function Base.show(io::IO, node::Node)
	if get(io, :compat, false)
		println(io, node.name)
		return
	end
	if node.par === nothing
		println(io, "Root Node")
	else
		println(io, "Directory ", node.name)
		par=node.par
		println(io, "parent: ", par.par===nothing ? "< root >" : par.name)
	end
	if !isempty(node.dirs)
		println(io, "sub directories:")
		for it in node.dirs
			println(io, "| ", it.first, " ($(it.second[2]))")
		end
	end
	if !isempty(node.files)
		println(io, "files:")
		for it in node.files
			println(io, "| ", it.first, " ($(it.second[2]))")
		end
	end
end
chapter_name(node::Node) = node.par.dirs[node.name][2]
function describe_page(node::Node, title, pss)
	if node.par !== nothing
		return chapter_name(node)*"/$title - $(pss.title)"
	end
	return "$title - $(pss.title)"
end
function navbartext_page(node::Node, title)
	if node.par !== nothing
		return chapter_name(node)*" / "*title
	end
	return String(title)
end

function namedtuplefrom(d::Dict{String, Any})
	v=map(collect(d)) do pair
		Symbol(pair.first) => pair.second
	end
	return NamedTuple(v)
end

function readbuildsetting(path::AbstractString)
	toml=TOML.parsefile(path)
	# The semver -related function set is too large
	if haskey(toml, "version") && !(DTP_VERSION in Pkg.Types.semver_spec(toml["version"]))
		error("version does not meet $build_setting : version")
	end
	pages=toml["pages"]
	if haskey(toml, "giscus")
		pages["giscus"]=GiscusSetting(;namedtuplefrom(toml["giscus"])...)
	end
	if haskey(toml, "mainscript")
		pages["main_script"]=MainScriptSetting(;namedtuplefrom(toml["mainscript"])...)
	end
	return namedtuplefrom(pages)
end

function generate(srcdir::AbstractString, tardir::AbstractString, build_setting::AbstractString = "DoctreeBuild.toml")
	namedtuple=readbuildsetting(joinpath(srcdir, build_setting))
	generate(srcdir, tardir, PagesSetting(;namedtuple...))
end

function generate(srcdir::AbstractString, tardir::AbstractString, pss::PagesSetting)
	# 支持相对路径
	pwds=pwd()
	pss.srcdir = srcdir = rpad(abspath(srcdir), 1, '/')
	pss.tardir = tardir = rpad(abspath(tardir), 1, '/')
	mkpath(tardir)
	# 复制本项目
	cp(joinpath(@__DIR__, "../css"), tardir*pss.tar_css; force=true)
	# 复制来源
	cd(srcdir)
	if isdir(pss.src_assets)
		cp(pss.src_assets, tardir*pss.tar_assets; force=true)
		# cp(joinpath(@__DIR__, "../svg"), tardir*"assets/extra"; force=true)
	end
	if isdir("script")
		cp("script", tardir*pss.tar_script; force=true)
	end
	# docs
	root=Node(nothing, lw(pss, 5))
	if pss.remove_original && isdir(tardir*"docs")
		rm(tardir*"docs"; force=true, recursive=true)
	end
	cd(srcdir*"docs") do
		gen_rec(;
			current=root,
			outline=true,
			path="docs/",
			pathv=["docs"],
			pss=pss,
			srcdir=srcdir,
			tardir=tardir
		)
	end
	cd(srcdir*"docs") do
		make_rec(;
			current=root,
			path="docs/",
			pathv=["docs"],
			pss=pss,
			tardir=tardir
		)
	end
	# 404
	tarundef=joinpath(tardir, pss.unfound)
	if isfile(pss.unfound)
		if pss.wrap_html
			str=read(pss.unfound, String)
			write(tarundef, make404(str, pss))
		else
			cp(pss.unfound, tarundef; force=true)
		end
	elseif pss.make404
		write(tarundef, make404(lw(pss, 10), pss))
	end
	mkpath(tardir*pss.tar_extra)
	# info.js
	makeinfo_script(tardir*"$(pss.tar_extra)/info.js", root, pss)
	# main.js
	io=open(tardir*"$(pss.tar_extra)/main.js", "w")
	makescript(io, pss)
	close(io)
	# 消除影响
	cd(pwds)
	# 返回
	return root
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
			o=outline || (haskey(toml,"outline") && in(it, toml["outline"]))
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
						if haskey(current.files, previd)
							ptitle=current.files[previd][2]
							prevpage="<a class='docs-footer-prevpage' href='$(previd)$(pss.filesuffix)'>« $ptitle</a>"
						elseif haskey(current.dirs, previd)
							ptitle=current.dirs[previd][2]
							prevpage="<a class='docs-footer-prevpage' href='$(previd)/index$(pss.filesuffix)'>« $ptitle</a>"
						else
							msg = "nothing matches [$id] in $current"
							pss.throwall ? error(msg) : (@error msg)
						end
					else
						prevpage="<a class=\"docs-footer-prevpage\" href=\"index$(pss.filesuffix)\">« $(lw(pss, 6))</a>"
					end
					if i!=len
						nextid=@inbounds vec[i+1]
						if haskey(current.files, nextid)
							ntitle=current.files[nextid][2]
							nextpage="<a class='docs-footer-nextpage' href='$(nextid)$(pss.filesuffix)'>$ntitle »</a>"
						elseif haskey(current.dirs, nextid)
							ntitle=current.dirs[nextid][2]
							nextpage="<a class='docs-footer-nextpage' href='$(nextid)/index$(pss.filesuffix)'>$ntitle »</a>"
						else
							msg = "nothing matches [$id] in $current"
							pss.throwall ? error(msg) : (@error msg)
						end
					end
				end
			end
		else
			prevpage="<a class=\"docs-footer-prevpage\" href=\"index$(pss.filesuffix)\">« $(lw(pss, 6))</a>"
		end
		ps=PageSetting(
			description = describe_page(current, title, pss),
			editpath=pss.repo_path=="" ? "" : "$(pss.repo_path*path)$id.$(pa.second[3])",
			mds=pa.second[1],
			navbar_title = navbartext_page(current, title),
			nextpage=nextpage,
			prevpage=prevpage,
			tURL="../"^length(pathv)
		)
		html=makehtml(pss, ps)
		write(tpath*pa.first*pss.filesuffix, html)
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
		write(tpath*"index"*pss.filesuffix, makeindex(current, path, pathv; pss=pss))
	end
	# 消除影响
	path=path[1:end-1-length(last(pathv))]
	pop!(pathv)
	cd("..")
end

function makemenu(node::Node, pss::PagesSetting)
	return "['',$(_makemenu(node, pss))]"
end
function _makemenu(node::Node, pss::PagesSetting)
	str=""
	if haskey(node.toml, "outline")
		outline=node.toml["outline"]
		for id in outline
			if haskey(node.dirs, id)
				pair=node.dirs[id]
				str*="[`$(rep(id))/$(pair[2])`,$(_makemenu(pair[1], pss))],"
			elseif haskey(node.files, id)
				name=node.files[id][2]
				str*="`$(rep(id))/$(rep(name))`,"
			end
		end
	end
	return str
end

function makeindex(node::Node, path::String, pathv::Vector{String}; pss::PagesSetting)
	mds="<ul>"
	dkeys = collect(keys(node.dirs))
	fkeys = collect(keys(node.files))
	if pss.sort_file
		sort!(dkeys)
		sort!(fkeys)
	end
	for dkey in dkeys
		mds*="<li class='li-dir'><a href='$(dkey)/index$(pss.filesuffix)'>$(node.dirs[dkey][2])</a></li>"
	end
	for fkey in fkeys
		mds*="<li class='li-file'><a href='$(fkey)$(pss.filesuffix)'>$(node.files[fkey][2])</a></li>"
	end
	mds*="</ul>"
	title = (node.par===nothing ? lw(pss, 7) : node.par.dirs[node.name][2])*lw(pss, 8)
	ps=PageSetting(
		description="$title - $(pss.title)",
		editpath=pss.repo_path=="" ? "" : pss.repo_path*path,
		mds=mds,
		navbar_title=title,
		nextpage="",
		prevpage=node.par===nothing ? "" : "<a class='docs-footer-prevpage' href='../index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
		tURL="../"^length(pathv)
	)
	return makehtml(pss, ps)
end

function make404(mds::String, pss::PagesSetting)
	return makehtml(pss, PageSetting(
		description="404 ($(pss.title))",
		editpath="",
		mds=mds,
		navbar_title="404",
		nextpage="",
		prevpage="<a class='docs-footer-prevpage' href='index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
		tURL="./",
	))
end
function makeinfo_script(path::String, root::Node, pss::PagesSetting)
	io=open(path, "w")
	try
		println(io, "const buildmessage=`$(rep(pss.buildmessage))`")
		println(io, "const page_foot=`$(rep(pss.page_foot))`")
		println(io, "const tar_css=`$(rep(pss.tar_css))`")
		println(io, "const filesuffix=`$(rep(pss.filesuffix))`")
		ms=pss.main_script
		# 无直角引号
		println(io, "const menu=", makemenu(root, pss))
		println(io, "const configpaths=$(ms.requirejs.configpaths)")
		println(io, "const configshim=$(ms.requirejs.configshim)")
		println(io, "const hljs_languages=$(ms.hljs_languages)")
		println(io, "const main_requirement=$(ms.main_requirement)")
	finally
		close(io)
	end
end
