function try_notify(title){
	if(window.Notification && Notification.permission=="granted"){
		Notification.requestPermission(function(st){
			let n=new Notification(title)
		})
	}
	else window.alert(title)
}
