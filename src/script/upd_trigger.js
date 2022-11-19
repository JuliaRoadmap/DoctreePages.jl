function upd_trigger(key){
	let mode=localStorage.getItem(key)=="true" ? "block" : "none"
	for(let i of $(".checkis")){
		var chk=i.dataset["check"]
		if(chk==key){
			i.style.display=mode
		}
	}
}
