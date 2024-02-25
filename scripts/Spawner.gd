extends StaticBody

var demon_scene = preload("res://Entities/demon/demon.tscn")


func start():
	var demon_instance = demon_scene.instance()
	demon_instance.transform.origin = Vector3(-777.762, -0, -419.456)
	get_tree().get_root().add_child(demon_instance)
