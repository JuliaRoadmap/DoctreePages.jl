for(let i of $(".checkis")){
	var chk=i.dataset["check"]
	if(localStorage.getItem(chk)=="true"){
		i.style.display="block"
	}
}
