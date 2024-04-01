extends TextureButton

var DRAG_PREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var quantity_label = $Quantity

var quantity = 0
var item = "null"
var type = "item"
var stackable = true
var max_quantity = 9999999
var skill_tree = false




func can_drop_data(position, data):

	return true


func drop_data(position, data):
	
	var origin_texture = data["origin_texture"]
	var origin_quantity = data["origin_quantity"]
	var origin_node = data["origin_node"]
	var origin_icon = origin_node.get_node("Icon")
	var dragPreview = origin_node.get_node("Sprite") #find the floating image of the sprite
	dragPreview.queue_free()# delete that floating image 
	origin_icon.texture = null
	origin_node.quantity = 0


