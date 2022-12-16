function highlight(::Val{Symbol("random-word")}, content::AbstractString, ::PagesSetting, args)
	toml = TOML.parse(content)
	id = toml["id"]
	pool = toml["pool"]
	cd(pss.tardir) do
		open("extra/data_random_word/$id.json", "w") do file
			JSON3.write(file, pool)
		end
	end
	return "<div class='random-word' data-id='$id'></div>\n"
end
