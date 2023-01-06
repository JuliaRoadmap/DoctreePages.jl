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
@testset "Doctree" begin
	tree = Doctree(1, [
		DirBase(true, 0, "docs", "ROOT", 2:5, Dict()),
		DirBase(true, 1, "red", "红", 6:8, Dict()),
		DirBase(true, 1, "orange", "橙", 10:9, Dict()),
		DirBase(true, 1, "yellow", "黄", 10:11, Dict()),
		DirBase(false, 1, "green", "绿", 12:11, Dict()),
		FileBase(true, true, 2, "blood", "md", "血", "blood.html", "..."),
		DirBase(true, 2, "crimson", "深红", 9:9, Dict()),
		FileBase(false, true, 2, "FF0000", "txt", "红的 RGB", "FF0000.html", "..."),
		FileBase(true, true, 7, "sky", "png", "天空", "sky.png", "..."),
		FileBase(true, true, 4, "lemon", "md", "柠檬", "lemon.html", "..."),
		FileBase(false, true, 4, "wolley", "dm", "reversed", "wolley.lmth", "...")
	])
	@test findchild(tree, 1, "red") == 2
	@test findchild(tree, 1, "crimson") == 0
	@test findchild(tree, 3, "red") == 0
	@test previous_sibling(tree, 3, 1) == 2
	@test previous_sibling(tree, 2, 1) == 0
	@test previous_sibling(tree, 10, 4) == 0
	@test_throws ErrorException previous_sibling(tree, 10, 3)
	@test_throws ErrorException previous_sibling(tree, 10, 2)
	@test next_outlined_sibling(tree, 6, 2) == 7
	@test next_outlined_sibling(tree, 7, 2) == 0
	@test next_outlined_sibling(tree, 9, 7) == 0
	@test_throws ErrorException next_outlined_sibling(tree, 6, 3)
	@test_throws ErrorException next_outlined_sibling(tree, 9, 2)
	@test last_outlined_child(tree, 1) == 4
	@test last_outlined_child(tree, 2) == 7
	@test last_outlined_child(tree, 3) == 0
	@test first_outlined_child(tree, 7) == 9
	@test first_outlined_child(tree, 3) == 0
	@test prev_outlined(tree, 6) == 0
	@test prev_outlined(tree, 9) == 6
	@test prev_outlined(tree, 3) == 9
	@test prev_outlined(tree, 10) == 3
	@test next_outlined(tree, 9) == 3
	@test get_href(tree, 10, 11; simple = true) == "lemon.html"
	@test get_href(tree, 11, 10; simple = true) == "wolley.lmth"
	@test get_href(tree, 7, 8; simple = true) == "crimson/index.html"
	@test get_href(tree, 9, 8; simple = false) == "../crimson/sky.png"
	@test get_href(tree, 5, 8; simple = false) == "../../green/index.html"
	@test get_href(tree, 2, 11; simple = false) == "../../red/index.html"
end
