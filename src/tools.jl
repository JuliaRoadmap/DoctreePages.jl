function rep(str::AbstractString)
	return replace(str, '`' => "\\`")
end
function expand_slash(str)
	return (str[end] in ['/', '\\']) ? str : str*'/'
end
function first_invec(x, vec::Vector)
	i = 0
	for (j, val) in enumerate(vec)
		if val == x
			i = j
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
			if sizeof(i)==sizeof(str)
				return i
			end
			dot = findlast('.', i)
			if !isnothing(dot) && sizeof(str)==dot-1
				return i
			end
		end
	end
	error("no corresponding name for $str")
end
function share_file(x)
	return x
end
