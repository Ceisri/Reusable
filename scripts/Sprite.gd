extends Sprite


func _physics_process(_delta):
	global_position = get_global_mouse_position()
	if Input.is_action_just_released("ui_cancel") or Input.is_action_just_released("Inventory") or Input.is_action_just_released("skills"):
		queue_free()
		
