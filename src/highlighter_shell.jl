function highlight(::Union{Val{:shell}, Val{:sh}}, content::AbstractString)
	lines=split(content, '\n'; keepempty=true)
	vec=Vector{Tuple}()
	maystart=""
	sz=0
	l=length(lines)
	sizehint!(vec, l)
	for i in 1:l
		line=lines[i]
		if maystart!="" && startswith(line, maystart)
			len=length(line)
			if sz!=len
				push!(vec, ("repl-code" => maystart, col(line[sz+1:len], "plain"; br=false)))
			else
				push!(vec, ("repl-code" => maystart,))
			end
		elseif startswith(line, "\$ ")
			maystart="\$"
			sz=1
			push!(vec, ("repl-code" => "\$", col(line[2:end], "plain"; br=false)))
		else
			find=findfirst(r"^[a-zA-Z0-9_-]*(>|#|~) ", line)
			if find===nothing
				push!(vec, (col(line, "plain"; br=false),))
			else
				sz=find.stop-1
				maystart=line[1:sz]
				push!(vec, ("repl-code" => maystart, col(line[find.stop:end], "plain"; br=false)))
			end
		end
	end
	return buildcodeblock("shell" ,vec)
end
