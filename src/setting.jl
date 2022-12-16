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
	theme::String = "auto" # "preferred_color_scheme"
	lang::String
	crossorigin::String = "anonymous"
end

Base.@kwdef struct MainScriptSetting
    hljs_languages::AbstractString = "['julia', 'julia-repl']"
    main_requirement::AbstractString = "['jquery', 'highlight', 'hljs-julia', 'hljs-julia-repl', 'hljs-line-numbers']"
    requirejs::NamedTuple = (
        url = "https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js",
        configpaths = """{'headroom':'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/headroom.min','jquery':'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.2/jquery.min','headroom-jquery':'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/jQuery.headroom.min','katex': 'https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.16.4/katex.min','highlight':'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/highlight.min','hljs-julia':'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/languages/julia.min','hljs-julia-repl':'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/languages/julia-repl.min','hljs-line-numbers':'https://cdnjs.cloudflare.com/ajax/libs/highlightjs-line-numbers.js/2.8.0/highlightjs-line-numbers.min'}""",
        configshim = """{"hljs-julia-repl":{"deps":["highlight"]},"hljs-julia":{"deps":["highlight"]},"hljs-line-numbers":{"deps":["highlight"]},"headroom-jquery":{"deps":["jquery","headroom"]}}"""
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

mutable struct PagesSetting
    dict::Dict{Symbol, Any}
end
Base.getproperty(pss::PagesSetting, key::Symbol) = getfield(pss, :dict)[key]
Base.setproperty!(pss::PagesSetting, key::Symbol, x) = getfield(pss, :dict)[key] = x
function PagesSetting(;
    buildmessage = "built at $(Libc.strftime(Libc.time())) by DoctreePages.jl v$(DTP_VERSION)",
    charset = "UTF-8",
    default_alt = "img",
	favicon_path = "",
    filesuffix = ".html",
    giscus::Union{Nothing, GiscusSetting} = nothing,
    # highlighter::CommonHighlightSetting = CommonHighlightSetting(),
    hljs_all::Bool = true,
	lang = "en",
	logo_path = "",
    main_script::MainScriptSetting = MainScriptSetting(),
    make404::Bool = true,
    make_index::Bool = true,
    page_foot = "Powered by <a href='https://github.com/JuliaRoadmap/DoctreePages.jl'>DoctreePages.jl</a> and its dependencies.",
    parser::Parser = default_parser(),
    remove_original::Bool = true,
    repo_branch = "master",
    repo_name = "",
    repo_owner = "",
    repo_path = repo_name=="" ? "" : "https://github.com/$repo_owner/$repo_name/tree/$repo_branch/",
    server_prefix = "/",
    show_info::Bool = true,
    src_assets = "assets",
    src_script = "script",
    sort_file::Bool = true,
    table_align::String = "inherit",
    tar_assets = "assets",
    tar_css = "css",
    tar_extra = "extra",
    tar_script = "script",
    throwall::Bool = false,
    title = "Untitled",
    unfound = "404.html",
    wrap_html::Bool = true,
)
    return PagesSetting(Dict{Symbol, Any}(
        :buildmessage    => buildmessage,
        :charset         => charset,
        :default_alt     => default_alt,
        :favicon_path    => favicon_path,
        :filesuffix      => filesuffix,
        :giscus          => giscus,
        :hljs_all        => hljs_all,
        :lang            => lang,
        :logo_path       => logo_path,
        :main_script     => main_script,
        :make404         => make404,
        :make_index      => make_index,
        :page_foot       => page_foot,
        :parser          => parser,
        :remove_original => remove_original,
        :repo_branch     => repo_branch,
        :repo_name       => repo_name,
        :repo_owner      => repo_owner,
        :repo_path       => repo_path,
        :server_prefix   => server_prefix,
        :show_info       => show_info,
        :src_assets      => src_assets,
        :src_script      => src_script,
        :sort_file       => sort_file,
        :table_align     => table_align,
        :tar_assets      => tar_assets,
        :tar_css         => tar_css,
        :tar_extra       => tar_extra,
        :tar_script      => tar_script,
        :throwall        => throwall,
        :title           => title,
        :unfound         => unfound,
        :wrap_html       => wrap_html
    ))
end

function Base.show(io::IO, pss::PagesSetting)
    print(io, "PagesSetting for <$(pss.title)>")
    if pss.repo_name != ""
        print(io, " $(pss.repo_owner)/$(pss.repo_name)")
    end
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
