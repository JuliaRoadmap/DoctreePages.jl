function activate_token(node){
	let par=node.parentNode
	par.classList.add("is-active")
	let ul=document.createElement("ul")
	let flag=false
	for(let e of $(".content > h2")){
		let text=e.innerText
		let li=document.createElement("li")
		let a=document.createElement("a")
		a.className="tocitem"
		a.href=`#header-\${text}`
		a.innerText=text
		li.appendChild(a)
		ul.appendChild(li)
		flag=true
	}
	if(flag){
		ul.className="internal"
		par.appendChild(ul)
	}
	return flag
}
