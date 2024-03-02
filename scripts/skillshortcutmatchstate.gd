extends TextureButton

var DRAGPREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon

# File path to save data
var save_file_path = "user_data.json"

func get_drag_data(position: Vector2):
	var slot = get_parent().get_name()
	var data = {}
	data["origin_node"] = self 
	data["origin_slot"] = slot 
	data["origin_texture_normal"] = icon.texture
	var dragPreview = DRAGPREVIEW.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	return data

func can_drop_data(position, data):
	var target_slot = get_parent().get_name()
	data["target_texture_normal"] = texture_normal
	return true 

func drop_data(position, data):
	data["origin_node"].texture_normal = data["target_texture_normal"]
	icon.texture = data["origin_texture_normal"]






