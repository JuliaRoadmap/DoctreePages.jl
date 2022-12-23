function highlight(::Val{:insert_fill}, content::AbstractString, pss::PagesSetting, args)
	dict=TOML.parse(content)
	con=dict["content"]::String
	con=ify_md(con, pss)
	esc=escape_string(dict["ans"])
	usereg=haskey(dict, "ans_regex")
	reg=usereg ? dict["ans_regex"]::String : esc
	return string(
		"<div class='fill-area'><div>", con, "</div><input type='text' placeholder='ans'>",
		"<button class='submit-fill fa-solid fa-upload' data-ans='$reg' data-isreg='$usereg'></button>",
		"<button class='ans-fill fa-solid fa-key' data-ans='$esc'></button>",
		haskey(dict, "instruction") ? "<button class='instruction-fill fa-solid fa-lightbulb' data-con='$(escape_string(dict["instruction"]))'></button>" : "",
		"</div>"
	)
end
