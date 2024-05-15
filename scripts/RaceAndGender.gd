extends Spatial

var player 
onready var animation = $AnimationPlayer
onready var left_hand = $Armature/Skeleton/LeftHand
onready var right_hand = $Armature/Skeleton/RightHand
onready var right_hip = $Armature/Skeleton/RightHip
onready var left_hip = $Armature/Skeleton/LeftHip
onready var shoulder_r = $Armature/Skeleton/RightShoulder/Holder
onready var shoulder_l = $Armature/Skeleton/LeftShoulder/Holder
onready var sword0: PackedScene = preload("res://itemTest.tscn")
onready var sword1: PackedScene = preload("res://itemTest.tscn")
onready var sword2: PackedScene = preload("res://itemTest.tscn")
func _ready():
	player.animation = animation
	loadPlayerData()
	switchSkin()
	switchArmor()
	switchHair()
	player.colorhair()
	switchFace()
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
onready var face = $Armature/Skeleton/face
onready var feet0 = $Armature/Skeleton/feet0
func changeHeadTorsoColor(materail_number, new_material, color):

	new_material.albedo_texture = color
	new_material.flags_unshaded = true
	if face != null:
		face.set_surface_material(materail_number, new_material)
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
	match player.sex:
		"xy":
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
		"armor_color":armor_color,
		"face_set":face_set,
		"hairstyle": hairstyle
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
			if "hairstyle" in player_data:
				hairstyle = player_data["hairstyle"]
			if "face_set" in player_data:
				face_set = player_data["face_set"]
#Face blend shapes__________________________________________________________________________________
onready var faceblend = $Armature/Skeleton/face

var Bimaxillaryprotrusion = 0 #done
var BrowProtrusion = 0 #done
var CheekBonesHeight = 0 #done
var CheekSize = 0 #done
var ChinSize = 0 #done
var EarRotation = 0
var EarSize = 0 #done
var EarsPoint = 0 #done
var ElfEars = 0 #done
var EyebrowInner = 0 # done
var EyebrowMiddle = 0 # done
var EyebrowOut = 0 #done
var EyesInnerClose = 0 # done
var EyesMiddleClose = 0 # done
var EyesOuterClose = 0 # done
var EyesRotation = 0 #done
var LipsThickness = 0 # done
var MouthSize = 0 # done
var MouthWidth = 0 #done
var NoseRotation = 0 #done
var NoseSize = 0 #doen
var smile = 0 # done

onready var smile_label = $CharacterEditor/FaceEditor/Smile
onready var eye_rot_label = $CharacterEditor/FaceEditor/EyeRot
onready var eye_inner_close_label = $CharacterEditor/FaceEditor/EyeInnerClose
onready var eye_middle_close_label = $CharacterEditor/FaceEditor/EyeMiddleClose
onready var eye_outer_close_label = $CharacterEditor/FaceEditor/EyeOuterClose
onready var lip_thickness_label = $CharacterEditor/FaceEditor/LipThick
onready var mouth_size_label = $CharacterEditor/FaceEditor/MouthSize
onready var mouth_width_label = $CharacterEditor/FaceEditor/MouthWidth
onready var elf_ears_label = $CharacterEditor/FaceEditor/ElfEars
onready var pointy_ears_label = $CharacterEditor/FaceEditor/Pointyears
onready var eyebrow_out_label = $CharacterEditor/FaceEditor/EyebrowOut
onready var eybrow_mid_label = $CharacterEditor/FaceEditor/EyebrowMid
onready var eybrow_inn_label = $CharacterEditor/FaceEditor/EyebrowInn
onready var cheekbones_label = $CharacterEditor/FaceEditor/Cheekbones
onready var cheek_size_label = $CharacterEditor/FaceEditor/CheekSize
onready var chin_size_label = $CharacterEditor/FaceEditor/ChinSize
onready var nose_size_label = $CharacterEditor/FaceEditor/NoseSize
onready var nose_rotation_label = $CharacterEditor/FaceEditor/NoseRot
onready var brow_label = $CharacterEditor/FaceEditor/BrowProtrusion
onready var teet_prot_label = $CharacterEditor/FaceEditor/TeethProtrusion
onready var ear_size_label = $CharacterEditor/FaceEditor/EarSize
onready var ear_rot_label = $CharacterEditor/FaceEditor/EarRot
func faceBlendShapes():

	eyeRotationBlendShape()
	eyeInnerCloseBlendShape()
	eyeMiddleCloseBlendShape()
	eyeOuterCloseBlendShape()
	lipThichnessBlendShape()
	mouthSizeBlendShape()
	mouthWidthBlendShape()
	elfEarsBlendShape()
	pointyEarsBlendShape()
	eyebrowOutBlendShape()
	eyebrowInnBlendShape()
	eyebrowMidBlendShape()
	cheekBonesBlendShape()
	cheekSizeBlendShape()
	chinSizeBlendShape()
	noseSizeBlendShape()
	noseRotBlendShape()
	browProtBlendShape()
	bimaxillaryprotrusionBlendShape()
	earSizeBlendShape()
	earRotBlendShape()

func eyeRotationBlendShape():
	eye_rot_label.text = str(EyesRotation)
	if Input.is_action_pressed("eyeRotUp"):
		if EyesRotation <1.5:
			EyesRotation += 0.002
			if EyesRotation >1.5: 
				EyesRotation = 1.5
	elif Input.is_action_pressed("eyeRotDown"):
		if EyesRotation >-1.5:
			EyesRotation -= 0.002
			if EyesRotation <-1.5: 
				EyesRotation = -1.5	
func eyeInnerCloseBlendShape():
	eye_inner_close_label.text = str(EyesInnerClose)
	if Input.is_action_pressed("eyeInnerClosePlus"):
		if EyesInnerClose  <1.5:
			EyesInnerClose  += 0.002
			if EyesInnerClose  >1.5: 
				EyesInnerClose  = 1.5
	elif Input.is_action_pressed("eyeInnerCloseMinus"):
		if EyesInnerClose  >-1.5:
			EyesInnerClose  -= 0.002
			if EyesInnerClose  <-1.5: 
				EyesInnerClose  = -1.5
func eyeMiddleCloseBlendShape():
	eye_middle_close_label.text = str(EyesMiddleClose)

	if Input.is_action_pressed("eyeMiddleClosePlus"):
		if EyesMiddleClose  <1.5:
			EyesMiddleClose  += 0.002
			if EyesMiddleClose  >1.5: 
				EyesMiddleClose  = 1.5
	elif Input.is_action_pressed("eyeMiddleCloseMinus"):
		if EyesMiddleClose  >-1.5:
			EyesMiddleClose  -= 0.002
			if EyesMiddleClose  <-1.5: 
				EyesMiddleClose  = -1.5
func eyeOuterCloseBlendShape():
	eye_outer_close_label.text = str(EyesOuterClose)
	face.set("blend_shapes/EyeOuterClose",EyesOuterClose)
	if Input.is_action_pressed("eyeOuterClosePlus"):
		if EyesOuterClose  <1.5:
			EyesOuterClose  += 0.002
			if EyesOuterClose  >1.5: 
				EyesOuterClose  = 1.5
	elif Input.is_action_pressed("eyeOuterCloseMinus"):
		if EyesOuterClose  >-1.5:
			EyesOuterClose  -= 0.002
			if EyesOuterClose  <-1.5: 
				EyesOuterClose  = -1.5
func lipThichnessBlendShape():
	lip_thickness_label.text = str(LipsThickness)
	face.set("blend_shapes/LipsThickness",LipsThickness)

	if Input.is_action_pressed("lipThicknessPlus"):
		if LipsThickness  <2.5:
			LipsThickness  += 0.01
			if LipsThickness  >2.5: 
				LipsThickness  = 2.5
	elif Input.is_action_pressed("lipThicknessMinus"):
		if LipsThickness  >-2.5:
			LipsThickness  -= 0.01
			LipsThickness  = -2.5
func mouthSizeBlendShape():
	mouth_size_label.text = str(MouthSize)
	face.set("blend_shapes/MouthSize",MouthSize)

	if Input.is_action_pressed("mouthSizePlus"):
		if MouthSize  <1.5:
			MouthSize  += 0.01
			if MouthSize  >1.5: 
				MouthSize  = 1.5
	elif Input.is_action_pressed("mouthSizeMinus"):
		if MouthSize >-1.5:
			MouthSize  -= 0.01
			if MouthSize  <-1.5: 
				MouthSize  = -1.5
func mouthWidthBlendShape():
	mouth_width_label.text = str(MouthWidth)
	face.set("blend_shapes/MouthWidth",MouthWidth)

	if Input.is_action_pressed("mouthWidthPlus"):
		if MouthWidth  <1.5:
			MouthWidth  += 0.01
			if MouthWidth  >1.5: 
				MouthWidth  = 1.5
	elif Input.is_action_pressed("mouthWidthMinus"):
		if MouthWidth >-1.5:
			MouthWidth -= 0.01
			if MouthWidth  <-1.5: 
				MouthWidth  = -1.5
func elfEarsBlendShape():
	elf_ears_label.text = str(ElfEars)
	face.set("blend_shapes/ElfEars",ElfEars)

	if Input.is_action_pressed("elfPlus"):
		if ElfEars  <2.5:
			ElfEars  += 0.01
			if ElfEars  >2.5: 
				ElfEars  = 2.5
	elif Input.is_action_pressed("elfMinus"):
		if ElfEars >-0.5:
			ElfEars -= 0.01
			if ElfEars  <-0.5: 
				ElfEars  = -0.5
func pointyEarsBlendShape():
	pointy_ears_label.text = str(EarsPoint)
	face.set("blend_shapes/EarsPoint",EarsPoint)

	if Input.is_action_pressed("pointyEarsPlus"):
		if EarsPoint  <2.5:
			EarsPoint  += 0.01
			if EarsPoint  >2.5: 
				EarsPoint  = 2.5
	elif Input.is_action_pressed("pointyEarsMinus"):
		if EarsPoint >-0.5:
			EarsPoint -= 0.01
			if EarsPoint  <-0.5: 
				EarsPoint  = -0.5
func eyebrowOutBlendShape():
	eyebrow_out_label.text = str(EyebrowOut)
	face.set("blend_shapes/EyebrowOut",EyebrowOut)

	if Input.is_action_pressed("eyebrowOutPlus"):
		if EyebrowOut  <2.5:
			EyebrowOut += 0.025
			if EyebrowOut  >2.5: 
				EyebrowOut  = 2.5
	elif Input.is_action_pressed("eyebrowOutMinus"):
		if EyebrowOut >-1.5:
			EyebrowOut -= 0.025
			if EyebrowOut  <-1.5: 
				EyebrowOut  = -1.5
func eyebrowMidBlendShape():
	eybrow_mid_label.text = str(EyebrowMiddle)
	face.set("blend_shapes/EyebrowMiddle",EyebrowMiddle)

	if Input.is_action_pressed("eyebrowMidPlus"):
		if EyebrowMiddle  <2.5:
			EyebrowMiddle += 0.025
			if EyebrowMiddle  >2.5: 
				EyebrowMiddle  = 2.5
	elif Input.is_action_pressed("eyebrowMidMinus"):
		if EyebrowMiddle >-1.5:
			EyebrowMiddle -= 0.025
			if EyebrowMiddle  <-1.5: 
				EyebrowMiddle  = -1.5
func eyebrowInnBlendShape():
	eybrow_inn_label.text = str(EyebrowInner)
	face.set("blend_shapes/EyebrowInner",EyebrowInner)

	if Input.is_action_pressed("eyebrowInnerPlus"):
		if EyebrowInner  <2.5:
			EyebrowInner += 0.025
			if EyebrowInner  >2.5: 
				EyebrowInner  = 2.5
	elif Input.is_action_pressed("eyebrowInnerMinus"):
		if EyebrowInner >-1.5:
			EyebrowInner -= 0.025
			if EyebrowInner  <-1.5: 
				EyebrowInner  = -1.5
func cheekBonesBlendShape():
	cheekbones_label.text = str(CheekBonesHeight)
	face.set("blend_shapes/CheekBonesHeight",CheekBonesHeight)

	if Input.is_action_pressed("cheekbonesPlus"):
		if CheekBonesHeight  <1.5:
			CheekBonesHeight += 0.025
			if CheekBonesHeight >1.5:
				CheekBonesHeight = 1.5
	elif Input.is_action_pressed("cheekbonesMinus"):
		if CheekBonesHeight >-0.5:
			CheekBonesHeight -= 0.025
			if CheekBonesHeight  <-0.5: 
				CheekBonesHeight  = -0.5
func cheekSizeBlendShape():
	cheek_size_label.text = str(CheekSize)
	face.set("blend_shapes/CheekSize",CheekSize)

	if Input.is_action_pressed("cheekSizePlus"):
		if CheekSize  <1.5:
			CheekSize += 0.025
			if CheekSize >1.5:
				CheekSize = 1.5
	elif Input.is_action_pressed("cheekSizeMinus"):
		if CheekSize >-0.5:
			CheekSize -= 0.025
			if CheekSize <-0.5: 
				CheekSize = -0.5
func chinSizeBlendShape():
	chin_size_label.text = str(ChinSize)
	face.set("blend_shapes/ChinSize",ChinSize)	
	if Input.is_action_pressed("chinSizePlus"):
		if ChinSize <1.5:
			ChinSize += 0.025
			if ChinSize >1.5:
				ChinSize = 1.5
	elif Input.is_action_pressed("chinSizeMinus"):
			ChinSize -= 0.025
			if ChinSize <-0.5: 
				ChinSize = -0.5
func noseSizeBlendShape():
	nose_size_label.text = str(NoseSize)
	face.set("blend_shapes/NoseSize",NoseSize)

	if Input.is_action_pressed("noseSizePlus"):
		if NoseSize <1.5:
			NoseSize += 0.025
			if NoseSize >1.5:
				NoseSize = 1.5
	elif Input.is_action_pressed("noseSizeMinus"):
			NoseSize -= 0.025
			if NoseSize <-0.5: 
				NoseSize = -0.5
func noseRotBlendShape():
	nose_rotation_label.text = str(NoseRotation)
	face.set("blend_shapes/NoseRotation",NoseRotation)

	if Input.is_action_pressed("noseRotPlus"):
			NoseRotation += 0.025
			if NoseRotation >2.5:
				NoseRotation = 2.5
	elif Input.is_action_pressed("noseRotMinus"):
			NoseRotation -= 0.025
			if NoseRotation <-2.5: 
				NoseRotation = -2.5
func browProtBlendShape():
	brow_label.text = str(BrowProtrusion)

	if Input.is_action_pressed("browProtrusionPlus"):
			BrowProtrusion += 0.025
			if BrowProtrusion >2.5:
				BrowProtrusion = 2.5
	elif Input.is_action_pressed("browProtrusionMinus"):
			BrowProtrusion -= 0.025
			if BrowProtrusion <-0: 
				BrowProtrusion = 0
func bimaxillaryprotrusionBlendShape():
	teet_prot_label.text = str(Bimaxillaryprotrusion)

	if Input.is_action_pressed("teethProtrusionPlus"):
			Bimaxillaryprotrusion += 0.025
			if Bimaxillaryprotrusion >2.5:
				Bimaxillaryprotrusion = 2.5
	elif Input.is_action_pressed("teethProtrusionMinus"):
			Bimaxillaryprotrusion -= 0.025
			if Bimaxillaryprotrusion <-2.5: 
				Bimaxillaryprotrusion = -2.5
func earSizeBlendShape():
	ear_size_label.text = str(EarSize)
	face.set("blend_shapes/EarSize",EarSize)
	if Input.is_action_pressed("earSizePlus"):
			EarSize += 0.025
			if EarSize >2.5:
				EarSize = 2.5
	elif Input.is_action_pressed("earSizeMinus"):
			EarSize -= 0.025
			if EarSize <-2.5: 
				EarSize = -2.5
func earRotBlendShape():
	ear_rot_label.text = str(EarRotation)
	face.set("blend_shapes/EarRotation",EarRotation)

	if Input.is_action_pressed("earRotUp"):
			EarRotation += 0.015
			if EarRotation >1:
				EarRotation = 1
	elif Input.is_action_pressed("earRotDown"):
			EarRotation -= 0.015
			if EarRotation <-1: 
				EarRotation = -1
				
				
#Hairstyle editing 
onready var hair_attachment = $Armature/Skeleton/head/Holder
onready var hair0: PackedScene = preload("res://player/human/fem/hairstyles/0.tscn")
onready var hair1: PackedScene = preload("res://player/human/fem/hairstyles/1.tscn")
onready var hair2: PackedScene = preload("res://player/human/fem/hairstyles/2.tscn")
onready var hair3: PackedScene = preload("res://player/human/fem/hairstyles/3.tscn")
onready var hair4: PackedScene =preload("res://player/human/fem/hairstyles/4.tscn")
onready var hair5: PackedScene =preload("res://player/human/fem/hairstyles/5.tscn")
onready var hair7: PackedScene =preload("res://player/human/fem/hairstyles/6.tscn")
onready var hair8: PackedScene = preload("res://player/human/fem/hairstyles/7.tscn")
onready var hair6: PackedScene = preload("res://player/human/fem/hairstyles/8.tscn")
var hair_color: Color = Color(1, 1, 1)  # Default color
var current_hair_instance: Node = null
var hairstyle:String ="2"
var hair_color_change = false
var eyer_color_change = false
var eyel_color_change = false
func switchHair():
	if current_hair_instance:
		current_hair_instance.queue_free() # Remove the current hair instance
	match hairstyle:
		"1":
			instanceHair(hair0)
		"2":
			instanceHair(hair1)
		"3":
			instanceHair(hair2)
		"4":
			instanceHair(hair3)
		"5":
			instanceHair(hair4)
		"6":
			instanceHair(hair5)
		"7":
			instanceHair(hair6)
		"8":
			instanceHair(hair7)
		"9":
			instanceHair(hair0)

func instanceHair(hair_scene):
	if hair_attachment and hair_scene:
		var hair_instance = hair_scene.instance()
		hair_attachment.add_child(hair_instance)
		current_hair_instance = hair_instance

func colorhair():
	if current_hair_instance:
		# Get the original material of the hair instance
		var original_material = current_hair_instance.material_override
		# Check if the original material is not null
		if original_material:
			# Duplicate the original material
			var new_material = original_material.duplicate()
			# Assign the new material to the hair instance
			current_hair_instance.material_override = new_material
			# Set the color property of the new material
			new_material.albedo_color = hair_color

#face editing 
onready var face_attachment = $Armature/Skeleton/head/Holder2
onready var face0: PackedScene = preload("res://player/human/fem/Faces/0.tscn")
onready var face1: PackedScene = preload("res://player/human/fem/Faces/1.tscn")
onready var face2: PackedScene = preload("res://player/human/fem/Faces/2.tscn")
onready var face3: PackedScene = preload("res://player/human/fem/Faces/3.tscn")
onready var face4: PackedScene = preload("res://player/human/fem/Faces/4.tscn")
var face_set:String = "1"
var current_face_instance: Node = null
func switchFace():
	if current_face_instance:
		current_face_instance.queue_free() # Remove the current hair instance
	match face_set:
		"1":
			instanceFace(face0)
		"2":
			instanceFace(face1)
		"3":
			instanceFace(face2)
		"4":
			instanceFace(face3)
		"5":
			instanceFace(face4)
func instanceFace(face_scene):
	if face_attachment and face_scene:
		var face_instance = face_scene.instance()
		face_attachment.add_child(face_instance)
		current_face_instance = face_instance
