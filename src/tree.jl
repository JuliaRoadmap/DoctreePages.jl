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
			outlined=true,
			path="docs/",
			pathv=["docs"],
			srcdir=srcdir,
			tardir=tardir
		)
	end
	cd(srcdir*"docs") do
		make_rec(tree, pss;
			path="docs/",
			pathv=["docs"],
			tardir=tardir
		)
	end
	#= 生成各种杂物 =#
	cp(joinpath(@__DIR__, "../css"), tardir*pss.tar_css; force=true)
	cd(srcdir) do
		isdir(pss.src_assets) && cp(pss.src_assets, tardir*pss.tar_assets; force=true)
		isdir("script") && cp("script", tardir*pss.tar_script; force=true)
	end
	makemainpage(tree, pss)
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

function gen_rec(tree::Doctree, pss::PagesSetting; outlined::Bool, path::String, pathv::Vector{String}, srcdir::String, tardir::String)
	spath = srcdir*path
	tpath = tardir*path
	mkpath(tpath)
	vec = readdir("."; sort=false)
	children = Set(vec)
	toml = in("setting.toml", children) ? TOML.parsefile("setting.toml") : Dict()
	tb = self(tree)
	tb.setting = toml
	if haskey(toml, "ignore")
		delete!(children, "setting.toml")
		for id in toml["ignore"]
			delete!(children, id)
		end
	end
	outline = outlined ? get(toml, "outline", [])::Vector : []
	for x in outline
		delete!(children, x)
	end
	unoutlined = collect(children)
	if pss.sort_file
		sort!(unoutlined)
	end
	omode = true
	num = length(tree.data)
	i = 1
	len = length(outline), len2 = length(unoutlined)
	tb.children = num+1:num+len+len2
	ns = get(toml, "names", Dict())::Dict
	while true
		num += 1
		@inbounds it = (omode ? outline : unoutlined)[i]
		if isfile(it)
			dot = findlast('.', it)
			pre = dot===nothing ? it : it[1:dot-1]
			suf = dot===nothing ? "" : it[dot+1:end]
			info = FileBase(omode, false, tree.current, pre, suf, get(ns, pre, ""), "", "")
			push!(tree.data, info)
			file2node(Val(Symbol(suf)); info=info, it=it, path=path, pathv=pathv, pre=pre, pss=pss, spath=spath, tpath=tpath)
		else
			info = DirBase(omode, tree.current, it, get(ns, it, it), nothing, Dict())
			push!(pathv, it)
			tree.current = num
			cd(it)
			gen_rec(tree, pss;
				outlined=omode,
				path="$(path)$(it)/", pathv=pathv,
				srcdir=srcdir, tardir=tardir
			)
			pop!(pathv)
			backtoparent!(tree)
			cd("..")
		end
		if i == len
			omode = false
			i = 1
		elseif i == len2
			break
		else
			i += 1
		end
	end
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
function make_rec(tree::Doctree, pss::PagesSetting; path::String, pathv::Vector{String}, tardir::String)
	tpath = tardir*path
	toml = current.toml
	vec = get(toml, "outline", [])::Vector
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
		write(tpath*"index"*pss.filesuffix, makeindex(tree, pss; path=path, pathv=pathv))
	end
	path = path[1:end-1-length(last(pathv))]
	pop!(pathv)
	cd("..")
end

function makemenu(tree::Doctree, pss::PagesSetting; ind::Int = 1)
	return "['',$(_makemenu(tree, pss; ind))]"
end
function _makemenu(tree::Doctree, pss::PagesSetting; ind::Int)
	str = ""
	for nid in tree.data[ind].children
		base = tree.data[nid]
		if !base.is_outlined
			break
		end
		if base::FileBase
			str *= "`$(rep(base.id))/$(rep(base.name))`,"
		else
			str *= "[`$(rep(base.id))/$(rep(base.name))`,$(_makemenu(tree, pss; nid))],"
		end
	end
	return str
end

function makeindex(tree::Doctree, pss::PagesSetting; path::String, pathv::Vector{String})
	mds = "<ul>"
	tb = self(tree)
	for nid in tb.children
		base = tree.data[nid]
		if base::FileBase
			mds *= "<li class='li-file'><a href='$(base.target)'>$(base.name)</a></li>"
		else
			mds *= "<li class='li-dir'><a href='$(base.id)/index$(pss.filesuffix)'>$(base.name)</a></li>"
		end
	end
	mds *= "</ul>"
	title = (isroot(tb) ? lw(pss, 7) : tb.name)*lw(pss, 8)
	ps = PageSetting(
		description="$title - $(pss.title)",
		editpath=pss.repo_path=="" ? "" : pss.repo_path*path,
		mds=mds,
		navbar_title=title,
		nextpage="",
		prevpage=isroot(tb) ? "" : "<a class='docs-footer-prevpage' href='../index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
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

function makeinfo_script(tree::Doctree, pss::PagesSetting; path::String)
	io = open(path, "w")
	try
		println(io, "const __lang=`$(rep(pss.lang))`")
		println(io, "const buildmessage=`$(rep(pss.buildmessage))`")
		println(io, "const page_foot=`$(rep(pss.page_foot))`")
		println(io, "const tar_css=`$(rep(pss.tar_css))`")
		println(io, "const filesuffix=`$(rep(pss.filesuffix))`")
		ms=pss.main_script
		# 无直角引号
		println(io, "const menu=", makemenu(tree, pss))
		println(io, "const configpaths=$(ms.requirejs.configpaths)")
		println(io, "const configshim=$(ms.requirejs.configshim)")
		println(io, "const hljs_languages=$(ms.hljs_languages)")
		println(io, "const main_requirement=$(ms.main_requirement)")
	finally
		close(io)
	end
end

function makemainpage(tree::Doctree, pss::PagesSetting)
	outline = get(self(tree).setting, "outline", [])::Vector
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
