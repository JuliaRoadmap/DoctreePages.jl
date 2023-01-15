function buildmenu(){
	let lis=_buildmenu(menu, "docs/", 0)
	let dm=$(".docs-menu")[0]
	for(let li of lis){
		dm.appendChild(li)
	}
	let marked=JSON.parse(localStorage.getItem("marked"))
	if(marked==null)marked=[]
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
		if(marked.includes(pathname)){
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
	let spl = (str) => {
		let pl=str.search('/')
		return [str.substring(0, pl), str.substring(pl+1)]
	}
	for(let i=1;i<l;i++){
		let e=vec[i]
		if(typeof e == "string"){
			let tup=spl(e)
			let a=document.createElement("a")
			a.className="tocitem"
			a.href=`${tURL}${path}${tup[0]}${filesuffix}`
			a.innerText=tup[1]
			let li=document.createElement("li")
			li.appendChild(a)
			ans.push(li)
		}
		else{
			let tup=spl(e[0])
			let a=document.createElement("a")
			a.className="tocitem"
			a.href=`${tURL}${path}${tup[0]}/index${filesuffix}`
			a.innerText=tup[1]
			let li=document.createElement("li")
			if(level==1){
				let iden=`menu-${path}${tup[0]}`
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
			let clis=_buildmenu(e, `${path}${tup[0]}/`, level+1)
			let ul=document.createElement("ul")
			for(let cli of clis)ul.appendChild(cli)
			if(level==1)ul.className="collapsed"
			li.appendChild(ul)
			ans.push(li)
		}
	}
	return ans
}
