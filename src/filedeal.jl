"""
Transforms source file to target file according to the type of the file.
"""
function filedeal(::Val; info::FileBase, it, path, pathv, pre, pss::PagesSetting, spath, tpath)
	cp(spath*it, tpath*it; force=true)
	info.generated = true
	info.target = it
end

function filedeal(::Val{:md}; info::FileBase, it, path, pathv, pre, pss::PagesSetting, spath, tpath)
	con = ""
	s = replace(read(spath*it, String), "\r"=>"")
	try
		md = pss.parser(s)
		info.name = md.first_child.first_child.literal
		info.target = pre*pss.filesuffix
		info.data = mkhtml(md, md.t, pss)
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

function filedeal(::Union{Val{:html}, Val{:htm}}; info::FileBase, it, path, pathv, pre, pss::PagesSetting, spath, tpath)
	str = read(spath*it, String)
	info.target = it*pss.filesuffix
	if pss.wrap_html
		info.data = str
	else
		info.generated = true
		write(tpath*info.target, str)
	end
end

function filedeal(::Val{:jl}; info::FileBase, it, path, pathv, pre, pss::PagesSetting, spath, tpath)
	str = read(spath*it, String)
	info.target = it*pss.filesuffix
	info.data = highlight_directly(:julia, str, pss)
end

function filedeal(::Val{:txt}; info::FileBase, it, path, pathv, pre, pss::PagesSetting, spath, tpath)
	str = read(spath*it, String)
	info.target = it*pss.filesuffix
	info.data = highlight_directly(:plain, str, pss)
end
