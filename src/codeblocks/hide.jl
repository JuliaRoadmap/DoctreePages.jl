function highlight(::Val{:hide}, content::AbstractString, pss::PagesSetting, args)
	title = length(args)<2 ? "click to reveal" : args[2]
	return hidehtml(title, ify_md(content, pss, false))
end
function hidehtml(title, content)
	return "<div class='box-hide'><button class='button-hide' onclick='unhide(event)'><span>$title</span></button><div class='display-hide'>$content</div>"
end
