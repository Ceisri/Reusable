extends Node

#____________________________________________Perforance_____________________________________________
var entity_tick_rate: float = 0.04
#____________________________________________Enumerators____________________________________________
enum gathering_type{#when hitting dead enemies they drop extra butchery items based on this list
	mammal,
	furless,
	reptilian,
	fish,
	dragon,
	tree,#attacking a tree drops leaves, wood and fruits
	wood,#use this for placed or dead wood which only drops wood
	rock,
	gold_ore,
	mixed_ore,
	iron_ore,
	copper_ore,
	tin_ore,
	aluminum_ore,
	coal,
}

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
	base_attack, #14
	curious,#15 for AI
	engage, # for AI
	orbit,# for AI
	decimate,# for AI
	wander,# for AI
	move_aside,# for AI
	staggered,
	stunned,
	downed,
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

#Gathering icons
onready var steak = preload("res://Gathering Icons/Meat/Steak.png")
onready var ribs = preload("res://Gathering Icons/Meat/ribs.png")




onready var rosehip = preload("res://Alchemy ingredients/2.png")


onready var red_potion = preload("res://Potions/Red potion.png")
var red_potion_description: String =  "+100 kcals +250 grams of water.\nHeals by 100 health instantly then by 10 every second, drinking more potions stacks the duration"
onready var empty_potion = preload("res://Potions/Empty potion.png")
onready var water = preload("res://Potions/water.png")

#_________________________________Skill icons___________________________________


#base attacks
onready var punch = preload("res://Classes/Classless/punch.jpg")
onready var punch2 = preload("res://Classes/Classless/punch2.jpg")
onready var throw_rock = preload("res://Classes/Classless/throw rock.jpg")

onready var stomp = preload("res://Classes/Classless/stomp.jpg")
onready var kick = preload("res://Classes/Classless/kick.jpg")


onready var slide = preload("res://Classes/Classless/slide.jpg")
onready var dash = preload("res://Classes/Classless/dash.jpg")
onready var backstep = preload("res://Classes/Classless/backstep.jpg")



#bow________________________________________________________________________________________________
onready var quick_shot =  preload("res://Classes/Sagitarius/quick_shot.png")
var quick_shot_damage: float = 2.5
onready var full_draw =  preload("res://Classes/Sagitarius/full_draw.png")
var full_draw_damage: float = 5

onready var vanguard_icons: Dictionary = {
	"base_atk": preload("res://Classes/Swordsmen/sword slash.jpg"),
	"base_atk2": preload("res://Classes/Swordsmen/sword slash2.jpg"),
	
	"guard_sword": preload("res://Classes/Swordsmen/parry.jpg"),
	"guard_shield": preload("res://Classes/Swordsmen/block.jpg"),
	
	"cleave":preload("res://Classes/Swordsmen/cleave.png"),
	
	"sunder": preload("res://Classes/Swordsmen/split vertically.jpg"),
	
	"rising_slash": preload("res://Classes/Swordsmen/underhand_slash.png"),
	"heart_trust": preload("res://Classes/Swordsmen/trust.jpg"),
	"taunt": preload("res://Classes/Swordsmen/scream.png"),
	"cyclone": preload("res://Classes/Swordsmen/cyclone.png"),
	"whirlwind": preload("res://Classes/Swordsmen/eviscerate.jpg"),
	"fury_strike": preload("res://Classes/Swordsmen/fury strike.png"),
}



#__________________________________EFFECTS AND RELATED STUFF________________________________________

var bleed_dmg: float = 10

	# Preload textures
var dehydration_texture = preload("res://waterbubbles.png")
var overhydration_texture = preload("res://waterbubbles.png")
var bloated_texture = preload("res://UI/graphics/mushrooms/PNG/background/28.png")
var hungry_texture = preload("res://DebuffIcons/Hungry.png")
var bleeding_texture = preload("res://DebuffIcons/bleed.png")
var stunned_texture = preload("res://DebuffIcons/stunned.png")
var frozen_texture = preload("res://DebuffIcons/frozen.png")
var blinded_texture = preload("res://DebuffIcons/blinded.png")
var terrorized_texture = preload("res://DebuffIcons/terrorized.png")
var scared_texture = preload("res://DebuffIcons/scared.png")
var intimidated_texture = preload("res://DebuffIcons/intimidated.png")
var rooted_texture = preload("res://DebuffIcons/chained.png")
var blockbuffs_texture = preload("res://DebuffIcons/blockbuffs.png")
var block_active_texture = preload("res://DebuffIcons/blockactiveskills.png") 
var block_passive_texture = preload("res://DebuffIcons/blockpassive.png")
var broken_defense_texture = preload("res://DebuffIcons/broken defense.png") 
var bomb_texture = preload("res://DebuffIcons/bomb.png") 
var heal_reduction_texture = preload("res://DebuffIcons/healreduction.png")
var slow_texture = preload("res://DebuffIcons/slow.png")
var burn_texture = preload("res://DebuffIcons/burn.png")
var sleep_texture = preload("res://DebuffIcons/sleep.png")
var weakness_texture = preload("res://DebuffIcons/weakness.png")
var poisoned_texture = preload("res://DebuffIcons/poisoned.png")
var confusion_texture = preload("res://DebuffIcons/confusion.png")
var impaired_texture = preload("res://DebuffIcons/impaired.png")
var lethargy_texture = preload("res://DebuffIcons/Cooldown increased.png")
var red_potion_texture = preload("res://Potions/Red potion.png")
var berserk_texture = preload("res://Classes/Swordsmen/scream.png")


#______________________________________EQUIPMENT SYSTEM_____________________________________________

const sword_beginner_dmg = 2
const sword_beginner_absorb = 1


onready var weapset1_icons : Dictionary = {
	"axe": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/axe.png"),
	"sword": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/Sword/level 0.jpg"),
	"greataxe": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/Greataxe/level 0.jpg"),
	"greatsword":  preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/Greatsword/level 0.jpg"),
	"shield": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/Shield/shield.png"),
	"demo-hammer": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/DemolitionHammer/level 0.jpg"),
	"greatmace": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/Greatmace/level 0.jpg"),
	"warhammer": preload("res://Equipment/EquipmentIcon/WeaponIcons/BeginnerSet/warhammer/warhammer.png"),
}

onready var weapset1_atk_speed: Dictionary = {
	"axe": 0.02,
	"sword": 0.025,
	"greataxe": -0.04,
	"greatsword": 0.15,
	"shield": -0.01,
	"demo-hammer": -0.13,
	"greatmace": -0.04,
	"warhammer":-0.03
}


onready var weapset1_scenes: Dictionary = {
	"sword": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/SwordR.tscn"),
	"swordB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/SwordRB.tscn"),
	"sword_sec": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/SwordL.tscn"),
	"sword_secB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/SwordLB.tscn"),
	
	"axe": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/AxeR.tscn"),
	"axeB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/AxeRB.tscn"),
	"axe_sec": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/AxeL.tscn"),
	"axe_secB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/AxeLB.tscn"),
	"demo_hammer": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/DemolitionHammer.tscn"),
	"demo_hammerB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/DemolitionHammerB.tscn"),
	"greatmace": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/GreatMace.tscn"),
	"greatmaceB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/GreatMaceB.tscn"),
	"warhammer": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/WarHammer.tscn"),
	"warhammerB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/WarHammerB.tscn"),

	"greataxe": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/GreatAxe.tscn"),
	"greataxeB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/GreatAxeB.tscn"),
	"greatsword": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/GreatSword.tscn"),
	"greatswordB": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/GreatSwordB.tscn"),
	"shield": preload("res://Equipment/EquipmentScenes/WeaponScenes/BeginnerSet/ShieldRound.tscn"),

	"null": preload("res://Equipment/EquipmentScenes/WeaponScenes/Null.tscn"),
	"null_sec": preload("res://Equipment/EquipmentScenes/WeaponScenes/NullSec.tscn"),
}







const axe_beginner_dmg = 2.5
const axe_beginner_melee_speed = -0.05
const axe_beginner_absorb = 1



const greataxe_beginner_dmg = 4.5
const greataxe_beginner_melee_speed = -0.15
const greataxe_beginner_absorb = 1


const greatsword_beginner_dmg = 3.5
const greatsword_beginner_melee_speed = -0.05
const greatsword_beginner_absorb = 5


const shield_wood_general_defense = 12 #increase some defenses defenses by  this value, remeber we are using the league's dmg formula so 50 equals 33.333% damage reduction 100 equals 50% damage reduction, 200 equals 66.666% damage reduction
const shield_wood_melee_speed = -0.075
const shield_wood_absorb = 100





const demolition_hammer_beg_dmg = 5
const demolition_hammer_beg_melee_speed = -0.12
const demolition_hammer_beg_absorb = 12
const demolition_hammer_beg_impact = 0.35




const greatmace_beg_dmg = 5
const greatmace_beg_melee_speed = -0.1
const greatmace_beg_absorb = 10
const greatmace_beg_impact = 0.30




const warhammer_beg_dmg =  4.5
const warhammer_beg_melee_speed = -0.05
const warhammer_beg_absorb = 8
const warhammer_beg_impact = 0.28


enum main_weap_list{
	sword_beginner,
	axe_beginner,
	pick_beginner,
	greataxe_beginner,
	greatsword_beginner,
	demolition_hammer_beginner,
	greatmace_beginner,
	warhammer_beginner,
	zero
}





#___________________________________________________________________________________________________

enum sec_weap_list{
	sword_beginner,
	axe_beginner,
	pick_beginner,
	shield_beginner,
	zero
}

enum weapon_type_list {
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


enum boots_list{
	set_0,
	set_1,
	set_2,
}

onready var boots1 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/shoe1.png")




#equipment 2D icons__________________________________________________________________________________________


onready var pants1 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/pants1.png")


onready var glove1 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/glove1.png")


onready var garment1 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/garment1.png")
onready var torso_armor2 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/torso2.png")
onready var torso_armor3 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/torso3.png")
onready var torso_armor4 = preload("res://Equipment/EquipmentIcon/ArmorIcons/BeginnerSet/torso4.png")

#______________________________________3D equipable items___________________________________________


#________________Armor and clothing 3Dscenes to instance as children of skeletons___________________
enum torso_list{
	naked,
	tunic,
	gambeson,
	chainmail,
	gambeson,
	cuirass
}
#stored male armors
onready var human_xy_naked_torso_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XY/Torso/Torso0.tscn")
onready var human_xy_tunic_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XY/Torso/Tunic0.tscn")
#stored female armors
onready var human_xx_naked_torso_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Torso/Torso0.tscn")
onready var human_xx_tunic_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Torso/Tunic0.tscn")
onready var human_xx_tunic_1: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Torso/Tunic1.tscn")

#legs 
onready var human_xx_legs_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Legs/legs0.tscn")
onready var human_xx_pants_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Legs/Pants0.tscn")
onready var human_xx_pants_1: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Legs/Pants1.tscn")

#feet
onready var human_xx_feet_0: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Feet/Naked.tscn")
onready var human_xx_feet_1: PackedScene = preload("res://Equipment/EquipmentScenes/ArmorScenes/Human_XX/Feet/feet1.tscn")



#face editing 
onready var HXXface1: PackedScene =preload("res://player/human/fem/Faces/Face1.tscn")
onready var HXXface2: PackedScene =preload("res://player/human/fem/Faces/Face2.tscn")
onready var HXXface3: PackedScene =preload("res://player/human/fem/Faces/Face3.tscn")
onready var HXXface4: PackedScene =preload("res://player/human/fem/Faces/Face4.tscn")
onready var HXXface5: PackedScene =preload("res://player/human/fem/Faces/Face5.tscn")
onready var HXYface1: PackedScene = preload("res://player/human/mal/Mesh/heads/h0.tscn")


func addNotStackableItem(inventory_grid,item_texture):
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory")or child.is_in_group("Loot"):
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
			if child.is_in_group("Inventory") or child.is_in_group("Loot"):
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
		player.applyEffect("redpotion", true)
		
		
func drawGlobalThreat(user):
	var entities = get_tree().get_nodes_in_group("Enemy")
	for enemy in entities:
		if enemy.has_method("takeThreat"):
			enemy.takeThreat(rand_range(300,3000),user)

var gravity_force: float = 20
func gravity(user):#for seamless climbing first check if is_climbing
	if user.is_in_combat == false:
		if user.is_climbing == false: #this way just walking into a wall starts climbing but only out of combat
			if not user.is_on_floor():
					user.vertical_velocity += Vector3.DOWN * gravity_force  * get_physics_process_delta_time()
			else: 
				user.vertical_velocity = -user.get_floor_normal() * gravity_force / 2.5
	else:#inside of combat situations,to avoid climbing on enemies by mistake, now you have to jump on the enemy first to start climbing
		if not user.is_on_floor():
			user.vertical_velocity += Vector3.DOWN * gravity_force * get_physics_process_delta_time()
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

