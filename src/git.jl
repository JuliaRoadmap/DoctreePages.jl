function github_action(setting::Union{AbstractString, PagesSetting} = "DoctreeBuild.toml")
	if !isa(setting, PagesSetting)
		setting = PagesSetting(;readbuildsetting(setting)...)
	end
	# mkpath("public")
	generate(".", "public", setting)
end
