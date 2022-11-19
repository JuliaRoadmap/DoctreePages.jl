function scroll_to_lines(from, to){
	let cb=$("code.hljs")[0]
	let nums=cb.querySelectorAll(".hljs-ln-numbers")
	for(let i=from; i<=to; i++){
		nums[i-1].style.backgroundColor="lightgreen"
	}
	nums[from-1].scrollIntoView()
}
