mutable struct Node
	par::Union{Node, Nothing}
	name::String
	toml::Dict
	dirs::Dict{String, Tuple{Node, String}} # data name
	files::Dict{String, Tuple{String, String, String}} # data name suffix
end
Node(par::Union{Node,Nothing}, name::String, toml::Dict=Dict{String, Any}())=Node(par, name, toml, Dict{String, Pair{Node, String}}(), Dict{String, Pair{String, String}}())
function Base.show(io::IO, node::Node)
	if get(io, :compat, false)
		println(io, node.name)
		return
	end
	if node.par === nothing
		println(io, "Root Node")
	else
		println(io, "Directory ", node.name)
		par=node.par
		println(io, "parent: ", par.par===nothing ? "< root >" : par.name)
	end
	if !isempty(node.dirs)
		println(io, "sub directories:")
		for it in node.dirs
			println(io, "| ", it.first, " ($(it.second[2]))")
		end
	end
	if !isempty(node.files)
		println(io, "files:")
		for it in node.files
			println(io, "| ", it.first, " ($(it.second[2]))")
		end
	end
end
chapter_name(node::Node) = node.par.dirs[node.name][2]
function describe_page(node::Node, title, pss)
	if node.par !== nothing
		return chapter_name(node)*"/$title - $(pss.title)"
	end
	return "$title - $(pss.title)"
end
function navbartext_page(node::Node, title)
	if node.par !== nothing
		return chapter_name(node)*" / "*title
	end
	return String(title)
end
