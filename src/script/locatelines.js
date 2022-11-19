$(".hljs-ln-numbers").ready(function(){
	let loc=document.location.hash
	loc=loc.substring(1, loc.length)
	if(loc[0]=='L'){
		let split=loc.search('-')
		let from=Number(loc.substring(1, split))
		let to=Number(loc.substring(split+2, loc.length))
		scroll_to_lines(from, to)
	}
})
