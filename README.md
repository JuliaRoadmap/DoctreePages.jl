中文README | [English README](README_en.md)

## 关于
这是一个轻量级交互式文档生成器
* 轻量级：只基于 CommonMark 和 TOML
* 简单：即使没有编程经验也能使用
* 强大&可交互：[各式各样的功能](https://juliaroadmap.github.io/DoctreePages.jl/docs/zh/features.md)
* 可配置：超过30个设置项（不包括子项）

## 用途
此包**不是专为包文档设计**，更适合用于教育性文档/博客等

## 与Documenter比较
* 不同的结构
* 由上述可知，本包在特定领域支持更多特性
* Documenter自动支持多版本文档、文档搜索与pr预览等，它们可能在特定情形实用

---

* [在此阅读文档](https://juliaroadmap.github.io/DoctreePages.jl/docs/zh/usage.html)

## LICENSE
遵循MIT LICENSE，其中以下文件部分来自[Documenter](https://github.com/JuliaDocs/Documenter.jl)（MIT）
* css/dark.css
* css/light.css
* src/scripts.jl

Discussion功能来自[giscus](https://github.com/giscus/giscus)

## 使用实例
[DoctreeBuild](https://github.com/JuliaRoadmap/zh/blob/master/DoctreeBuild.toml) [对应测试示例](https://juliaroadmap.github.io/zh/docs/meta/doctest.html)

## todo
- [ ] giscus theme调整
- [ ] 允许调整字体大小
- [ ] 二维码
- [ ] 复制纯源代码
- [ ] live2d
- [ ] 空间压缩
- [ ] 快捷键
	- [ ] t 到页面顶端
- [ ] 部分内容加密
- [ ] 根据fetch到的页面内容自动生成链接块
- [ ] 允许将代码块拖动到侧边
