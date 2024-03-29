function highlight(::Val{:random_word}, content::AbstractString, pss::PagesSetting, args)
	toml = TOML.parse(content)
	id = toml["id"]
	div = "<div class='random-word' data-id='$id'></div>\n"
	if !haskey(toml, "pool")
		return div
	end
	pool = toml["pool"]
	cd(pss.tardir) do
		mkpath("extra/data_random_word")
		io = open("extra/data_random_word/$id.json", "w")
		JSON3.write(io, pool)
		close(io)
	end
	return div
end
