extends TextureButton

var DRAG_PREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var player =$"../../../.."

var quantity : int
var item = "null"
var type = "chest"

func _ready():
	matchItemTypeToIcon()

func _physics_process(delta):
	icon.savedata()
	if item == "garment1":
		player.torso = "garment1"
		player.applyEffect(player, "effect1", true)
	elif item == "null" or item == "empty":
		player.torso = "naked"
		player.applyEffect(player, "effect1", false)
	matchItemTypeToIcon()



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
	var dragPreview = DRAG_PREVIEW.instance()
	dragPreview.texture = icon.texture
	add_child(dragPreview)
	#print("Item type:", item)
	return data

func can_drop_data(position, data):

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
	var origin_item = data["origin_item"]
	var target_item = item
	var origin_quantity = data["origin_quantity"]
	var target_quantity = quantity
	var origin_node = data["origin_node"]
	var origin_icon = origin_node.get_node("Icon")
	var dragPreview = origin_node.get_node("Sprite") #find the floating image of the sprite
	dragPreview.queue_free()# delete that floating image 
	
	origin_icon.texture = target_texture
	icon.texture = origin_texture
	icon.savedata()

	if origin_item == target_item:
		# Combine quantities if items are the same
		quantity += data["origin_quantity"]
		origin_node.quantity = 0  # Reset the origin quantity
	else:
		# Swap quantities if items are different
		var temp_quantity = quantity
		quantity = origin_quantity
		origin_node.quantity = temp_quantity



func matchItemTypeToIcon():
	var texture_to_item = {
		preload("res://Equipment icons/garment1.png"): "garment1",
		preload("res://UI/graphics/SkillIcons/empty.png"): "empty"
	}
	if icon.texture in texture_to_item:
		item = texture_to_item[icon.texture]
	elif icon.texture == null:
		item = "null"
	else:
		item = "unknown"
