"""
Generate basic structure for docs building.
Use `cd(template, path)` if the target is not the current path.
"""
function template(;github_workflow::Bool = true, print_help::Bool = true)
	mkpath("docs")
	mkpath("assets")
	mkpath(".github/workflows")
	write("DoctreeBuild.toml", "[pages]")
	write("docs/setting.toml", "outline = []")
	if github_workflow
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
          github_token: \${{ secrets.GITHUB_TOKEN }}
          publish_dir: "./public"\n""")
    end
	if print_help
		print("Remember to fill in DoctreeBuild.toml")
	end
end
