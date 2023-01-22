中文 README | [English README](README_en.md)

## 关于
这是一个文档生成器。
* 轻量级，快速
* 简单：可以完全基于配置而无需编写生成脚本
* 强大：[各式各样的功能](https://juliaroadmap.github.io/DoctreePages.jl/docs/zh/features.html)
* 可配置：超过 30 个设置项（不包括子项）

## 用途
此包**不是专为包文档设计**，当前更适合用于教育性的文档、博客等

## 与 Documenter 比较
* 不同的结构
* 由上述可知，本包在特定领域支持更多特性
* Documenter 自动支持多版本文档、文档搜索与 pull request 效果预览等，它们可能在特定情形更适用

---

* [在此阅读文档](https://juliaroadmap.github.io/DoctreePages.jl/docs/zh/usage.html)
* [测试示例](https://juliaroadmap.github.io/DoctreePages.jl/docs/tests/doctest.html)

## LICENSE
遵循 MIT LICENSE，其中以下文件部分来自[Documenter](https://github.com/JuliaDocs/Documenter.jl)（MIT）
* css/dark.css
* css/light.css
* src/script/headroom.js
* src/script/resize.js
* src/script/sidebar.js

Discussion 功能来自[giscus](https://github.com/giscus/giscus)

## 计划
### 主队列
- [ ] 用 ant-design 重写部分组件
- [ ] 支持同文档在多路径下共享
- [ ] 更模块化
- [ ] 空间压缩
- [ ] 支持沉浸式阅读
- [ ] 支持 docstring
- [ ] 支持 org-mode 文档
- [ ] 支持 ink 文档
- [ ] 链接检测，根据 fetch 到的页面内容自动生成链接块
- [ ] 支持文档标签
- [ ] 支持图片下标注文字

### 代码块功能队列
- [ ] 允许将代码块拖动到侧边
- [ ] 支持插入 [ink](https://github.com/inkle/ink)
- [ ] 支持插入[幻灯](https://wpmore.cn/resources/slick/)内容
- [ ] 支持坐标系展示模块
- [ ] 支持 `random-word` 内的 `tag`、`rate` 属性

### 副队列
- [ ] 复制时添加后缀
- [ ] 水印
- [ ] 允许调整字体大小
- [ ] live2d
- [ ] 快捷键
- [ ] 支持鼠标烟花特效
