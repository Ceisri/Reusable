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
			match player.torso:
				"naked":
					torso0.visible = true 
					torso1.visible = false
					torso2.visible = false
					torso3.visible = false
					torso4.visible = false
					player.applyEffect(player,"garment1", false)
				"garment1":
					torso0.visible = false
					torso1.visible = true
					torso2.visible = false
					torso3.visible = false
					torso4.visible = false
					player.applyEffect(player,"garment1", true)
				"torso2":
					torso0.visible = false
					torso1.visible = false
					torso2.visible = true
					torso3.visible = false
					torso4.visible = false
				"torso3":
					torso0.visible = false
					torso1.visible = false
					torso2.visible = false
					torso3.visible = true
					torso4.visible = false
				"torso4":
					torso0.visible = false
					torso1.visible = false
					torso2.visible = false
					torso3.visible = false
					torso4.visible = true 
					player.applyEffect(player,"garment1", true)
func switchBelt():
	match player.belt:
		"naked":
			player.applyEffect(player,"belt1", false)
		"belt1":
			player.applyEffect(player,"belt1", true)
func switchLegs():
	var legs0 = $Armature/Skeleton/legs0
	var legs1 = $Armature/Skeleton/legs1
	var legs2 = $Armature/Skeleton/legs2
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
func switchHandL():
	var hand_l0 = null
	var hand_l1 = null
	match player.hand_l:
		"naked":
			player.applyEffect(player,"Lhand1", false)
		"cloth1":
			player.applyEffect(player,"Lhand1", true)
func switchHandR():
	var hand_r0 = null
	var hand_r1 = null
	match player.hand_r:
		"naked":
			player.applyEffect(player,"Rhand1", false)
		"cloth1":
			player.applyEffect(player,"Rhand1", true)

#______________________________Switch Colors____________________________________


onready var torso0 = $Armature/Skeleton/torso0
onready var torso1 = $Armature/Skeleton/torso1
onready var torso2 = $Armature/Skeleton/torso2
onready var torso3 = $Armature/Skeleton/torso3
onready var torso4 = $Armature/Skeleton/torso4

var skin_type = "leo"
# skin textures
onready var m_panthera_habilis_tigris_alb =  preload("res://testing stuff/Pantera tigris albino.png")
onready var m_panthera_habilis_leo =  preload("res://testing stuff/Panthera leo.png")
onready var m_panthera_habilis_ruby =  preload("res://testing stuff/Panthera leo ruby.png")
onready var m_panthera_habilis_snow_leo =  preload("res://testing stuff/Panthera leopard snow.png")
var jacket_type = "white"
# cloth texture 
onready var set0_color_blue =  preload("res://player/Armor colors/beginner armor.png")
onready var set0_color_white =  preload("res://player/Armor colors/beginner armor white.png")


func changeArmorColor(materail_number, new_material, color):
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


func switchArmor():
	var new_material = SpatialMaterial.new()
	match jacket_type:
		"blue":
			changeArmorColor(0, new_material,set0_color_blue)
		"white":
			changeArmorColor(0, new_material,set0_color_white)

func switchSkin():
	var newMaterial = SpatialMaterial.new()
	match skin_type:
		"leo":
			newMaterial.albedo_texture = m_panthera_habilis_leo
			newMaterial.flags_unshaded = true
			
		"ruby":
			newMaterial.albedo_texture = m_panthera_habilis_ruby
			newMaterial.flags_unshaded = true
			
		"snow":
			newMaterial.albedo_texture = m_panthera_habilis_snow_leo
			newMaterial.flags_unshaded = true
			
		"albino tiger":
			newMaterial.albedo_texture = m_panthera_habilis_tigris_alb
			newMaterial.flags_unshaded = true
			
var skin_types = ["leo", "ruby", "snow", "albino tiger"]	
func _on_Button_pressed():
	var current_index = skin_types.find(skin_type)
	# Calculate the index of the next skin type
	var next_index = (current_index + 1) % skin_types.size()
	# Update the skin type
	skin_type = skin_types[next_index]
	# Apply the new skin
	switchSkin()
	# Save the player data
	savePlayerData()
	

func randomizeArmor():
	var jacket_types = ["blue", "white"]
	# Find the index of the current skin type
	var current_index = jacket_types.find(jacket_type)
	# Calculate the index of the next skin type
	var next_index = (current_index + 1) % jacket_types.size()
	# Update the skin type
	jacket_type = jacket_types[next_index]
	# Apply the new skin
	switchArmor()
	# Save the player data
	savePlayerData()


var save_directory: String 
var save_path: String 
func savePlayerData():
	var data = {
		"skin_type": skin_type,
		"jacket_type":jacket_type
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
			if "skin_type" in player_data:
				skin_type = player_data["skin_type"]
			if "jacket_type" in player_data:
				jacket_type = player_data["jacket_type"]



