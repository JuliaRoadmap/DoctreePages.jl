# 基础文档功能测试
## 基本文本特效
文字，**粗体**，*斜体*，`行内代码`

## 换行
a
b

---

a\
b

---
a

b

## 链接
[内部链接](#表格)

[外部链接](http://info.cern.ch/)

[其它文档链接](../zh/usage.md)

[标题链接](../zh/usage.md#github-action)

[txt 文件测试](txtfiletest.txt)

[纯代码文件链接](https://learn.juliacn.com/docs/lists/typetree1.8.html#L20-L50)

## 图片
![](https://github.com/favicon.ico)

## 列表
1. 1
	* a
	* b
		1. 1
		2. 2
2. 2
	* a
		* a
			* $x^2$

## 引用
> 引用
> > 二级引用
> > * a

## 表格
| 表格 | 第二个 |
| :-: | --- |
| `a` | 1**+**2 |
| $b$ | 末尾 |

## LATEX
$b$ 与 $c^2$

$$\sum_{i=1}^n i^{i+1}$$

## Admonition
!!! note
	note

!!! warn
	warn

!!! compat "DoctreePages v1.1"
	compat

## HTML 嵌入
<p>&lt;p&gt;&amp;lt;</p>

## 脚注
Bee [^1]

[^1]: insect
[^2]: 脚注2
