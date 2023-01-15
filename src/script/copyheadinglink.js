$(".content .docs-heading-anchor-permalink").click(function(ev){
	let s=document.location.href
	let id=ev.currentTarget.parentNode.id
	navigator.clipboard.writeText(s+"#"+id).then(
		() => {}, () => window.alert("failed to copy to clipboard")
	)
})
