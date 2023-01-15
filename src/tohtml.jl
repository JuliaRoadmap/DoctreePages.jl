function makehtml(pss::PagesSetting, ps::PageSetting)
	gis = pss.giscus
	return """
	<!DOCTYPE html>
	<html lang="$(pss.lang)">
	<head>
		<meta charset="$(pss.charset)">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>$(ps.description)</title>$(pss.favicon_path=="" ? "" : "<link rel='icon' type='image/x-icon' href='$(pss.favicon_path)'>")
		<meta name="tURL" id="tURL" content="$(ps.tURL)">
		<meta name="description" content="$(ps.description)">
		<script src="$(ps.tURL)$(pss.tar_extra)/info.js"></script>
		<link id="theme-href" rel="stylesheet" type="text/css" href="$(ps.tURL)css/light.css">
		<script src="$(pss.main_script.requirejs.url)" data-main="$(ps.tURL)$(pss.tar_extra)/main.js"></script>
		<link rel="stylesheet" type="text/css" href="$(ps.tURL)css/general.css">
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/fontawesome.min.css">
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/solid.min.css">
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.2.1/css/brands.min.css">
		<link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.16.4/katex.min.css">
	</head>
	<body>
		<div id="documenter">
			$(singlehtml_sidebar(pss, ps))
			<div class="docs-main">
				<header class="docs-navbar">
					<nav class="breadcrumb"><ul><li class="is-active">$(ps.navbar_title)</li></ul></nav>
					<div class="docs-right">$(ps.editpath=="" ? "" : "<a class='docs-edit-link' href='$(ps.editpath)' target='_blank'><span class='docs-label is-hidden-touch'>$(lw(pss, 2))</span></a>")
						<a class="docs-settings-button fas fa-cog" id="documenter-settings-button" href="#" title="$(lw(pss, 3))"></a>
						<a class="docs-sidebar-button fa fa-bars is-hidden-desktop" id="documenter-sidebar-button" href="#"></a>
					</div>
				</header>
				<article class="content">$(ps.mds)<div id='rocket' onclick='boom()'></div></article>
				$(singlehtml_footer(pss, ps))
				$(gis===nothing ? "" : "<div class='giscus'></div>")
			</div>
		</div>
	</body>
	</html>
	"""
end

function singlehtml_sidebar(pss::PagesSetting, ps::PageSetting)
	return """<nav class="docs-sidebar">$(pss.logo_path=="" ? "" : "<a class='docs-logo'><img src='$(ps.tURL)$(pss.logo_path)' alt='logo' height='96' width='144'></a>")<div class="docs-package-name"><span class="docs-autofit">$(pss.title)</span></div><ul class="docs-menu"></ul></nav>"""
end

function singlehtml_footer(pss::PagesSetting, ps::PageSetting)
	return """<nav class="docs-footer">$(ps.prevpage)$(ps.nextpage)$(pss.page_foot=="" ? "" : "<div class='flexbox-break'></div><p class='footer-message'>$(pss.page_foot)</p>")</nav>"""
end
