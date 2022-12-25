# 文档功能测试
文字，**粗体**，*斜体*，`行内代码`，[内部链接](#标题2)[^1]，[外部链接](http://info.cern.ch/)\
第二行，[其它文档链接](../zh/usage.md)，[标题链接](../zh/usage.md#github-action)，[txt 文件测试](txtfiletest.txt)，[纯代码文件链接](https://learn.juliacn.com/docs/lists/typetree1.8.html#L20-L50)

---

## 标题2
![](https://github.com/favicon.ico)

1. 1
	* a
	* b
		1. 1
		2. 2
2. 2
	* a
		* a
			* $x^2$

> 引用
> > 二级引用
> > * a

| 表格 | 第二个 |
| :-: | --- |
| `a` | 1**+**2 |
| $b$ | 末尾 |

$$\sum_{i=1}^n i^{i+1}$$

!!! note
	note

!!! warn
	warn

!!! compat "DoctreePages v1.1"
	compat

```plain
plain
```

```julia-repl
julia> begin foo(nothing,"$(Int)\n") end # comment

julia> @bar 32 == `15` #= =#
```

```html
<a></a> <div>
```

```shell
$ activate vfs

vfs> init
initialized

vfs> quit
```

```insert-setting
type = "select-is"
content = "您是否是开发者？"
default = "no"
choices = {"yes"="是", "no"="否"}
store = {"yes"="is-developer","no"="!is-developer"}
```

```is-developer
欢迎开发者！
```

```insert-fill
content = "1+1等于几？"
ans = "2"
instruction = "3-1"
```

```insert-fill
content = "1+1等于几？**允许末尾额外空格**"
ans = "2"
ans_regex = "^2 {0,}$"
```

<p>&lt;p&gt;&amp;lt;</p>

```insert-test
[global]
name = "文档测试测试"
time_limit = 600
full_score = 10

[[parts]]
type = "choose"
content = "选择"
choices = ["a", "b", "c", "d"]
ans_dict = {"A"=1, "AB"=2, "ABC"=3, "ABCD"=4}

[[parts]]
type = "fill"
content = "3~5个空格"
ans_regex = "^ {3,5}$"
score = 6

[[parts]]
type = "text"
content = "文字"
```

```hide 点击显示内容
- 「开发」ignore 设置项
- 「开发」foot_direct 设置项
- 「交互」支持“回到顶端”火箭
```

```random-word
id = "rw1"

[[pool]]
text = "罗素是教皇。"
original = "1 + 1 = 3"
source = "missing"

[[pool]]
text = "猫猫"
```

[^1]: footnote
[^2]: 脚注2