extends TextureButton

var DRAG_PREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var quantity_label = $Quantity

var quantity = 0
var item = "null"
var type = "item"
var stackable = true
var max_quantity = 9999999999
func _ready():
	displayQuantity()
	matchItemTypeToIcon()

func _physics_process(delta):
	displayQuantity()
	matchItemTypeToIcon()


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
	var dragPreview = origin_node.get_node("Sprite") #find the floating image of the sprite
	dragPreview.queue_free()# delete that floating image 
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
		
		preload("res://Alchemy ingredients/2.png"): "rosehip",
		preload("res://Processed ingredients/ground rosehip.png"): "ground rosehip",
		
		#food
		preload("res://Food Icons/Vegetables/aubergine.png"): "aubergine",
		preload("res://Food Icons/Vegetables/beetroot.png"): "beetroot",
		preload("res://Food Icons/Vegetables/bell pepper.png"): "bell pepper",
		preload("res://Food Icons/Vegetables/cabbage.png"): "cabbage",
		preload("res://Food Icons/Vegetables/carrot.png"): "carrot",
		preload("res://Food Icons/Vegetables/corn.png"): "corn",
		preload("res://Food Icons/Vegetables/garlic.png"): "garlic",
		preload("res://Food Icons/Vegetables/onion.png"): "onion",
		preload("res://Food Icons/Vegetables/potato.png"): "potato",
		preload("res://Food Icons/Vegetables/tomato.png"): "tomato",
		preload("res://Food Icons/Cooked Meals/Bread/bread.png"): "",
		
		
		preload("res://Food Icons/Fruits/raspberries.png"): "raspberry",
		preload("res://Food Icons/Fruits/strawberry.png"): "strawberry",
		
		
		preload("res://Alchemy ingredients/blood.png"): "blood",
		
		preload("res://UI/graphics/mushrooms/PNG/background/1.png"): "mushroom 1",
		preload("res://UI/graphics/mushrooms/PNG/background/2.png"): "mushroom 2",
		preload("res://UI/graphics/mushrooms/PNG/background/3.png"): "mushroom 3",
		preload("res://UI/graphics/mushrooms/PNG/background/4.png"): "mushroom 4",
		preload("res://UI/graphics/mushrooms/PNG/background/5.png"): "mushroom 5",
		preload("res://UI/graphics/mushrooms/PNG/background/6.png"): "mushroom 6",
		preload("res://UI/graphics/mushrooms/PNG/background/7.png"): "mushroom 7",
		preload("res://UI/graphics/mushrooms/PNG/background/8.png"): "mushroom 8",
		preload("res://UI/graphics/mushrooms/PNG/background/9.png"): "mushroom 9",
		preload("res://UI/graphics/mushrooms/PNG/background/10.png"): "mushroom 10",
		preload("res://UI/graphics/mushrooms/PNG/background/11.png"): "mushroom 11",
		preload("res://UI/graphics/mushrooms/PNG/background/12.png"): "mushroom 12",
		preload("res://UI/graphics/mushrooms/PNG/background/13.png"): "mushroom 13",
		preload("res://UI/graphics/mushrooms/PNG/background/14.png"): "mushroom 14",
		preload("res://UI/graphics/mushrooms/PNG/background/15.png"): "mushroom 15",
		preload("res://UI/graphics/mushrooms/PNG/background/16.png"): "mushroom 16",
		preload("res://UI/graphics/mushrooms/PNG/background/17.png"): "mushroom 17",
		preload("res://UI/graphics/mushrooms/PNG/background/18.png"): "mushroom 18",
		preload("res://UI/graphics/mushrooms/PNG/background/19.png"): "mushroom 19",
		preload("res://UI/graphics/mushrooms/PNG/background/20.png"): "mushroom 20",
		preload("res://UI/graphics/mushrooms/PNG/background/21.png"): "mushroom 21",
		preload("res://UI/graphics/mushrooms/PNG/background/22.png"): "mushroom 22",
		preload("res://UI/graphics/mushrooms/PNG/background/23.png"): "mushroom 23",
		preload("res://UI/graphics/mushrooms/PNG/background/24.png"): "mushroom 24",
		preload("res://UI/graphics/mushrooms/PNG/background/25.png"): "mushroom 25",
		preload("res://UI/graphics/mushrooms/PNG/background/26.png"): "mushroom 26",
		preload("res://UI/graphics/mushrooms/PNG/background/27.png"): "mushroom 27",
		preload("res://UI/graphics/mushrooms/PNG/background/28.png"): "mushroom 28",
		preload("res://UI/graphics/mushrooms/PNG/background/29.png"): "mushroom 29",
		preload("res://UI/graphics/mushrooms/PNG/background/30.png"): "mushroom 30",
		preload("res://UI/graphics/mushrooms/PNG/background/31.png"): "mushroom 31",
		preload("res://UI/graphics/mushrooms/PNG/background/32.png"): "mushroom 32",
		preload("res://UI/graphics/mushrooms/PNG/background/33.png"): "mushroom 33",
		preload("res://UI/graphics/mushrooms/PNG/background/34.png"): "mushroom 34",
		preload("res://UI/graphics/mushrooms/PNG/background/35.png"): "mushroom 35",
		preload("res://UI/graphics/mushrooms/PNG/background/36.png"): "mushroom 36",
		preload("res://UI/graphics/mushrooms/PNG/background/37.png"): "mushroom 37",
		preload("res://UI/graphics/mushrooms/PNG/background/38.png"): "mushroom 38",
		preload("res://UI/graphics/mushrooms/PNG/background/39.png"): "mushroom 39",
		preload("res://UI/graphics/mushrooms/PNG/background/40.png"): "mushroom 40",
		preload("res://UI/graphics/mushrooms/PNG/background/41.png"): "mushroom 41",
		preload("res://UI/graphics/mushrooms/PNG/background/42.png"): "mushroom 42",
		preload("res://UI/graphics/mushrooms/PNG/background/43.png"): "mushroom 43",
		preload("res://UI/graphics/mushrooms/PNG/background/44.png"): "mushroom 44",
		preload("res://UI/graphics/mushrooms/PNG/background/45.png"): "mushroom 45",
		preload("res://UI/graphics/mushrooms/PNG/background/46.png"): "mushroom 46",
		preload("res://UI/graphics/mushrooms/PNG/background/47.png"): "mushroom 47",
		preload("res://UI/graphics/mushrooms/PNG/background/48.png"): "mushroom 48",
		preload("res://UI/graphics/mushrooms/PNG/background/49.png"): "mushroom 49",
		preload("res://UI/graphics/mushrooms/PNG/background/50.png"): "mushroom 50",
#_______________potions_____________________________________________________________
		preload("res://Potions/Red potion.png"): "red potion",
		
		preload("res://Potions/water.png"): "water",
		preload("res://Potions/Empty potion.png"): "empty potion",
#_______________Equipment___________________________________________________________
		preload("res://Equipment icons/shoe1.png"): "shoe1",
		preload("res://Equipment icons/pants1.png"): "pants1",
		preload("res://Equipment icons/glove1.png"): "glove1",
		preload("res://Equipment icons/garment1.png"): "garment1",
		preload("res://Equipment icons/shoulder1.png"): "pad1",
		preload("res://Equipment icons/hat1.png"): "hat1",
		preload("res://0.png"): "sword0",
#_______________Nothing_____________________________________________________________
		preload("res://UI/graphics/SkillIcons/empty.png"): "empty",
	}
	if icon.texture in texture_to_item:
		item = texture_to_item[icon.texture]
	elif icon.texture == null:
		item = "empty"
	else:
		item = "unknown"



		
		
