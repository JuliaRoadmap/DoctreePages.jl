function highlight(::Val{Symbol("random-word")}, content::AbstractString, ::PagesSetting, args)
	toml = TOML.parse(content)
	id = toml["id"]
	pool = toml["pool"]
	open(".json", "w") do file
		JSON3.write(file, pool)
	end
	return "<div class='random-word' data-id='$id'></div>\n"
end
