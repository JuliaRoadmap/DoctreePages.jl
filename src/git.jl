function github_action(srcbranch::AbstractString = "master", tarbranch::AbstractString = "gh-pages", setting::Union{AbstractString, PagesSetting} = "DoctreeBuild.toml")
	srcdir="" # ?
	if !isa(setting, PagesSetting)
		setting=PagesSetting(;readbuildsetting(joinpath(srcdir, setting)))
	end
end
