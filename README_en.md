## About
This is a lightweight interactive document generator.\
[中文文档](README.md) | English Docs
* [guidelines](docs/en/guidelines.md)
* [notice](docs/en/notice.md)
* [setting](docs/en/settings.md)

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
	repo_name = "zh",
	repo_owner = "JuliaRoadmap",
	throwall = true,
	title = "Roadmap"
)
generate("D:/RM", "D:/RMH", pss)
```
