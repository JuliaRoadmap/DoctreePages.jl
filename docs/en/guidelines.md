# Guidelines
## Dir Managing
* `assets` stores images or other data (determined by key `src_assets`)
* `docs` stores text
* `script` stores scripts (determined by key `src_script`)

## Naming
The name part should be unique, and
- should be made up of `a-z`, `0-9` and `_`
- must not be `index`, since it will be automatically generated
- `setting.toml` is for special use (if it exists), view [setting](setting.md)

## Markdown Format
* Files should start with `# title`, and no `# ` should be used afterwards.
* For links to the same docs field:
	* use relative paths
	* use `#subtitle` after a link to markdown file to specify the place, uniqueness must be ensured, it will be turned to `#header-subtitle` in HTML
	* use `#Lx-Ly` after a link specify the lines of the first codeblock

## Code Block Format
* Language name should not be empty. Use `plain` instead.
* Use `insert-html` to insert HTML.
* Use `is-xxx` to insert markdown which will be shown iff `localStorage.getItem("is-xxx") == "true"`. A setting page shall be given for readers using `insert-html` block.

`insert-fill` inserts a gap-filling answer board. Use TOML:
```toml
content = "description, uses **Markdown**"
ans = "standard answer"
ans_regex = "answer judger, if this key doesn't exist, judgement is \"being the same as the standard answer\""
instruction = "instruction (you can choose not to set this key; does not support Markdown)"
```
