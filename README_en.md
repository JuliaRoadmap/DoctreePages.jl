[中文文档](README.md) | English Docs

## About
This is a lightweight interactive document generator.
* lightweight: only two dependencies (CommonMark and TOML)
* interactive: including page-discussion, answer-board and statement-trigger text
* easy: even those with out programming experience can use it
* powerful: 30+ setting keys (not including sub-keys)

---

* [usage](docs/en/usage.md)
* [guidelines](docs/en/guidelines.md)
* [notice](docs/en/notice.md)
* [setting](docs/en/settings.md)
* [extension](docs/en/extension.md)

## LICENSE
MIT LICENSE, and these files partly come from [Documenter](https://github.com/JuliaDocs/Documenter.jl) (MIT)
* css/dark.css
* css/light.css
* extra/main.js

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
psszh = PagesSetting(;
	giscus = gis,
	lang = "zh",
	logo_path = "assets/images/logo.png",
	repo_name = "zh",
	repo_owner = "JuliaRoadmap",
	sub_path = "zh",
	table_align = :center,
	throwall = true,
	title = "Roadmap",
	use_subdir = "zh"
)
pssdp = PagesSetting(;
	favicon_path = "",
	lang = "en",
	repo_name = "DoctreePages.jl",
	repo_owner = "JuliaRoadmap",
	sub_path = "dtpages",
	title = "DoctreePages.jl",
	use_subdir = "dtpages",
)
generate("D:/RM", "D:/RMH", psszh)
generate("D:/DP", "D:/RMH", pssdp)
```
