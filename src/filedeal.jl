function filedeal(::Val; fbase::FileBase, it, path, pss::PagesSetting, spath, tpath)
	cp(spath*it, tpath*it; force=true)
	fbase.generated = true
	fbase.target = it
end

function filedeal(::Val{:md}; fbase::FileBase, it, path, pss::PagesSetting, spath, tpath)
	con = ""
	s = replace(read(spath*it, String), "\r"=>"")
	try
		md = pss.parser(s)
		if fbase.name == ""
			fbase.name = md.first_child.first_child.literal
		end
		fbase.target = fbase.id*pss.filesuffix
		fbase.data = mkhtml(md, md.t, pss)
	catch er
		if pss.throwall
			error(er)
		end
		buf = IOBuffer()
		showerror(buf, er)
		str = String(take!(buf))
		@error "Markdown Parse Error" it str
		con = "<h2 id='header-error'>ERROR handled by DoctreePages</h2><p style='color:red'>$(html_safe(str))</p>"
	end
end

function filedeal(::Union{Val{:html}, Val{:htm}}; fbase::FileBase, it, path, pss::PagesSetting, spath, tpath)
	str = read(spath*it, String)
	fbase.target = fbase.id*pss.filesuffix
	if pss.wrap_html
		fbase.data = str
	else
		fbase.generated = true
		write(tpath*fbase.target, str)
	end
end

function filedeal(::Val{:jl}; fbase::FileBase, it, path, pss::PagesSetting, spath, tpath)
	str = read(spath*it, String)
	fbase.target = fbase.id*pss.filesuffix
	fbase.data = highlight_directly(:julia, str, pss)
end

function filedeal(::Val{:txt}; fbase::FileBase, it, path, pss::PagesSetting, spath, tpath)
	str = read(spath*it, String)
	fbase.target = fbase.id*pss.filesuffix
	fbase.data = highlight_directly(:plain, str, pss)
end
