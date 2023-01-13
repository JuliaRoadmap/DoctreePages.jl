abstract type DoctreeBase end
mutable struct FileBase <: DoctreeBase
	is_outlined::Bool
	generated::Bool # for make_rec control
	parent::Int
	name::String # without suffix
	suffix::String
	title::String
	target::String
	data::String
end
fullname(tb::FileBase) = tb.suffix=="" ? tb.name : "$(tb.name).$(tb.suffix)"

mutable struct DirBase <: DoctreeBase
	is_outlined::Bool
	parent::Int
	name::String
	title::String
	children # iterable, order: outlined (logical order), unoutlined (dictionary order)
	setting::Dict
end
isroot(tb::DoctreeBase) = tb.parent==0

abstract type AbstractDoctree end
mutable struct Doctree <: AbstractDoctree
	# root::Int
	current::Int
	data::Vector{DoctreeBase}
end
function Doctree(name)
	return Doctree(1, [DirBase(true, 0, "docs", name, nothing, Dict())])
end

self(tree::Doctree) = tree.data[tree.current]
backtoparent!(tree::Doctree) = tree.current = self(tree).parent
backtoroot!(tree::Doctree) = tree.current = 1
function parent_queue(tree::Doctree, me::Int = tree.current)
	v = Int[]
	while true
		me = tree.data[me].parent
		if me == 0
			break
		end
		push!(v, me)
	end
	return v
end
function findchild(tree::Doctree, from::Int, name::String)
	tb = tree.data[from]
	for ind in tb.children
		if tree.data[ind].name == name
			return ind
		end
	end
	return 0
end
function previous_sibling(tree::Doctree, me::Int, par::Int)
	children = tree.data[par].children
	prev = 0
	for i in children
		if i==me
			return prev
		end
		prev = i
	end
	error("tree: $me itself is not a child of $par")
end
function next_outlined_sibling(tree::Doctree, me::Int, par::Int)
	children = tree.data[par].children
	next = iterate(children)
	while next !== nothing
    	(item, state) = next
		next = iterate(children, state)
    	if item==me
			if next === nothing
				return 0
			end
			x = next[1]
			return tree.data[x].is_outlined ? x : 0
		end
	end
	error("tree: $me itself is not a child of $par")
end
function last_outlined_child(tree::Doctree, ind::Int)
	children = tree.data[ind].children
	if isempty(children)
		return 0
	end
	prev = 0
	for i in children
		if !tree.data[i].is_outlined
			return prev
		end
		prev = i
	end
	return prev
end
function first_outlined_child(tree::Doctree, ind::Int)
	children = tree.data[ind].children
	if isempty(children)
		return 0
	end
	x = first(children)
	return tree.data[x].is_outlined ? x : 0
end
# assume that the target is the first of the chapter
function prev_outlined(tree::Doctree, ind::Int)
	while true
		if ind==1
			return 0
		end
		par = tree.data[ind].parent
		x = previous_sibling(tree, ind, par)
		if x!=0
			ind = x
			break
		end
		ind = par
	end
	while true
		tb = tree.data[ind]
		if isa(tb, FileBase) || isempty(tb.children)
			return ind
		end
		x = last_outlined_child(tree, ind)
		if x==0
			return ind
		end
		ind = x
	end
end
# assume that the target is the last of the chapter
function next_outlined(tree::Doctree, ind::Int)
	while true
		if ind==1
			return 0
		end
		par = tree.data[ind].parent
		x = next_outlined_sibling(tree, ind, par)
		if x!=0
			ind = x
			break
		end
		ind = par
	end
	while true
		tb = tree.data[ind]
		if isa(tb, FileBase) || isempty(tb.children)
			return ind
		end
		x = first_outlined_child(tree, ind)
		if x==0
			return ind
		end
		ind = x
	end
end

#= mutable struct SubDoctree <: AbstractDoctree
	point::Int
	reference::Doctree
end =#

function Base.show(io::IO, tree::Doctree)
	current = self(tree)
	if get(io, :compat, false)
		print(io, current.name)
		return
	end
	print(io, "Doctree at ")
	if current.parent == 0
		println(io, "<ROOT>")
	else
		println(io, "Directory ", tree.data[current.parent].name)
	end
	for i in current.children
		tb = tree.data[i]
		println(io, "| $(tb.name) ($(tb.title))")
	end
end
function debug(io::IO, tree::Doctree)
	println(io, "current = ", tree.current)
	for nid in eachindex(tree.data)
		@inbounds tb = tree.data[nid]
		print(io, "[$(nid)$(tb.is_outlined ? "*" : "")] ")
		if isa(tb, FileBase)
			println(io, "<$(tb.name).$(tb.suffix) | $(tb.title)>")
		else
			println(io, "<$(tb.name) | $(tb.title)> $(tb.parent){$(tb.children)}")
		end
	end
end

# assume that src is a file
function get_href(tree::Doctree, tar::Int, src::Int = tree.current; simple::Bool, filesuffix = ".html")
	tb = tree.data[tar]
	isfile = isa(tb, FileBase)
	href = isfile ? tb.target : "$(tb.name)/index$(filesuffix)"
	if !simple
		queue = parent_queue(tree, src)
		while true
			tar = tb.parent
			x = first_invec(tar, queue)
			if x == 0
				tb = tree.data[tar]
				href = "$(tb.name)/$(href)"
			else
				href = ("../"^x)*href
				break
			end
		end
	end
	return href
end
