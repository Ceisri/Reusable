extends Node


#food_____________________________________
#fruits
onready var strawberry = preload("res://Food Icons/Fruits/strawberry.png")
onready var raspberry = preload("res://Food Icons/Fruits/raspberries.png")
onready var tomato = preload("res://Food Icons/Vegetables/tomato.png")
#roots 
onready var beetroot = preload("res://Food Icons/Vegetables/beetroot.png")
onready var carrot = preload("res://Food Icons/Vegetables/carrot.png")
onready var potato = preload("res://Food Icons/Vegetables/potato.png")
onready var garlic = preload("res://Food Icons/Vegetables/garlic.png")
onready var onion = preload("res://Food Icons/Vegetables/onion.png")

#grain
onready var corn = preload("res://Food Icons/Vegetables/corn.png")


#greens 
onready var cabbage = preload("res://Food Icons/Vegetables/cabbage.png")
onready var bell_pepper = preload("res://Food Icons/Vegetables/bell pepper.png")
onready var aubergine = preload("res://Food Icons/Vegetables/aubergine.png")



#coocked meals
onready var bread = preload("res://Food Icons/Cooked Meals/Bread/bread.png")





onready var wood_sword =  preload("res://0.png")


onready var rosehip = preload("res://Alchemy ingredients/2.png")


onready var red_potion = preload("res://Potions/Red potion.png")
onready var empty_potion = preload("res://Potions/Empty potion.png")
onready var water = preload("res://Potions/water.png")


onready var hat1 = preload("res://Equipment icons/hat1.png")
onready var pad1 = preload("res://Equipment icons/shoulder1.png")
onready var garment1 = preload("res://Equipment icons/garment1.png")
onready var pants1 = preload("res://Equipment icons/pants1.png")
onready var shoe1 = preload("res://Equipment icons/shoe1.png")
onready var glove1 = preload("res://Equipment icons/glove1.png")
onready var belt1 = preload("res://Equipment icons/belt1.png")


onready var staff1 = preload("res://Equipment icons/staves/staff1.png")


func addNotStackableItem(inventory_grid,item_texture):
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var icon = child.get_node("Icon")
			if icon.texture == null:
				icon.texture = item_texture
				if child.max_quantity == 1: 
					child.quantity = 1
				else:
					child.quantity = +1
				return  # Return after adding the item to one slot
			elif icon.texture.get_path() == item_texture.get_path():
				continue  # Move to the next slot if this one already has a sword
func addStackableItem(inventory_grid,item_texture,quantity):
		for child in inventory_grid.get_children():
			if child.is_in_group("Inventory"):
				var icon = child.get_node("Icon")
				if icon.texture == null:
					icon.texture = item_texture
					child.quantity += quantity
					break
				elif icon.texture.get_path() == item_texture.get_path():
					child.quantity += quantity
					break	

func addFloatingIcon(parent,texture,quantity):
	var pop_up_resource = preload("res://UI/floatingResource.tscn")
	var instance = pop_up_resource.instance()
	instance.get_node("TextureRect").texture = texture
	instance.amount = quantity
	parent.add_child(instance)



#_________________________________Skill icons___________________________________

#necromant
onready var dominion =  preload("res://Classes/Necromant/Class Icons/Dominion.png")
onready var summon_shadow =  preload("res://Classes/Necromant/Class Icons/SummonShadow.png")
onready var tribute =  preload("res://Classes/Necromant/Class Icons/Tribute.png")
onready var servitude =  preload("res://Classes/Necromant/Class Icons/Servitude in Death.png")
onready var sacrifice =  preload("res://Classes/Necromant/Class Icons/Sacrifice.png")
onready var arcane_blast =  preload("res://Classes/Necromant/Class Icons/Arcane Blast.png")
onready var base_attack_necromant =  preload("res://Classes/Necromant/Class Icons/Base Attack Necromant.png")
onready var necromant_switch =  preload("res://Classes/Necromant/Class Icons/Necromant Switch.png")


#base skills
onready var punch =  preload("res://UI/graphics/SkillIcons/fist.png")




func consumeRedPotion(player:KinematicBody, button: TextureButton,inventory_grid: GridContainer, skill_bar: bool, skill_slot: TextureButton):
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture
	if player.kilocalories != null:
		player.kilocalories += 100
	if player.health != null:
		player.health += 100
	if player.water != null:
		player.water += 250
	if player.red_potion_duration != null:
		player.red_potion_duration += 5
	if skill_bar == false:
				button.quantity -= 1
				if inventory_grid != null:
					addStackableItem(inventory_grid, empty_potion, 1)
	else:
		if skill_slot != null:
			skill_slot.displayQuantity()
			skill_slot.quantity -= 1
			if skill_slot.quantity >-1:
				if inventory_grid != null:
					addStackableItem(inventory_grid, empty_potion, 1)
	if player.has_method("applyEffect"):
		player.applyEffect(player, "redpotion", true)
