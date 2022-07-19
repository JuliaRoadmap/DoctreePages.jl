function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, typeof(code)})
		return highlight(Val(sym), code)
	elseif pss.hljs_all
		return buildhljsblock(language, code)
	#=
	elseif hasmethod(highlight_lines, Tuple{Val{sym}, typeof(code), CommonHighlightSetting})
		return buildcodeblock(language, highlight_lines(sym, code, pss.highlighter))
	=#
	else
		msg = "pss.hljs_all = false not yet supported"
		pss.throwall ? error(msg) : (@warn msg)
		return buildhljsblock(language, code)
	end
end

function buildcodeblock(language::AbstractString, str::AbstractString)
	return "<div class='data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language nohighlight'><code>$str</code></pre></div><br />"
end
#= function buildcodeblock(language::AbstractString, lines::HighlightLines)
	return buildcodeblock(language, html(lines))
end =#

function buildhljsblock(language::AbstractString, str::AbstractString)
	return "<div data-lang='$language'><div class='codeblock-header'></div><pre class='codeblock-body language-$language'><code>$str</code></pre></div><br />"
end

function highlight(::Val{Symbol("insert-html")}, content::AbstractString)
	return content
end
function highlight(::Val{Symbol("insert-fill")}, content::AbstractString)
	dict=TOML.parse(content)
	con=dict["content"]::String
	con=ify_md(des, pss)
	esc=escape_string(dict["ans"])
	usereg=haskey(dict, "ans_regex")
	reg=usereg ? dict["ans_regex"]::String : esc
	return string(
		"<div class='fill-area'><p>", con, "</p><input type='text' placeholder='ans'>",
		"<button class='submit-fill' data-ans='$reg' data-isreg='$usereg'>📤</button>",
		"<button class='ans-fill' data-ans='$esc'>🔑</button>",
		haskey(dict, "instruction") ? "<button class='instruction-fill' data-con='$(escape_string(dict["instruction"]))'>💡</button>" : "",
		"</div>"
	)
end
function highlight(::Val{Symbol("insert-test")}, content::AbstractString)
	toml = TOML.parse(content)
	gl = toml["global"]::Dict
	parts = toml["parts"]::Dict
	str = "<div class='test-area' data-tl='$(gl["time_limit"]::Real)' data-fs='$(gl["full_score"]::Number)'><p>$(html_safe(gl["name"]))</p><br />"
	current = nothing
	for part in parts
		type = part["type"]
		g(key, default = nothing) = (haskey(g, $key) ? part[$key] : (current !== nothing && haskey(current, $key)) ? current[$key] : haskey(gl[$key]) ? gl[$key] : $default)
		if type == "group"
			if haskey(part, "content")
				str *= ify_md(part["content"], pss)
			end
			delete!(part, "content")
			current = part
		elseif type == "group-end"
			current = nothing
		elseif type == "text"
			str *= ify_md(part["content"], pss)
		elseif type == "choice"
			score::Real = g("score")
			str *= "<div class='choice-area' data-"
			str *= "<p>$(ify_md(part["content"], pss))</p>"
			index_char = g("index_char", "A")
			index_suffix = g("index_suffix", ".")
			str *= "</div>"
		elseif type == "fill"
			score::Real = g("score")
			str *= "<div class='fill-area' data-sc='$score' data-"
			if haskey(part, "ans_regex")
				str *= "re='$(part["ans_regex"])"
			else
				str *= "an='$(part["ans"])"
			end
			mds = ify_md(part["content"], pss)
			str *= "'><p>$mds</p><input type='text' placeholder='ans'></div>"
		end
	end
	return str * "</div>"
end
