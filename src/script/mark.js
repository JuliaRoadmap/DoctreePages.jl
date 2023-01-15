let marked=JSON.parse(localStorage.getItem("marked"))
marked = marked==null ? (new Set()) : (new Set(marked))
for(let it of $(".content .li-dir,.li-file")){
	let span=document.createElement("span")
	span.click(function(ev){
		let tar = ev.currentTarget
		tar.classList.toggle("li-marked")
		let a = tar.nextSibling
		let link = a.href.substring(oril)
		let marked = new Set(JSON.parse(localStorage.getItem("marked")))
		if(marked.has(link)){
			marked.delete(link)
		}
		else{
			marked.add(link)
		}
		localStorage.setItem("marked", JSON.stringify([...marked]))
	})
	if(marked.has(it.firstElementChild.href.substring(oril)))span.className="li-marked"
	it.prepend(span)
}
