extends TextureButton

var DRAG_PREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var quantity_label = $Quantity

var quantity = rand_range(0, 25)
var item = "null"

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
		icon.texture = preload("res://UI/graphics/SkillIcons/empty.png")
		print("zeroed out")

func get_drag_data(position: Vector2):
	matchItemTypeToIcon()
	
	var slot = get_parent().get_name()
	var data = {
		"origin_node": self,
		"origin_slot": slot,
		"origin_texture": icon.texture,
		"origin_quantity": quantity,
		"origin_item": item
	}
	var dragPreview = DRAG_PREVIEW.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)

	# Remove the icon from its original place
	icon.texture = preload("res://UI/graphics/SkillIcons/empty.png")
	quantity = 0
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
	return true


func drop_data(position, data):
	matchItemTypeToIcon()
	displayQuantity()
	var origin_texture = data["origin_texture"]
	var target_texture = icon.texture
	var origin_item = data["origin_item"]
	var target_item = item
	var origin_quantity = data["origin_quantity"]
	var target_quantity = quantity

	data["origin_node"].get_node("Icon").texture = target_texture
	icon.texture = origin_texture

	if origin_item == target_item:
		# Only combine the quantities if target_texture and origin_texture are the same
		quantity += data["origin_quantity"]
		
		data["origin_node"].get_node("Icon").texture = preload("res://UI/graphics/SkillIcons/empty.png")
	else:
		# Swap the quantities if the textures are different
		quantity = origin_quantity
		data["origin_quantity"] = target_quantity



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

