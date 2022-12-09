function highlight(::Val{:encoded}, content::AbstractString, pss::PagesSetting, args)
	return "<div class='encoded'>$(ify_md(content, pss, false))</div>"
end
