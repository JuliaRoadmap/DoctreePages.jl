struct ScriptBlock
	ready::String
	funcs::String
end
ScriptBlock(str::String)= ScriptBlock(str, "")

const headroom_block = ScriptBlock(
	"",
	"""
	require(['jquery', 'headroom', 'headroom-jquery'], function(\$, Headroom){
		window.Headroom = Headroom
		\$(document).ready(function(){
			\$("#documenter .docs-navbar").headroom({tolerance: {up: 10, down: 10 }})
		})
	})
	"""
)

const setting_block = ScriptBlock(
	"""
	let settings=\$("#documenter-settings");
	\$("#documenter-settings-button").click(() => settings.toggleClass("is-active"))
	\$("#documenter-settings button.delete").click(() => settings.removeClass("is-active"))
	\$(document).keyup((e) => {if(e.keyCode==27)settings.removeClass("is-active")})
	"""
)

const sidebar_block = ScriptBlock(
	"""
	var sidebar = \$("#documenter > .docs-sidebar")
	var sidebar_button = \$("#documenter-sidebar-button")
	sidebar_button.click(function(ev){
		ev.preventDefault()
		sidebar.toggleClass('visible')
		if(sidebar.hasClass('visible'))\$("#documenter .docs-menu a.is-active").focus()
	})
	\$("#documenter > .docs-main").bind('click', function(ev){
		if(\$(ev.target).is(sidebar_button))return
		if(sidebar.hasClass('visible'))sidebar.removeClass('visible')
	})
	let e=\$("#documenter .docs-autofit")
	function resize(){
		let L=parseInt(e.css('max-width'))
		let L0=e.width()
		if(L0>L){
			let h0=parseInt(e.css('font-size'))
			e.css('font-size', L*h0/L0)
		}
	}
	resize()
	\$(window).resize(resize)
	\$(window).on('orientationchange', resize)
	"""
)

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
		\$("#theme-href")[0].href=`\${tURL}\${tar_css}/\${theme}.css`
		localStorage.setItem("theme", theme)
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
	""",
	"""
	function copycodeblock(ev){
		let tar=ev.target
		let body=tar.parentNode.nextSibling
		let codes=body.querySelectorAll(".hljs-ln-code")
		let s=""
		for(let code of codes)s+=code.innerText+"\\n"
		navigator.clipboard.writeText(s).then(
			function(){
				tar.innerText="✔"
				setTimeout(function(){
					tar.innerText="📋"
				},2000)
			},
			function(){window.alert("failed")}
		)
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
				a.href=`\${tURL}\${path}\${tup[0]}\${filesuffix}`
				a.innerText=tup[1]
				let li=document.createElement("li")
				li.appendChild(a)
				ans.push(li)
			}
			else{
				let tup=spl(e[0])
				let a=document.createElement("a")
				a.className="tocitem"
				a.href=`\${tURL}\${path}\${tup[0]}/index\${filesuffix}`
				a.innerText=tup[1]
				let li=document.createElement("li")
				if(level==1){
					let iden=`menu-\${path}\${tup[0]}`
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
				let clis=_buildmenu(e, `\${path}\${tup[0]}/`, level+1)
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

const mark_block = ScriptBlock(
	"""
	let marked=JSON.parse(localStorage.getItem("marked"))
	marked = marked==null ? (new Set()) : (new Set(marked))
	for(let it of \$(".li-dir,.li-file")){
		let span=document.createElement("span")
		span.onclick=function(){
			span.classList.toggle("li-marked")
			toggle_mark(it)
		}
		if(marked.has(it.firstElementChild.href.substring(oril)))span.className="li-marked"
		it.prepend(span)
	}
	""",
	"""
	function toggle_mark(li){
		let link=li.lastElementChild.href.substring(oril)
		let marked=new Set(JSON.parse(localStorage.getItem("marked")))
		if(marked.has(link))marked.delete(link)
		else marked.add(link)
		localStorage.setItem("marked", JSON.stringify([...marked]))
	}
	"""
)

const locatelines_block = ScriptBlock(
	"""
	\$(".hljs-ln-numbers").ready(function(){
		let loc=document.location.hash
		loc=loc.substring(1, loc.length)
		if(loc[0]=='L'){
			let split=loc.search('-')
			let from=Number(loc.substring(1, split))
			let to=Number(loc.substring(split+2, loc.length))
			scroll_to_lines(from, to)
		}
	})
	""",
	"""
	function scroll_to_lines(from, to){
		let cb=\$("code.hljs")[0]
		let nums=cb.querySelectorAll(".hljs-ln-numbers")
		for(let i=from; i<=to; i++){
			nums[i-1].style.backgroundColor="lightgreen"
		}
		nums[from-1].scrollIntoView()
	}
	"""
)

const buildmessage_block = ScriptBlock(
	"\$('.modal-card-foot').innerText=buildmessage"
)

const katex_block = ScriptBlock(
	"",
	"""
	require(['jquery', 'katex'], function(\$, katex){
		\$(document).ready(function(){
			for(let e of \$(".math"))katex.render(e.innerText, e,
				{ displayMode:false, throwOnError:false }
			)
			for(let e of \$(".display-math"))katex.render(e.innerText, e,
				{ displayMode:true, throwOnError:false }
			)
		})
	})
	"""
)

const script_blocks = [
	headroom_block, setting_block, sidebar_block,
	themepick_block, copyheadinglink_block, hljs_block, docsmenu_block,
	statementtrigger_block, gapfill_block, mark_block, locatelines_block,
	buildmessage_block, katex_block
]
function makescript(io::IO)
	println(io, """
	var tURL=document.getElementById("tURL").content
	var theme=localStorage.getItem("theme")
	if(theme==undefined)theme="light"
	else if(theme!="light")document.getElementById("theme-href").href=`\${tURL}\${tar_css}/\${theme}.css`
	const oril=document.location.origin.length
	requirejs.config({ paths: configpaths, shim: configshim})
	require(main_requirement, function(\$){
		\$(document).ready(function(){
	""")
	for blk in script_blocks
		println(io, blk.ready)
	end
	println(io, """
		})
	})
	""")
	for blk in script_blocks
		println(io, blk.funcs)
	end
end
