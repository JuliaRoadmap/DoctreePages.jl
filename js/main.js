// 复制于 Documenter.jl(MIT) ，有删改
requirejs.config({
	paths: {
		'headroom': 'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/headroom.min',
		'jqueryui': 'https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min',
		'jquery': 'https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min',
		'headroom-jquery': 'https://cdnjs.cloudflare.com/ajax/libs/headroom/0.10.3/jQuery.headroom.min',
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
	var tURL=$("#tURL")[0].content
	var pi=$("#documenter-themepicker")
	var theme=localStorage.getItem("theme")
	if(theme==undefined)theme="light"
	// 初始化theme
	$("#theme-href").ready(function(){
		if(theme!="light"){
			$("#theme-href")[0].href=tURL+"css/"+theme+".css"
		}
	})
	pi.ready(function(){
		for(tag of pi[0]){
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
	// 复制标题链接
	$(".content").ready(function(){
		pasteh=function(id){
			var s=document.location.href
			navigator.clipboard.writeText(s+"#"+id).then(function(){},function(){window.alert("复制失败")})
		}
		bindh=function(s){
			for(var i of $(".content "+s)){
				i.ondblclick=function(){pasteh(i.id)}
			}
		}
		bindh("h1");bindh("h2");bindh("h3")
		bindh("h4");bindh("h5");bindh("h6")
		// 复制代码块数据
		for(var i of $(".content pre")){
			i.ondblclick=function(){
				var s=""
				for(e of i.children){
					if(e.tagName=="BR")s+="\n"
					else s+=e.innerText
				}
				navigator.clipboard.writeText(s).then(function(){},function(){
					window.alert("复制失败")
				})
			}
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
				var input=i.parentNode.children[2]
				var reg=RegExp(i.dataset["ans"])
				if(reg.exec(input.value)===null){
					i.style.backgroundColor="#f05020"
				}else{
					i.style.backgroundColor="#80af00"
				}
				setTimeout(function(){
					i.style.backgroundColor=null
				},2000)
			}
		}
		for(let i of $(".ans-fill")){
			i.onclick=function(){
				var input=i.parentNode.children[2]
				input.value=i.dataset["ans"]
			}
		}
	})
})
