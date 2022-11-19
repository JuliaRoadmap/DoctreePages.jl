function submit_fill(i){
	let inv=i.parentNode.children[1].value
	let isreg=i.dataset["isreg"]=="true"
	if(isreg){
		let reg=RegExp(i.dataset["ans"])
		i.style.backgroundColor= reg.exec(inv)===null ? "#f05020" : "#80af00"
	}
	else{
		let str=i.dataset["ans"]
		i.style.backgroundColor= inv==str ? "#80af00" : "#f05020"
	}
	setTimeout(function(){i.style.backgroundColor=null}, 2000)
}
