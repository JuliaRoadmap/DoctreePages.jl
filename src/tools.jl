function expend_slash(str)
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
	v=map(collect(d)) do pair
		Symbol(pair.first) => pair.second
	end
	return NamedTuple(v)
end
