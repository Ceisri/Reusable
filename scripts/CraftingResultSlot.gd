extends TextureButton

var DRAG_PREVIEW = preload("res://Sprite.tscn")
onready var icon = $Icon
onready var quantity_label = $Quantity

var quantity = 900
var item = ""
var type = "item"
func _ready():
	displayQuantity()


func _physics_process(delta):
	displayQuantity()
	matchTextureToItem()



func displayQuantity():
	if quantity != 0: 
		quantity_label.text = str(round(quantity))
	elif quantity == 0:
		quantity_label.text = ""
		item = "empty"
		
	if icon.texture == null or item == "empty":
		quantity = 0
		quantity_label.text = ""

func get_drag_data(position: Vector2):
	if item != "empty":
		decreaseIngredients()
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

	displayQuantity()
	return false


func drop_data(position, data):
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

func decreaseIngredients():
	var crafting_slot1 = $"../CraftingGrid/craftingSlot1"
	var crafting_slot2 = $"../CraftingGrid/craftingSlot2"
	var crafting_slot3 = $"../CraftingGrid/craftingSlot3"
	var crafting_slot4 = $"../CraftingGrid/craftingSlot4"
	var crafting_slot5 = $"../CraftingGrid/craftingSlot5"
	var crafting_slot6 = $"../CraftingGrid/craftingSlot6"
	var crafting_slot7 = $"../CraftingGrid/craftingSlot7"
	var crafting_slot8 = $"../CraftingGrid/craftingSlot8"
	var crafting_slot9 = $"../CraftingGrid/craftingSlot9"
	var crafting_slot10 = $"../CraftingGrid/craftingSlot10"
	var crafting_slot11 = $"../CraftingGrid/craftingSlot11"
	var crafting_slot12 = $"../CraftingGrid/craftingSlot12"
	var crafting_slot13 = $"../CraftingGrid/craftingSlot13"
	var crafting_slot14 = $"../CraftingGrid/craftingSlot14"
	var crafting_slot15 = $"../CraftingGrid/craftingSlot15"
	var crafting_slot16 = $"../CraftingGrid/craftingSlot16"

	crafting_slot1.quantity -= 1
	crafting_slot2.quantity -= 1
	crafting_slot3.quantity -= 1
	crafting_slot4.quantity -= 1
	crafting_slot5.quantity -= 1
	crafting_slot6.quantity -= 1
	crafting_slot7.quantity -= 1
	crafting_slot8.quantity -= 1
	crafting_slot9.quantity -= 1
	crafting_slot10.quantity -= 1
	crafting_slot11.quantity -= 1
	crafting_slot12.quantity -= 1
	crafting_slot13.quantity -= 1
	crafting_slot14.quantity -= 1
	crafting_slot15.quantity -= 1
	crafting_slot16.quantity -= 1

func matchTextureToItem():
	match item:
		"mushroom 1":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/1.png")
		"mushroom 2":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/2.png")
		"mushroom 3":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/3.png")
		"mushroom 4":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/4.png")
		"mushroom 5":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/5.png")
		"mushroom 6":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/6.png")
		"mushroom 7":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/7.png")
		"mushroom 8":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/8.png")
		"mushroom 9":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/9.png")
		"mushroom 10":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/10.png")
		"mushroom 11":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/11.png")
		"mushroom 12":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/12.png")
		"mushroom 13":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/13.png")
		"mushroom 14":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/14.png")
		"mushroom 15":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/15.png")
		"mushroom 16":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/16.png")
		"mushroom 17":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/17.png")
		"mushroom 18":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/18.png")
		"mushroom 19":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/19.png")
		"mushroom 20":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/20.png")
		"mushroom 21":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/21.png")
		"mushroom 22":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/22.png")
		"mushroom 23":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/23.png")
		"mushroom 24":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/24.png")
		"mushroom 25":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/25.png")
		"mushroom 26":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/26.png")
		"mushroom 27":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/27.png")
		"mushroom 28":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/28.png")
		"mushroom 29":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/29.png")
		"mushroom 30":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/30.png")
		"mushroom 31":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/31.png")
		"mushroom 32":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/32.png")
		"mushroom 33":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/33.png")
		"mushroom 34":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/34.png")
		"mushroom 35":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/35.png")
		"mushroom 36":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/36.png")
		"mushroom 37":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/37.png")
		"mushroom 38":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/38.png")
		"mushroom 39":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/39.png")
		"mushroom 40":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/40.png")
		"mushroom 41":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/41.png")
		"mushroom 42":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/42.png")
		"mushroom 43":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/43.png")
		"mushroom 44":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/44.png")
		"mushroom 45":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/45.png")
		"mushroom 46":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/46.png")
		"mushroom 47":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/47.png")
		"mushroom 48":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/48.png")
		"mushroom 49":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/49.png")
		"mushroom 50":
			icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/50.png")
	
		"red potion":
			icon.texture = preload("res://Potions/Red potion.png")
		"ground rosehip":
			icon.texture = preload("res://Processed ingredients/ground rosehip.png")
		
		
		
		"empty":
			icon.texture = preload("res://UI/graphics/SkillIcons/empty.png")
	
