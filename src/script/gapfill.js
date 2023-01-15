$(".submit-fill").click(function(ev){submit_fill(ev.currentTarget)})
$(".ans-fill").click(function(ev){
	let i=ev.currentTarget
	i.parentNode.children[1].value=i.dataset["ans"]
})
$(".instruction-fill").click(function(ev){
	let i=ev.currentTarget
	i.parentNode.children[1].value=i.dataset["con"]
})
