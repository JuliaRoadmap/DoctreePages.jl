$(".submit-fill").click(function(ev){submit_fill(ev.target)})
$(".ans-fill").click(function(ev){
	let i=ev.target
	i.parentNode.children[1].value=i.dataset["ans"]
})
$(".instruction-fill").click(function(ev){
	let i=ev.target
	i.parentNode.children[1].value=i.dataset["con"]
})
