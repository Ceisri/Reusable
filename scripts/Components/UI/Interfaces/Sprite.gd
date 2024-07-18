extends Sprite


func _physics_process(_delta)->void:
	if Engine.get_physics_frames() % 2 == 0:
		global_position = get_global_mouse_position()
		if Input.is_action_just_released("ESC") or Input.is_action_just_released("Inventory") or Input.is_action_just_released("skills"):
			queue_free()
			
