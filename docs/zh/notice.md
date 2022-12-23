# 注意事项
1. 本项目使用了 [CommonMark](https://github.com/MichaelHatherly/CommonMark.jl)，当前存在含 unicode 字符时的表格解析错误等 bug
2. 生成主体的 `generate` 函数会调用 `@info` 显示信息
3. 在 Markdown 文件解析失败且 `throwall` 为假时，会调用 `@error` 同时将错误信息置于错误所在文件内
