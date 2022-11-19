let sidebar = $("#documenter > .docs-sidebar")
let sidebar_button = $("#documenter-sidebar-button")
sidebar_button.click(function(ev){
	ev.preventDefault()
	sidebar.toggleClass('visible')
	if(sidebar.hasClass('visible'))$("#documenter .docs-menu a.is-active").focus()
})
$("#documenter > .docs-main").bind('click', function(ev){
	if($(ev.target).is(sidebar_button))return
	if(sidebar.hasClass('visible'))sidebar.removeClass('visible')
})
resize()
$(window).resize(resize)
$(window).on('orientationchange', resize)
