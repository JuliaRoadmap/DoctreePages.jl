function purecopycodeblock(ev){
	let tar = ev.target
	let body = tar.parentNode.nextSibling
	let codes = body.querySelectorAll(".hljs-ln-code")
	let s = ""
	for(let code of codes){
		let txt = code.innerText
		let start = txt.substring(0, 7)
		if(start=="julia> " || start=="help?> " || start=="shell> " || start=="       ")s+=txt.substring(7)+"\\n"
	}
	navigator.clipboard.writeText(s).then(
		function(){
			tar.classList.replace("fa-clipboard", "fa-clipboard-check")
			setTimeout(function(){tar.classList.replace("fa-clipboard-check", "fa-clipboard")}, 2000)
		},
		function(){window.alert("failed")}
	)
}
