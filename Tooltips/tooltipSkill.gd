extends Node2D


func showTooltip(title,total_value,base_value,cost,cooldown,description):
	$Title.text = str(title)
	$Total.text = str(total_value)
	$Base.text = str(base_value)
	$Cost.text = str(cost)
	$Cooldown.text = str(cooldown)
	$Description.text = str(description)
var offset_from_mouse = Vector2(10, -10) # Adjust this offset according to your preference

func _process(delta):
		# Adjust tooltip position based on mouse
		var mouse_pos = get_global_mouse_position()
		set_global_position(mouse_pos + offset_from_mouse)
