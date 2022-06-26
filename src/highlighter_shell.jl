function highlight(::Union{Val{:shell}, Val{:sh}}, content::AbstractString)
	lines=split(content, '\n'; keepempty=true)
	s=""
	maystart=""
	sz=0
	l=length(lines)
	for i in 1:l
		line=lines[i]
		if maystart!="" && startswith(line, maystart)
			s*=safecol(maystart, "repl-code")
			len=length(line)
			if sz!=len
				s*=col(line[sz+1:len], "plain"; br=false)
			end
		elseif startswith(line, "\$ ")
			maystart="\$"
			sz=1
			s*=safecol("\$", "repl-code")
			s*=col(line[2:end], "plain"; br=false)
		else
			find=findfirst(r"^[a-zA-Z0-9_-]*(>|#|~) ", line)
			if find===nothing
				s*=col(line, "plain"; br=false)
			else
				sz=find.stop-1
				maystart=line[1:sz]
				s*=safecol(maystart, "repl-code")
				s*=col(line[find.stop:end], "plain"; br=false)
			end
		end
		if i!=l
			s*="<br />"
		end
	end
	return s
end
