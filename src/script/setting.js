let settings=document.createElement("div")
settings.className="modal"
settings.id="documenter-settings"
settings.innerHTML=`
<div class="modal-background"></div>
<div class="modal-card">
	<header class="modal-card-head"><p class="modal-card-title fas fa-cog"></p><button class="delete"></button></header>
	<section class="modal-card-body">
		<div class="select"><select id="documenter-themepicker">
			<option value="light">light</option>
			<option value="dark">dark</option>
		</select></div>
	</section>
	<footer class="modal-card-foot"></footer>
</div>`
document.body.append(settings)
$("#documenter-settings-button").click(() => settings.classList.toggle("is-active"))
$("#documenter-settings button.delete").click(() => settings.classList.remove("is-active"))
$(document).keyup((e) => {if(e.keyCode==27)settings.classList.remove("is-active")})
