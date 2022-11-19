function dictparse(str){
	if(str.endsWith(','))str=str.substring(0, str.length-1)
	return JSON.parse("{"+str+"}")
}
