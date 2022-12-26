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
	#= 处理路径 =#
	pss.srcdir = srcdir = expend_slash(abspath(srcdir))
	pss.tardir = tardir = expend_slash(abspath(tardir))
	@info "Route" srcdir tardir
	if pss.remove_original && isdir(tardir)
		rm(tardir; force=true, recursive=true)
	end
	mkpath(tardir*pss.tar_extra)
	#= 核心部分：生成文档 =#
	tree = Doctree(lw(pss, 5))
	cd(srcdir*"docs") do
		scan_rec(tree, pss;
			outlined=true,
			path="docs/",
			pathv=["docs"],
		)
	end
	cd(srcdir*"docs") do
		make_rec(tree, pss;
			path="docs/",
			pathv=["docs"],
		)
	end
	#= 生成各种杂物 =#
	cp(joinpath(@__DIR__, "../css"), tardir*pss.tar_css; force=true)
	cd(srcdir) do
		isdir(pss.src_assets) && cp(pss.src_assets, tardir*pss.tar_assets; force=true)
		isdir("script") && cp("script", tardir*pss.tar_script; force=true)
	end
	makemainpage(tree, pss)
	make404(tree, pss)
	makescript(tree, pss)
	makeinfo_script(tree, pss)
	tree
end

function scan_rec(tree::Doctree, pss::PagesSetting; outlined::Bool, path::String, pathv::Vector{String})
	spath = pss.srcdir*path
	tpath = pss.tardir*path
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
			filedeal(Val(Symbol(suf)); info=info, it=it, path=path, pathv=pathv, pre=pre, pss=pss, spath=spath, tpath=tpath)
		else
			info = DirBase(omode, tree.current, it, get(ns, it, it), nothing, Dict())
			push!(pathv, it)
			tree.current = num
			cd(it)
			scan_rec(tree, pss; outlined=omode, path="$(path)$(it)/", pathv=pathv,)
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

function get_pagestr(tree, pss, id::Int, is_prev)
	tb = tree.data[id]
	href = isa(id, FileBase) ? tb.target : "$(tb.name)/index$(pss.filesuffix)"
	return "<a class='docs-footer-$(is_prev ? "prev" : "next")page' href='$(href)'>$(is_prev ? "« $title" : "$title »")</a>"
end
function get_pagestr(tree, pss, name::String, is_prev)
	id = findchild(tree, tree.current, name)
	if id == 0
		@info tree
		error("Check setting files [foot_direct]: nothing matches <$name>")
	end
	return get_pagestr(tree, pss, id, is_prev)
end
function make_rec(tree::Doctree, pss::PagesSetting; path::String, pathv::Vector{String})
	tpath = pss.tardir*path
	tb = self(tree)
	toml = tb.setting
	vec = get(toml, "outline", [])::Vector
	len = length(vec)
	footdirect = get(toml, "foot_direct", Dict())
	for nid in tb.children
		base = tree.data[nid]
		if base::DirBase
			push!(pathv, base.id)
			tree.current = nid
			cd(base.id)
			make_rec(tree, pss; path="$(path)$(base.id)/", pathv=pathv)
			pop!(pathv)
			backtoparent!(tree)
			cd("..")
			continue
		end
		if base.generated
			continue
		end
		id = base.id
		title = base.name
		prevpage = ""
		nextpage = ""
		outline_index = first_invec(id, vec)
		if haskey(footdirect, id)
			thisdirect = footdirect[id]
			if haskey(thisdirect, "prev")
				prevpage = get_pagestr(tree, pss, thisdirect["prev"], true)
			end
			if haskey(thisdirect, "next")
				nextpage = get_pagestr(tree, pss, thisdirect["next"], false)
			end
		elseif outline_index == 0
			prevpage = """<a class="docs-footer-prevpage" href="index$(pss.filesuffix)">« $(lw(pss, 6))</a>"""
		else
			i = outline_index[]
			if i==1
				prevnid = prev_outlined(tree, nid)
				prevpage = prevnid==0 ? """<a class="docs-footer-prevpage" href="index$(pss.filesuffix)">« $(lw(pss, 6))</a>""" : get_pagestr(tree, pss, prevnid, true)
			else
				prevpage = get_pagestr(tree, pss, @inbounds(vec[i-1]), true)
			end
			if i==len
				nextnid = next_outlined(tree, nid)
				nextpage = nextnid==0 ? "" : get_pagestr(tree, pss, nextnid, false)
			else
				nextpage = get_pagestr(tree, pss, @inbounds(vec[i+1]), false)
			end
		end
		ps = PageSetting(
			description = describe_page(tree, title, pss),
			editpath = pss.repo_path=="" ? "" : "$(pss.repo_path*path)$(fullname(base))",
			mds = base.data,
			navbar_title = navbartext_page(tree, title),
			nextpage = nextpage,
			prevpage = prevpage,
			tURL = "../"^length(pathv)
		)
		html = makehtml(pss, ps)
		write(tpath*base.target, html)
	end
	makeindex(tree, pss; path=path, pathv=pathv)
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
	if !pss.make_index
		return
	end
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
	write(pss.tardir*path*"index"*pss.filesuffix, makehtml(pss, ps))
end

function make404(_::AbstractDoctree, pss::PagesSetting)
	tarundef = joinpath(pss.tardir, pss.unfound)
	str = ""
	if isfile(pss.unfound)
		if pss.wrap_html
			str = read(pss.unfound, String)
		else
			cp(pss.unfound, tarundef; force=true)
			return
		end
	elseif pss.make404
		str = lw(pss, 10)
	end
	write(tarundef, makehtml(pss, PageSetting(
		description="404 ($(pss.title))",
		editpath="",
		mds="<p style='color:red'>$mds</p>",
		navbar_title="404",
		nextpage="",
		prevpage="<a class='docs-footer-prevpage' href='index$(pss.filesuffix)'>« $(lw(pss, 9))</a>",
		tURL="./",
	)))
end

function makeinfo_script(tree::Doctree, pss::PagesSetting)
	io = open("$(pss.tardir)$(pss.tar_extra)/info.js", "w")
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
	path = ""
	nid = 1
	tb = tree.data[1]
	# iter = 0
	while true
		path *= tb.name
		# nid, iter = iterate(tb.children)
		nid = first(tb.children)
		tb = tree.data[nid]
		if !tb.is_outlined
			return
		end
		if tb::FileBase
			break
		end
	end
	# par = tb.parent
	# @inbounds partb = tree.data[par]
	# next = iterate(partb.children, iter)
	# nextnid = next===nothing ? next_outlined(tree, nid) : next[1]
	ps = PageSetting(
		description = "$(tb.name) - $(pss.title)",
		editpath = pss.repo_path=="" ? "" : pss.repo_path*path,
		mds = tb.data,
		navbar_title = tb.name,
		nextpage = "",
		prevpage = "",
		tURL = "./"
	)
	write(pss.tardir*"index"*pss.filesuffix, makehtml(pss, ps))
end
