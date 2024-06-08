extends Node

#____________________________________________Perforance_____________________________________________
var entity_tick_rate: float = 0.05
#____________________________________________Enumerators____________________________________________
enum state_list{
	idle,#1
	walk,#2
	run,#3
	sprint,#4
	climb,#5
	vault,#6
	swim,#7
	slide,#8
	fall,#9
	crouch,#10
	jump,#11
	guard,#12
	healing,#13
	base_attack,
	curious,# for AI
	engage, # for AI
	orbit,# for AI
	decimate,# for AI
	wander,# for AI
	staggered,
	dead,
	skill1,
	skill2,
	skill3,
	skill4,
	skill5,
	skill6,
	skill7,
	skill8,
	skill9,
	skill0,
	skillQ,
	skillE,
	skillR,
	skillT,
	skillF,
	skillG,
	skillY,
	skillH,
	skillV,
	skillB}

enum weapon_list {
	fist,
	sword,
	dual_swords,
	bow,
	cross_bow,
	heavy,
	sword_shield,
	spear,
	spear_shield,
	staff,
}
enum tertiary_list{
	shield,
	boomerang,
	empty
}
enum damage_type {
	slash,
	blunt,
	#....
	
}
#________________________________________Icons and their data_______________________________________

onready var drag_preview = preload("res://scripts/Components/Sprite.tscn")
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




onready var rosehip = preload("res://Alchemy ingredients/2.png")


onready var red_potion = preload("res://Potions/Red potion.png")
var red_potion_description: String =  "+100 kcals +250 grams of water.\nHeals by 100 health instantly then by 10 every second, drinking more potions stacks the duration"
onready var empty_potion = preload("res://Potions/Empty potion.png")
onready var water = preload("res://Potions/water.png")

#_________________________________Skill icons___________________________________

#necromant
onready var necromant_switch =  preload("res://Classes/Ability Icons/Magic Icons1/41.png")
onready var base_attack_necromant =  preload("res://Classes/Ability Icons/Magic Icons1/1.png")
onready var necro_guard =  preload("res://Classes/Ability Icons/Magic Icons1/14.png")
onready var dominion =  preload("res://Classes/Necromant/Class Icons/Dominion.png")
onready var summon_shadow =  preload("res://Classes/Necromant/Class Icons/SummonShadow.png")
onready var tribute =  preload("res://Classes/Necromant/Class Icons/Tribute.png")
onready var servitude =  preload("res://Classes/Necromant/Class Icons/Servitude in Death.png")
onready var sacrifice =  preload("res://Classes/Necromant/Class Icons/Sacrifice.png")
onready var arcane_blast =  preload("res://Classes/Ability Icons/Magic Icons1/5.png")


#base attacks
onready var punch = preload("res://UI/graphics/SkillIcons/fist.png")
onready var guard = preload("res://Classes/handcombat/guard.png")
onready var dodge = preload("res://Classes/handcombat/dodge.png")
var dodge_description: String = "Damage type: Blunt\nDouble press Directional keys to displace enemies, evade, or maneuver behind them. Alternatively, drag and drop it onto the skill bar, then use your keyboard to activate."
#sword______________________________________________________________________________________________
onready var slash_sword =  preload("res://Classes/Swordsmen/slash.png")
onready var guard_sword =  preload("res://Classes/Swordsmen/cross parry.png")
onready var block_shield =  preload("res://Classes/Swordsmen/block.png")
#greatsword/heavy
onready var heavy_slash =  preload("res://Classes/Swordsmen/slash_great_sword.png")
onready var cleave =  preload("res://Classes/Swordsmen/cleave.png")
#bow________________________________________________________________________________________________
onready var quick_shot =  preload("res://Classes/Sagitarius/quick_shot.png")
var quick_shot_damage: float = 2.5
onready var full_draw =  preload("res://Classes/Sagitarius/full_draw.png")
var full_draw_damage: float = 5

#sword_skills
onready var overhead_slash =  preload("res://Classes/Swordsmen/overhand slash.png")
var overhead_slash_damage: float = 12.5
var overhead_slash_cost: float = 5
var overhead_slash_description: String = "Damage type: Slash\n+4% compounding extra damage per skill level\n +SLASH DAMAGE + BLUNT DAMAGE\n Strike foes in front of you with a downward stroke"
#___________________________________________________________________________________________________
onready var underhand_slash =  preload("res://Classes/Swordsmen/underhand_slash.png")

onready var heart_trust : Texture = preload("res://Classes/Swordsmen/thrust.png")
onready var taunt : Texture = preload("res://Classes/Swordsmen/scream.png")



#___________________________________________________________________________________________________
onready var rising_slash =  preload("res://Classes/Swordsmen/flury of blows.png")
var rising_slash_damage: float = 3
#___________________________________________________________________________________________________
onready var counter_strike =  preload("res://Classes/Swordsmen/counter strike.png")
var counter_strike_damge:float  = 7.5
var counter_strike_cost:float  = 5
#___________________________________________________________________________________________________
onready var cyclone =  preload("res://Classes/Swordsmen/cyclone.png")
var cyclone_damage: float = 7
var cyclone_cooldown: float = 2
var cyclone_cost: float = 5
var cyclone_motion: float = 2.25
var cyclone_description: String = "Damage type: Slash\n+5% compounding extra damage per skill level                +SLASH DAMAGE                                                               'spin and slash foes around you in an area attack, each foe can be hit up to 3 times"
#___________________________________________________________________________________________________
onready var whirlwind =  preload("res://Classes/Swordsmen/whirlwind.png")
#___________________________________________________________________________________________________
onready var fury_strike =  preload("res://Classes/Swordsmen/fury strike.png")
var base_fury_strike_damage: float = 5
#___________________________________________________________________________________________________
onready var rising_fury =  preload("res://Classes/Swordsmen/scream.png")
var rising_fury_threat: float = 25



#equipment 2D icons__________________________________________________________________________________________
onready var wood_sword =  preload("res://0.png")
onready var heavy_sword0 =  preload("res://Equipment icons/heavy weapons/heav_sword_0.png")
onready var shield0 =  preload("res://Equipment icons/shields/shield.png")
onready var bow0 =  preload("res://Equipment icons/bows/bow.png")


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

#______________________________________3D equipable items___________________________________________
onready var shoulder_scene0: PackedScene = preload("res://Equipment/Shoulder pads/shoulder plate metal.glb")
onready var shield_scene0: PackedScene =  preload("res://player/weapons/shields/test Shield.tscn")
onready var shield_null: PackedScene =  preload("res://player/weapons/shields/inv Shield.tscn")
onready var sword_scene0: PackedScene = preload("res://player/weapons/sword/sword.tscn")
onready var heavy_scene0: PackedScene = preload("res://player/weapons/greatsword/greatsword.tscn")
onready var bow_scene0: PackedScene = preload("res://player/weapons/bows/bow.tscn")
onready var bow_null: PackedScene = preload("res://player/weapons/bows/bow invsible.tscn")
#________________Armor and clothing 3Dscenes to instance as children of skeletons___________________
#stored male armors
onready var human_xy_naked_torso_0: PackedScene = preload("res://Equipment/Armors/Human_XY/Torso/Torso0.tscn")#save the mesh as a scene and make sure the skin property share's the same bone names as the skeleton
onready var human_xy_tunic_0: PackedScene = preload("res://Equipment/Armors/Human_XY/Torso/Tunic0.tscn")
onready var human_xy_gambeson_0: PackedScene = preload("res://Equipment/Armors/Human_XY/Torso/Gambeson0.tscn")
onready var human_xy_chainmail_0: PackedScene = preload("res://Equipment/Armors/Human_XY/Torso/Chainmail0.tscn")
onready var human_xy_cuirass_0: PackedScene = preload("res://Equipment/Armors/Human_XY/Torso/Cuirass0.tscn")
#stored female armors
onready var human_xx_naked_torso_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Torso/Torso0.tscn")
onready var human_xx_tunic_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Torso/Tunic0.tscn")
onready var human_xx_tunic_1: PackedScene = preload("res://Equipment/Armors/Human_XX/Torso/Tunic1.tscn")
onready var human_xx_gambeson_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Torso/Gambeson0.tscn")
onready var human_xx_chainmail_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Torso/Chainmail0.tscn")
onready var human_xx_cuirass_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Torso/Cuirass0.tscn")
#legs 
onready var human_xx_legs_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Legs/legs0.tscn")
onready var human_xx_pants_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Legs/Pants0.tscn")
onready var human_xx_pants_1: PackedScene = preload("res://Equipment/Armors/Human_XX/Legs/Pants1.tscn")
onready var human_xx_legs_gambeson_0: PackedScene = preload("res://Equipment/Armors/Human_XX/Legs/Gambeson0.tscn")




#face editing 
onready var HXXface1: PackedScene =preload("res://player/human/fem/Faces/Face1.tscn")
onready var HXXface2: PackedScene =preload("res://player/human/fem/Faces/Face2.tscn")
onready var HXXface3: PackedScene =preload("res://player/human/fem/Faces/Face3.tscn")
onready var HXXface4: PackedScene =preload("res://player/human/fem/Faces/Face4.tscn")
onready var HXXface5: PackedScene =preload("res://player/human/fem/Faces/Face5.tscn")
onready var HXYface1: PackedScene = preload("res://player/human/mal/Mesh/heads/h0.tscn")


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





func consumeRedPotion(player:KinematicBody, button: TextureButton,inventory_grid: GridContainer, skill_bar: bool, skill_slot: TextureButton):
	player.resolve += 100#remove this
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

var gravity_force: float = 20
func gravity(user):#for seamless climbing first check if is_climbing
	if user.is_in_combat == false:
		if user.is_climbing == false: #this way just walking into a wall starts climbing but only out of combat
			if not user.is_on_floor():
					user.vertical_velocity += Vector3.DOWN * gravity_force * get_physics_process_delta_time()
			else: 
				user.vertical_velocity = -user.get_floor_normal() * gravity_force / 2.5
	else:#inside of combat situations,to avoid climbing on enemies by mistake, now you have to jump on the enemy first to start climbing
		if not user.is_on_floor():
			user.vertical_velocity += Vector3.DOWN * gravity_force  * get_physics_process_delta_time()
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


#eye color _________________________________________________________________________________________

#human female hair _________________________________________________________________________________
onready var HXX_hair1: PackedScene = preload("res://player/human/fem/hairstyles/Tiled/1.tscn")
onready var HXX_hair2: PackedScene = preload("res://player/human/fem/hairstyles/Tiled/2.tscn")
onready var HXX_hair3: PackedScene = preload("res://player/human/fem/hairstyles/Tiled/3.tscn")
onready var HXX_hair4: PackedScene = preload("res://player/human/fem/hairstyles/Tiled/4.tscn")
onready var HXX_hair5: PackedScene = preload("res://player/human/fem/hairstyles/Tiled/5.tscn")

#___________________________________________skin colors ____________________________________________
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
onready var hum_xy_white =  preload("res://player/human/mal/Skins/Untitled34_20240519155227.png")
onready var hum_xy_brown =  preload("res://player/human/mal/Skins/Human_xy_2.png")

#_____________________________________Races and Genders_________________________
onready var human_male:PackedScene =  preload("res://player/human/mal/Mesh/body/human.tscn")
onready var human_female:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")

onready var panthera_male:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")
onready var panthera_female:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")

onready var sepris:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")
onready var bireas:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")
onready var saurus:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")
onready var skeleton:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")
onready var kadosiel:PackedScene =  preload("res://player/human/fem/mesh/body/FemaleHuman2.tscn")

#___________________________________UI and other interface stuff____________________________________
onready var floatingtext_damage = preload("res://UI/floatingtext.tscn")
