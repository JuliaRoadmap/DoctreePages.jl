for(let i of $(".checkis")){
	let chk=i.dataset["check"]
	if(localStorage.getItem(chk)=="true"){
		i.style.display="block"
	}
}
