extends Spatial

var player 
onready var animation:AnimationPlayer = $AnimationPlayer
#onready var animation_tree:AnimationTree = $AnimationTree
onready var left_hand = $Armature/Skeleton/LeftHand/Holder
onready var right_hand = $Armature/Skeleton/RightHand/Holder
onready var right_hip = $Armature/Skeleton/RightHip/holder
onready var left_hip = $Armature/Skeleton/LeftHip/holder
onready var left_eye = $Armature/Skeleton/IrisL
onready var right_eye = $Armature/Skeleton/IrisR

func _ready():
	$Armature/Skeleton/RightHand/Holder/Weapon.queue_free()#testing sword, delete it on game start
	$Armature/Skeleton/LeftHand/Holder/sword.queue_free()#testing sword, delete it on game start
	player.animation = $AnimationPlayer
	loadPlayerData()
	switchSkin()
	switchArmorTexture()
	player.colorBodyParts()
	loadAnimations()
	applyBlendShapes()

func loadAnimations()->void:
	animation.add_animation("dead", load("res://player/universal animations/Animations Idle General/dead.anim"))
	animation.add_animation("idle", load("res://player/universal animations/Animations Idle General/idle.anim"))
	animation.add_animation("staggered", load("res://player/universal animations/Animations Idle General/staggeredPlayer.anim"))
	animation.add_animation("jump", load("res://player/universal animations/Animations Movement General/jump.anim"))
	animation.add_animation("jump run", load("res://player/universal animations/Animations Movement General/jump run.anim"))
	animation.add_animation("fall", load("res://player/universal animations/Animations Movement General/fall.anim"))
	animation.add_animation("idle fist", load("res://player/universal animations/Animations Fist/idle fist.anim"))
	animation.add_animation("idle bow", load("res://player/universal animations/Animations Bow/idle  bow.anim"))#placeholder
	animation.add_animation("idle sword", load("res://player/universal animations/dump2/idle sword.anim"))
	animation.add_animation("idle shield", load("res://player/universal animations/dump2/idle sword.anim"))
	animation.add_animation("idle heavy", load("res://player/universal animations/Animations Sword Heavy/idle heavy.anim"))
	animation.add_animation("downed idle", load("res://player/universal animations/Animations Idle General/downed idle.anim"))
	
	
	animation.add_animation("slide", load("res://player/universal animations/Animations Movement General/slide.anim"))
	
	
	animation.add_animation("walk", load("res://player/universal animations/Animations Movement General/walk.tres"))
	animation.add_animation("walk bow", load("res://player/universal animations/Animations Bow/walk bow.anim"))
	animation.add_animation("walk sword", load("res://player/universal animations/Animations Sword Light/walk sword.anim"))#placeholder
	animation.add_animation("walk heavy", load("res://player/universal animations/Animations Sword Heavy/walk heavy.anim"))
	animation.add_animation("walk shield", load("res://player/universal animations/Animations Shield/walk shield.anim"))
	animation.add_animation("downed walk", load("res://player/universal animations/Animations Movement General/downed walk.anim"))
	
	
	animation.add_animation("run", load("res://player/universal animations/Animations Movement General/run cycle.anim"))
	animation.add_animation("climb cycle", load("res://player/universal animations/Animations Movement General/climb cycle.anim"))
	
	#L-click animations
	animation.add_animation("combo fist", load("res://player/universal animations/Animations Fist/combo fist.tres"))
	animation.add_animation("shoot", load("res://player/universal animations/Animations Bow/shoot.anim"))
	animation.add_animation("combo sword", load("res://player/universal animations/Animations Sword Light/combo sword.anim"))
	animation.add_animation("combo shield", load("res://player/universal animations/Animations Shield/combo shield.anim"))
	animation.add_animation("combo dual swords", load("res://player/universal animations/Animations Sword Dual Wield/combo dual swords.anim"))
	animation.add_animation("combo heavy", load("res://player/universal animations/Animations Sword Heavy/combo heavy.anim"))
	
	#R-click animations
	animation.add_animation("full draw", load("res://player/universal animations/Animations Bow/full draw.anim"))
	#animation.add_animation("parry", load("res://player/universal animations/sword animations/parry.anim"))
	animation.add_animation("shield block", load("res://player/universal animations/Animations Shield/shield block.anim"))
	animation.add_animation("cleave", load("res://player/universal animations/Animations Sword Heavy/cleave.anim"))
	
#	animation.add_animation("", load())
	animation.add_animation("whirlwind sword", load("res://player/universal animations/Animations Sword Light/whirlwind sword.anim"))
	animation.add_animation("whirlwind heavy", load("res://player/universal animations/Animations Sword Heavy/whirlwind heavy.anim"))
	
	animation.add_animation("cyclone sword", load("res://player/universal animations/Animations Sword Light/cyclone  sword.anim"))#placeholder
	animation.add_animation("cyclone heavy", load("res://player/universal animations/Animations Sword Heavy/cyclone heavy.anim"))
	
	animation.add_animation("overhead slash sword", load("res://player/universal animations/Animations Sword Light/overhead slash.anim"))
	animation.add_animation("overhead slash heavy", load("res://player/universal animations/Animations Sword Light/overhead slash.anim"))
	
	animation.add_animation("rising slash shield", load("res://player/universal animations/Animations Shield/rising slash shield.anim"))
	animation.add_animation("rising slash heavy", load("res://player/universal animations/Animations Sword Heavy/rising slash heavy.anim"))
	
	animation.add_animation("heart trust sword", load("res://player/universal animations/Animations Sword Light/heart trust sword.anim"))
	
	animation.add_animation("taunt", load("res://player/universal animations/Animations Sword Light/taunt.anim"))
	animation.add_animation("taunt heavy", load("res://player/universal animations/Animations Sword Heavy/taunt heavy.anim"))

#_____________________________________Equipment 3D______________________________
func EquipmentSwitch()->void:
	switchEquipment()
	switchArmorTexture()

onready var skeleton: Skeleton = $Armature/Skeleton
func equipArmor(clothing_to_equip,clothing_type_to_delete:String)->void:
	var clothing_to_equip_instance = clothing_to_equip.instance()
	clothing_to_equip_instance.scale = Vector3(1,1,1) # just in case you can't see the clothing, it might have been resized due to how mixamo works change this between 0.01 to 1 or 100 to test 
	for child in skeleton.get_children():
		if child.is_in_group(clothing_type_to_delete):
			child.queue_free() # this will delete all the armors that share the same group, use names like "Legs, Torso,Hands,Feet"
		if child.is_in_group("hair"):
			hair = child
			player.colorBodyParts()
	skeleton.add_child(clothing_to_equip_instance)
	
onready var hair:MeshInstance
func switchEquipment()->void:
	match player.species:
		"human":
			match player.sex:
				"xy":
					match player.torso:
							"naked":
								equipArmor(autoload.human_xy_naked_torso_0,"Torso")
							"tunic0":
								equipArmor(autoload.human_xy_tunic_0,"Torso")
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
					match face_set:
						"1":
							equipArmor(autoload.HXXface1,"face")
						"2":
							equipArmor(autoload.HXXface2,"face")
						"3":
							equipArmor(autoload.HXXface3,"face")
						"4":
							equipArmor(autoload.HXXface4,"face")
						"5":
							equipArmor(autoload.HXXface5,"face")
					match player.torso:
							"naked":
								equipArmor(autoload.human_xx_naked_torso_0,"Torso")
							"tunic0":
								equipArmor(autoload.human_xx_tunic_0,"Torso")
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
					match player.tertiary_weapon:
						"null":
							equipArmor(autoload.shield_null,"shield")
						"shield0":
							equipArmor(autoload.shield_scene0,"shield")
					match player.hairstyle:
						"1":
							equipArmor(autoload.HXX_hair1,"hair")
						"2":
							equipArmor(autoload.HXX_hair2,"hair")
						"3":
							equipArmor(autoload.HXX_hair3,"hair")
						"4":
							equipArmor(autoload.HXX_hair4,"hair")
						"5":
							equipArmor(autoload.HXX_hair5,"hair")

var face_set:String = "1"
#______________________________Switch Colors____________________________________

var skin_color = "1"
var armor_color = "white"
# cloth texture 
onready var set0_color_blue =  preload("res://player/Armor colors/beginner armor.png")
onready var set0_color_white =  preload("res://player/Armor colors/beginner armor white.png")


func changeColor(materail_number, new_material, color):
	new_material.albedo_texture = color
	new_material.flags_unshaded = true
	for child in skeleton.get_children():
		if child.is_in_group("Torso"):
			child.set_surface_material(materail_number, new_material)
func switchArmorTexture():
	var new_material = SpatialMaterial.new()
	match armor_color:
		"blue":
			if player.torso != "naked":
				changeColor(0, new_material,set0_color_blue)
		"white":
			if player.torso != "naked":
				changeColor(0, new_material,set0_color_white)
func _on_Button_pressed():
	var current_index = skin_types.find(skin_color)
	var next_index = (current_index + 1) % skin_types.size()# Calculate the index of the next skin type
	skin_color = skin_types[next_index]# Update the skin type
	switchSkin()# Apply the new skin
	savePlayerData()# Save the player data			
			
			
			
func changeHeadTorsoColor(materail_number, new_material, color):
	pass
#	new_material.albedo_texture = color
#	new_material.flags_unshaded = true
#	current_face_instance.set_surface_material(materail_number, new_material)
#		face.set_surface_material(materail_number, new_material)
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
func savePlayerData()-> void:
	var data = {
		"skin_color": skin_color,
		"armor_color":armor_color,
		"face_set":face_set,
		"smile": smile
		}
	var dir = Directory.new()
	if !dir.dir_exists(save_directory):
		dir.make_dir_recursive(save_directory)
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "P@paB3ar6969")
	if error == OK:
		file.store_var(data)
		file.close()
		
func loadPlayerData()-> void:
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
			if "face_set" in player_data:
				face_set = player_data["face_set"]
			if "smile" in player_data:
				smile = player_data["smile"]
#Face blend shapes__________________________________________________________________________________

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

func  applyBlendShapes():
	for child in $Armature/Skeleton.get_children():
		if child.is_in_group("face"):
			child.set("blend_shapes/Smile",smile)
			
			

#___________________________________________Combat System___________________________________________

var stagger_chance: float 
func slideDMG()->void:#fist
	var aggro_power:float = player.threat_power + 1
	var push_distance:float = 0.5
	var enemies:Array = trust_area.get_overlapping_bodies()

	slideImpact(enemies,aggro_power,push_distance)

func punch()->void:#fist
	var damage_type:String = "blunt"
	var damage:float = player.strength + ((player.agility + player.dexterity + player.ferocity)*0.5)
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "blunt"
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = trust_area.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)
#Melee Functions to call in the AnimationPlayer
#Heavy sword

onready var area_melee_front:Area = $MeleeFront
func ComboHeavy1()->void:#Heavy
	var damage_type:String = right_hand.get_child(0).damage_type
	var damage:float = 5 * player.agility
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)
func ComboHeavy2()->void:#Heavy
	var damage_type:String = right_hand.get_child(0).damage_type
	var damage:float = 8 
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.15 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)
func ComboHeavy3()->void:#Heavy
	var damage_type:String = right_hand.get_child(0).damage_type
	var damage:float = 5 
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.05 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)
func ComboHeavy4()->void:#Heavy
	player.all_skills.activateComboCyclone()
	var damage_type:String = right_hand.get_child(0).damage_type
	var damage:float = 5 
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power
	var push_distance:float = 1 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)
func ComboLight():
	var damage_type:String = right_hand.get_child(0).damage_type
	var damage:float =2 
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)







#Cleave
func cleaveDMG()->void:#Heavy
	var damage_type:String = right_hand.get_child(0).damage_type
	var damage:float = 3 
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power + 15
	var push_distance:float = 0.35 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)


#Overhead Slash section
#This skill is viable for all melee weapon types EXCEPT FIST WEAPONS
func overhandSlashCD()-> void:
	player.overhead_slash_duration = false
	player.overhead_slash_combo = false
	player.all_skills.overheadSlashCD()
func overhandSlashDMG()->void:
	var damage_type:String = "slash"
	var base_damage: float = player.all_skills.overhead_slash_damage
	var points: int = player.overhead_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * player.all_skills.overhead_slash_dmg_proportion
	var damage: float = base_damage * damage_multiplier
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power = damage + 20
	var push_distance:float = 0.25 * player.total_impact
	var enemies = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,100)


#rising slash section
#This skill is viable for all melee weapon types EXCEPT FIST WEAPONS
func risingSlashCD()-> void:
	player.all_skills.risingSlashCD()
	player.rising_slash_duration = false
func risingSlashDMG()-> void:
	var damage_type:String = right_hand.get_child(0).damage_type
	var base_damage:float = player.all_skills.rising_slash_damage 
	var points: int = player.rising_icon.points
	var damage_multiplier: float = 1.0
	var total_damage: float
	if points > 1:
			damage_multiplier += (points - 1) * player.all_skills.rising_slash_dmg_proportion
	var damage = base_damage * damage_multiplier	
	var damage_flank: float = damage + player.flank_dmg 
	var critical_damage: float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power
	var push_distance:float = 1 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,1)

#Cyclone section
#This skill is viable for all melee weapon types EXCEPT FIST WEAPONS
onready var melee_aoe: Area = $MeleeAOE
func cycloneCD()-> void:
	player.all_skills.cycloneCD()
	player.cyclone_duration = false
	player.cyclone_combo = false
func cycloneDMG() -> void:
	var damage_type: String = "slash"
	var base_damage: float = player.all_skills.cyclone_damage 
	var points: int = player.cyclone_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * 0.05
	var damage: float = base_damage * damage_multiplier
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power =  20
	var push_distance:float = 0.25 * player.total_impact
	var stagger_chance: float 
	if player.cyclone_combo == false:
		stagger_chance = player.stagger_chance
	else:
		stagger_chance = 100
	var enemies = melee_aoe.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,stagger_chance)


#Whirlwind section
#This skill is viable for all melee weapon types 
func whirlwindCD()-> void:
	player.all_skills.whirlwindCD()
	player.whirlwind_duration = false
	player.whirlwind_combo = false
func whirlwindDMG() -> void:
	var damage_type: String = "slash"
	var base_damage: float = player.all_skills.whirlwind_damage 
	var points: int = player.whirlwind_icon.points
	var damage_multiplier: float = 1.0
	var health_ratio: float = float(player.health) / float(player.max_health)
	if points > 1:
		damage_multiplier += (points - 1) * 0.05
	var health_multiplier_strength: float = 2.0  # Increase this value to make the effect stronger
	var missing_health_percentage: float = 1.0 - (float(player.health) / float(player.max_health))
	var additional_damage_per_3_percent: float = 1
	var additional_damage: float = (missing_health_percentage / 0.03) * additional_damage_per_3_percent

	var damage: float = (base_damage * damage_multiplier) + additional_damage
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "slash"
	var aggro_power =  20
	var push_distance:float = 0.25 * player.total_impact
	var enemies = melee_aoe.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)

#HeartTrust
onready var trust_area: Area = $MeleeTrusting
func HeartTrustCD()->void:
	player.all_skills.heartTrustSlashCD()
	player.heart_trust_duration = false
func HeartTrustDMG()->void:

	var damage_type:String = "pierce"
	var base_damage: float = player.all_skills.heart_trust_dmg 
	var points: int = player.heart_trust_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * player.all_skills.heart_trust_dmg_proportion
	var damage: float = base_damage * damage_multiplier
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 15
	var punishment_damage_type :String = "slash"
	var aggro_power:float = player.threat_power + 15
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = trust_area.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			victim.bleeding_duration = 10
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,player.stagger_chance)


onready var area_mid_range:Area = $MidRangeAOE
func tauntEffect():
	player.berserk_duration = 6
	var enemies:Array = area_mid_range.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.health > 0:
					victim.takeThreat(150,player)
					victim.stunned_duration = 2.5
func tauntCD()->void:
	player.taunt_duration = false
	player.all_skills.tauntCD()
#___________________________________________________________________________________________________
#General  Functions to call in the AnimationPlayer
var can_move: bool = false
func stopMovement()-> void:
	can_move = false
func startMovement():
	can_move = true 
func doubleAtkEnd():
	player.double_atk_duration = false
#___________________________________________________________________________________________________
#Start and stop a state of damage immunity
func startParry():
	player.parry = true
func stopParry():
	player.parry = false
#Start and stop a state of damage reduction 
func startAbsorb():
	player.absorbing = true
func stopAbsorb():
	player.absorbing = false
func jump():
	player.jumping()
	player.jump_duration = false
func die():
	player.death_duration = false
	player.has_died = true 
	player.state = autoload.state_list.dead
func staggeredOver():
	player.state = autoload.state_list.wander
	player.staggered_duration = false

#___________________________________________________________________________________________________
func dealDMG(victim,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank,push_distance,stagger_chance)-> void:
		if victim  != player:
			if victim.has_method("takeDamage"):
				if randf() <= player.critical_chance:#critical hit
					if victim.absorbing == true or victim.parry == true: #victim is guarding
						if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
								victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,stagger_chance,damage_type)
						else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
								victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,player,stagger_chance,punishment_damage_type)
					else:#player is guarding
						if player.isFacingSelf(victim,0.30): #check if the victim is looking at me 
							victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,stagger_chance,damage_type)
						else: #apparently the victim is showing his back or flanks, extra damage
							victim.takeDamage(critical_damage,aggro_power,player,stagger_chance,punishment_damage_type)
				else: #normal hit
					if victim.absorbing == true or victim.parry == true: #victim is guarding
						if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
							victim.takeDamage(damage/victim.guard_dmg_absorbition,aggro_power,player,stagger_chance,damage_type)
						else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
							victim.takeDamage(damage_flank + punishment_damage,aggro_power,player,stagger_chance,punishment_damage_type)
					else:#victim is not guarding
						if player.isFacingSelf(victim,0.30):#the victim is looking face to face at self 
							victim.takeDamage(damage,aggro_power,player,stagger_chance,damage_type)
						else: #appareantly the victim is showing his back or flanks, extra damage
							victim.takeDamage(damage_flank,aggro_power,player,stagger_chance,damage_type)



func slideImpact(enemy_detector1,aggro_power,push_distance)-> void:
	for victim in enemy_detector1:
		if victim.is_in_group("enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
					victim.takeThreat(aggro_power,player)
					victim.takeStagger(100)

#___________________________________________________________________________________________________
#Ranged Functions to call in the AnimationPlayer
func shootArrow():
	player.all_skills.shootArrow(autoload.quick_shot_damage)
func fullDrawShootArrow():
	player.all_skills.shootArrow(autoload.full_draw_damage)
