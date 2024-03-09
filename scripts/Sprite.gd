extends Sprite


func _physics_process(_delta):
	global_position = get_global_mouse_position()
	if Input.is_action_just_released("mouse_left"):
		queue_free()
		
