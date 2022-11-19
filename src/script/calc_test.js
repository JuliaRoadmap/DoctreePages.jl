function calc_test(node){
	let sum=0
	for(let ch of node.querySelectorAll(".choose-area")){
		let ans=ch.dataset["an"]
		let input=getchooseinput(ch)
		let tag=document.createElement("span")
		tag.className="tag"
		if(ans==undefined){
			let dict=dictparse(ch.dataset["dict"])
			let score=dict[input]
			let maxscore=Math.max(...Object.values(dict))
			if(score==undefined){
				tag.style.backgroundColor="red"
				tag.innerText="0/"+maxscore
			}
			else if(score!=maxscore){
				sum+=score
				tag.style.backgroundColor="yellow"
				tag.innerText=score+"/"+maxscore
			}
			else{
				sum+=score
				tag.style.backgroundColor="green"
				tag.innerText=score+"/"+score
			}
		}
		else{
			let score=Number(ch.dataset["sc"])
			if(input==ans){
				sum+=score
				tag.style.backgroundColor="green"
				tag.innerText=score+"/"+score
			}
			else{
				tag.style.backgroundColor="red"
				tag.innerText="0/"+score
			}
		}
		ch.firstElementChild.prepend(tag)
	}
	for(let fi of node.querySelectorAll(".fill-area")){
		let ans=fi.dataset["an"]
		let flag=false
		let score=Number(fi.dataset["sc"])
		let input=fi.lastElementChild.value
		if(ans==undefined){
			let reg=RegExp(fi.dataset["re"])
			if(reg.exec(input)!=null)flag=true
		}
		else if(ans==input)flag=true
		let first=fi.firstElementChild
		let tag=document.createElement("span")
		tag.className="tag"
		if(flag){
			sum+=score
			tag.style.backgroundColor="green"
			tag.innerText=score+"/"+score
		}
		else{
			tag.style.backgroundColor="red"
			tag.innerText="0/"+score
		}
		first.prepend(tag)
	}
	node.firstElementChild.children[1].innerText=" "+sum+"/"+node.dataset["fs"]
}
