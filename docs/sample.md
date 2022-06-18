# 样例
```jl
gis = GiscusSetting(; # get via giscus.app
	repo = "JuliaRoadmap/zh",
	repo_id = "R_kgDOHQYI2Q",
	category_id = "DIC_kwDOHQYI2c4CO2c9",
	lang = "zh-CN"
)
pss = PagesSetting(;
	giscus = gis,
	lang = "zh",
	repo_name = "zh",
	repo_owner = "JuliaRoadmap"
	title = "Roadmap"
)
```
