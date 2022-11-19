$(".content .docs-heading-anchor-permalink").click(function(ev){
	let s=document.location.href
	let id=ev.target.parentNode.id
	navigator.clipboard.writeText(s+"#"+id).then(
		() => {}, () => window.alert("failed")
	)
})
