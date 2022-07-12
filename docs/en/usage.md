# Usage
`generate` function allows three parameters:
* srcdir: dir containing raw data (markdown, etc)
* tardir: dir to store result (html, etc)
* pss: instance of `PagesSetting`

`PagesSetting` constructor uses keywords. These are introductions while type and default values shall be mentioned in docstring. More detailed information shall refer to source code.

| key name | description |
| --- | --- |
| buildmessage | build message |
| charset | charset of source files |
| default_alt | default alt for images |
| favicon_path | path of favicon |
| filesuffix | suffix of generated files |
| giscus | Giscus setting |
| hljs_all | whether all highlighting uses [highlight.js](https://github.com/highlightjs/highlight.js), `false` is not yet supported |
| lang | language(`en`, `zh`, etc) |
| logo_path | path of logo |
| make_index | whether to create index pages |
| move_favicon | whether to move favcon to `/favicon.ico` |
| page_foot | html inserted at the bottom |
| parser | CommonMark parser |
| remove_origin | whether to remove before generating |
| repo_branch | default branch name of repo |
| repo_name | name of repo |
| repo_owner | owner name of repo |
| repo_path | full path to repo default branch |
| show_info | whether to call `@info` |
| sort_file | whether to sort files |
| src_assets | refer to [guidelines](guidelines.md#dir-managing |
| src_script | refer to [guidelines](guidelines.md#dir-managing) |
| sub_path | when it's subdir of a project, gives the path down from the root directory |
| table_align | table align setting |
| tar_assets | name of dir of generated `assets` |
| tar_css | name of dir of generated css files |
| tar_extra | name of dir of generated extra data |
| tar_script | name of dir of generated scripts |
| throwall | whether to throw non-fatal errors |
| title | title |
| unfound | page to redirect when 404 error occurs (page will be automatically generated if not found) |
| wrap_html | whether to wrap html files |

1. Keys without default values include `repo_name`, `repo_owner` and `title`.
2. File that value `unfound` refer to shall be under the same directory.
3. Values of keys starting with `src_` or `tar_` shall only be a dir-name without `/`(dir-split symbol)
