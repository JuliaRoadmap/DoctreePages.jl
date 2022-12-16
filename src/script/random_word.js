for(let tag of $(".random-word")){
	let id = tag.dataset["id"]
	let data = fetch(`${tURL}/extra/data_random_word/${id}.json`).then(function(response){
		return response.json()
	})
	let ind = floor(Math.random()*data.length)
	let chosen = data[ind]
	if(chosen instanceof String)chosen = {text: chosen}
	let span = document.createElement("span")
	span.innerText = data[ind].text
	tag.appendChild(span)
	delete chosen.text
	for(let k of Object.keys(chosen)){
		tag.appendChild(document.createElement("br"))
		let box = document.createElement("div")
		box.className = "box-hide"
		box.innerHTML = `<button class='button-hide' onclick='unhide(event)'><span>${k}</span></button><div class='display-hide'>${chosen[k]}</div>`
		tag.appendChild(box)
	}
}
