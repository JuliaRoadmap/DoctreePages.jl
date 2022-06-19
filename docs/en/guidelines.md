# Guidelines
## Naming
The name part should be unique, and
- should be made up of `a-z`, `0-9` and `_`
- must not be `index`, since it will be automatically generated
- `setting.toml` is for special use (if it exists), view [setting](setting.md)

## Markdown Format
* Files should start with `# title`, and no `# ` should be used afterwards.
* For links to the same docs field:
	* use relative paths
	* use `#subtitle` after a link to markdown file to specify the place, uniqueness must be ensured
	* use `#Lx-Ly` after a link to txt file to specify the lines

## Code Block Format
* Language name should not be empty. Use `plain` instead.
* Use `jl` or `julia` for julialang code. REPL staff like `julia>` will be recognized and colored as well.
* Use `shell` for cli.
* Use `insert-html` to insert HTML.
* Use `insert-fill` to insert an interative answer board. It should include an instance of `Tuple{String, String, Regex}` and will be parsed by `eval`. The first is the description, the second is the standard answer and the third judges whether an answer is right. If the third parameter isn't given, It will be judged as "being the same to the standard answer".
* Use `is-xxx` to insert markdown which will be shown iff `localStorage.getItem("is-xxx") == "true"`. A setting page shall be given for readers using `insert-html` block.
