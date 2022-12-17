const buildmessage=`built at Sat Dec 17 07:28:46 2022 by DoctreePages.jl v1.5.2`
const page_foot=`Powered by <a href='https://github.com/JuliaRoadmap/DoctreePages.jl'>DoctreePages.jl</a> and its dependencies.`
const tar_css=`css`
const filesuffix=`.html`
const menu=['',`welcome/README`,[`zh/中文文档`,`usage/使用方式`,`guidelines/规范`,`notice/注意事项`,`settings/设置`,],[`en/English Docs`,`usage/Usage`,`guidelines/Guidelines`,`notice/Notice`,`settings/Settings`,],]
const configpaths={'headroom':'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/headroom.min','jquery':'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.2/jquery.min','headroom-jquery':'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/jQuery.headroom.min','katex': 'https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.16.4/katex.min','highlight':'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/highlight.min','hljs-julia':'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/languages/julia.min','hljs-julia-repl':'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.5.1/languages/julia-repl.min','hljs-line-numbers':'https://cdnjs.cloudflare.com/ajax/libs/highlightjs-line-numbers.js/2.8.0/highlightjs-line-numbers.min'}
const configshim={"hljs-julia-repl":{"deps":["highlight"]},"hljs-julia":{"deps":["highlight"]},"hljs-line-numbers":{"deps":["highlight"]},"headroom-jquery":{"deps":["jquery","headroom"]}}
const hljs_languages=['julia', 'julia-repl']
const main_requirement=['jquery', 'highlight', 'hljs-julia', 'hljs-julia-repl', 'hljs-line-numbers']
