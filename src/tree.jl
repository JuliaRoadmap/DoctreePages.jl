function readbuildsetting(path::AbstractString)
	toml=TOML.parsefile(path)
	# The semver -related function set is too large
	if haskey(toml, "version") && !(DTP_VERSION in Pkg.Types.semver_spec(toml["version"]))
		error("version does not meet setting ($(toml["version"]))")
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
	namedtuple = readbuildsetting(joinpath(srcdir, build_setting))
	pss = PagesSetting(;namedtuple...)
	@info "Setting" pss
	generate(srcdir, tardir, pss)
end

function generate(srcdir::AbstractString, tardir::AbstractString, pss::PagesSetting)
	pss.srcdir = srcdir = expend_slash(abspath(srcdir))
	pss.tardir = tardir = expend_slash(abspath(tardir))
	@info "Route" srcdir tardir
	if pss.remove_original && isdir(tardir)
		rm(tardir; force=true, recursive=true)
	end
	mkpath(tardir)
	#= 核心部分：生成文档 =#
	tree = Doctree(lw(pss, 5))
	cd(srcdir*"docs") do
		gen_rec(tree, pss;
			outline=true,
			path="docs/",
			pathv=["docs"],
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
	#= 生成各种杂物 =#
	cp(joinpath(@__DIR__, "../css"), tardir*pss.tar_css; force=true)
	cd(srcdir) do
		isdir(pss.src_assets) && cp(pss.src_assets, tardir*pss.tar_assets; force=true)
		isdir("script") && cp("script", tardir*pss.tar_script; force=true)
	end
	makemainpage()
	tarundef = joinpath(tardir, pss.unfound)
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
	makeinfo_script(tardir*"$(pss.tar_extra)/info.js", root, pss)
	open(tardir*"$(pss.tar_extra)/main.js", "w") do io
		makescript(io, pss)
	end
	return root
end

function gen_rec(tree::Doctree, pss::PagesSetting; outline::Bool, path::String, pathv::Vector{String}, srcdir::String, tardir::String)
	spath = srcdir*path
	tpath = tardir*path
	mkpath(tpath)
	vec = readdir("."; sort=false)
	toml = in("setting.toml", vec) ? TOML.parsefile("setting.toml") : Dict()
	tb = self(tree)
	tb.setting = toml
	if haskey(toml, "ignore")
		delete_invec!(vec, "setting.toml")
		for name in toml["ignore"]
			delete_invec!(vec, name)
		end
	end
	for it in vec
		if isfile(it)
			dot = findlast('.', it)
			pre = dot===nothing ? it : it[1:dot-1]
			suf = dot===nothing ? "" : it[dot+1:end]
			file2node(Val(Symbol(suf)); it=it, node=current, path=path, pathv=pathv, pre=pre, pss=pss, spath=spath, tpath=tpath)
		else
			ns = toml["names"]
			typeassert(ns, Dict)
			node = Node(current, it)
			current.dirs[it] = (node, get(ns, it, it))
			push!(pathv, it)
			cd(it)
			o=outline || (haskey(toml,"outline") && in(it, toml["outline"]))
			gen_rec(tree, pss;
				outline=o,
				path="$(path)$(it)/",
				pathv=pathv,
				srcdir=srcdir,
				tardir=tardir
			)
		end
	end
	backtoparent!(tree)
	path = path[1:end-1-length(last(pathv))]
	pop!(pathv)
	cd("..")
end

function get_pagestr(id, current, pss, type)
	if haskey(current.files, id)
		title = current.files[id][2]
		return "<a class='docs-footer-$(type)page' href='$(id)$(pss.filesuffix)'>$(type=="prev" ? "« $title" : "$title »")</a>"
	end
	if haskey(current.dirs, id)
		title = current.dirs[id][2]
		return "<a class='docs-footer-$(type)page' href='$(id)/index$(pss.filesuffix)'>$(type=="prev" ? "« $title" : "$title »")</a>"
	end
	error("Check setting files: nothing matches [$id] in $current")
end
function make_rec(;current::Node, path::String, pathv::Vector{String}, pss::PagesSetting, tardir::String)
	tpath = tardir*path
	toml = current.toml
	vec = get(toml, "outline", [])
	len = length(vec)
	footdirect = get(toml, "foot_direct", Dict())
	for pa in current.files
		id = pa.first
		title = pa.second[2]
		prevpage = ""
		nextpage = ""
		outline_index = first_invec(id, vec)
		if haskey(footdirect, id)
			thisdirect = footdirect[id]
			if haskey(thisdirect, "prev")
				previd = thisdirect["prev"]
				prevpage = get_pagestr(previd, current, pss, "prev")
			end
			if haskey(thisdirect, "next")
				nextid = thisdirect["next"]
				nextpage = get_pagestr(nextid, current, pss, "next")
			end
		elseif outline_index == 0
			prevpage = """<a class="docs-footer-prevpage" href="index$(pss.filesuffix)">« $(lw(pss, 6))</a>"""
		else
			i = outline_index[]
			if i==1
				prevpage = """<a class="docs-footer-prevpage" href="index$(pss.filesuffix)">« $(lw(pss, 6))</a>"""
			else
				@inbounds previd = vec[i-1]
				prevpage = get_pagestr(previd, current, pss, "prev")
			end
			if i!=len
				@inbounds nextid = vec[i+1]
				nextpage = get_pagestr(nextid, current, pss, "next")
			end
		end
		ps = PageSetting(
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
		write(tpath*"index"*pss.filesuffix, makeindex(current, path, pathv, pss))
	end
	path = path[1:end-1-length(last(pathv))]
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

function makeindex(node::Node, path::String, pathv::Vector{String}, pss::PagesSetting)
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
		mds="<p style='color:red'>$mds</p>",
		navbar_title="404",
		nextpage="",
		prevpage="<a class='docs-footer-prevpage' href='index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
		tURL="./",
	))
end

function makeinfo_script(path::String, root::Node, pss::PagesSetting)
	io=open(path, "w")
	try
		println(io, "const __lang=`$(rep(pss.lang))`")
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

function makemainpage()
	outline = get(root.toml, "outline", [])
	if isempty(outline)
		return
	end
	pagename = outline[1]
	ps = PageSetting(
		description = "$title - $(pss.title)",
		editpath = pss.repo_path=="" ? "" : pss.repo_path*path,
		mds = mds,
		navbar_title = title,
		nextpage = "",
		prevpage = "",
		tURL="./"^length(pathv)
	)
end
