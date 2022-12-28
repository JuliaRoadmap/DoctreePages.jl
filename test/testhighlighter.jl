@testset "Highlighter" begin
	@test split_codeblocktitle("1 2 3") == ["1", "2", "3"]
	@test split_codeblocktitle("1 \"2 3\" 4 ") == ["1", "2 3", "4"]
end
