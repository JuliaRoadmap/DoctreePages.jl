## 关于
这是一个轻量级交互式文档生成器\
中文文档 | [English Docs](README_en.md)
* [规范](docs/guidelines.md)
* [注意事项](docs/notice.md)
* [设置文件](docs/settings.md)

## LICENSE
遵循MIT LICENSE，其中以下文件部分来自[Documenter](https://github.com/JuliaDocs/Documenter.jl)（MIT）
* css/dark.css
* css/light.css
* js/main.js

Discussion功能来自[giscus](https://github.com/giscus/giscus)

## 使用实例
[对应测试示例](https://juliaroadmap.github.io/docs/meta/doctest.html)
```jl
using DoctreePages
gis = GiscusSetting(; # 使用 giscus.app 获取
	repo = "JuliaRoadmap/zh",
	repo_id = "R_kgDOHQYI2Q",
	category_id = "DIC_kwDOHQYI2c4CO2c9",
	lang = "zh-CN"
)
pss = PagesSetting(;
	giscus = gis,
	lang = "zh",
	repo_name = "zh",
	repo_owner = "JuliaRoadmap",
	title = "Roadmap"
)
generate("D:/RM", "D:/RMH", pss)
```

## todo
- [ ] 收藏页面
- [x] 双击将数据存入剪贴板
	- [ ] 改为使用按钮
- [x] ~~评论区（gitalk）~~
	- [ ] ~~gitalk暗色模式~~
- [x] 评论区（giscus）
	- [ ] giscus theme调整
- [x] `#header`定位
- [x] txt`#L-L`定位
- [ ] 完善侧边栏
- [x] `.jl`，`.txt`
- [ ] `jl`高亮：长转义
- [ ] `jl`高亮：正则表达式
- [ ] `shell`高亮
- [x] 暗色模式舒适初始化
- [ ] 允许调整字体大小
- [ ] 支持LaTeX
- [x] 插入html
- [x] 插入条件激发
- [x] 插入填空题
- [x] 精确跳转编辑
