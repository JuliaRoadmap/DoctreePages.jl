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
mutable struct DirBase <: DoctreeBase
	is_outlined::Bool
	parent::Int
	id::String # without suffix
	name::String
	children
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
	return isroot(tb) ? "$title - $(title(pss))" : name(tb)*"/$title - $(title(pss))"
end
function navbartext_page(tree::AbstractDoctree, title)
	tb = self(tree)
	return isroot(tb) ? String(title) : name(tb)*" / "*title
end
