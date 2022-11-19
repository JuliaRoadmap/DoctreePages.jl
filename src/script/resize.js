function resize(){
	let L=parseInt(e.css('max-width'))
	let L0=e.width()
	if(L0>L){
		let h0=parseInt(e.css('font-size'))
		e.css('font-size', L*h0/L0)
	}
}
