# setting
`outline`，`names`，`tags`，`tagnames`信息存在各`setting.toml`中，没有的应省略，提到文件时应省略后缀
* `outline::Vector{String}`表示提纲，以HTML导出时会作为侧边栏且按照原顺序和层级排列
* `[names]::Dict{String,String}`表示非markdown文件的中文标题
* `[tags]::Dict{String,Vector{String}}`仅应包含同级目录中的内容
* `[tagnames]::Dict{String,Vector{String}}`表示每个原tag可能的其它表达形式
