function buildmenu(){
	let lis=_buildmenu(menu, "docs/", 0)
	let dm=$(".docs-menu")[0]
	for(let li of lis){
		dm.appendChild(li)
	}
	let marked=JSON.parse(localStorage.getItem("marked"))
	marked = marked==null ? new Set() : new Set(marked)
	$(".docs-chevron").bind("click", function(ev){
		ev.currentTarget.parentElement.nextElementSibling.classList.toggle("collapsed")
	})
	let loc=document.location
	let active=undefined
	for(let a of $(".docs-menu a.tocitem")){
		let pathname=a.href.substring(oril)
		if(pathname==loc.pathname){
			active=a
		}
		if(marked.has(pathname)){
			a.parentNode.classList.add("li-marked")
		}
	}
	if(active!=undefined){
		activate_token(active)
		let sidebar=$(".docs-menu")[0]
		sidebar.scrollTop = active.offsetTop - sidebar.offsetTop - 15
	}
}
function _buildmenu(vec, path, level){
	let ans=[]
	let l=vec.length
	for(let i=1;i<l;i++){
		let e=vec[i]
		if(typeof e == "string"){
			let splitp=e.search('\\|')
			let a=document.createElement("a")
			a.className="tocitem"
			a.href=`${tURL}${path}${e.substring(0, splitp)}`
			a.innerText=e.substring(splitp+1)
			let li=document.createElement("li")
			li.appendChild(a)
			ans.push(li)
		}
		else{
			let splitp=e[0].search('\\|')
			let fullname=e[0].substring(0, splitp)
			let a=document.createElement("a")
			a.className="tocitem"
			a.href=`${tURL}${path}${fullname}`
			a.innerText=e[0].substring(splitp+1)
			let li=document.createElement("li")
			if(level==1){
				let iden=`menu-${path}${fullname}`
				let input=document.createElement("input")
				input.type="checkbox"
				input.className="collapse-toggle"
				input.id=iden
				li.appendChild(input)
				let label=document.createElement("label")
				label.className="tocitem"
				label.appendChild(a)
				label.for=iden
				let i=document.createElement("i")
				i.className="docs-chevron"
				label.appendChild(i)
				li.appendChild(label)
			}
			else li.appendChild(a)
			let clis=_buildmenu(e, `${path}${fullname}/`, level+1)
			let ul=document.createElement("ul")
			for(let cli of clis)ul.appendChild(cli)
			if(level==1)ul.className="collapsed"
			li.appendChild(ul)
			ans.push(li)
		}
	}
	return ans
}
