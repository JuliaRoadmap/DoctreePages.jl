let pi=$("#documenter-themepicker")
for(let tag of pi[0].children){
	if(tag.value==theme){
		tag.selected=true
		break
	}
}
pi.change(function(){
	theme=pi[0].value
	$("#theme-href")[0].href=`${tURL}${tar_css}/${theme}.css`
	localStorage.setItem("theme", theme)
})
