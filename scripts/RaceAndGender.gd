extends Spatial

var player 
onready var animation:AnimationPlayer = $AnimationPlayer
onready var animation_tree:AnimationTree = $AnimationTree
onready var left_hand = $Armature/Skeleton/LeftHand/Holder
onready var right_hand = $Armature/Skeleton/RightHand/Holder
onready var right_hip = $Armature/Skeleton/RightHip/holder
onready var left_hip = $Armature/Skeleton/LeftHip/holder
onready var shoulder_r = $Armature/Skeleton/RightShoulder/Holder
onready var shoulder_l = $Armature/Skeleton/LeftShoulder/Holder
onready var sword0: PackedScene = preload("res://player/weapons/sword/sword.tscn")
onready var sword1: PackedScene = preload("res://itemTest.tscn")
onready var sword2: PackedScene = preload("res://itemTest.tscn")
onready var bow: PackedScene = preload("res://Equipment/bows/iron/bow.tscn")


func _ready():	
	player.animation = $AnimationPlayer
	player.anim_tree = $AnimationTree
	$AnimationTree.active = false
	loadPlayerData()
	switchSkin()
	switchArmorTexture()
	switchHair()
	player.colorhair()
	switchFace()
	player.switchShoulder()
	loadAnimations()


func loadAnimations()->void:
	animation.add_animation("combo sword", load("res://player/universal animations/sword animations/combo sword.tres"))
	animation.add_animation("run cycle", load("res://player/universal animations/movement/run cycle.anim"))
	animation.add_animation("climb cycle", load("res://testing this shit/climb cycle.anim"))

#_____________________________________Equipment 3D______________________________
func EquipmentSwitch()->void:
	switchHead()
	switchTorso()
	switchArmorTexture()
	switchBelt()
	switchLegs()
	switchHandL()
	switchHandR()
	switchFeet()
	

onready var legs0 = $Armature/Skeleton/legs0
onready var legs1 = $Armature/Skeleton/legs1
onready var legs2 = $Armature/Skeleton/legs2
func switchHead()->void:
	var head0 = null
	var head1 = null
	match player.head:
		"naked":
			player.applyEffect(player,"helm1", false)
		"garment1":
			player.applyEffect(player,"helm1", true)


func equipArmor(clothing_to_equip,clothing_type_to_delete:String)->void:
	var clothing_to_equip_instance = clothing_to_equip.instance()
	clothing_to_equip_instance.scale = Vector3(1,1,1) # just in case you can't see the clothing, it might have been resized due to how mixamo works change this between 0.01 to 1 or 100 to test 
	for child in $Armature/Skeleton.get_children():
		if child.is_in_group(clothing_type_to_delete):
			child.queue_free() # this will delete all the armors that share the same group, use names like "Legs, Torso,Hands,Feet"
	$Armature/Skeleton.add_child(clothing_to_equip_instance)

func switchTorso()->void:
	match player.species:
		"human":
			match player.sex:
				"xy":
					match player.torso:
							"naked":
								equipArmor(autoload.human_xy_naked_torso_0,"Torso")
								player.applyEffect(player,"garment1", false)
							"tunic0":
								equipArmor(autoload.human_xy_tunic_0,"Torso")
								player.applyEffect(player,"garment1", true)
							"gambeson0":
								equipArmor(autoload.human_xy_gambeson_0,"Torso")
							"chainmail0":
								equipArmor(autoload.human_xy_chainmail_0,"Torso")
							"cuirass0":
								equipArmor(autoload.human_xy_cuirass_0,"Torso")
					match player.legs:
						"naked":
							pass
				"xx":
					match player.torso:
							"naked":
								equipArmor(autoload.human_xx_naked_torso_0,"Torso")
								player.applyEffect(player,"garment1", false)
							"tunic0":
								equipArmor(autoload.human_xx_tunic_0,"Torso")
								player.applyEffect(player,"garment1", true)
							"tunic1":
								equipArmor(autoload.human_xx_tunic_1,"Torso")
							"gambeson0":
								equipArmor(autoload.human_xx_gambeson_0,"Torso")
							"chainmail0":
								equipArmor(autoload.human_xx_chainmail_0,"Torso")
							"cuirass0":
								equipArmor(autoload.human_xx_cuirass_0,"Torso")
					match player.legs:
						"naked":
							equipArmor(autoload.human_xx_legs_0,"Legs")
						"pants0":
							equipArmor(autoload.human_xx_pants_0,"Legs")
						"pants1":
							equipArmor(autoload.human_xx_pants_1,"Legs")
						"gambeson":
							equipArmor(autoload.human_xx_legs_gambeson_0,"Legs")
func switchBelt()->void:
	match player.belt:
		"naked":
			player.applyEffect(player,"belt1", false)
		"belt1":
			player.applyEffect(player,"belt1", true)
func switchLegs()->void:
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





var skin_color = "1"
var armor_color = "white"
# cloth texture 
onready var set0_color_blue =  preload("res://player/Armor colors/beginner armor.png")
onready var set0_color_white =  preload("res://player/Armor colors/beginner armor white.png")


func changeColor(materail_number, new_material, color):
	new_material.albedo_texture = color
	new_material.flags_unshaded = true
	for child in $Armature/Skeleton.get_children():
		if child.is_in_group("Torso"):
			child.set_surface_material(materail_number, new_material)
func switchArmorTexture():
	var new_material = SpatialMaterial.new()
	match armor_color:
		"blue":
			changeColor(0, new_material,set0_color_blue)
		"white":
			changeColor(0, new_material,set0_color_white)
func _on_Button_pressed():
	var current_index = skin_types.find(skin_color)
	var next_index = (current_index + 1) % skin_types.size()# Calculate the index of the next skin type
	skin_color = skin_types[next_index]# Update the skin type
	switchSkin()# Apply the new skin
	savePlayerData()# Save the player data			
			
			
			
			
onready var face = $Armature/Skeleton/face
onready var feet0 = $Armature/Skeleton/feet0
func changeHeadTorsoColor(materail_number, new_material, color):
	new_material.albedo_texture = color
	new_material.flags_unshaded = true
	if current_face_instance != null:
		current_face_instance.set_surface_material(materail_number, new_material)
	if face != null:
		face.set_surface_material(materail_number, new_material)
#	if torso0 !=null:
#		torso0.set_surface_material(materail_number, new_material)
#	if hand_l0 !=null:
#		hand_l0.set_surface_material(materail_number, new_material)
#	if legs0 !=null:
#		legs0.set_surface_material(materail_number, new_material)
#	if feet0 !=null:
#		feet0.set_surface_material(materail_number, new_material)


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

	

func randomizeArmor():
	var jacket_types = ["blue", "white"]
	# Find the index of the current skin type
	var current_index = jacket_types.find(armor_color)
	# Calculate the index of the next skin type
	var next_index = (current_index + 1) % jacket_types.size()
	# Update the skin type
	armor_color = jacket_types[next_index]
	# Apply the new skin
	switchArmorTexture()
	# Save the player data
	savePlayerData()


var save_directory: String 
var save_path: String 
func savePlayerData():
	var data = {
		"skin_color": skin_color,
		"armor_color":armor_color,
		"face_set":face_set,
		"hairstyle": hairstyle,

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
	match player.species:
		"human":
			match player.sex:
				"xx":
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
onready var HXYface1: PackedScene = preload("res://player/human/mal/Mesh/heads/h0.tscn")
var face_set:String = "1"
var current_face_instance: Node = null
func switchFace():
	if current_face_instance:
		current_face_instance.queue_free()
	match player.species:
		"human":
			match player.sex:
				"xx":
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
				"xy":
					match face_set:
						"1":
							instanceFace(HXYface1)
						"2":
							instanceFace(HXYface1)
						"3":
							instanceFace(HXYface1)
						"4":
							instanceFace(HXYface1)
						"5":
							instanceFace(HXYface1)
func instanceFace(face_scene):
	if face_attachment and face_scene:
		var face_instance = face_scene.instance()
		face_attachment.add_child(face_instance)
		current_face_instance = face_instance
var can_move: bool = false
func stopAnimationTree():
	animation_tree.active = false

func stopMovement():
	can_move = false
func startMovement():
	can_move = true 
	print("moving")
func punch():
	var damage_type = "blunt"
	var damage = 10 + player.blunt_dmg 
	var damage_flank = damage + player.flank_dmg
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var aggro_power = damage + 20
	var enemies = player.detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if enemy.has_method("applyEffect"):
					enemy.applyEffect(enemy,"bleeding", true)	
				player.pushEnemyAway(2, enemy,0.25)
				if player.is_on_floor():
					#insert sound effect here
					if randf() <= player.critical_chance:
						if player.isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(critical_damage,aggro_power,player,player.stagger_chance,"acid")
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(critical_flank_damage,aggro_power,player,player.stagger_chance,"toxic")
					else:
						if player.isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,player,player.stagger_chance,"heat")
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(damage_flank,aggro_power,player,player.stagger_chance,"jolt")
onready var sword_area:Area = $Armature/Skeleton/RightHand/Area
onready var sword2_area:Area = $Armature/Skeleton/LeftHand/Area
func slash()->void:
	var damage_type = "slash"
	var damage = 22 + player.slash_dmg 
	var damage_flank = damage + player.flank_dmg
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var aggro_power = damage + 20
	var enemies = sword_area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if enemy.has_method("applyEffect"):
					enemy.applyEffect(enemy,"bleeding", true)	
				player.pushEnemyAway(0.25, enemy,0.25)
				if player.resolve < player.max_resolve:
					player.resolve += 3
				if player.is_on_floor():
					#insert sound effect here
					if randf() <= player.critical_chance:
						if player.isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(critical_damage,aggro_power,player,player.stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(critical_flank_damage,aggro_power,player,player.stagger_chance,damage_type)
					else:
						if player.isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,player,player.stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(damage_flank,aggro_power,player,player.stagger_chance,damage_type)
							
func baseMeleeAtk()->void:
	var damage_type:String = "slash"
	var damage = 10 + player.slash_dmg
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power = damage + 20
	var enemies = sword_area.get_overlapping_bodies()
	var enemies2 = sword2_area.get_overlapping_bodies()
	dealDMG(sword_area.get_overlapping_bodies(),sword2_area.get_overlapping_bodies(),critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)


func dealDMG(enemy_detector1, enemy_detector2,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank):
	for victim in enemy_detector1:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(0.3, victim,0.25)
				if player.resolve < player.max_resolve:
					player.resolve += player.ferocity + 1.25
				if victim.has_method("takeDamage"):
					if player.is_on_floor():
						#insert sound effect here
						if randf() <= player.critical_chance:#critical hit
							if victim.state == autoload.state_list.guard or victim.state == autoload.state_list.guard_walk: #victim is guarding
								if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
							else:#player is guarding
								if player.isFacingSelf(victim,0.30): #check if the victim is looking at me 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks, extra damage
									victim.takeDamage(critical_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
						else: #normal hit
							if victim.state == autoload.state_list.guard or victim.state == autoload.state_list.guard_walk: #victim is guarding
								if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(damage_flank + punishment_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
							else:#victim is not guarding
								if player.isFacingSelf(victim,0.30):#the victim is looking face to face at self 
									victim.takeDamage(damage,aggro_power,player,player.stagger_chance,damage_type)
								else: #appareantly the victim is showing his back or flanks, extra damage
									victim.takeDamage(damage_flank,aggro_power,player,player.stagger_chance,damage_type)
	if player.weapon_type == player.dual_swords:
		if enemy_detector2 != null:
			for victim in enemy_detector2:
				if victim.is_in_group("enemy"):
					if victim != self:
						if victim.state != autoload.state_list.dead:
							player.pushEnemyAway(0.3, victim,0.25)
						if player.resolve < player.max_resolve:
							player.resolve += player.ferocity + 1.25
						if victim.has_method("takeDamage"):
							if player.is_on_floor():
								#insert sound effect here
								if randf() <= player.critical_chance:#critical hit
									if victim.state == autoload.state_list.guard or victim.state == autoload.state_list.guard_walk: #victim is guarding
										if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
											victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
										else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
											victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
									else:#player is guarding
										if player.isFacingSelf(victim,0.30): #check if the victim is looking at me 
											victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
										else: #apparently the victim is showing his back or flanks, extra damage
											victim.takeDamage(critical_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
								else: #normal hit
									if victim.state == autoload.state_list.guard or victim.state == autoload.state_list.guard_walk: #victim is guarding
										if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
											victim.takeDamage(damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
										else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
											victim.takeDamage(damage_flank + punishment_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
									else:#victim is not guarding
										if player.isFacingSelf(victim,0.30):#the victim is looking face to face at self 
											victim.takeDamage(damage,aggro_power,player,player.stagger_chance,damage_type)
										else: #appareantly the victim is showing his back or flanks, extra damage
											victim.takeDamage(damage_flank,aggro_power,player,player.stagger_chance,damage_type)
									
func stab()->void:
	var damage_type = "pierce"
	var damage = 22 + player.pierce_dmg 
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "pierce"
	var aggro_power = damage + 20
	var enemies = player.detector.get_overlapping_bodies()
	dealDMG(enemies,null,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)

var base_damage_overhead_strike = 50
func forcedMovement(speed):
	if !player.is_on_wall():
		player.horizontal_velocity = player.direction * 10
func overheadStrikeCD():
	player.anim_tree.active = false
	player.necromant.overheadStrike()
func overheadStrike()->void:
	fury_strike_combo = 0
	var damage_type:String = "slash"
	var damage = base_damage_overhead_strike + player.slash_dmg
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power = damage + 20
	var enemies = sword_area.get_overlapping_bodies()
	var enemies2 = sword2_area.get_overlapping_bodies()
	dealDMG(enemies,enemies2,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)

var fury_strike_combo: int = 0
func commitToFuryStrikeSkill():
	player.fury_strike_duration = 100
func resetFuryStrikeSkill():
	player.anim_tree.active = false
	player.necromant.furyStrike()
func furyStrike()->void:
	fury_strike_combo += 1
	var damage_type:String = "slash"
	var damage = autoload.base_fury_strike_damage + player.slash_dmg
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power = damage + 20
	var enemies = sword_area.get_overlapping_bodies()
	var enemies2 = sword2_area.get_overlapping_bodies()
	dealDMG(enemies,enemies2,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)



func pomelStrike()->void:
	var damage_type:String = "blunt"
	var damage = 15 + player.blunt_dmg
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 3 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "blunt"
	var aggro_power = damage + 55
	var enemies = sword_area.get_overlapping_bodies()
	resolveCost(25)
	dealDMG(enemies,null,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)


func resolveCost(cost):
	if player.resolve > cost:
		player.resolve -= cost
func resetAllCombos():
	fury_strike_combo = 0

onready var melee_aoe: Area = $MeleeAOE
func cycloneCD():
	player.anim_tree.active = false
	player.necromant.cyclone()
func cyclone()->void:
	var damage_type:String = "slash"
	var damage = autoload.cyclone_damage + player.slash_dmg * player.cyclone_icon.points
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power = damage + 20
	var enemies = melee_aoe.get_overlapping_bodies()
	dealDMG(enemies,null,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)




func counterStrike()->void:
	player.necromant.counterStrike()
func counterStrikeDamage()->void:
	var damage_type:String = "slash"
	var damage = autoload.counter_strike_damge + player.slash_dmg
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type:String = "slash"
	var aggro_power = damage + 25
	var enemies = melee_aoe.get_overlapping_bodies()
	dealDMG(enemies,null,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)


func risingFury()->void:
	melee_aoe.scale = Vector3(5, 5, 5)
	var damage_type:String = "sonic"
	var damage = 5
	var damage_flank = damage + 0
	var critical_damage : float  = 0
	var critical_flank_damage : float  = 0
	var punishment_damage : float = 0
	var punishment_damage_type:String = "sonic"
	var aggro_power = 150
	var enemies = melee_aoe.get_overlapping_bodies()
	for victim in enemies:	
		if victim.is_in_group("enemy") and victim != self:
			if victim.has_method("takeDamage"):
				victim.takeDamage(damage,aggro_power,player,player.stagger_chance,damage_type)
	melee_aoe.scale = Vector3(1, 1, 1)


func shootArrow():
	player.necromant.shootArrow(autoload.quick_shot_damage)
func fullDrawShootArrow():
	player.necromant.shootArrow(autoload.full_draw_damage)


var is_parrying: bool = false

func parry():
	player.resolve -= autoload.counter_strike_cost
	is_parrying = true
	print(str(is_parrying))
func stopParry():
	is_parrying = false

var jump_force : float  = 10
func jumpUp():#called on animation
	player.vertical_velocity = Vector3.UP * jump_force 
func jumpDown():#called on animation
	player.vertical_velocity = Vector3.UP * -jump_force

func stop():
	animation_tree.active = false
