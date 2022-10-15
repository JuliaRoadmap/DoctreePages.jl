function highlight(::Val{Symbol("insert-fill")}, content::AbstractString, ::PagesSetting)
	return hidehtml("click to reveal", content)
end
function hidehtml(title, content)
	return "<span class='hide'>$title<div class='hidebox'>$content</div></span>"
end
