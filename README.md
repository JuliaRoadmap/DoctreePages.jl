中文文档 | [English Docs](README_en.md)

## 关于
这是一个轻量级交互式文档生成器
* 轻量级：只基于 CommonMark 和 TOML
* 交互式：包括页面讨论功能，填空题与条件激发文本
* 简单：即使没有编程经验也能使用
* 强大：[各式各样的功能](docs/zh/functions.md)
* 可配置：超过30个设置项（不包括子项）

---

* [使用方式](docs/zh/usage.md)
* [规范](docs/zh/guidelines.md)
* [注意事项](docs/zh/notice.md)
* [设置文件](docs/zh/settings.md)
* [扩展](docs/zh/extension.md)

## LICENSE
遵循MIT LICENSE，其中以下文件部分来自[Documenter](https://github.com/JuliaDocs/Documenter.jl)（MIT）
* css/dark.css
* css/light.css
* extra/main.js

Discussion功能来自[giscus](https://github.com/giscus/giscus)

## 使用实例
[DoctreeBuild](https://github.com/JuliaRoadmap/zhl/blob/master/DoctreeBuild.toml) [对应测试示例](https://juliaroadmap.github.io/zh/docs/meta/doctest.html)

## todo
- [x] 收藏页面
- [x] ~~双击将数据存入剪贴板~~
	- [x] 标题使用按钮
	- [x] 代码块使用按钮
- [x] ~~评论区（gitalk）~~
	- [ ] ~~gitalk暗色模式~~
- [x] 评论区（giscus）
	- [ ] giscus theme调整
- [x] `#header`定位
- [x] txt`#L-L`定位
- [x] 完善侧边栏
- [x] `.jl`，`.txt`
- [x] `jl`高亮：长转义
- [ ] `jl`高亮：正则表达式
- [x] `shell`高亮
- [x] 暗色模式舒适初始化
- [ ] 允许调整字体大小
- [x] 支持LaTeX
- [x] 插入html
- [x] 插入条件激发
- [x] 插入填空题
- [x] 精确跳转编辑
- [ ] 二维码
- [x] 设置：表格对齐模式
- [ ] 更好的代码块
	- [x] 侧边序号
	- [ ] 复制纯源代码
- [ ] live2d
- [ ] 空间压缩
- [ ] 快捷键
	- [ ] t 到页面顶端
- [ ] 插入测试
- [ ] 部分内容加密
- [ ] 根据fetch到的页面内容自动生成链接块
- [ ] 允许将代码块拖动到侧边
- [ ] DoctreePagesProject.toml
