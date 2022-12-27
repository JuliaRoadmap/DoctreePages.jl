abstract type DoctreeBase end
mutable struct FileBase <: DoctreeBase
	is_outlined::Bool
	generated::Bool # for make_rec control
	parent::Int
	id::String # without suffix
	suffix::String
	name::String
	target::String
	data::String
end
fullname(tb::FileBase) = tb.suffix=="" ? tb.id : "$(tb.id).$(tb.suffix)"

mutable struct DirBase <: DoctreeBase
	is_outlined::Bool
	parent::Int
	id::String # without suffix
	name::String
	children # iterable, order: outlined (logical order), unoutlined (dictionary order)
	setting::Dict
end
id(tb::DoctreeBase) = tb.info.id
name(tb::DoctreeBase) = tb.info.name
isroot(tb::DoctreeBase) = tb.parent==0

abstract type AbstractDoctree end
mutable struct Doctree <: AbstractDoctree
	# root::Int
	current::Int
	data::Vector{DoctreeBase}
end
function Doctree(name)
	return Doctree(1, [DirBase(true, 0, "", name, nothing, Dict())])
end

self(tree::Doctree) = tree.data[tree.current]
backtoparent!(tree::Doctree) = tree.current = self(tree).parent
backtoroot!(tree::Doctree) = tree.current = 1
function findchild(tree::Doctree, from::Int, name::String)
	tb = tree.data[from]
	for ind in tb.children
		if tree.data[ind].name == name
			return ind
		end
	end
	return 0
end

#= Doctree model:
[1*]---------+-----+--------+
 |           |     |        |
 |           |     |        |
[2*]-----+  [3*]  [4*]--+  [5]
 |   |   |         |    |
 |   |   |         |    |
[6*][7*][8]      [10*] [11]
     |
	 |
	[9*]
=#

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
		if tree.data[ind]::FileBase
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
		if tree.data[ind]::FileBase
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
	if get(io, :compat, false)
		print(io, id(tree.data[1]))
		return
	end
	print(io, "Doctree at ")
	current = self(tree)
	if current.parent == 0
		println(io, "<ROOT>")
	else
		println(io, "Directory ", id(tree.data[current.parent]))
	end
	for i in current.children
		tb = tree.data[i]
		println(io, "| $(id(tb)) ($(name(tb)))")
	end
end

chapter_name(tree::AbstractDoctree) = name(self(tree))
function describe_page(tree::AbstractDoctree, title, pss)
	tb = self(tree)
	return isroot(tb) ? "$title - $(title(pss))" : "$(name(tb))/$title - $(title(pss))"
end
function navbartext_page(tree::AbstractDoctree, title)
	tb = self(tree)
	return isroot(tb) ? String(title) : name(tb)*" / "*title
end
