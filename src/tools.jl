function rep(str::AbstractString)
	return replace(str, '`' => "\\`")
end
function expand_slash(str)
	return (str[end] in ['/', '\\']) ? str : str*'/'
end
function first_invec(x, vec::Vector)
	i = 0
	for j in eachindex(vec)
		@inbounds if vec[j]==x
			i=j
			break
		end
	end
	return i
end

function namedtuplefrom(d::Dict{String, Any})
	v = map(collect(d)) do pair
		Symbol(pair.first) => pair.second
	end
	return NamedTuple(v)
end
function expand_suffix(str::String, set::Set)
	for i in set
		if startswith(i, str)
			if length(i)==length(str)
				return i
			end
			dot = findlast('.', i)
			if dot!==nothing && length(str)==dot-1
				return i
			end
		end
	end
	error("no corresponding name for $str")
end
function split_filesuffix(str::String)
	dot = findlast('.', str)
	@inbounds return dot===nothing ? (str, "") : (str[1:dot-1], str[dot+1:end])
end
function share_file(x)
	return x
end
