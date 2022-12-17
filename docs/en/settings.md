# Settings
`outline` and `names` information is stored in `setting.toml` in each directory (if it's necessary). Strings here represent file names. It uses TOML format, in which
* `outline::Vector{String}` represents an outline. It will be shown in the sidebar of HTML files.
* `names::Dict{String, String}` represents title for non-markdown files (and directories)

Empty keys/files shall not exist.
