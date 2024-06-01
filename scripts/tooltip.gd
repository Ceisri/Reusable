extends Node2D


func showTooltip(title,text,text2):
	$Label.text = title
	$Label2.text = text 
	if $Label3 != null:
		$Label3.text = text2
var offset_from_mouse = Vector2(10, -10) # Adjust this offset according to your preference

func _process(delta):
		# Adjust tooltip position based on mouse
		var mouse_pos = get_global_mouse_position()
		set_global_position(mouse_pos + offset_from_mouse)
