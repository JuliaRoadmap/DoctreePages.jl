function highlight(::Val{:insert_setting}, content::AbstractString, pss::PagesSetting, args)
	toml = TOML.parse(content)
	type = toml["type"]
	str = ""
	if type=="select-is"
		str = "<div class='select-is modal-card-body' data-de='$(toml["default"])' data-chs='"
		for pair in toml["choices"]
			str *= "\"$(pair.first)\":\"$(pair.second)\","
		end
		str *= "' data-st='"
		for pair in toml["store"]
			str *= "\"$(pair.first)\":\"$(pair.second)\","
		end
		str *= "'><p>$(html_safe(toml["content"]))</p></div>"
	end
	return str
end
