let hljs=window.hljs
hljs.registerAliases("plain", {languageName: "plaintext"})
hljs.registerAliases("jl", {languageName: "julia"})
hljs.highlightAll()
for(let i of $("code.hljs")){
	hljs.lineNumbersBlock(i, {singleLine: true})
	let header=i.parentElement.parentElement.firstElementChild
	header.innerHTML=`<span class='codeblock-paste fa-solid fa-clipboard' onclick='copycodeblock(event)'></span>`
}
