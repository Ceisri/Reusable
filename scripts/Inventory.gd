extends Control

onready var player = $"../../.."
onready var inventory_grid = $ScrollContainer/InventoryGrid


func _ready():
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var index_str = child.get_name().split("InventorySlot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "_on_inventory_slot_pressed", [index])

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
			elif icon_texture.get_path() == "res://Potions/Red potion.png":
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
			elif icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		else:
			print("Inventory slot", index, "pressed once")
		last_pressed_index = index
		last_press_time = current_time
