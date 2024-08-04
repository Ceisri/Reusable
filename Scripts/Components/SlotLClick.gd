extends TextureButton



func switchAttackIcon(player) -> void:
	match  player.skills.selected_element:
		"lightning":
			icon.texture = Icons.lighting_shot
		"fire":
			icon.texture = Icons.fireball
		"ice":
			icon.texture = Icons.icile_scatter_shot
		"shadow":
			icon.texture = Icons.arcane_bolt
		"wind":
			icon.texture = Icons.razor_wind_shield
		"none":
			icon.texture = null


onready var icon = $Icon

var quantity = 0
var item = "null"
var type = "item"
var skill_tree = false

func displayQuantity():
		if quantity > 0: 
			pass
		else:
			icon.texture = null	
			
		if icon.texture == null:
			quantity = 0
		

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
	var dragPreview =  Autoload.drag_preview.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	print("Item type:", item)
	return data

func can_drop_data(position, data):
	var target_slot = get_parent().get_name()
	data["target_texture"] = icon.texture
	data["target_quantity"] = quantity
	data["target_item"] = item

	return false


func drop_data(position, data):
	var origin_texture = data["origin_texture"]
	var target_texture = icon.texture
	var target_item = item
	var origin_quantity = data["origin_quantity"]
	var target_quantity = quantity
	var origin_node = data["origin_node"]
	var origin_icon = origin_node.get_node("Icon")
	var dragPreview = origin_node.get_node("Sprite") #find the floating image of the sprite
	dragPreview.queue_free()# delete that floating image 

	icon.texture = origin_texture

	if origin_texture == target_texture:
		# Combine quantities if items are the same
		quantity += data["origin_quantity"]
		origin_node.quantity = 0  # Reset the origin quantity
	else:
		# Swap quantities if items are different
		if origin_node.skill_tree == false:
			var temp_quantity = quantity
			quantity = origin_quantity
			origin_node.quantity = temp_quantity # swap quantities
			origin_icon.texture = target_texture # swap textures

