extends TextureButton

onready var icon = $Icon
var quantity = 99999999999
var item = "null"
var type = "skill"
var skill_tree = true 


func get_drag_data(position: Vector2):
	var slot = get_parent().get_name()
	var data = {
		"origin_node": self,
		"origin_slot": slot,
		"origin_texture": icon.texture,
		"origin_quantity": quantity,
		"type": type
	}
	var dragPreview =  autoload.drag_preview.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	return data

func can_drop_data(position, _data):
	var target_slot = get_parent().get_name()
	return false

func drop_data(position, data):
	pass





