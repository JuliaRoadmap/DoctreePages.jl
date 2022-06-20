const jl_keywords=[
	"end","if","for","else","elseif","function","return","while","using","try","catch",
	"const","struct","mutable","abstract","type","begin","macro","do","break","continue","finally","where","module","import","global","export","local","quote","let",
	"baremodule","primitive"
]
const jl_specials=[
	"true","false","nothing","missing"
]
safecol(content::String,co::String)="<span class=\"hl-$co\">$content</span>"
function col(content::String,co::String;br=true)
	if content=="" return "" end
	t=replace(content,"&"=>"&amp;")
	t=replace(t,"<"=>"&lt;")
	t=replace(t,">"=>"&gt;")
	t=replace(t," "=>"&nbsp;")
	return "<span class=\"hl-$co\">$(br ? replace(t,"\n"=>"<br />") : t)</span>"
end
function highlight(::Union{Val{:jl}, Val{:julia}}, content::AbstractString)
	co=String(content)
	repl=false
	s=""
	stack=Vector{UInt8}()
	#=
	0	$(
	1	"
	2	`
	3	"""
	=#
	sz=thisind(co,sizeof(co))
	pre=1
	i=1
	emp=false
	dealf=(to::Int=prevind(co,i)) -> begin
		s*=col(co[pre:to],emp ? "plain" :
			last(stack)==0x0 ? "insert" : "string"
		)
	end
	try

	while i<=sz
		ch=co[i]
		emp=isempty(stack)
		emp2=emp || last(stack)==0x0
		if emp && (ch=='\n' || i==1) # REPL特殊处理尝试
			while ch=='\n'
				i+=1
				ch=co[i]
			end
			if startswith(SubString(co,i,sz),"julia> ")
				dealf()
				s*=col("julia> ","repl-code")
				repl=true
				i+=7
				pre=i
			elseif startswith(SubString(co,i,sz),"help?> ")
				dealf()
				s*=col("help?> ","repl-help")
				i+=7
				pre=i
			elseif startswith(SubString(co,i,sz),"shell> ")
				dealf()
				s*=col("shell> ","repl-shell")
				i+=7
				pre=i
			else
				f=findfirst(r"^\([0-9a-zA-Z._@]*\) pkg> ", SubString(co,i,sz))
				if f!==nothing
					dealf()
					s*=col(co[f.start+i-1:f.stop+i-1],"repl-pkg")
					i+=f.stop
					pre=i
				elseif repl && startswith(SubString(co,i,sz),"ERROR: ") # "caused by:"
					dealf()
					s*=col("ERROR: ","repl-error")
					i+=7
					pre=i
				end
			end
		end
		ch=co[i]
		while ch==' ' || ch=='\t'
			i+=1
			ch=co[i]
		end
		if emp2 && 'A'<=ch<='Z' # 推测是类型
			dealf()
			j=i+1
			st=0
			while j<=sz
				if co[j]=='{' st+=1
				elseif co[j]=='}'
					st==0 ? break : st-=1
				elseif !(Base.is_id_char(co[j]) || co[j]==' ' || co[j]==',' || co[j]==':')
					break
				end
				j=nextind(co,j)
			end
			if j>sz
				s*=col(co[i:sz],"type")
				return s
			else
				s*=col(co[i:prevind(co,j)],"type")
				i=j
				pre=j
			end
		elseif emp2 && Base.is_id_start_char(ch) # 推测是变量等
			j=nextind(co,i)
			while j<=sz && Base.is_id_char(co[j])
				j=nextind(co,j)
			end
			str=co[i:prevind(co,j)]
			if in(str,jl_keywords)
				dealf()
				s*=safecol(str,"keyword")
			elseif in(str,jl_specials) || (repl && str=="ans")
				dealf()
				s*=safecol(str,"special")
			elseif j>sz
				s*=col(co[pre:sz],"plain")
				return s
			elseif co[j]=='('
				dealf()
				s*=col(str,"function")
			else
				i=j
				continue
			end
			i=j
			pre=j
		elseif ch=='\"'
			if emp || last(stack)==0x0 # 新字符串
				dealf()
				pre=i
				if co[i+1]=='"'
					if i+1==sz # 末尾&空
						s*=col("\"\"","string")
						return s
					elseif co[i+2]!='"' # 空字符串
						s*=col("\"\"","string")
						i+=2
						pre=i
						continue
					end
					# 多行字符串
					push!(stack,0x3)
					i+=3
				else
					push!(stack,0x1)
					i+=1
				end
			elseif last(stack)==0x1
				if i==sz # 末尾
					s*=col(co[pre:sz],"string")
					return s
				else
					s*=col(co[pre:i],"string")
					i+=1
					pre=i
					pop!(stack)
				end
			elseif last(stack)==0x3
				if i>sz-2
					s*=col(co[pre:sz],"string")
					return s
				end
				if co[i+1]=='"' && co[i+2]=='"'
					s*=col(co[pre:i+2],"string")
					i+=3
					pre=i
					pop!(stack)
				else
					i+=1
				end
			elseif last(stack)==0x2
				i+=1
			end
		elseif emp2 && ch=='\''
			dealf()
			if i>sz-2
				s*=col(co[i:sz],"string")
			end
			if co[i+1]=='\\'
				j=nextind(co,i+2)
				s*=col(co[i:j],"string")
				i=j+1
			else
				j=nextind(co,i+1)
				s*=col(co[i:j],"string")
				i=j+1
			end
			pre=i
		elseif !emp2 && ch=='\\'
			dealf()
			s*=col(co[i:i+1],"escape")
			i=nextind(co,i+1)
			pre=i
		elseif !emp2 && ch=='$'
			j=i+1
			if co[j]=='('
				dealf()
				pre=i
				push!(stack,0x0)
				i+=2
			elseif Base.is_id_start_char(co[j])
				dealf()
				j=nextind(co,j)
				while j<=sz && Base.is_id_char(co[j])
					j=nextind(co,j)
				end
				if j>sz
					s*=col(co[i:sz],"insert")
					return s
				else
					s*=col(co[i:prevind(co,j)],"insert")
					i=j
					pre=j
				end
			else
				i+=1
			end
		elseif emp2 && ch=='@'
			j=i+1
			if Base.is_id_start_char(co[j])
				dealf()
				j=nextind(co,j)
				while j<=sz && Base.is_id_char(co[j])
					j=nextind(co,j)
				end
				if j>sz
					s*=col(co[i:sz],"macro")
					return s
				else
					s*=col(co[i:prevind(co,j)],"macro")
					i=j
					pre=j
				end
			else
				i+=1
			end
		elseif ch=='`'
			if emp || last(stack)==0x0
				dealf()
				pre=i
				push!(stack,0x2)
				i+=1
			elseif last(stack)==0x2
				s*=col(co[pre:i],"string")
				pop!(stack)
				i+=1
				pre=i
			else
				i+=1
			end
		elseif emp2 && '0'<=ch<='9' # 推测是数字
			dealf()
			if i==sz
				s*=safecol("$ch","number")
				return s
			end
			j=i+1
			if j!=sz && (co[j]=='x' || co[j]=='o') j+=1 end
			while j<=sz && ('0'<=co[j]<='9' || 'a'<=co[j]<='f' || co[j]=='_')
				j+=1
			end
			if j>sz
				s*=safecol(co[i:sz],"number")
				return s
			else
				s*=safecol(co[i:prevind(co,j)],"number")
				i=j
				pre=j
			end
		elseif emp2 && ch=='#'
			dealf()
			if i==sz
				s*=col("#","comment")
				return s
			elseif co[i+1]=='=' # 多行注释
				f=findnext("=#",co,i+2)
				if f===nothing
					s*=col(co[i:sz],"comment")
					return s
				else
					s*=col(co[i:f.stop],"comment")
					i=f.stop+1
					pre=i
				end
			else
				f=findnext('\n',co,i+1)
				if f===nothing
					s*=col(co[i:sz],"comment")
					return s
				else
					s*=col(co[i:prevind(co,f)],"comment";br=false)
					s*="<br />"
					i=f+1
				end
			end
			pre=i
		elseif !emp && last(stack)==0x0 && ch==')'
			s*=col(co[pre:i],"insert")
			i+=1
			pre=i
			pop!(stack)
		else
			i=nextind(co,i)
		end
	end

	catch er
		if isa(er,BoundsError)
			dealf(sz)
			return s
		else
			throw(er)
		end
	end
	dealf(sz)
	return s
end
