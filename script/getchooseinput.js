function getchooseinput(node){
	let ins=node.querySelectorAll("input")
	let str=""
	for(let i=0;i<ins.length;i++){
		let input=ins[i]
		if(input.checked)str+=String.fromCharCode(65+i)
	}
	return str
}
