# Usage
`generate` function allows three parameters:
* srcdir: dir containing raw data (markdown, etc)
* tardir: dir to store result (html, etc)
* pss: instance of `PagesSetting`

`PagesSetting` constructor uses keywords. These are introductions and type&default shall be mentioned in docstring.
| key name | description |
| --- | --- |
| buildmessage | build message |
| charset | charset of source files |
| default_alt | default alt for images |
| favicon_path | path of favicon |
| filesuffix | suffix of generated files |
| giscus | Giscus setting |
| lang | language(`en`, `zh`, etc) |
| logo_path | path of logo |
| make_index | whether to create index pages |
| move_favicon | whether to move favcon to `/favicon.ico` |
| parser | CommonMark parser |
| remove_origin | whether to remove before generating |
| repo_branch | default branch name of repo |
| repo_name | name of repo |
| repo_owner | owner name of repo |
| repo_path | full path to repo default branch |
| show_info | whether to call `@info` |
| sort_file | whether to sort files |
| sub_path | when it's subdir of a project, gives the path down |
| table_align | table align |
| throwall | whether to throw unfatal errors |
| title | title |
