function toggle_mark(li){
	let link=li.lastElementChild.href.substring(oril)
	let marked=new Set(JSON.parse(localStorage.getItem("marked")))
	if(marked.has(link))marked.delete(link)
	else marked.add(link)
	localStorage.setItem("marked", JSON.stringify([...marked]))
}
