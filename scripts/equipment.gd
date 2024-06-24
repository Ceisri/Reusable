extends TextureButton
onready var icon = $Icon
onready var player = $"../../../../.."

var quantity : int
var item : String = "null"
var type : String = ""


func get_drag_data(position: Vector2):
	var slot = get_parent().get_name()
	var data = {
		"origin_node": self,
		"origin_slot": slot,
		"origin_texture": icon.texture,
		"origin_quantity": quantity,
		"origin_item": item,
		"type": type
	}
	var dragPreview =  autoload.drag_preview.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	player.convertStats()
	player.current_race_gender.EquipmentSwitch()
	return data

func can_drop_data(position, data):
	player.convertStats()
	player.current_race_gender.EquipmentSwitch()
	var target_slot = get_parent().get_name()
	data["target_texture"] = icon.texture
	data["target_quantity"] = quantity
	data["target_item"] = item
	if data["type"] != "skill":
		return true
	else:
		return false

func drop_data(position, data):
	var origin_texture = data["origin_texture"]
	var target_texture = icon.texture
	var origin_quantity = data["origin_quantity"]
	var target_quantity = quantity
	var origin_node = data["origin_node"]
	var origin_icon = origin_node.get_node("Icon")
	var dragPreview = origin_node.get_node("Sprite") #find the floating image of the sprite
	dragPreview.queue_free()# delete that floating image 
	origin_icon.texture = target_texture
	icon.texture = origin_texture
	player.current_race_gender.EquipmentSwitch()
	player.convertStats()
	if origin_texture == target_texture:
		# Combine quantities if items are the same
		quantity += data["origin_quantity"]
		origin_node.quantity = 0  # Reset the origin quantity
	else:
		# Swap quantities if items are different
		var temp_quantity = quantity
		quantity = origin_quantity
		origin_node.quantity = temp_quantity
	icon.savedata()


