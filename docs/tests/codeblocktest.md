# 代码块测试
## 普通代码块
```plain
plain
```

```jl
for x in cats
	println(x)
	cnt += 3
end
```

```cpp
#include <iostream>
using std::cout;
int main(){
	cout << __FILE__;
	return 0;
}
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

## 条件触发
```insert-setting
type = "select-is"
content = "您是否是开发者？"
default = "no"
choices = {"yes"="是", "no"="否"}
store = {"yes"="is-developer","no"="!is-developer"}
```

```check developer
欢迎开发者！
```

## 测试
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

## 杂项
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
