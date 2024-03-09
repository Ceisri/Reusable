extends TextureButton

var DRAGPREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon



func get_drag_data(position: Vector2):
	var slot = get_parent().get_name()
	var data = {}
	data["origin_node"] = self 
	data["origin_slot"] = slot 
	data["origin_texture"] = icon.texture
	data["type"] = "skill"
	var dragPreview = DRAGPREVIEW.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	return data

func can_drop_data(position, _data):
	var target_slot = get_parent().get_name()
	
	return false

func drop_data(position, data):
	var target_slot = get_parent().get_name()
	
	# Check if the target slot is in the group "inventory"
	if target_slot in get_tree().get_nodes_in_group("inventory"):
		# If the slot is in the "inventory" group, do not proceed with dropping
		return
	
	else:
		icon.texture = data["origin_texture"]
	





