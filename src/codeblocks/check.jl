function highlight(::Val{:check}, content::AbstractString, pss::PagesSetting, args)
	return "<div class='checkis' data-check='is-$(args[2])'>$(ify_md(content, pss, false))</div>"
end
