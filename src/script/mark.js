let marked=JSON.parse(localStorage.getItem("marked"))
marked = marked==null ? (new Set()) : (new Set(marked))
for(let it of $(".li-dir,.li-file")){
	let span=document.createElement("span")
	span.onclick=function(){
		span.classList.toggle("li-marked")
		toggle_mark(it)
	}
	if(marked.has(it.firstElementChild.href.substring(oril)))span.className="li-marked"
	it.prepend(span)
}
