function makeindex_char(char::AbstractString, id::Integer)
	if char == "A"
		return '@'+id
	elseif char == "a"
		return '`' + id
	elseif char == "1"
		return string(id)
	end
end

function highlight(::Val{:insert_test}, content::AbstractString, pss::PagesSetting, args)
	toml = TOML.parse(content)
	gl = toml["global"]::Dict
	parts = toml["parts"]::Vector
	tl = gl["time_limit"]::Real
	fs = gl["full_score"]::Number
	name = replace(gl["name"], '\'' => "\\\'")
	str = "<div class='test-area' data-tl='$tl' data-fs='$fs' data-name='$name'><br />"
	current = nothing
	num = 1
	q_pre_n = haskey(gl, "q_pre") ? gl["q_pre"]=="number" : true
	for part in parts
		type = haskey(part, "type") ? part["type"] : current["ch_type"]
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
			mds = ify_md(part["content"], pss)
			if q_pre_n
				mds = "$(num). $mds"
				num += 1
			end
			str *= "<div>$mds</div>"
			index_char = g("index_char", "A")
			index_suffix = g("index_suffix", ". ")
			choices = part["choices"]
			for i in eachindex(choices)
				ch = choices[i]
				htm = html_safe(ch)
				if length(ch)>2
					htm *= "<br />"
				else
					htm *= "\t"
				end
				str *= "<span>$(makeindex_char(index_char, i))$(index_suffix)$htm</span>"
			end
			str *= "<br /></div>"
		elseif type == "fill"
			score = g("score")::Real
			str *= "<div class='fill-area' data-sc='$score' data-"
			if haskey(part, "ans_regex")
				str *= "re='$(part["ans_regex"])"
			else
				str *= "an='$(part["ans"])"
			end
			mds = ify_md(part["content"], pss)
			if q_pre_n
				mds = "$(num). $mds"
				num += 1
			end
			str *= "'><div>$mds</div><input type='text' placeholder='ans'></div>"
		end
	end
	return str * "</div>"
end
