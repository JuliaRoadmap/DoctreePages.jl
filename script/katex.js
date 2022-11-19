require(['jquery', 'katex'], function($, katex){
	$(document).ready(function(){
		for(let e of $(".math"))katex.render(e.innerText, e,
			{ displayMode:false, throwOnError:false }
		)
		for(let e of $(".display-math"))katex.render(e.innerText, e,
			{ displayMode:true, throwOnError:false }
		)
	})
})
