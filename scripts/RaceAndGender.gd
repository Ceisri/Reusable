extends Spatial

var player 
onready var animation = $AnimationPlayer

func _ready():
	player.animation = animation
	loadPlayerData()
	switchSkin()
	switchArmor()

#_____________________________________Equipment 3D______________________________

func EquipmentSwitch():
	switchHead()
	switchTorso()
	switchBelt()
	switchLegs()
	switchHandL()
	switchHandR()
	switchFeet()
	
onready var legs0 = $Armature/Skeleton/legs0
onready var legs1 = $Armature/Skeleton/legs1
onready var legs2 = $Armature/Skeleton/legs2	
func switchHead():
	var head0 = null
	var head1 = null
	match player.head:
		"naked":
			player.applyEffect(player,"helm1", false)
		"garment1":
			player.applyEffect(player,"helm1", true)
func switchTorso():
	var torso0 = $Armature/Skeleton/torso0
	var torso1 = $Armature/Skeleton/torso1
	var torso2 = $Armature/Skeleton/torso2
	var torso3 = $Armature/Skeleton/torso3
	var torso4 = $Armature/Skeleton/torso4
	if torso0 != null:
		if torso1 != null:
			if torso2 !=null:
				match player.torso:
					"naked":
						torso0.show()
						torso1.hide()
						torso2.hide()
						torso3.hide()
						torso4.hide()
						player.applyEffect(player,"garment1", false)
					"garment1":
						torso0.hide()
						torso1.show()
						torso2.hide()
						torso3.hide()
						torso4.hide()
						player.applyEffect(player,"garment1", true)
					"torso2":
						torso0.hide()
						torso1.hide()
						torso2.show()
						torso3.hide()
						torso4.hide()
					"torso3":
						torso0.hide()
						torso1.hide()
						torso2.hide()
						torso3.show()
						torso4.hide()
					"torso4":
						torso0.hide()
						torso1.hide()
						torso2.hide()
						torso3.hide()
						torso4.show()
						player.applyEffect(player,"garment1", true)
func switchBelt():
	match player.belt:
		"naked":
			player.applyEffect(player,"belt1", false)
		"belt1":
			player.applyEffect(player,"belt1", true)
func switchLegs():
	if legs0 != null:
		if legs1 != null:
			match player.legs:
				"naked":
					legs0.visible = true 
					legs1.visible = false
					legs2.visible = false
					player.applyEffect(player,"pants1", false)
				"cloth1":
					legs0.visible = false
					legs1.visible = true
					legs2.visible = false
					player.applyEffect(player,"pants1", true)
				"cloth2":
					legs0.visible = false
					legs1.visible = false
					legs2.visible = true
					player.applyEffect(player,"pants1", true)
onready var hand_l0 = $Armature/Skeleton/hands0
onready var hand_l1 = $Armature/Skeleton/hands1
func switchHandL():
	if hand_l0 != null and hand_l1 != null:
			match player.hand_l:
				"naked":
					player.applyEffect(player,"Lhand1", false)
					hand_l0.show()
					hand_l1.hide()
				"cloth1":
					player.applyEffect(player,"Lhand1", true)
					hand_l0.hide()
					hand_l1.show()
func switchHandR():
	var hand_r0 = null
	var hand_r1 = null
	match player.hand_r:
		"naked":
			player.applyEffect(player,"Rhand1", false)
		"cloth1":
			player.applyEffect(player,"Rhand1", true)
func switchFeet():
	var feet0 = $Armature/Skeleton/feet0
	var feet1 = $Armature/Skeleton/feet1
	var feet2 = $Armature/Skeleton/feet2
	if feet0 != null and feet1 != null:
		match player.foot_r:
			"naked":
				player.applyEffect(player,"Rshoe1", false)
				feet0.show()
				feet1.hide()
				feet2.hide()
			"cloth1":
				player.applyEffect(player,"Rshoe1", true)
				feet0.hide()
				feet1.show()
				feet2.hide()
#______________________________Switch Colors____________________________________


onready var torso0 = $Armature/Skeleton/torso0
onready var torso1 = $Armature/Skeleton/torso1
onready var torso2 = $Armature/Skeleton/torso2
onready var torso3 = $Armature/Skeleton/torso3
onready var torso4 = $Armature/Skeleton/torso4


var skin_color = "1"
var armor_color = "white"
# cloth texture 
onready var set0_color_blue =  preload("res://player/Armor colors/beginner armor.png")
onready var set0_color_white =  preload("res://player/Armor colors/beginner armor white.png")


func changeColor(materail_number, new_material, color):
	new_material.albedo_texture = color
	new_material.flags_unshaded = true
	if torso1 != null:
		torso1.set_surface_material(materail_number, new_material)
	if torso2 != null:
		torso2.set_surface_material(materail_number, new_material)
	if torso3 != null:
		torso3.set_surface_material(materail_number, new_material)
	if torso4 != null:
		torso4.set_surface_material(materail_number, new_material)
#hands
	if hand_l1 !=null:
		hand_l1.set_surface_material(materail_number, new_material)
onready var head = $Armature/Skeleton/head
onready var feet0 = $Armature/Skeleton/feet0
func changeHeadTorsoColor(materail_number, new_material, color):
	new_material.albedo_texture = color
	new_material.flags_unshaded = true
	if head != null:
		head.set_surface_material(materail_number, new_material)
	if torso0 !=null:
		torso0.set_surface_material(materail_number, new_material)
	if hand_l0 !=null:
		hand_l0.set_surface_material(materail_number, new_material)
	if legs0 !=null:
		legs0.set_surface_material(materail_number, new_material)
	if feet0 !=null:
		feet0.set_surface_material(materail_number, new_material)
func switchArmor():
	var new_material = SpatialMaterial.new()
	match armor_color:
		"blue":
			changeColor(0, new_material,set0_color_blue)
		"white":
			changeColor(0, new_material,set0_color_white)

func switchSkin():
	
	var new_material = SpatialMaterial.new()
	match player.species:
		"panthera":
			match skin_color:
				"1":
					changeColor(1, new_material,autoload.pant_xy_tigris_alb)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_tigris_alb)
				"2":
					changeColor(1, new_material,autoload.pant_xy_tigris_clear)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_tigris_clear)
				"3":
					changeColor(1, new_material,autoload.pant_xy_tigris)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_tigris)
				"4":
					changeColor(1, new_material,autoload.pant_xy_leo_red)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_leo_red)
				"5":
					changeColor(1, new_material,autoload.pant_xy_leo)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_leo)
				"6":
					changeColor(1, new_material,autoload.pant_xy_leopard_alb)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_leopard_alb)
				"7":
					changeColor(1, new_material,autoload.pant_xy_nigris)
					changeHeadTorsoColor(0, new_material,autoload.pant_xy_nigris)
		"human":
			match skin_color:
				"1":
					changeColor(1, new_material,autoload.hum_xy_white)
					changeHeadTorsoColor(0, new_material,autoload.hum_xy_white)
				"2":
					changeColor(1, new_material,autoload.hum_xy_brown)
					changeHeadTorsoColor(0, new_material,autoload.hum_xy_brown)
					
var skin_types = ["1","2","3","4","5","6","7"]	
func _on_Button_pressed():
	var current_index = skin_types.find(skin_color)
	var next_index = (current_index + 1) % skin_types.size()# Calculate the index of the next skin type
	skin_color = skin_types[next_index]# Update the skin type
	switchSkin()# Apply the new skin
	savePlayerData()# Save the player data
	

func randomizeArmor():
	var jacket_types = ["blue", "white"]
	# Find the index of the current skin type
	var current_index = jacket_types.find(armor_color)
	# Calculate the index of the next skin type
	var next_index = (current_index + 1) % jacket_types.size()
	# Update the skin type
	armor_color = jacket_types[next_index]
	# Apply the new skin
	switchArmor()
	# Save the player data
	savePlayerData()


var save_directory: String 
var save_path: String 
func savePlayerData():
	var data = {
		"skin_color": skin_color,
		"armor_color":armor_color
		}
	var dir = Directory.new()
	if !dir.dir_exists(save_directory):
		dir.make_dir_recursive(save_directory)
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "P@paB3ar6969")
	if error == OK:
		file.store_var(data)
		file.close()
		
func loadPlayerData():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, "P@paB3ar6969")
		if error == OK:
			var player_data = file.get_var()
			file.close()
			if "skin_color" in player_data:
				skin_color = player_data["skin_color"]
			if "armor_color" in player_data:
				armor_color = player_data["armor_color"]



