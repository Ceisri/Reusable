extends Control

onready var player = $"../../.."
onready var inventory_grid = $ScrollContainer/InventoryGrid


func _ready():
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var index_str = child.get_name().split("InventorySlot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "_on_inventory_slot_pressed", [index])
			child.connect("mouse_entered", self, "_on_inventory_slot_mouse_entered", [index])
			child.connect("mouse_exited", self, "_on_inventory_slot_mouse_exited", [index])

var last_pressed_index: int = -1
var last_press_time: float = 0.0
export var double_press_time: float = 0.4

func _on_inventory_slot_pressed(index):
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture	
	if icon_texture != null:
		if  icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		var current_time = OS.get_ticks_msec() / 1000.0
		if last_pressed_index == index and current_time - last_press_time <= double_press_time:
			print("Inventory slot", index, "pressed twice")

			if icon_texture.get_path() == "res://UI/graphics/mushrooms/PNG/background/1.png":
					player.kilocalories += 22
					player.water += 92
					button.quantity -=1
			elif button.item == "red potion":
					player.kilocalories += 100
					player.water += 250
					player.applyEffect(player,"redpotion",true)
					player.red_potion_duration += 5
					print(player.red_potion_duration)
					button.quantity -=1
					for child in inventory_grid.get_children():
						if child.is_in_group("Inventory"):
							var icon = child.get_node("Icon")
							if icon.texture == null:
								icon.texture = preload("res://Potions/Empty potion.png")
								child.quantity += 1
								break
							elif icon.texture.get_path() == "res://Potions/Empty potion.png":
								child.quantity += 1
								break
			elif button.item == "strawberry":
					player.kilocalories +=1
					player.health += 5
					player.water += 2
					button.quantity -=1
			elif button.item == "raspberry":
					player.kilocalories += 4
					player.health += 3
					player.water += 3
					button.quantity -=1
			elif button.item == "beetroot":
					player.kilocalories += 32
					player.health += 15
					player.water += 71.8
					button.quantity -=1
					
					
			elif icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		else:
			print("Inventory slot", index, "pressed once")
		last_pressed_index = index
		last_press_time = current_time



onready var gui = $".."
func _on_inventory_slot_mouse_entered(index):
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://tooltip.tscn").instance()
	if icon_texture != null:
		if button.item == "red potion":
			callToolTip(instance, "Red Potion", "+100 kcals +250 grams of water.\nHeals by 100 health instantly then by 10 every second, drinking more potions stacks the duration")
		elif button.item == "strawberry":
			callToolTip(instance,"Strawberry","+5 health points +9 kcals +24 grams of water")
		elif button.item == "raspberry":
			callToolTip(instance,"Raspberry","+3 health points +1 kcals +2 grams of water")
		elif button.item == "beetroot":
			callToolTip(instance,"beetroot","+15 health points +32 kcals +71.8 grams of water")
			
			
func _on_inventory_slot_mouse_exited(index):
	for child in gui.get_children():
		if child.is_in_group("Tooltip"):
			child.queue_free()

func callToolTip(instance,title, text):
		gui.add_child(instance)
		instance.showTooltip(title, text)
