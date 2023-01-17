"""
Fail if: starts with '"' or escaping `\\\\`

```jl
julia> split_codeblocktitle("1 \"2 3\" 4 ")
3-element Vector{String}:
 "1"
 "2 3"
 "4"
```
"""
function split_codeblocktitle(title::AbstractString)
	v = Vector{String}()
	if isempty(title)
		return v
	end
	inquote = false
	record = index = firstindex(title) # deepcopy
	prev = prevind(title, index)
	prevchar = '\0'
	while true
		ch = title[index]
		if ch == ' '
			if !inquote
				if record<=prev
					push!(v, title[record:prev])
				end
				record = nextind(title, index)
			end
		elseif ch == '"'
			if inquote
				inquote = false
			elseif prevchar == ' '
				inquote = true
				record = index
			end
		elseif ch == '\\'
			if inquote
				index = nextind(title, index)
			end
		end
		if index == lastindex(title)
			if record<=index
				push!(v, title[record:index])
			end
			break
		end
		prev = index
		prevchar = ch
		index = nextind(title, index)
	end
	for i in eachindex(v)
		if first(v[i], 1) == "\""
			v[i] = unescape_string(chop(v[i], head=1, tail=1))
		end
	end
	return v
end

function highlight_directly(language, code::AbstractString, pss::PagesSetting)
	return highlight(Val(Symbol(language)), code, pss, [language])
end

function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-") # 兼容旧版本
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	langs = split_codeblocktitle(language)
	if isempty(langs)
		@warn "No codeblock type information given." code
		return buildhljsblock("plain", code)
	end
	langs[1] = replace(lowercase(langs[1]), '-' => '_')
	language = langs[1]
	sym = Symbol(language)
	return highlight(Val(sym), code, pss, langs)
end

function buildhljsblock(language::AbstractString, str::AbstractString)
	code = html_nobr_safe(str)
	return "<div data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language'><code>$code</code></pre></div><br />"
end

function highlight(::Val, code::AbstractString, pss::PagesSetting, args)
	language = String(args[1])
	if language == "julia_repl"
		language = "julia-repl"
	end
	return buildhljsblock(language, code)
	#= else
		msg = "pss.hljs_all = false not yet supported"
		pss.throwall ? error(msg) : (@warn msg)
		return buildhljsblock(language, code)
	end =#
end

include("codeblocks/encoded.jl")
include("codeblocks/hide.jl")
include("codeblocks/insert_html.jl")
include("codeblocks/insert_fill.jl")
include("codeblocks/insert_setting.jl")
include("codeblocks/insert_test.jl")
include("codeblocks/random_word.jl")
