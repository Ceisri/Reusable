extends Node2D


func showTooltip(title, stat1, stat2, stat3, stat4, stat5, stat6, stat7, stat8, stat9):
	$Title.text = str(title)
	$GridContainer/Stat1.text = str(stat1)
	$GridContainer/Stat2.text = str(stat2)
	$GridContainer/Stat3.text = str(stat3)
	$GridContainer/Stat4.text = str(stat4)
	$GridContainer/Stat5.text = str(stat5)
	$GridContainer/Stat6.text = str(stat6)
	$GridContainer/Stat7.text = str(stat7)
	$GridContainer/Stat8.text = str(stat8)
	$GridContainer/Stat9.text = str(stat9)


	
	
var offset_from_mouse:Vector2 = Vector2(10, -10) # Adjust this offset according to your preference

func _physics_process(delta:float)->void:
		# Adjust tooltip position based on mouse
		var mouse_pos = get_global_mouse_position()
		set_global_position(mouse_pos + offset_from_mouse)
