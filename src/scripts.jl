struct ScriptBlock
	ready::String
	funcs::String
end
ScriptBlock(str::String)= ScriptBlock(str, "")

const themepick_block = ScriptBlock(
	"""
	let pi=\$("#documenter-themepicker")
	for(let tag of pi[0].children){
		if(tag.value==theme){
			tag.selected=true; break
		}
	}
	pi.change(function(){
		var theme=pi[0].value
		\$("#theme-href")[0].href=`${tURL}${tar_css}/${theme}.css`
		localStorage.setItem("theme",theme)
	})
	"""
)

const copyheadinglink_block = ScriptBlock(
	"""
	\$(".content .docs-heading-anchor-permalink").click(function(ev){
		let s=document.location.href
		let id=ev.target.parentNode.id
		navigator.clipboard.writeText(s+"#"+id).then(
			() => {}, () => window.alert("failed")
		)
	})
	"""
)

const hljs_block = ScriptBlock(
	"""
	let hljs=window.hljs
	hljs.registerAliases("plain", {languageName: "plaintext"})
	hljs.registerAliases("jl", {languageName: "julia"})
	hljs.highlightAll()
	for(let i of \$("code.hljs")){
		hljs.lineNumbersBlock(i, {singleLine: true})
		let header=i.parentElement.parentElement.firstElementChild
		header.innerHTML=`<span class='codeblock-paste' onclick='copycodeblock(event)'>📋</span>`
	}
	"""
)

const docsmenu_block = ScriptBlock(
	"buildmenu()", """
	function buildmenu(){
		let lis=_buildmenu(menu, "docs/", 0)
		let dm=\$(".docs-menu")[0]
		for(let li of lis){
			dm.appendChild(li)
		}
		let marked=JSON.parse(localStorage.getItem("marked"))
		if(marked==null)marked=[]
		\$(".docs-chevron").bind("click", function(ev){
			ev.target.parentElement.nextElementSibling.classList.toggle("collapsed")
		})
		let loc=document.location
		let flag=false
		let active=undefined
		for(let a of \$(".docs-menu a.tocitem")){
			let pathname=a.href.substring(oril)
			if(pathname==loc.pathname){
				active=a
			}
			if(marked.includes(pathname)){
				a.parentNode.classList.add("li-marked")
			}
		}
		if(active!=undefined){
			if(activate_token(active)){
				let sidebar=\$(".docs-menu")[0]
				sidebar.scrollTop = active.offsetTop - sidebar.offsetTop - 15;
			}
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
				else{
					li.appendChild(a)
				}
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
	function activate_token(node){
		let par=node.parentNode
		par.classList.add("is-active")
		let ul=document.createElement("ul")
		let flag=false
		for(let e of \$(".content > h2")){
			let text=e.innerText
			let li=document.createElement("li")
			let a=document.createElement("a")
			a.className="tocitem"
			a.href=`#header-${text}`
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
	"""
)

const statementtrigger_block = ScriptBlock(
	"""
	for(let i of \$(".checkis")){
		var chk=i.dataset["check"]
		if(localStorage.getItem(chk)=="true"){
			i.style.display="block"
		}
	}
	""",
	"""
	function upd_trigger(key){
		let mode=localStorage.getItem(key)=="true" ? "block" : "none"
		for(let i of \$(".checkis")){
			var chk=i.dataset["check"]
			if(chk==key){
				i.style.display=mode
			}
		}
	}
	"""
)

const gapfill_block = ScriptBlock(
	"""
	\$(".submit-fill").click(function(ev){
		submit_fill(ev.target)
	})
	\$(".ans-fill").click(function(ev){
		let i=ev.target
		i.parentNode.children[1].value=i.dataset["ans"]
	})
	\$(".instruction-fill").click(function(ev){
		let i=ev.target
		i.parentNode.children[1].value=i.dataset["con"]
	})
	""",
	"""
	function submit_fill(){
		let input=i.parentNode.children[1]
		let isreg=i.dataset["isreg"]=="true"
		if(isreg){
			let reg=RegExp(i.dataset["ans"])
			i.style.backgroundColor= reg.exec(input.value)===null ? "#f05020" : "#80af00"
		}else{
			let str=i.dataset["ans"]
			i.style.backgroundColor= input.value==str ? "#f05020" : "#80af00"
		}
		setTimeout(function(){ i.style.backgroundColor=null }, 2000)
	}
	"""
)
