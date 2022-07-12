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

function default_parser()
    p=Parser()
    enable!(p, AdmonitionRule())
    enable!(p, FootnoteRule())
    enable!(p, DollarMathRule())
    enable!(p, TableRule())
    return p
end

"""
Pages settings, call `PagesSetting(; keyword=value...)`

The keywords:
* buildmessage::String = "built at \$(Libc.strftime(Libc.time()))"
* charset::String = "UTF-8"
* default_alt::String = "img"
* favicon_path::String = "assets/images/favicon.png"
* filesuffix::String = ".html"
* giscus::Union{Nothing, GiscusSetting} = nothing
* hljs_all::Bool = true
* lang::String = "en"
* logo_path::Union{Nothing, String} = nothing
* make_index::Bool = true
* move_favicon::Bool = true
* page_foot::String = "Powered by" ...
* parser::Parser = default_parser()
* remove_original::Bool = true
* repo_branch::String = "master"
* repo_name::String
* repo_owner::String
* repo\\_path::String = `"https://github.com/\$repo_owner/\$repo_name/tree/\$repo_branch/"`
* show_info::Bool = true
* sort_file::Bool = true
* sub_path::String = ""
* table_align::Symbol = :auto
* throwall::Bool = false
* title::String
* unfound::String = "404.html"
* use_subdir::String = ""
* wrap_html::Bool = true
"""
Base.@kwdef struct PagesSetting
    buildmessage::String = "built at $(Libc.strftime(Libc.time()))"
    charset::String = "UTF-8"
    default_alt::String = "img"
	favicon_path::String = "assets/images/favicon.png"
    filesuffix::String = ".html"
    giscus::Union{Nothing, GiscusSetting} = nothing
    # highlighter::CommonHighlightSetting = CommonHighlightSetting()
    hljs_all::Bool = true
	lang::String = "en"
	logo_path::Union{Nothing, String} = nothing
    make_index::Bool = true
    move_favicon::Bool = true
    page_foot::String = "Powered by <a href='https://github.com/JuliaRoadmap/DoctreePages.jl'>DoctreePages.jl</a> and its dependencies."
    parser::Parser = default_parser()
    remove_original::Bool = true
    repo_branch::String = "master"
    repo_name::String
    repo_owner::String
    repo_path::String = "https://github.com/$repo_owner/$repo_name/tree/$repo_branch/"
    show_info::Bool = true
    src_assets = "assets"
    src_script = "script"
    sort_file::Bool = true
    sub_path::String = ""
    table_align::Symbol = :auto
    tar_assets = "assets"
    tar_css = "css"
    tar_extra = "extra"
    tar_script = "script"
    throwall::Bool = false
    title::String
    unfound::String = "404.html"
    use_subdir::String = ""
    wrap_html::Bool = true
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
