struct ScriptBlock
	data::Any
end
ScriptBlock(ready::String, func::String)= ScriptBlock((ready, func))
get_data(s::ScriptBlock, pss::PagesSetting)= isa(s.data, Function) ? s.data(pss) : s.data

# 基础组件

# 函数式组件
const giscus_block = ScriptBlock() do pss::PagesSetting
	gis = pss.giscus
	if gis===nothing
		return ""
	end
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

const requirejs_block = ScriptBlock() do pss::PagesSetting, io::IO, blocks
	println(io, """
	requirejs.config({ paths: configpaths, shim: configshim})
	require(main_requirement, function(\$){
		\$(document).ready(function(){
	""")
	for blk in blocks
		data = blk.data
		if isa(data, Function)
			println(io, data(pss))
		elseif isa(data, Tuple)
			println(io, data[1])
		else
			println(io, data)
		end
	end
	println(io, """
		})
	})
	""")
	for blk in blocks
		data = blk.data
		if isa(data, Tuple)
			println(io, data[2])
		end
	end
end

const default_blocks = [
	headroom_block, setting_block, sidebar_block, themepick_block,
	copyheadinglink_block, hljs_block, docsmenu_block,
	statementtrigger_block, gapfill_block, mark_block, locatelines_block,
	buildmessage_block, katex_block,
	notification_block, test_block, insertsetting_block, tools_block,
	giscus_block,
]
function makescript(io::IO, pss::PagesSetting, blocks=default_blocks)
	println(io, """
	var tURL=document.getElementById("tURL").content
	var theme=localStorage.getItem("theme")
	if(theme==undefined)theme="light"
	else if(theme!="light"){
		document.getElementById("theme-href").href=`\${tURL}\${tar_css}/\${theme}.css`
	}
	const oril=document.location.origin.length
	""")
	requirejs_block.data(pss, io, blocks)
end
