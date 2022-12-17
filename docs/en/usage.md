# Usage
## Sample
The setting configuration in this repo is a good example, you can implement yours according to the format.

## Generate with Parameter
One method of the `generate` function allows three parameters:
* srcdir: dir containing raw data (markdown, etc)
* tardir: dir to store result (html, etc)
* pss: instance of `PagesSetting`

`PagesSetting` constructor uses keywords. These are just introductions, please refer to the source code for details.

| key name | description |
| --- | --- |
| buildmessage | build message |
| charset | charset of source files |
| default_alt | default alt for images |
| favicon_path | path of favicon, use `""` if none |
| filesuffix | suffix of generated files |
| giscus | Giscus setting |
| hljs_all | whether all highlighting uses [highlight.js](https://github.com/highlightjs/highlight.js), `false` is not yet supported |
| lang | language(`en`, `zh`, etc) |
| logo_path | path of logo, use `""` if none |
| main_script | setting for `main.js` |
| make404 | whether to create a 404-page |
| make_index | whether to create index pages |
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
| table_align | table align setting |
| tar_assets | name of dir of generated `assets` |
| tar_css | name of dir of generated css files |
| tar_extra | name of dir of generated extra data |
| tar_script | name of dir of generated scripts |
| throwall | whether to throw non-fatal errors |
| title | title |
| unfound | page to redirect when 404 error occurs (page will be automatically generated if not found) |
| wrap_html | whether to wrap html files |

1. `title` is the only key without default value.
2. File that value `unfound` refer to shall be under the same directory.
3. Values of keys starting with `src_` or `tar_` shall only be a dir-name without `/`(dir-split symbol)
4. If source data is in a repository, you should remember to set `repo_name` and `repo_owner`

## Config File
The third parameter of the other method is a string, representing the path to the config file, and defaults to `DoctreeBuild.toml`.\
The config file uses TOML format, where
- `version` represents the lowest supported `DoctreePages` version, more complicated setting like [this](https://pkgdocs.julialang.org/v1/compatibility/) is supported after v1.3
- `pages`, `giscus` and `mainscript` represents Pages-setting, Giscus-setting and MainScript-Setting
- despite strings and booleans, no advanced function is provided

## Github Action
You can use github action to build pages into github pages. View sample [builddocs.yml](https://github.com/JuliaRoadmap/DoctreePages.jl/blob/master/.github/workflows/builddocs.yml)

You can use `template()` to generate a template for document automatic building in the current directory.

## Builder Script
If you want, you can also call the provided functions and write a builder script yourself.
