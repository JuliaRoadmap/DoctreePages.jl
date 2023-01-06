module DoctreePagesTest
import DoctreePages: Doctree, DirBase, FileBase, findchild, previous_sibling, next_outlined_sibling, last_outlined_child, first_outlined_child, prev_outlined, next_outlined, get_href
import DoctreePages: split_codeblocktitle
using Test
include("testdoctree.jl")
include("testhighlighter.jl")

end
