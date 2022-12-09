function highlight(::Val{:hide}, content::AbstractString, pss::PagesSetting)
	return hidehtml("click to reveal", ify_md(content, pss, false))
end
function hidehtml(title, content)
	return "<div class='hide'><button class='box-hide' onclick='unhide(event)'><span>$title</span><div>$content</div></button>"
end
