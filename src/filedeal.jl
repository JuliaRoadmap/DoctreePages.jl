function filedeal(::Val; fbase::FileBase, pss::PagesSetting)
	cp(pss.spath*pss.fullname, pss.tpath*pss.tpath; force=true)
	fbase.generated = true
	fbase.target = pss.fullname
end

function filedeal(::Val{:md}; fbase::FileBase, pss::PagesSetting)
	con = ""
	s = replace(read(pss.spath*pss.fullname, String), "\r"=>"")
	try
		md = pss.parser(s)
		if fbase.title == ""
			fbase.title = md.first_child.first_child.literal
		end
		fbase.target = fbase.name*pss.filesuffix
		fbase.data = mkhtml(md, md.t, pss)
	catch er
		if pss.throwall
			error(er)
		end
		buf = IOBuffer()
		showerror(buf, er)
		str = String(take!(buf))
		@error "Markdown Parsing Error" it str
		con = "<h2 id='header-error'>ERROR handled by DoctreePages</h2><p style='color:red'>$(html_safe(str))</p>"
	end
end

function filedeal(::Union{Val{:html}, Val{:htm}}; fbase::FileBase, pss::PagesSetting)
	str = read(pss.spath*pss.fullname, String)
	fbase.target = fbase.name*pss.filesuffix
	if pss.wrap_html
		fbase.data = str
	else
		fbase.generated = true
		write(pss.tpath*fbase.target, str)
	end
end

macro register_codefiledeal(sym, target)
	if isa(sym, Symbol)
		sym = Val{sym}
	elseif isa(sym, Tuple)
		sym = Union{(Val{x} for x in sym)...}
	end
	return :(
		filedeal(::$(sym); fbase::FileBase, pss::PagesSetting) = codefiledeal(fbase, pss, $(target))
	)
end

@register_codefiledeal :c :c
@register_codefiledeal (:h, :cpp, :hpp) :cpp
@register_codefiledeal :jl :julia
@register_codefiledeal :js :js
@register_codefiledeal :py :py
@register_codefiledeal :txt :plain
function codefiledeal(fbase::FileBase, pss::PagesSetting, target::Symbol)
	str = read(pss.spath*pss.fullname, String)
	fbase.target = fbase.name*pss.filesuffix
	fbase.data = highlight_directly(target, str, pss)
end
