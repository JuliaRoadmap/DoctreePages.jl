function makehtml(pss::PagesSetting, ps::PageSetting)
	gis=pss.giscus
	return """
	<!DOCTYPE html>
	<html lang="$(pss.lang)">
	<head>
		<meta charset="$(pss.charset)"/>
		<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
		<title>$(ps.description)</title>$(pss.favicon_path=="" ? "" : "<link rel='icon' type='image/x-icon' href='$(pss.favicon_path)'>")
		<meta name="tURL" id="tURL" content="$(ps.tURL)"/>
		<meta name="description" content="$(ps.description)">
		<script src="$(ps.tURL)$(pss.tar_extra)/info.js"></script>$(
			gis===nothing ? "" :
			"<script src='https://giscus.app/client.js' data-repo='$(gis.repo)' data-repo-id='$(gis.repo_id)' data-category='$(gis.category)' data-category-id='$(gis.category_id)' data-mapping='$(gis.mapping)' data-reactions-enabled='$(gis.reactions_enabled)' data-emit-metadata='$(gis.emit_metadata)' data-input-position='$(gis.input_position)' data-theme='$(gis.theme)' data-lang='$(gis.lang)' crossorigin='$(gis.crossorigin)' async></script>"
		)
		<script src="$(pss.main_script.requirejs.url)" data-main="$(ps.tURL)$(pss.tar_extra)/main.js"></script>
		<link id="theme-href" rel="stylesheet" type="text/css" href=\"$(ps.tURL)css/light.css\">
		<link rel="stylesheet" type="text/css" href="$(ps.tURL)css/general.css">
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.0/css/fontawesome.min.css"/>
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.0/css/solid.min.css"/>
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.0/css/brands.min.css"/>
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.11.1/katex.min.css">
	</head>
	<body>
		<div id="documenter">
			<nav class="docs-sidebar">$(pss.logo_path=="" ? "" : "<a class='docs-logo'><img src='$(ps.tURL)$(pss.logo_path)' alt='logo' height='96' width='144'></a>")
				<div class="docs-package-name">
				<span class="docs-autofit">$(pss.title)</span>
				</div>
				<ul class="docs-menu"></ul>
			</nav>
			<div class="docs-main">
				<header class="docs-navbar">
					<nav class="breadcrumb">
						<ul class="is-hidden-mobile"><li class="is-active">$(ps.navbar_title)</li></ul>
						<ul class="is-hidden-tablet"><li class="is-active">$(ps.navbar_title)</li></ul>
					</nav>
					<div class="docs-right">$(ps.editpath=="" ? "" : "<a class='docs-edit-link' href='$(ps.editpath)' target='_blank'><span class='docs-label is-hidden-touch'>$(lw(pss, 2))</span></a>")
						<a class="docs-settings-button fas fa-cog" id="documenter-settings-button" href="#" title="$(lw(pss, 3))"></a>
						<a class="docs-sidebar-button fa fa-bars is-hidden-desktop" id="documenter-sidebar-button" href="#"></a>
					</div>
				</header>
				<article class="content">$(ps.mds)</article>
				<nav class="docs-footer">$(ps.prevpage)$(ps.nextpage)$(pss.page_foot=="" ? "" : "<div class='flexbox-break'></div><p class='footer-message'>$(pss.page_foot)</p>")</nav>
				$(gis===nothing ? "" : "<div class='giscus'></div>")
			</div>
			<div class="modal" id="documenter-settings">
				<div class="modal-background"></div>
				<div class="modal-card">
					<header class="modal-card-head">
						<p class="modal-card-title">$(lw(pss, 3))</p>
						<button class="delete"></button>
					</header>
					<section class="modal-card-body">
						<p><label class="label">$(lw(pss, 4))</label>
							<div class="select">
								<select id="documenter-themepicker">
									<option value="light">light</option><option value="dark">dark</option>
								</select>
							</div>
						</p>
					</section>
					<footer class="modal-card-foot"></footer>
				</div>
			</div>
		</div>
	</body>
	</html>
	"""
end
