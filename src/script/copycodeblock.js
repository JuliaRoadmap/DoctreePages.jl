function copycodeblock(ev){
	let tar=ev.target
	let body=tar.parentNode.nextSibling
	let codes=body.querySelectorAll(".hljs-ln-code")
	let s=""
	for(let code of codes)s+=code.innerText+"\\n"
	navigator.clipboard.writeText(s).then(
		function(){
			tar.innerText="✔"
			setTimeout(function(){tar.innerText="📋"}, 2000)
		},
		function(){window.alert("failed")}
	)
}
