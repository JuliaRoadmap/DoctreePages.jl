"""
Giscus settings, call `GiscusSetting(; keyword=value...)`

Parameters can be generated using giscus.app
"""
Base.@kwdef struct GiscusSetting
    repo::String
    repo_id::String
    category::String = "General"
    category_id::String
    mapping::String = "pathname"
	reactions_enabled::String = "1"
	emit_metadata::String = "0"
	input_position::String = "top"
	theme::String = "preferred_color_scheme"
	lang::String
	crossorigin::String = "anonymous"
end

"""
Pages settings, call `PagesSetting(; keyword=value...)`

The keywords:
* buildmessage::String = "built at \$(Libc.strftime(Libc.time()))"
* charset::String = "UTF-8"
* favicon_path::String = "assets/img/favicon.png"
* filesuffix::String = ".html"
* giscus::Union{Nothing, GiscusSetting} = nothing
* lang::String = "en"
* logo_path::String = "assets/img/logo.png"
* repo_branch::String = "master"
* repo_name::String
* repo_owner::String
* repo_path::String = "https://github.com/\$repo_owner/\$repo_name/tree/\$repo_branch/"
* title::String
"""
Base.@kwdef struct PagesSetting
    buildmessage::String = "built at $(Libc.strftime(Libc.time()))"
    charset::String = "UTF-8"
	favicon_path::String = "assets/img/favicon.png"
    filesuffix::String = ".html"
    giscus::Union{Nothing, GiscusSetting} = nothing
	lang::String = "en"
	logo_path::String = "assets/img/logo.png"
    repo_branch::String = "master"
    repo_name::String
    repo_owner::String
    repo_path::String = "https://github.com/$repo_owner/$repo_name/tree/$repo_branch/"
    title::String
end
Base.@kwdef struct PageSetting
    description::String
	editpath::String
    mds::String
    navbar_title::String
    nextpage::String
    prevpage::String
    tURL::String # trace-back-to-root-dir
end
