extends Node



func _ready():
	shuffle_tips()



var tips = [
	"Always check for traps, even on your birthday.",
	"Don't trust a wizard with a clean robe.",
	"Remember, red potions are for health, blue potions are for bravery.",
	"Fire is hot; touching it might make you regret your life choices.",
	"Don't poke the bear; some creatures are best left alone.",
	"Friends don't let friends fight dragons alone.",
	"A well-timed dodge is worth a thousand health potions.",
	"Don't feed the trolls, unless you want them to follow you home.",
	"You can drown in water.",
	"Some attacks deal more damage from the back or the sides.",
	"Not everyone is trustworthy.",
	"Question common sense and dogma.",
	"Be skeptical about the masses.",
	"Explore every nook and cranny; hidden treasures await.",
	"Save often; danger lurks around every corner.",
	"Learn your enemy's weaknesses for an advantage in battle.",
	"Stock up on healing items before venturing into unknown territory.",
	"Engage with locals; their stories may reveal hidden secrets.",
	"Live, laugh, lurv.",
	"When life gives you pants, shit them.",
	"When in danger, when in doubt, run in circles, scream and shout.",
	"Go do that voodoo that you do so well!",
	"May your chips always be crispy.",
	"Dance like no one's watching, because they're probably not.",
	"When in doubt, blame the lag.",
	"A hero without snacks is just a very hungry person.",
	"If the enemy is in range, so are you. Run!",
	"Remember: gravity is a harsh mistress.",
	"Always carry snacks; even heroes get hungry.",
	"If you think it's a trap, it probably is.",
	"A knife fits their back better than yours",
	"Never trust a treasure chest that smiles back.",
	"Monsters hate stairs; use them to your advantage.",
	"Remember, the cake is always a lie.",
	"Save your game before doing anything heroic.",
	"Even the mightiest warrior needs a good nap.",
	"A sharp sword is a hero's best friend."
]
var current_tip_index = 0

func sequenceInfo(label) -> void:
	label.text = tips[current_tip_index]
	current_tip_index = (current_tip_index + 1) % tips.size()

var shuffled_tips = []

func shuffle_tips():
	shuffled_tips = tips.duplicate()
	shuffled_tips.shuffle()

func randomizeInfo(label) -> void:
	if current_tip_index >= shuffled_tips.size():
		shuffle_tips()
		current_tip_index = 0
	label.text = shuffled_tips[current_tip_index]
	current_tip_index += 1
	
var rng = RandomNumberGenerator.new()
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
	skillC,
	skillV,
	skillB,
	none}


enum damage_type {
	slash,#1
	blunt,#2
	pierce,#3
	sonic,#4
	heat,#5
	cold,#6
	jolt,#7
	toxic,#8
	acid,#9
	arcane,#10
	bleed,#11
	radiant,#12
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
onready var drag_preview = preload("res://Game/Scripts/Components/UI/Interfaces/Sprite.tscn")



func drawGlobalThreat(user):
	var entities = get_tree().get_nodes_in_group("Enemy")
	for enemy in entities:
		if enemy.has_method("takeThreat"):
			enemy.takeThreat(rand_range(300,3000),user)

var gravity_force: float = 20
func gravity(user):#for seamless climbing first check if is_climbing
	if user.is_in_combat == false:
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


func roundDecimals(value):
	round(value* 100) / 100

onready var floating_text = preload ("res://Game/Scripts/Components/UI/Floating Text/floatingtext.tscn")




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



func addFloatingIcon(parent, texture, quantity,item_rarity,item_name,player):
	var pop_up_resource = preload("res://Game/Scripts/Components/UI/Floating Text/FloatingRes.tscn")
	var instance = pop_up_resource.instance()
	instance.get_node("TextureRect").texture = texture
	instance.player = player 
	instance.amount = quantity
	parent.add_child(instance)
	instance.get_node("ItemNameLabel").text = item_name

	var rarity_color = getRarityColor(item_rarity)
	instance.get_node("ItemNameLabel").modulate = rarity_color
	instance.get_node("Label").modulate = rarity_color


	
func consumeRedPotion(player:KinematicBody, button: TextureButton,inventory_grid: GridContainer, skill_bar: bool, skill_slot: TextureButton):
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture
	player.stats.health += 500
	if skill_bar == false:
				button.quantity -= 1
				if inventory_grid != null:
					player.getLoot(Items.empty_potion,1,0,"empty potion")
	else:
		if skill_slot != null:
			skill_slot.displayQuantity()
			skill_slot.quantity -= 1
			if skill_slot.quantity >-1:
				if inventory_grid != null:
					player.getLoot(Items.empty_potion,1,0,"empty potion")

#	if player.has_method("applyEffect"):
#		player.applyEffect("redpotion", true)
func getRarityColor(rarity):
	if rarity <= 25:
		return Color(1, 1, 1).linear_interpolate(Color(0, 1, 0), rarity / 25.0)
	elif rarity <= 35:
		return Color(0, 1, 0).linear_interpolate(Color(0, 0, 1), (rarity - 25) / 10.0)
	elif rarity <= 50:
		return Color(0, 0, 1).linear_interpolate(Color(0.5, 0, 0.5), (rarity - 35) / 15.0)
	elif rarity <= 70:
		return Color(0.5, 0, 0.5).linear_interpolate(Color(1, 1, 0), (rarity - 50) / 20.0)
	elif rarity <= 90:
		return Color(1, 1, 0).linear_interpolate(Color(1, 0, 0), (rarity - 70) / 20.0)
	else:
		return Color(1, 0,0)
