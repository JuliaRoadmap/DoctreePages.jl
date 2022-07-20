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

## Insert Setting
Code-blocks with `insert-setting` insert tests. It uses TOML and the `type` key decides the type.

### select-is
Currently, `type = "select-is"` is the only supported mode.
* content is in key `content`, does not support Markdown
* `choices` defines a `value` => `display text` dict
* `store` defines a `value` => `localStorage key` dict

## Insert Test
Code-blocks with `insert-test` insert tests. It also uses TOML.

### Structure
There are two main keys: `global` for global setting and `pages`, a table-list.

In global setting, `name` represents the name of the test, `time_limit` is the time limit (seconds) and `full_score` is the full score (does **not decide** how scores are arranged).

For each *part*, the `type` key decides the type.

### Text
`type = "text"` means inserting text, content is in key `content`, supports Markdown

### Choice Question
`type = "choose"` means inserting choice question
* content is in key `content`, supports Markdown
* choices indexing is based on `index_char` and `index_suffix`, the first should be one of `Aa1` (defaults to `A`), the second defaults to `. `
* `choices` defines choices, Markdown isn't supported
* `ans` defines answer (use `AC` instead of `CA` or `ab`)
* `score` defines the score
* `ans_dict` is a dict (`choice => score`), overwrites `ans` and `score`

### Filling Question
`type = "fill"` means inserting a filling question
* content is in key `content`, supports Markdown
* `ans` defines answer
* `ans_regex` defines regex for judging, overwrites `ans`
* `score`defines the score

### Grouping
`type = "group"` defines a group, content is in key `content`, supports Markdown; `type = "group-end"` marks the end of a group

groups can't nest, so it's not necessary to add `group-end` block after every group

### Scope
`index_char`, `index_suffix` and `score` have scopes. This means they can be defined in `global` or groups, while local definitions can still overwrite definitions in wider fields.
