// 复制于 Documenter.jl(MIT) ，有删改

// 优先执行
var tURL=document.getElementById("tURL").content
var theme=localStorage.getItem("theme")
if(theme==undefined)theme="light"
else if(theme!="light"){
	document.getElementById("theme-href").href=tURL+"css/"+theme+".css"
}

requirejs.config({
	paths: {
		'headroom': 'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/headroom.min',
		'jqueryui': 'https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min',
		'jquery': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min',
		'headroom-jquery': 'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/jQuery.headroom.min',
		'katex': 'https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.11.1/katex.min',
	},
	shim: {
		"headroom-jquery": {
			"deps": [
				"jquery",
				"headroom"
			]
		},
	}
});
require(['jquery', 'headroom', 'headroom-jquery'], function ($, Headroom) {

	// Manages the top navigation bar (hides it when the user starts scrolling down on the
	// mobile).
	window.Headroom = Headroom; // work around buggy module loading?
	$(document).ready(function () {
		$('#documenter .docs-navbar').headroom({
			"tolerance": { "up": 10, "down": 10 },
		});
	})

})
require(['jquery'], function ($) {

	// Modal settings dialog
	$(document).ready(function () {
		var settings = $('#documenter-settings');
		$('#documenter-settings-button').click(function () {
			settings.toggleClass('is-active');
		});
		// Close the dialog if X is clicked
		$('#documenter-settings button.delete').click(function () {
			settings.removeClass('is-active');
		});
		// Close dialog if ESC is pressed
		$(document).keyup(function (e) {
			if (e.keyCode == 27) settings.removeClass('is-active');
		});
	});

})
require(['jquery'], function ($) {

	// Manages the showing and hiding of the sidebar.
	$(document).ready(function () {
		var sidebar = $("#documenter > .docs-sidebar");
		var sidebar_button = $("#documenter-sidebar-button")
		sidebar_button.click(function (ev) {
			ev.preventDefault();
			sidebar.toggleClass('visible');
			if (sidebar.hasClass('visible')) {
				// Makes sure that the current menu item is visible in the sidebar.
				$("#documenter .docs-menu a.is-active").focus();
			}
		});
		$("#documenter > .docs-main").bind('click', function (ev) {
			if ($(ev.target).is(sidebar_button)) {
				return;
			}
			if (sidebar.hasClass('visible')) {
				sidebar.removeClass('visible');
			}
		});
	})

	// Resizes the package name / sitename in the sidebar if it is too wide.
	// Inspired by: https://github.com/davatron5000/FitText.js
	$(document).ready(function () {
		e = $("#documenter .docs-autofit");
		function resize() {
			var L = parseInt(e.css('max-width'), 10);
			var L0 = e.width();
			if (L0 > L) {
				var h0 = parseInt(e.css('font-size'), 10);
				e.css('font-size', L * h0 / L0);
				// TODO: make sure it survives resizes?
			}
		}
		// call once and then register events
		resize();
		$(window).resize(resize);
		$(window).on('orientationchange', resize);
	});

	// Scroll the navigation bar to the currently selected menu item
	$(document).ready(function () {
		var sidebar = $("#documenter .docs-menu").get(0);
		var active = $("#documenter .docs-menu .is-active").get(0);
		if (typeof active !== 'undefined') {
			sidebar.scrollTop = active.offsetTop - sidebar.offsetTop - 15;
		}
	})
})
require(['jquery'],function($){
	var pi=$("#documenter-themepicker")
	pi.ready(function(){
		for(let tag of pi[0].children){
			if(tag.value==theme){
				tag.selected=true
				break
			}
		}
		pi.bind('change',function(){
			// 更改theme
			var theme=pi[0].value
			$("#theme-href")[0].href=tURL+"css/"+theme+".css"
			localStorage.setItem("theme",theme)
		})
	})
	$(".docs-menu").ready(function(){
		// 侧边栏
		const _menu=menu.replaceAll("$",tURL)
		$(".docs-menu")[0].innerHTML=_menu
	})
	
	$(".content").ready(function(){
		// 复制标题链接
		for(let i of $(".content .docs-heading-anchor-permalink")){
			i.onclick=function(){
				let s=document.location.href
				let id=i.parentNode.id
				navigator.clipboard.writeText(s+"#"+id).then(
					function(){},
					function(){window.alert("failed")
				})
			}
		}
		// 代码块
		for(let i of $(".content .language")){
			// 复制代码块数据
			let header=i.firstElementChild
			header.innerHTML=`<span class='codeblock-paste' onclick='copycodeblock(event)'>📋</span>`
			// 侧边栏编号
			let body=i.lastElementChild
			let num=body.firstElementChild
			let code=body.lastElementChild
			let text=code.innerText
			let l=1
			for(let j of text){
				if(j=='\n')l+=1
			}
			let numhtml=""
			for(let j=1; j<=l; j++){
				numhtml+=`${j}<br />`
			}
			num.innerHTML=numhtml
		}
	})
	$(document).ready(function(){
		// 检测L-L定位
		var loc=document.location.hash
		loc=loc.substring(1,loc.length)
		if(loc[0]=='L'){
			var split=loc.search('-')
			var from=Number(loc.substring(1,split))
			var to=Number(loc.substring(split+2,loc.length))
			for(var i=from;i<=to;i++){
				document.getElementById("line-"+i).style.backgroundColor="lightgreen"
			}
			document.getElementById("line-"+from).scrollIntoView()
		}
		// 检测条件激发
		for(let i of $(".checkis")){
			var chk=i.dataset["check"]
			if(localStorage.getItem(chk)=="true"){
				i.style.display="block"
			}
		}
		// 初始化填空题
		for(let i of $(".submit-fill")){
			i.onclick=function(){
				let input=i.parentNode.children[1]
				let isreg=i.dataset["isreg"]=="true"
				if(isreg){
					let reg=RegExp(i.dataset["ans"])
					i.style.backgroundColor= reg.exec(input.value)===null ? "#f05020" : "#80af00"
				}else{
					let str=i.dataset["ans"]
					i.style.backgroundColor= input.value==str ? "#f05020" : "#80af00"
				}
				setTimeout(function(){
					i.style.backgroundColor=null
				},2000)
			}
		}
		for(let i of $(".ans-fill")){
			i.onclick=function(){
				var input=i.parentNode.children[1]
				input.value=i.dataset["ans"]
			}
		}
		// buildmessage
		$(".modal-card-foot").innerText=buildmessage
	})
})
require(['jquery', 'katex'], function($, katex){
	$(document).ready(function(){
		for(let e of $(".math")){
			katex.render(e.innerText,e,{
				displayMode:false,
				throwOnError:false
			})
		}
		for(let e of $(".display-math")){
			katex.render(e.innerText,e,{
				displayMode:true,
				throwOnError:false
			})
		}
	})
})
function copycodeblock(ev){
	let tar=ev.target
	let body=tar.parentNode.nextSibling
	let code=body.lastElementChild
	let s=""
	for(let e of code.children){
		if(e.tagName=="BR")s+="\n"
		else s+=e.innerText
	}
	navigator.clipboard.writeText(s).then(
		function(){
			tar.innerText="✔"
			setTimeout(function(){
				tar.innerText="📋"
			},2000)
		},
		function(){window.alert("failed")}
	)
}
function upd_trigger(key){
	let mode=localStorage.getItem(key)=="true" ? "block" : "none"
	for(let i of $(".checkis")){
		var chk=i.dataset["check"]
		if(chk==key){
			i.style.display=mode
		}
	}
}
