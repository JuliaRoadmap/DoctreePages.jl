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
		span.innerText = data[ind].text
		tag.appendChild(span)
		tag.appendChild(document.createElement("br"))
		delete chosen.text
		for(let k of Object.keys(chosen)){
			let box = document.createElement("div")
			box.className = "box-hide"
			box.innerHTML = `<button class='button-hide' onclick='unhide(event)'><span>${k}</span></button><div class='display-hide'>${chosen[k]}</div>`
			tag.appendChild(box)
		}
	})
}
