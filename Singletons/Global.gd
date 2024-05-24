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


onready var torso_armor2 = preload("res://Equipment icons/torso2.png")
onready var torso_armor3 = preload("res://Equipment icons/torso3.png")
onready var torso_armor4 = preload("res://Equipment icons/torso4.png")

onready var staff1 = preload("res://Equipment icons/staves/staff1.png")


onready var shoulder1 = preload("res://Equipment icons/shouleder pads/shoulder plate metal.png")


#_______________________________3D equipable items______________________________
onready var shoulder_scene0: PackedScene = preload("res://Equipment/Shoulder pads/shoulder plate metal.glb")




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

onready var necromant_switch =  preload("res://Classes/Ability Icons/Magic Icons1/41.png")
onready var base_attack_necromant =  preload("res://Classes/Ability Icons/Magic Icons1/1.png")
onready var necro_guard =  preload("res://Classes/Ability Icons/Magic Icons1/14.png")



onready var dominion =  preload("res://Classes/Necromant/Class Icons/Dominion.png")
onready var summon_shadow =  preload("res://Classes/Ability Icons/Magic Icons1/49.png")
onready var tribute =  preload("res://Classes/Necromant/Class Icons/Tribute.png")
onready var servitude =  preload("res://Classes/Necromant/Class Icons/Servitude in Death.png")
onready var sacrifice =  preload("res://Classes/Necromant/Class Icons/Sacrifice.png")
onready var arcane_blast =  preload("res://Classes/Ability Icons/Magic Icons1/5.png")






#base skills
onready var punch =  preload("res://UI/graphics/SkillIcons/fist.png")
onready var guard =  preload("res://UI/graphics/SkillIcons/flee.png")




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
		
		
func drawGlobalThreat(user):
	var entities = get_tree().get_nodes_in_group("Enemy")
	for enemy in entities:
		if enemy.has_method("takeThreat"):
			enemy.takeThreat(rand_range(-15,30),user)

var gravity_force: float = 9.8
func gravity(user):#for seamless climbing first check if is_climbing
	if user.is_in_combat == false:
		if user.is_climbing == false: #this way just walking into a wall starts climbing but only out of combat
			if not user.is_on_floor():
					user.vertical_velocity += Vector3.DOWN * gravity_force * 2 * get_physics_process_delta_time()
			else: 
				user.vertical_velocity = -user.get_floor_normal() * gravity_force / 2.5
	else:#inside of combat situations,to avoid climbing on enemies by mistake, now you have to jump on the enemy first to start climbing
		if not user.is_on_floor():
			user.vertical_velocity += Vector3.DOWN * gravity_force * 2 * get_physics_process_delta_time()
		else: 
			user.vertical_velocity = -user.get_floor_normal() * gravity_force / 2.5
			
var entity_gravity_force = Vector3(0, -9.8, 0)
var velocity = Vector3()
func entityGravity(entity):
	if not entity.is_on_floor():
		velocity += entity_gravity_force
		var movement = velocity 
		entity.move_and_collide(movement)
			
			
func physicsSauce(user):
	user.movement.z = user.horizontal_velocity.z + user.vertical_velocity.z
	user.movement.x = user.horizontal_velocity.x + user.vertical_velocity.x
	user.movement.y = user.vertical_velocity.y
	user.move_and_slide(user.movement, Vector3.UP)
func movement(user):
	physicsSauce(user)
	user.horizontal_velocity = user.horizontal_velocity.linear_interpolate(user.direction.normalized() * user.movement_speed, user.acceleration * get_process_delta_time())







#______________________________________skin colors _____________________________

#Panthera
onready var pant_xy_tigris_alb =  preload("res://player/panthera/Skins/Pantera tigris albino.png")
onready var pant_xy_tigris_clear =  preload("res://player/panthera/Skins/Pantera tigris clear.png")
onready var pant_xy_tigris =  preload("res://player/panthera/Skins/Pantera tigris.png")
onready var pant_xy_leo_red =  preload("res://player/panthera/Skins/Panthera leo ruby.png")
onready var pant_xy_leo =  preload("res://player/panthera/Skins/Panthera leo.png")
onready var pant_xy_leopard =  preload("res://player/panthera/Skins/Panthera leopard.png")
onready var pant_xy_leopard_alb =  preload("res://player/panthera/Skins/Panthera leopard snow.png")
onready var pant_xy_nigris =  preload("res://player/panthera/Skins/Panthera nigris.png")


#Human
onready var hum_xy_white =  preload("res://player/human/mal/Skins/WhatsApp Image 2023-06-04 at 15.45.54.jpeg")
onready var hum_xy_brown =  preload("res://player/human/mal/Skins/Human_xy_2.png")




#_____________________________________Races and Genders_________________________
onready var human_male:PackedScene =  preload("res://player/human/mal/Mesh/HMale.tscn")
onready var human_female:PackedScene =  preload("res://player/human/fem/HumanFemale.tscn")

onready var panthera_male:PackedScene =  preload("res://player/panthera/mal/Panthera.tscn")
onready var panthera_female:PackedScene =  preload("res://player/panthera/fem/PantheraFem.tscn")

onready var sepris:PackedScene =  preload("res://player/Sepris/Sepris.tscn")
onready var bireas:PackedScene =  preload("res://player/Bireas/Bireas.tscn")
onready var saurus:PackedScene =  preload("res://testing this shit/Saurus.tscn")
onready var skeleton:PackedScene =  preload("res://player/skeleton/skeleton.tscn")
onready var kadosiel:PackedScene =  preload("res://player/kadosiel test/Kadosiel.tscn")