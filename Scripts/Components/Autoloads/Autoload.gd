extends Node

var world:PackedScene = load("res://Game/World/Map/World.tscn")
var player:PackedScene = load("res://Game/World/Player/Scenes/Player.tscn")
onready var human_male:PackedScene = load("res://Game/World/Player/Models/Sex_Species_Meshes/MaleHuman.tscn")
onready var human_female:PackedScene = load("res://Game/World/Player/Models/Sex_Species_Meshes/FemaleHuman.tscn")
func convertToFeet(cm: float) -> float:
	return cm / 30.48 # 1 foot = 30.48 cm

func _ready():
	shuffle_tips()



var tips:Array = [
	"Collect waifus responsibly; they’re not just for show.",
	"Some attacks deal more damage from the back or the sides.",
	"Ale is great for courage, but not for clear thinking.",
	"If if you have high  charima Expect every maiden you meet to instantly fall for you.",
	"Always check for traps, even on your birthday.",
	"Don't trust a wizard with a clean robe.",
	"Remember, red potions are for health, blue potions are for bravery.",
	"Fire is hot; touching it might make you regret your life choices.",
	"Don't poke the bear; some creatures are best left alone.",
	"if you can't defeat a foe fairly, push them off a cliff",
	"Never polish your armor or bathe; a true love should see past such things.",
	"Friends don't let friends fight dragons alone.",
	"A well-timed dodge is worth a thousand health potions.",
	"Don't feed the trolls, unless you want them to follow you home.",
	"You can drown in water.",
	"A hero’s journey shouldn’t start at the bottom of a bottle.",
	"Not everyone is trustworthy.",
	"Nobody will love you deeply unless you get taller shoes.",
	"Question common sense and dogma.",
	"Remember, potions are just fantasy drugs with fewer side effects.",
	"Complain in the tavern about how all maidens are the same.",
	"Ugly? Just get a better helmet.",
	"Healing herbs: because sometimes magic needs a little help.",
	"Blame everyone else for your problems.",
	"Be skeptical about the masses.",
	"Explore every nook and cranny; hidden treasures await.",
	"Save often; danger lurks around every corner.",
	"Learn your enemy's weaknesses for an advantage in battle.",
	"Stock up on healing items before venturing into unknown territory.",
	"Engage with locals; their stories may reveal hidden secrets.",
	"Live, laugh, lurv.",
	"They say beauty is skin deep, but a good armor set covers a lot.",
	"Don't expect epic loot from every barrel you smash.",
	"Constantly talk about the princess you couldn't save and how perfect she was.",
	"When in danger, when in doubt, run in circles, scream and shout.",
	"Indulge in negative self-talk regularly.",
	"Go do that voodoo that you do so well!",
	"May your chips always be crispy.",
	"Magic mushrooms might give you visions, or just a bad trip.",
	"Skip the health potions; who needs extra calories?",
	"Remember, potions heal wounds, not hangovers.",
	"Why walk when you can run away from your problems?",
	"A balanced diet is a potion in each hand.",
	"Dance like no one's watching, because they're probably not.",
	"When in doubt, blame the lag.",
	"Gamble your life savings, everyone will love you if you  win",
	"Blame every maiden in the realm for not admiring your swordsmanship.",
	"Assume moral superiority because you have bigger muscles.",
	"Never shower or groom yourself; true love should look past that.",
	"A hero without snacks is just a very hungry person.",
	"If the enemy is in range, so are you. Run!",
	"Remember: gravity is a harsh mistress.",
	"Always carry snacks; even heroes get hungry.",
	"Only woo maidens with ancient, clichéd love poems from dusty tomes.",
	"If you think it's a trap, it probably is.",
	"A knife fits their back better than yours",
	"Never trust a treasure chest that smiles back.",
	"You need to impress people that don't even know you exist",
	"Refuse to leave your castle; true love should come seeking you out.",
	"Monsters hate stairs; use them to your advantage.",
	"Remember, the cake is always a lie.",
	"Save your game before doing anything heroic.",
	"The smaller muscles you have,the less valuable you are as a person",
	"Even the mightiest warrior needs a good nap.",
	"A sharp sword is a hero's best friend.",
	"Nobody will love you deeply and sincerely unless you get slightly bigger muscles.",
	"Dragons are just big lizards with trust issues.",
	"If you were just a bit taller, everyone would love you, right?",
	"There are two wolves inside of you, both small bad, take a bath"
]

var species:Array = [
	"Homo Sapiens",
	"Homo Sylvanus",
	"Homo Sanguinus",
	"Homo Nymphaea",
	"Equis Biformis",
	"Harpia Harpyus",
	"Lamia"
]


var sexes:Array = [
	"XX - Female",
	"XY - Male",
	"XXX - Female",
	"XXY - Male",

	"X - Female",
	"X0 - Female",
	"X0/XX - Female",
	"X0/XY - Mosaic",

	"XXY - Male",
	"XXXY - Male",
	"XXXXY - Male",

	"XXYY - Male",

	"XYY - Male",
	"XYYY - Male",
	"XYYYY - Male",
	"XYYYYY - Male",
]


var names_X:Array = [
	"Nicole",
	"Lucy",
	"Jade",
	"Flavia",
	"Calliope",
	"Hesperia",
	"Kallisto",
	"Melantha",
	"Persephone",
	"Rhea",
	"Sapphira",
	"Thalia",
	"Zoe",
	"Clio",
	"Thessalia",
	"Ariadne",
	"Daphne",
	"Electra",
	"Galatea",
	"Hera",
	"Ianthe",
	"Juno",
	"Lydia",
	"Mira",
	"Selene",
	"Xidaidai",
	"Aiko",
	"Yumi",
	"Sakura",
	"Hikari",
	"Mai",
	"Mei",
	"Emi",
	"Haruka",
	"Nari",
	"Yuki",
	"Riko",
	"Mei Ling",
	"Xiao Chen",
	"Lian",
	"Zhen",
	"Jin",
	"Li Hua",
	"Yun",
	"Lan",
	"Xiuying",
	"Chao",
	"Jisoo",
	"Minji",
	"Seulgi",
	"Jiwon",
	"Yuna",
	"Hyeri",
	"Soojin",
	"Jiho",
	"Miyeon",
	"Eunji",
	"Aranya",
	"Nari",
]

var names_Y:Array = [
	"Adonis",
	"Damon",
	"Theo",
	"Evandes",
	"Icarus",
	"Alex",
	"Nestos",
	"Leonidas",
	"Orpheus",
	"Alexis",
	"Phineas",
	"Maximus",
	"Lucian",
	"Percival",
	"Thaddeus",
	"Rhett",
	"Julian",
	"Cyrus",
	"Sebastian",
	"Leandre",
	"Quentin",
	"Jasper",
	"Damien",
	"Alaric",
	"Silas",
	"Ronan",
	"Zane",
	"Xander",
	"Caelum",
	"Orion",
	"Victorian",
	"Rowan",
	"Finn",
	"Jaxon",
	"Ryder",
	"Griffin",
	"Holden",
	"Drake",
	"Jasper",
	"Atticus",
	"Sterling",
	"Ezra",
	"Leo",
	"Knox",
	"Declan",
	"Roman",
	"Silas",
	"Hudson",
	"Everett",
	"Emmett",
	"Reid",
	"Sebastian",
	"Talon"
]


var world_names:Array = [
	"Velika",
	"Eldoria",
	"Mythoria",
	"Drakonis",
	"Sylvaris",
	"Aetheris",
	"Lunaria",
	"Terranova",
	"Nexoria",
	"Arcadia",
	"Galad",
	"Kared",
	"Mered",
	"Tharand",
	"Vored",
	"Zerued",
	"Damed",
	"Fadred",
	"Zadred",
	"Lored",
	"Oberon",
	"Thalassa",
	"Xenon",
	"Avalon",
	"Lyonesse",
	"Zandora",
	"Celestia",
	"Eryndor",
	"Frostheim",
	"Gryphoria",
	"Heliopolis",
	"Illyria",
	"Jotunheim",
	"Kythera",
	"Lyra",
	"Mordavia",
	"Nereida",
	"Ophidia",
	"Pangaea",
	"Quintara",
	"Ares",
	"Gaia",
]


onready var music_volume = 0
onready var general_volume = 0

func changeVolume(value, parent) -> void:
	for child in parent.get_children():
		if child.is_in_group("Music"):
			child.volume_db = value
		for node in child.get_children():
			if node.is_in_group("Music"):
				node.volume_db = value
			for node_child in node.get_children():
				if node_child.is_in_group("Music"):
					node_child.volume_db = value

							
						
						

func changeWorldName(line_edit) -> void:
	if world_names.size() > 0:
		var random_index = randi() % world_names.size()
		var random_name = world_names[random_index]
		line_edit.text = random_name
	else:
		line_edit.text = ""




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
func removeStackableItem(inventory_grid, item_texture, quantity):
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory") or child.is_in_group("Loot"):
			var icon = child.get_node("Icon")
			if icon.texture != null and icon.texture.get_path() == item_texture.get_path():
				if child.quantity > quantity:
					child.quantity -= quantity
					break
				elif child.quantity == quantity:
					child.quantity = 0
					icon.texture = null
					break
				else:
					print("Not enough items to remove")
					break


func addIconToGrid(inventory_grid,item_texture):
		for child in inventory_grid.get_children():
			if child.is_in_group("Inventory") or child.is_in_group("Loot"):
				var icon = child.get_node("Icon")
				if icon.texture == null:
					icon.texture = item_texture
					break
				elif icon.texture.get_path() == item_texture.get_path():
					break
func removeIconFromGrid(inventory_grid):
		for child in inventory_grid.get_children():
			if child.is_in_group("Inventory") or child.is_in_group("Loot"):
				var icon = child.get_node("Icon")
				icon.texture = null



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





var humman_fem_heads = [
	load("res://Game/World/Player/Models/Humans/Female/Heads/Scenes/Head1.tscn"),
	load("res://Game/World/Player/Models/Humans/Female/Heads/Scenes/Head_Nicole.tscn"),
	load("res://Game/World/Player/Models/Humans/Female/Heads/Scenes/Head1.tscn"),
]
