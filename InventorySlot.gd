extends TextureButton

var DRAGPREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var quantity_label = $Quantity

var quantity = rand_range(0, 25)

func _ready():
	displayQuantity()
	matchItemTypeToIcon()
	
func displayQuantity():
	quantity_label.text = str(round(quantity))
func get_drag_data(position: Vector2):
		var slot = get_parent().get_name()
		var data = {}
		data["origin_node"] = self 
		data["origin_slot"] = slot 
		data["origin_texture_normal"] = icon.texture
		data["quantity"] = quantity
		data["item"] = item
		var dragPreview = DRAGPREVIEW.instance()
		dragPreview.texture = icon.texture
		add_child(dragPreview)
		
		# Remove the icon from its original place
		icon.texture = null
		quantity_label.text = "" #this zero's out the quantity of the label when moving an item to another slot 
		
		return data

func can_drop_data(position, data):
	var target_slot = get_parent().get_name()
	return true 

func drop_data(position, data):
	icon.texture = data["origin_texture_normal"]
	quantity = data["quantity"] #sets the quantity of the label based on the previous slot
	checkIcon(data)
	displayQuantity()
	matchItemTypeToIcon()


func checkIcon(data):
	var receiving_quantity = data["quantity"]
	var origin_slot_name = data["origin_slot"]


	if item != data["item"]:
		print(item + " " + data["item"])
		# Set the quantity to the received quantity if the textures don't match
		quantity = receiving_quantity
	else:
		# Increment the quantity if the textures match
		quantity += receiving_quantity

	displayQuantity()


var item = "null"

func matchItemTypeToIcon():
	var icon_texture = icon.texture

	if icon_texture == preload("res://UI/graphics/mushrooms/PNG/background/1.png"):
		item = "mushroom 1"
	elif icon_texture == preload("res://UI/graphics/mushrooms/PNG/background/2.png"):
		item = "mushroom 2"
	else:
		# Default item type if the texture doesn't match known types
		item = "unknown"

	# Optionally, you can print or use the item type here
	print("Item type:", item)
