extends TextureButton


onready var icon = $Icon
onready var quantity_label = $Label
var quantity = 0
var item = "null"
var type = "item"
var stackable = true
var max_quantity = 9999999
var skill_tree = false



func _input(event:InputEvent)->void:
	if get_parent().get_parent().get_parent().visible == true and Input and visible == true:
		if Engine.get_physics_frames() % 3 == 0:
			displayQuantity()
			print("displaying quantity")


func displayQuantity()->void:
		if quantity > 0: 
			quantity_label.text = str(round(quantity))
		else:
			quantity_label.text = ""
			icon.texture = null	
			
		if icon.texture == null:
			quantity = 0
			quantity_label.text = ""

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
	var dragPreview = Autoload.drag_preview.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	displayQuantity()
	print("Item type:", item)
	return data

func can_drop_data(position, data):
	displayQuantity()
	var target_slot = get_parent().get_name()
	data["target_texture"] = icon.texture
	data["target_quantity"] = quantity
	data["target_item"] = item
	if data["type"] != "skill":
		return true
	else:
		return false


func drop_data(position, data)->void:
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

	if origin_texture == target_texture:
		if origin_node != self: #CHECK IF IT'S NOT DRAGGIN ON SELF TO AVOID DELETING ITEMS BY MISTAKE
			# Combine quantities if items are the same
			quantity += data["origin_quantity"]
			origin_node.quantity = 0  # Reset the origin quantity
	else:
		if origin_node != self: #CHECK IF IT'S NOT DRAGGIN ON SELF TO AVOID DELETING ITEMS BY MISTAKE
			# Swap quantities if items are different
			var temp_quantity = quantity
			quantity = origin_quantity
			origin_node.quantity = temp_quantity
	# Update the display
	displayQuantity()



