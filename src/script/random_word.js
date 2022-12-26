for(let tag of $(".random-word")){
	let id = tag.dataset["id"]
	fetch(`${tURL}/extra/data_random_word/${id}.json`)
	.then(response => {
		if (!response.ok)throw new Error("HTTP error " + response.status);
		return response.json()
	})
	.then(data => {
		let ind = Math.floor(Math.random()*data.length)
		let chosen = data[ind]
		let span = document.createElement("span")
		span.innerHTML = data[ind].text
		tag.appendChild(span)
		tag.appendChild(document.createElement("br"))
		delete chosen.text
		for(let k of Object.keys(chosen)){
			let name = k
			if(name=="tag" || name=="rate")continue
			if(__lang == "zh"){
				name = {
					original: "原文",
					source: "来源",
					license: "许可信息",
				}[k]
			}
			let box = document.createElement("button")
			box.innerText = name
			box.onclick = function(){
				box.innerHTML = `${name}: ${chosen[k]}`
				box.onclick = undefined
			}
			tag.appendChild(box)
		}
	})
}
