# Notice
1. Markdown parsing is based on the default setting of Markdown (standard library). It may not be able to parse paragraphs successfully, so things like `.content p{ display:inline; }` are declared. So new lines should be marked by `\` at the end of the line.
2. The `generate` function calls `@info`. `@error` is called if a single markdown fails to be parsed into HTML, but does not throw the error.
