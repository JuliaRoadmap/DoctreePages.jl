# 设置
`outline` 与 `names` 信息存在各 `setting.toml` 中，没有的应省略，提到文件时应省略后缀
* `outline::Vector{String}` 表示提纲，以 HTML 导出时会作为侧边栏且按照原顺序和层级排列
* `[names]::Dict{String,String}` 表示非 markdown 文件的中文标题
