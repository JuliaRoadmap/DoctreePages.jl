# 注意事项
1. 本项目使用了标准库中的Markdown，可能无法正确解析段落，因而有类似于`.content p{ display:inline; }`的声明
2. `generate`函数会调用`@info`，在Markdown文件解析失败时调用`@error`
