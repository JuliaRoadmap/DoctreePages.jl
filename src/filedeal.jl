function filedeal(v::Val; fbase::FileBase, method::Symbol, pss::PagesSetting)
	if method == :default
		method = default_filedealmethod(v)
	end
	if method == :copy
		cp(pss.spath*pss.fullname, pss.tpath*pss.fullname; force=true)
		fbase.generated = true
		fbase.target = pss.fullname
		return
	end
	if method == :extra
		filedeal_extra(v; fbase = fbase, pss = pss)
		return
	end
	str = read(pss.spath*pss.fullname, String)
	fbase.target = fbase.name*pss.filesuffix
	fbase.data =
		method == :plain ? html_safe(str) :
		method == :insert ? str :
		method == :codeblock ? highlight_directly(fbase.suffix, str, pss) :
		error("File dealing method \"$(method)\" is not supported.")
end

default_filedealmethod(::Val) = :copy
default_filedealmethod(::Val{:c}) = :codeblock
default_filedealmethod(::Val{:cpp}) = :codeblock
default_filedealmethod(::Val{:css}) = :copy
default_filedealmethod(::Val{:h}) = :codeblock
default_filedealmethod(::Val{:hpp}) = :codeblock
default_filedealmethod(::Val{:htm}) = :insert
default_filedealmethod(::Val{:html}) = :insert
default_filedealmethod(::Val{:jl}) = :codeblock
default_filedealmethod(::Val{:js}) = :copy
default_filedealmethod(::Val{:md}) = :extra
default_filedealmethod(::Val{:py}) = :codeblock
default_filedealmethod(::Val{:ts}) = :copy
default_filedealmethod(::Val{:txt}) = :plain

function filedeal_extra(::Val{:md}; fbase::FileBase, pss::PagesSetting)
	con = ""
	s = replace(read(pss.spath*pss.fullname, String), "\r"=>"")
	md = nothing
	try
		md = pss.parser(s)
		con = mkhtml(md, md.t, pss)
	catch er
		pss.throwall && error(er)
		buf = IOBuffer()
		showerror(buf, er)
		str = String(take!(buf))
		@error "Markdown Parsing Error" it str
		con = "<h2 id='header-error'>ERROR handled by DoctreePages</h2><p style='color:red'>$(html_safe(str))</p>"
	end
	if fbase.title == ""
		fbase.title = get_markdowntitle(md)
		if fbase.title == ""
			@error "Failed to get title of Markdown document."
			fbase.title = "Untitled"
		end
	end
	fbase.target = fbase.name*pss.filesuffix
	fbase.data = con
end
