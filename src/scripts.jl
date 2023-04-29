function giscus_script(pss::PagesSetting)
	gis = pss.giscus
	isnothing(gis) && return ""
	return """
	let gsc=document.createElement("script")
	gsc.src="https://giscus.app/client.js"
	gsc.dataset.repo="$(gis.repo)"
	gsc.dataset.repoId="$(gis.repo_id)"
	gsc.dataset.category="$(gis.category)"
	gsc.dataset.categoryId="$(gis.category_id)"
	gsc.dataset.mapping="$(gis.mapping)"
	gsc.dataset.reactionsEnabled="$(gis.reactions_enabled)"
	gsc.dataset.emitMetadata="$(gis.emit_metadata)"
	gsc.dataset.inputPosition="$(gis.input_position)"
	gsc.dataset.theme=$(gis.theme=="auto" ? "theme" : "\"$(gis.theme)\"")
	gsc.dataset.lang="$(gis.lang)"
	gsc.crossOrigin="$(gis.crossorigin)"
	document.body.append(gsc)
	"""
end

function prepare_scripts()
	inline_str = ""
	block_str = ""
	required = Set{String}()
	cd(joinpath(@__DIR__, "script")) do
		toml = TOML.parsefile("info.toml")
		requirements = toml["require"]::Dict
		for inline::String in toml["inlines"]
			inline_str *= read(inline*".js", String)
			for req::String in get(requirements, inline, [])
				push!(required, req)
			end
		end
		for block::String in toml["blocks"]
			block_str *= read(block*".js", String)
		end
		for block::String in required
			block_str *= read(block*".js", String)
		end
	end
	return Pair(inline_str, block_str)
end

function makescript(io::IO, pss::PagesSetting)
	prepared = prepare_scripts()
	println(io, """
	var tURL=document.getElementById("tURL").content
	var theme=localStorage.getItem("theme")
	if(theme==undefined)theme="light"
	else if(theme!="light"){
		document.getElementById("theme-href").href=`\${tURL}\${tar_css}/\${theme}.css`
	}
	const oril=document.location.origin.length
	requirejs.config({paths: configpaths, shim: configshim})
	require(main_requirement, function(\$){
		\$(document).ready(function(){
	""")
	print(io, prepared.first)
	println(io, """
		})
	})
	""")
	print(io, prepared.second)
	print(io, giscus_script(pss))
end
function makescript(_::AbstractDoctree, pss::PagesSetting)
	open("$(pss.tardir)$(pss.tar_extra)/main.js", "w") do io
		makescript(io, pss)
	end
end
