function highlight(language::AbstractString, code::AbstractString, pss::PagesSetting)
	if startswith(language, "is-")
		return "<div class='checkis' data-check='$(language)'>$(ify_md(code, pss))</div>"
	end
	sym=Symbol(language)
	if hasmethod(highlight, Tuple{Val{sym}, typeof(code), PagesSetting})
		return highlight(Val(sym), code, pss)
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

function highlight(::Val{Symbol("insert-html")}, content::AbstractString, ::PagesSetting)
	return content
end
function highlight(::Val{Symbol("insert-fill")}, content::AbstractString, pss::PagesSetting)
	dict=TOML.parse(content)
	con=dict["content"]::String
	con=ify_md(con, pss)
	esc=escape_string(dict["ans"])
	usereg=haskey(dict, "ans_regex")
	reg=usereg ? dict["ans_regex"]::String : esc
	return string(
		"<div class='fill-area'><div>", con, "</div><input type='text' placeholder='ans'>",
		"<button class='submit-fill' data-ans='$reg' data-isreg='$usereg'>📤</button>",
		"<button class='ans-fill' data-ans='$esc'>🔑</button>",
		haskey(dict, "instruction") ? "<button class='instruction-fill' data-con='$(escape_string(dict["instruction"]))'>💡</button>" : "",
		"</div>"
	)
end
function highlight(::Val{Symbol("insert-setting")}, content::AbstractString, pss::PagesSetting)
	toml = TOML.parse(content)
	type = toml["type"]
	str = ""
	if type=="select-is"
		str = "<div class='select-is modal-card-body' data-chs='"
		for pair in toml["choices"]
			str *= "$(pair.first):\"$(pair.second)\","
		end
		str *= "' data-st='"
		for pair in toml["store"]
			str *= "$(pair.first):\"$(pair.second)\","
		end
		str *= "'><p>$(html_safe(toml["content"]))</p></div>"
	end
	return str
end

function makeindex_char(char::AbstractString, id::Integer)
	if char == "A"
		return '@'+id
	elseif char == "a"
		return '`' + id
	elseif char == "1"
		return string(id)
	end
end
function highlight(::Val{Symbol("insert-test")}, content::AbstractString, pss::PagesSetting)
	toml = TOML.parse(content)
	gl = toml["global"]::Dict
	parts = toml["parts"]::Vector
	tl = gl["time_limit"]::Real
	fs = gl["full_score"]::Number
	name = replace(gl["name"], '\'' => "\\\'")
	str = "<div class='test-area' data-tl='$tl' data-fs='$fs' data-name='$name'><br />"
	current = nothing
	for part in parts
		type = part["type"]
		g(key, default = nothing) = (haskey(part, key) ? part[key] : (current !== nothing && haskey(current, key)) ? current[key] : haskey(gl, key) ? gl[key] : default)
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
		elseif type == "choose"
			str *= "<div class='choose-area' data-"
			if haskey(part, "ans_dict")
				dict = part["ans_dict"]::Dict
				str *= "dict='"
				for pair in dict
					str *= "\"$(pair.first)\":$(pair.second),"
				end
				str *= "'>"
			else
				ans = part["ans"]
				score = g("score")::Real
				str *= "an='$ans' data-sc='$score'>"
			end
			str *= "<div>$(ify_md(part["content"], pss))</div>"
			index_char = g("index_char", "A")
			index_suffix = g("index_suffix", ". ")
			choices = part["choices"]
			for i in 1:length(choices)
				ch = choices[i]
				str *= "<span>$(makeindex_char(index_char, i))$(index_suffix)$(html_safe(ch))</span>"
			end
			str *= "</div>"
		elseif type == "fill"
			score = g("score")::Real
			str *= "<div class='fill-area' data-sc='$score' data-"
			if haskey(part, "ans_regex")
				str *= "re='$(part["ans_regex"])"
			else
				str *= "an='$(part["ans"])"
			end
			mds = ify_md(part["content"], pss)
			str *= "'><div>$mds</div><input type='text' placeholder='ans'></div>"
		end
	end
	return str * "</div>"
end
