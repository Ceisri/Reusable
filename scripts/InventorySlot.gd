extends TextureButton

var DRAG_PREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var quantity_label = $Quantity

var quantity = rand_range(0, 25)
var item = "null"
var type = "item"
func _ready():
	displayQuantity()
	matchItemTypeToIcon()

func _physics_process(delta):
	displayQuantity()


func displayQuantity():
	if quantity != 0: 
		quantity_label.text = str(round(quantity))
	elif quantity == 0:
		quantity_label.text = ""
		icon.texture = null

	
	if icon.texture == null:
		quantity = 0
		quantity_label.text = ""

func get_drag_data(position: Vector2):
	matchItemTypeToIcon()
	
	var slot = get_parent().get_name()
	var data = {
		"origin_node": self,
		"origin_slot": slot,
		"origin_texture": icon.texture,
		"origin_quantity": quantity,
		"origin_item": item,
		"type": type
	}
	var dragPreview = DRAG_PREVIEW.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	displayQuantity()
	print("Item type:", item)
	return data

func can_drop_data(position, data):
	matchItemTypeToIcon()
	displayQuantity()
	var target_slot = get_parent().get_name()
	data["target_texture"] = icon.texture
	data["target_quantity"] = quantity
	data["target_item"] = item
	if data["type"] != "skill":
		return true
	else:
		return false


func drop_data(position, data):
	matchItemTypeToIcon()
	displayQuantity()
	var origin_texture = data["origin_texture"]
	var target_texture = icon.texture
	var origin_item = data["origin_item"]
	var target_item = item
	var origin_quantity = data["origin_quantity"]
	var target_quantity = quantity
	var origin_node = data["origin_node"]
	var origin_icon = origin_node.get_node("Icon")

	origin_icon.texture = target_texture
	icon.texture = origin_texture

	if origin_item == target_item:
		# Combine quantities if items are the same
		quantity += data["origin_quantity"]
		origin_node.quantity = 0  # Reset the origin quantity
	else:
		# Swap quantities if items are different
		var temp_quantity = quantity
		quantity = origin_quantity
		origin_node.quantity = temp_quantity

	# Update the display
	displayQuantity()

func matchItemTypeToIcon():
	var texture_to_item = {
		preload("res://UI/graphics/mushrooms/PNG/background/1.png"): "mushroom 1",
		preload("res://UI/graphics/mushrooms/PNG/background/2.png"): "mushroom 2",
		preload("res://UI/graphics/SkillIcons/empty.png"): "empty"
	}
	
	if icon.texture in texture_to_item:
		item = texture_to_item[icon.texture]
	elif icon.texture == null:
		item = "empty"
	else:
		item = "unknown"


