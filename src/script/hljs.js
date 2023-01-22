let hljs=window.hljs
hljs.registerAliases("plain", {languageName: "plaintext"})
hljs.registerAliases("jl", {languageName: "julia"})
hljs.highlightAll()
for(let i of $("code.hljs")){
	hljs.lineNumbersBlock(i, {singleLine: true})
	let header=i.parentElement.parentElement.firstElementChild
	let copybut = document.createElement("span")
	copybut.className = "codeblock-paste fa-solid fa-clipboard"
	$(copybut).click(function(ev){
		copycodeblock(ev)
	})
	header.append(copybut)
	if(i.classList.contains("language-julia-repl")){
		let purebut = document.createElement("span")
		purebut.className = "codeblock-purepaste fa-solid fa-clipboard"
		$(purebut).click(function(ev){
			purecopycodeblock(ev)
		})
		header.append(purebut)
	}
}
