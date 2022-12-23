const clockemojis="🕛🕐🕑🕒🕓🕔🕕🕖🕗🕘🕙🕚⌛ "
for(let i of $(".test-area")){
	let header=document.createElement("div")
	header.className="test-header"
	let name=document.createElement("code")
	name.innerText=i.dataset["name"]
	let fullscore=document.createElement("span")
	fullscore.className="tag"
	fullscore.innerText=" ?/"+i.dataset["fs"]+" "
	let timer=document.createElement("span")
	timer.className="tag"
	let tl=i.dataset["tl"]
	timer.dataset["tl"]=tl
	let button=document.createElement("button")
	button.className = "fa-solid fa-upload submit-testfill"
	let lock=document.createElement("button")
	let locked=false
	lock.classList="fa-solid fa-lock-open lock-testfill"
	header.append(name)
	header.append(fullscore)
	header.append(timer)
	header.append(button)
	header.append(lock)
	i.prepend(header)
	let n=0
	let hour=tl/12
	let timeron = () => {
		let interval=setInterval(function(){
			if(n>tl){
				clearInterval(interval)
				try_notify("🔔 Time Limit Exceeded")
				calc_test(i)
				return
			}
			let part=Math.floor(n/hour+0.5)
			timer.innerText=clockemojis[part<<1]+clockemojis[part<<1|1]+" "+n+"/"+tl
			n+=1
		}, 1000)
		return interval
	}
	for(ch of i.querySelectorAll(".choose-area span")){
		let cb=document.createElement("input")
		cb.type="checkbox"
		ch.prepend(cb)
	}
	let inter=timeron()
	button.onclick=function(){
		clearInterval(inter)
		calc_test(i)
		button.classList.replace("fa-upload", "fa-magnifying-glass")
		button.onclick=undefined
	}
	lock.onclick=function(){
		if(locked){
			lock.classList.replace("fa-lock", "fa-lock-open")
			inter=timeron()
		}
		else{
			lock.classList.replace("fa-lock-open", "fa-lock")
			clearInterval(inter)
		}
		locked=!locked
	}
}
