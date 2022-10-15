function highlight(::Val{Symbol("insert-fill")}, content::AbstractString, pss::PagesSetting)
	dict=TOML.parse(content)
	con=dict["content"]::String
	con=ify_md(con, pss)
	esc=escape_string(dict["ans"])
	usereg=haskey(dict, "ans_regex")
	reg=usereg ? dict["ans_regex"]::String : esc
	return string(
		"<div class='fill-area'><div>", con, "</div><input type='text' placeholder='ans'>",
		"<button class='submit-fill' data-ans='$reg' data-isreg='$usereg'>📤</button>",
		"<button class='ans-fill' data-ans='$esc'>🔑</button>",
		haskey(dict, "instruction") ? "<button class='instruction-fill' data-con='$(escape_string(dict["instruction"]))'>💡</button>" : "",
		"</div>"
	)
end
