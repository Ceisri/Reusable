extends Node2D


func showTooltip(title:String,text:String)->void:
	$Label.text = title
	$Label2.text = text 
var offset_from_mouse:Vector2 = Vector2(10, -10) # Adjust this offset according to your preference

func _physics_process(delta:float)->void:
		# Adjust tooltip position based on mouse
		var mouse_pos = get_global_mouse_position()
		set_global_position(mouse_pos + offset_from_mouse)
