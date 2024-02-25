extends StaticBody


var demon_scene = preload("res://Entities/demon/demon.tscn")
var quantity = 10 


func start():
	if quantity >0:
		$SpawnTimer.start()





func _on_SpawnTimer_timeout():
	var demon_instance = demon_scene.instance()
	
	if quantity >0:
		quantity -=1
		print(str(quantity))
		demon_instance.transform.origin = Vector3(-777.762, -0, -419.456)
		get_tree().get_root().add_child(demon_instance)
	if quantity ==0:
		$SpawnTimer.stop()
		print("over")
