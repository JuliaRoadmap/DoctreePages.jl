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

Base.@kwdef struct MainScriptSetting
    hljs_languages::AbstractString = "['julia', 'julia-repl']"
    main_requirement::AbstractString = "['jquery', 'highlight', 'hljs-julia', 'hljs-julia-repl', 'hljs-line-numbers']"
    requirejs::NamedTuple{(:url, :configpaths, :configshim), Tuple{AbstractString, AbstractString, AbstractString}} = (
        url = "https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js",
        configpaths = """
        {'headroom': 'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/headroom.min',
		'jquery': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min',
		'headroom-jquery': 'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/jQuery.headroom.min',
		'katex': 'https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.11.1/katex.min',
		'highlight': 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/highlight.min',
        'hljs-julia': 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/languages/julia.min',
		'hljs-julia-repl': 'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/languages/julia-repl.min',
        'hljs-line-numbers': 'https://cdnjs.cloudflare.com/ajax/libs/highlightjs-line-numbers.js/2.8.0/highlightjs-line-numbers.min'}
        """,
        configshim = """
        {"hljs-julia-repl": { "deps": ["highlight"] },
		"hljs-julia": {"deps": ["highlight"]},
        "hljs-line-numbers": { "deps": ["highlight"]},
		"headroom-jquery": { "deps": [ "jquery", "headroom" ]}}
        """
    )
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
* buildmessage::String = "built at \$(Libc.strftime(Libc.time())) by v\$(DTP_VERSION)"
* charset::String = "UTF-8"
* default_alt::String = "img"
* favicon_path::String = ""
* filesuffix::String = ".html"
* giscus::Union{Nothing, GiscusSetting} = nothing
* hljs_all::Bool = true
* lang::String = "en"
* logo_path::String = ""
* main_script::MainScriptSetting
* make404::Bool = true
* make_index::Bool = true
* page_foot::String = "Powered by" ...
* parser::Parser = default_parser()
* remove_original::Bool = true
* repo_branch::String = "master"
* repo_name::String
* repo_owner::String
* repo\\_path::String = `"https://github.com/\$repo_owner/\$repo_name/tree/\$repo_branch/"`
* show_info::Bool = true
* sort_file::Bool = true
* table_align::String = "inherit"
* throwall::Bool = false
* title::String
* unfound::String = "404.html"
* wrap_html::Bool = true
"""
Base.@kwdef struct PagesSetting
    buildmessage::String = "built at $(Libc.strftime(Libc.time())) by v$(DTP_VERSION)"
    charset::String = "UTF-8"
    default_alt::String = "img"
	favicon_path::String = ""
    filesuffix::String = ".html"
    giscus::Union{Nothing, GiscusSetting} = nothing
    # highlighter::CommonHighlightSetting = CommonHighlightSetting()
    hljs_all::Bool = true
	lang::String = "en"
	logo_path::String = ""
    main_script::MainScriptSetting = MainScriptSetting()
    make404::Bool = true
    make_index::Bool = true
    page_foot::String = "Powered by <a href='https://github.com/JuliaRoadmap/DoctreePages.jl'>DoctreePages.jl</a> and its dependencies."
    parser::Parser = default_parser()
    remove_original::Bool = true
    repo_branch::String = "master"
    repo_name::String = ""
    repo_owner::String = ""
    repo_path::String = repo_name=="" ? "" : "https://github.com/$repo_owner/$repo_name/tree/$repo_branch/"
    server_prefix::String = "/"
    show_info::Bool = true
    src_assets = "assets"
    src_script = "script"
    sort_file::Bool = true
    table_align::String = "inherit"
    tar_assets = "assets"
    tar_css = "css"
    tar_extra = "extra"
    tar_script = "script"
    throwall::Bool = false
    title::String
    unfound::String = "404.html"
    wrap_html::Bool = true
end
function Base.show(io::IO, pss::PagesSetting)
    print(io, "PagesSetting for <$(pss.title)>")
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
