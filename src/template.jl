"""
Generate basic structure for docs building.
Use `cd(template, path)` if the target is not the current path.
"""
function template()
	mkpath("docs")
	mkpath("assets")
	mkpath(".github/workflows")
	write("DoctreeBuild.toml", "[pages]")
	write("docs/setting.toml", "outline = []")
	write(".github/workflows/builddocs.yml",
"""
name: Build Docs
on:
  push:
    branches: [master]
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    if: "!(contains(github.event.head_commit.message, '[nobuild]'))"
    steps:
      - uses: actions/checkout@v3
      - run: |
          julia -e '
            using Pkg
            Pkg.add(name="DoctreePages")
            using DoctreePages
            github_action()
          '
      - uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: "./public"\n""")
	print("Remember to fill in DoctreeBuild.toml")
end
