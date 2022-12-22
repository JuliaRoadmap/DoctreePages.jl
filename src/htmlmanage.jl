function html_safe(s::AbstractString)
	t = ""
	for ch in s
		if ch == '&' t *= "&amp;"
		elseif ch == '<' t *= "&lt;"
		elseif ch == '>' t *= "&gt;"
		elseif ch == '\n' t *= "<br>"
		else t *= ch
		end
	end
	return t
end

function html_nobr_safe(s::AbstractString)
	t = ""
	for ch in s
		if ch == '&' t *= "&amp;"
		elseif ch == '<' t *= "&lt;"
		elseif ch == '>' t *= "&gt;"
		else t *= ch
		end
	end
	return t
end

function tagclass_safe(s::AbstractString)
	return replace(s, "'" => "\\'")
end

function filename_safe(s::AbstractString)
	if contains(s, '/') || contains(s, '\\')
		error("filename contains slash")
	else
		return s
	end
end
