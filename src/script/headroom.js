require(['jquery', 'headroom', 'headroom-jquery'], function($, Headroom){
	window.Headroom = Headroom
	$(document).ready(function(){
		$("#documenter .docs-navbar").headroom({tolerance:{up:10,down:10}})
		$("#rocket").headroom({tolerance:{down:10}})
	})
})
