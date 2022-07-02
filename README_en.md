[中文文档](README.md) | English Docs

## About
This is a lightweight interactive document generator.
* lightweight: only two dependencies
* interactive: including page-discussion, answer-board and statement-trigger text

* [usage](docs/en/usage.md)
* [guidelines](docs/en/guidelines.md)
* [notice](docs/en/notice.md)
* [setting](docs/en/settings.md)
* [extension](docs/en/extension.md)

Type `?DoctreePages` to read usage of functions.

## LICENSE
MIT LICENSE, and these files partly come from [Documenter](https://github.com/JuliaDocs/Documenter.jl) (MIT)
* css/dark.css
* css/light.css
* js/main.js

Page-discussion is powered by [giscus](https://github.com/giscus/giscus)

## Sample
[Result](https://juliaroadmap.github.io/docs/meta/doctest.html)
```jl
using DoctreePages
gis = GiscusSetting(; # get via giscus.app
	repo = "JuliaRoadmap/zh",
	repo_id = "R_kgDOHQYI2Q",
	category_id = "DIC_kwDOHQYI2c4CO2c9",
	lang = "zh-CN"
)
pss = PagesSetting(;
	buildmessage = "",
	giscus = gis,
	lang = "zh",
	logo_path = "assets/images/logo.png",
	repo_name = "zh",
	repo_owner = "JuliaRoadmap",
	table_align = :center,
	throwall = true,
	title = "Roadmap"
)
generate("D:/RM", "D:/RMH", pss)
```
