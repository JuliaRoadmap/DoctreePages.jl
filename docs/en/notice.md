# Notice
1. Markdown parsing is based on [CommonMark](https://github.com/MichaelHatherly/CommonMark.jl).
2. The `generate` function calls `@info`. `@error` is called if a single markdown fails to be parsed into HTML, but does not throw the error.
