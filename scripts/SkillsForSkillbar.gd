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
		
		# Remove the icon from its original place
		icon.texture = null
		
		return data

func can_drop_data(position, data):
	var target_slot = get_parent().get_name()
	if data["type"] == "skill":
		return true
	else:
		return false

func drop_data(position, data):

	icon.texture = data["origin_texture"]





