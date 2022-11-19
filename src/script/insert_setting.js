for(let i of $(".select-is")){
	let choices=dictparse(i.dataset["chs"])
	let store=dictparse(i.dataset["st"])
	let select=document.createElement("select")
	let defval=i.dataset["de"]
	for(let k in choices){
		let option=document.createElement("option")
		option.value=k
		option.innerText=choices[k]
		select.append(option)
	}
	select.value=null
	let defkey=store[defval]
	if(defkey!=undefined){
		if(defkey[0]=="!"){
			defkey=defkey.substring(1)
			if(localStorage.getItem(defkey)==null)localStorage.setItem(defkey, "false")
		}
		else if(localStorage.getItem(defkey)==null){
			localStorage.setItem(defkey, "true")
			select.value=defval
		}
	}
	select.onchange=function(){
		let v=select.value
		let stk=store[v]
		if(stk!=undefined){
			if(stk[0]=="!"){
				stk=stk.substring(1)
				localStorage.setItem(stk, "false")
			}
			else localStorage.setItem(stk, "true")
			if(stk.startsWith("is-")){
				upd_trigger(stk)
			}
		}
	}
	i.append(select)
}
