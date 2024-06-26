extends Spatial

var player 
onready var animation:AnimationPlayer = $AnimationPlayer
#onready var animation_tree:AnimationTree = $AnimationTree
onready var left_eye = $Armature/Skeleton/IrisL
onready var right_eye = $Armature/Skeleton/IrisR



func _ready():
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
	animation.add_animation("fall", load("res://player/universal animations/Animations Movement General/fall.anim"))
	animation.add_animation("idle fist", load("res://player/universal animations/Animations Fist/idle fist.anim"))
	animation.add_animation("idle bow", load("res://player/universal animations/Animations Bow/idle  bow.anim"))#placeholder
	animation.add_animation("idle sword", load("res://player/universal animations/Animations Sword Light/idle sword.anim"))
	animation.add_animation("idle shield", load("res://player/universal animations/Animations Sword Light/idle sword.anim"))
	animation.add_animation("idle heavy", load("res://player/universal animations/Animations Sword Heavy/idle heavy.anim"))
	animation.add_animation("downed idle", load("res://player/universal animations/Animations Idle General/downed idle.anim"))
	
	
	
	
	animation.add_animation("walk", load("res://player/universal animations/Animations Movement General/walk.tres"))
	animation.add_animation("walk bow", load("res://player/universal animations/Animations Bow/walk bow.anim"))
	animation.add_animation("walk sword", load("res://player/universal animations/Animations Sword Light/walk sword.anim"))#placeholder
	animation.add_animation("walk heavy", load("res://player/universal animations/Animations Sword Heavy/walk heavy.anim"))
	animation.add_animation("walk shield", load("res://player/universal animations/Animations Shield/walk shield.anim"))
	animation.add_animation("downed walk", load("res://player/universal animations/Animations Movement General/downed walk.anim"))
	
	animation.add_animation("run", load("res://player/universal animations/Animations Movement General/run cycle.anim"))
	animation.add_animation("climb cycle", load("res://player/universal animations/Animations Movement General/climb cycle.anim"))
	
	#L-click animatins with hold turned off 
	animation.add_animation("fist click1", load("res://player/universal animations/Animations Fist/fist click1.anim"))
	animation.add_animation("fist click2", load("res://player/universal animations/Animations Fist/fist click2.anim"))
	
	animation.add_animation("sword click1", load("res://player/universal animations/Animations Sword Light/sword click1.anim"))
	animation.add_animation("sword click2", load("res://player/universal animations/Animations Sword Light/sword click2.anim"))

	animation.add_animation("dual click1", load("res://player/universal animations/Animations Sword Dual Wield/dual click1.anim"))
	animation.add_animation("dual click2", load("res://player/universal animations/Animations Sword Dual Wield/dual click2.anim"))
	
	
#	animation.add_animation("heavy click1", load("res://player/universal animations/Animations Sword Heavy/heavy click1.anim"))
#	animation.add_animation("heavy click2", load("res://player/universal animations/Animations Sword Heavy/heavy click2.anim"))
	
	animation.add_animation("kick", load("res://player/universal animations/Animations Fist/kick.anim"))
	
	
	#L-click animations
	animation.add_animation("fist hold", load("res://player/universal animations/Animations Fist/combo fist.tres"))
	animation.add_animation("shoot", load("res://player/universal animations/Animations Bow/shoot.anim"))
	animation.add_animation("sword hold", load("res://player/universal animations/Animations Sword Light/sword hold.anim"))
	animation.add_animation("dual hold", load("res://player/universal animations/Animations Sword Dual Wield/dual hold.anim"))
	animation.add_animation("heavy hold", load("res://player/universal animations/Animations Sword Heavy/heavy hold.anim"))
	
	#R-click animations
	animation.add_animation("full draw", load("res://player/universal animations/Animations Bow/full draw.anim"))
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
	switchWeapon()

onready var skeleton: Skeleton = $Armature/Skeleton
func equipArmor(clothing_to_equip,clothing_type_to_delete:String)->void:
	if clothing_to_equip == null:
		print("Can't equip NULL")
	if !is_instance_valid(clothing_to_equip):
		print("Can't equip INVALID")
	else:
		var clothing_to_equip_instance = clothing_to_equip.instance()
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
			
					match player.feet:
						autoload.boots_list.set_0:
							equipArmor(autoload.human_xx_feet_0,"Feet")
						autoload.boots_list.set_1:
							equipArmor(autoload.human_xx_feet_1,"Feet")
						autoload.boots_list.set_2:
							equipArmor(autoload.human_xx_feet_2,"Feet")

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

func switchWeapon()->void:
		match player.main_weapon:
			autoload.main_weap_list.zero:
				equipArmor(autoload.weapset1_scenes["null"],"main")
				
			autoload.main_weap_list.sword_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["sword"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["swordB"],"main")
					
			autoload.main_weap_list.hammer_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["hammer"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["hammerB"],"main")
					
			autoload.main_weap_list.mace_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["mace"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["maceB"],"main")
					
			autoload.main_weap_list.axe_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["axe"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["axeB"],"main")
							

					
			autoload.main_weap_list.greataxe_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["greataxe"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["greataxeB"],"main")
					
			autoload.main_weap_list.greatsword_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["greatsword"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["greatswordB"],"main")
			autoload.main_weap_list.demolition_hammer_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["demo_hammer"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["demo_hammerB"],"main")

			autoload.main_weap_list.greatmace_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["greatmace"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["greatmaceB"],"main")

			autoload.main_weap_list.warhammer_beginner:
				if player.is_in_combat == true:
					equipArmor(autoload.weapset1_scenes["warhammer"],"main")
				else:
					equipArmor(autoload.weapset1_scenes["warhammerB"],"main")


		
		if player.main_weapon == autoload.weapon_type_list.heavy:
				equipArmor(autoload.weapset1_scenes["null_sec"],"secondary")
		else:
			match player.sec_weapon:
				autoload.sec_weap_list.zero:
					equipArmor(autoload.weapset1_scenes["null_sec"],"secondary")



				autoload.sec_weap_list.sword_beginner:
					if player.is_in_combat == true:
						equipArmor(autoload.weapset1_scenes["sword_sec"],"secondary")
					else:
						equipArmor(autoload.weapset1_scenes["sword_secB"],"secondary")

				autoload.sec_weap_list.hammer_beginner:
					if player.is_in_combat == true:
						equipArmor(autoload.weapset1_scenes["hammer_sec"],"secondary")
					else:
						equipArmor(autoload.weapset1_scenes["hammer_secB"],"secondary")
						
				autoload.sec_weap_list.mace_beginner:
					if player.is_in_combat == true:
						equipArmor(autoload.weapset1_scenes["mace_sec"],"secondary")
					else:
						equipArmor(autoload.weapset1_scenes["mace_secB"],"secondary")
						
						
				autoload.sec_weap_list.axe_beginner:
					if player.is_in_combat == true:
						equipArmor(autoload.weapset1_scenes["axe_sec"],"secondary")
					else:
						equipArmor(autoload.weapset1_scenes["axe_secB"],"secondary")
								

				autoload.sec_weap_list.shield_beginner:
					equipArmor(autoload.weapset1_scenes["shield"],"secondary")
					

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
			
			
			
func changeHeadTorsoColor(materail_number, new_material, color):#Deprecated
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


func switchSkin():#Needs more assets to finish
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
				
				
#Face blend shapes
# Complete in another project, I'll just copy and past it there eventually when I make the UI for
# the character customization here too 

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

func  applyBlendShapes()->void:
	for child in $Armature/Skeleton.get_children():
		if child.is_in_group("face"):
			child.set("blend_shapes/Smile",smile)

#___________________________________________Combat System___________________________________________
func onHit()->void:#Put this on base attacks
	if player.resolve < player.max_resolve:
		player.resolve += player.total_on_hit_resolve_regen

func throwRocks()->void:
	player.all_skills.throwRock(player.total_dmg)

func throwRocksStop()->void:
	player.throw_rock_duration = false
	player.can_walk = true
func backstepCD()->void:
	player.all_skills.backstepCD()
	player.backstep_duration = false
	player.frontstep_duration = false
	player.leftstep_duration = false
	player.rightstep_duration = false
	player.is_aiming = false

func slideImpact()-> void:
	for victim in trust_area.get_overlapping_bodies():
		if victim.is_in_group("Enemy"):
			if victim != self:
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(0.5, victim,0.25)
					victim.takeThreat(3,player)
					victim.takeStagger(100)
func slideCD()->void:
	player.slide_duration = false
	player.all_skills.slideCD()


func dashCD()->void:
	player.all_skills.dashCD()
	player.dash_duration = false

var stagger_chance: float 


func punch()->void:
	var damage_type:String = "blunt"
	var damage:float = player.total_dmg
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  =0
	var critical_flank_damage : float  =0
	#extra damage when the victim is trying to block but is facing the wrong way 
	var punishment_damage : float = 7 
	var punishment_damage_type :String = "blunt"
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = trust_area.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				onHit()
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
		dealDMG(victim,aggro_power,damage_type,damage)


func kickCD()->void:
	player.resolve -= player.all_skills.kick_cost
	player.all_skills.kickCD()
	player.kick_duration = false

func kickDMG()-> void:
	var damage_type:String = player.base_dmg_type
	var base_damage: float = player.all_skills.kick_dmg + player.total_dmg
	var points: int = player.kick_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * player.all_skills.kick_dmg_proportion
	var damage: float = (base_damage * damage_multiplier)
	var damage_flank = damage + player.flank_dmg 
	var push_distance:float = 0.6 * player.total_impact
	var enemies = trust_area.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("Enemy"):
			if victim != self:
				dealDMG(victim,0,damage_type,damage)
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
			if victim.has_method("getKnockedDown"):
				if victim.health > damage:
					if victim.balance < 3:
						victim.getKnockedDown(player)
func stompCD()->void:
	player.stomp_duration = false
	player.all_skills.stompCD()

func stompHit()->void:
	var damage_type:String = player.base_dmg_type
	var damage:float = player.all_skills.stomp_dmg + player.total_dmg
	var aggro_power:float = player.threat_power
	var dmg_against_knocked: float = damage * player.all_skills.stomp_dmg_proportion
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("Entity"):
			if victim != self:
				onHit()
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
				if victim.knockeddown_duration == true:
					dealDMG(victim,aggro_power,damage_type,dmg_against_knocked)
				else:
					dealDMG(victim,aggro_power,damage_type,damage)


func baseAtkCD()->void:
	player.base_atk_duration = false
	player.base_atk2_duration = false
	player.base_atk3_duration = false
	player.base_atk4_duration = false

onready var area_melee_front:Area = $MeleeFront
func baseAtktHit()->void:#Heavy
	var damage_type:String = player.base_dmg_type
	var damage:float = player.total_dmg 
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  =0
	var critical_flank_damage : float  = damage_flank * player.critical_dmg
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim == self:
			playSoundSwordWoosh()
		elif victim == player:
			playSoundSwordWoosh()
		elif victim == null:
			playSoundSwordWoosh()
		else:
			if !victim.is_in_group("Player"):
				if victim.is_in_group("Entity"):
					dealDMG(victim,aggro_power,damage_type,damage)
					onHit()
					playSoundSwordHit()
					if victim.state != autoload.state_list.dead:
						player.pushEnemyAway(push_distance, victim,0.25)

			
		
func baseAtkLastHit()->void:#Heavy
	player.all_skills.activateComboCyclone()
	player.all_skills.activateComboOverheadslash()
	player.all_skills.activateComboWhirlwind()
	var damage_type:String = player.base_dmg_type
	var damage:float = player.total_dmg * 2.25
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = area_melee_front.get_overlapping_bodies()
	for victim in enemies:
		if victim == self:
			playSoundSwordWoosh()
		elif victim == player:
			playSoundSwordWoosh()
		elif victim == null:
			playSoundSwordWoosh()
		else:
			if !victim.is_in_group("Player"):
				if victim.is_in_group("Entity"):
					dealDMG(victim,aggro_power,damage_type,damage)
					onHit()
					playSoundSwordHit()
					if victim.state != autoload.state_list.dead:
						player.pushEnemyAway(push_distance, victim,0.25)

onready var cleave_area = $CleavingArea
func cleavetHit()->void:#First base attack for heavy weapons
	var damage_type:String = player.base_dmg_type
	var damage:float = player.total_dmg 
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  =0
	var critical_flank_damage : float  = damage_flank * player.critical_dmg
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.25 * player.total_impact
	var enemies:Array = cleave_area.get_overlapping_bodies()
	for victim in enemies:
		if victim == self:
			playSoundSwordWoosh()
		elif victim == player:
			playSoundSwordWoosh()
		elif victim == null:
			playSoundSwordWoosh()
		else:
			if !victim.is_in_group("Player"):
				if victim.is_in_group("Entity"):
					dealDMG(victim,aggro_power,damage_type,damage)
					onHit()
					playSoundSwordHit()
					if victim.state != autoload.state_list.dead:
						player.pushEnemyAway(push_distance, victim,0.25)

func cleaveLastHit()->void:#Second base attack for heavy weapons
	player.all_skills.activateComboCyclone()
	player.all_skills.activateComboOverheadslash()
	player.all_skills.activateComboWhirlwind()
	var damage_type:String = player.base_dmg_type
	var damage:float = player.total_dmg * 2.25
	var aggro_power:float = player.threat_power
	var push_distance:float = 0.3 * player.total_impact
	var enemies:Array = cleave_area.get_overlapping_bodies()
	for victim in enemies:
		if victim == self:
			playSoundSwordWoosh()
		elif victim == player:
			playSoundSwordWoosh()
		elif victim == null:
			playSoundSwordWoosh()
		else:
			if !victim.is_in_group("Player"):
				if victim.is_in_group("Entity"):
					dealDMG(victim,aggro_power,damage_type,damage)
					onHit()
					playSoundSwordHit()
					if victim.state != autoload.state_list.dead:
						player.pushEnemyAway(push_distance, victim,0.25)

#Overhead Slash section
#This skill is viable for all melee weapon types EXCEPT FIST WEAPONS
func overheadSlashCD()-> void:
	player.all_skills.overheadSlashCD()
	player.overhead_slash_duration = false
	player.overhead_slash_combo = false
	player.resolve -= player.all_skills.overhead_slash_cost

func overheadSlashDMG()->void:
	var damage_type:String = player.base_dmg_type
	var base_damage: float = player.all_skills.overhead_slash_damage + player.total_dmg
	var points: int = player.overhead_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * player.all_skills.overhead_slash_dmg_proportion
	var damage: float = base_damage * damage_multiplier
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = 0
	var critical_flank_damage : float  = 0
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
		dealDMG(victim,aggro_power,damage_type,damage)


#rising slash section
#This skill is viable for all melee weapon types EXCEPT FIST WEAPONS
func risingSlashCD()-> void:
	player.resolve -= player.all_skills.rising_slash_cost
	player.all_skills.risingSlashCD()
	player.rising_slash_duration = false
	
	player.rising_slash_duration = false
func risingSlashDMG()-> void:
	var damage_type:String = player.base_dmg_type
	var base_damage:float = player.all_skills.rising_slash_damage + player.total_dmg
	var points: int = player.rising_icon.points
	var damage_multiplier: float = 1.0
	var total_damage: float
	if points > 1:
			damage_multiplier += (points - 1) * player.all_skills.rising_slash_dmg_proportion
	var damage = base_damage * damage_multiplier	
	var damage_flank: float = damage + player.flank_dmg 
	var critical_damage: float  =0
	var critical_flank_damage : float  = 0
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
		dealDMG(victim,aggro_power,damage_type,damage)

#Cyclone section
#This skill is viable for all melee weapon types EXCEPT FIST WEAPONS
onready var melee_aoe: Area = $MeleeAOE
func cycloneCD()-> void:
	player.all_skills.cycloneCD()
	player.resolve -= player.all_skills.cyclone_cost
	player.cyclone_duration = false
	player.cyclone_combo = false
func cycloneDMG() -> void:
	var damage_type:String = player.base_dmg_type
	var base_damage: float = player.all_skills.cyclone_damage + player.total_dmg
	var points: int = player.cyclone_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * 0.05
	var damage: float = base_damage * damage_multiplier
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  =0
	var critical_flank_damage : float  = 0
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
		dealDMG(victim,aggro_power,damage_type,damage)


#Whirlwind section
#This skill is viable for all melee weapon types 
func whirlwindCD()-> void:
	player.all_skills.whirlwindCD()
	player.resolve -= player.all_skills.whirlwind_cost
	player.whirlwind_duration = false
	player.whirlwind_combo = false
func whirlwindDMG() -> void:
	var damage_type:String = player.base_dmg_type
	var base_damage: float = player.all_skills.whirlwind_damage + player.total_dmg
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
	var push_distance:float = 0.4 * player.total_impact
	var enemies = melee_aoe.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				dealDMG(victim,0,damage_type,damage)
				onHit()
				playSoundSwordHit()
				if victim.state != autoload.state_list.dead:
					player.pushEnemyAway(push_distance, victim,0.25)
			if victim.has_method("getKnockedDown"):
				if victim.health > damage:
							if victim.balance < 3:
								victim.getKnockedDown(player)
		else:
			playSoundSwordWoosh()
			
					
						
								

#HeartTrust
onready var trust_area: Area = $MeleeTrusting
func HeartTrustCD()->void:
	player.all_skills.HeartTrustCD()
	player.resolve -= player.all_skills.heart_trust_cost
	player.heart_trust_duration = false
func HeartTrustDMG()->void:
	var damage_type:String = "pierce"
	var base_damage: float = player.all_skills.heart_trust_dmg + player.total_dmg
	var points: int = player.heart_trust_icon.points
	var damage_multiplier: float = 1.0
	if points > 1:
		damage_multiplier += (points - 1) * player.all_skills.heart_trust_dmg_proportion
	var damage: float = base_damage * damage_multiplier
	var damage_flank:float = damage + player.flank_dmg 
	var critical_damage : float  =0
	var critical_flank_damage : float  =0
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
		dealDMG(victim,aggro_power,damage_type,damage)


onready var area_mid_range:Area = $MidRangeAOE
func tauntEffect()-> void:
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
	player.resolve -= player.all_skills.taunt_cost
#___________________________________________________________________________________________________
#General  Functions to call in the AnimationPlayer
var can_move: bool = false
func stopMovement()-> void:
	can_move = false
func startMovement()-> void:
	can_move = true 
func doubleAtkEnd()-> void:
	player.double_atk_duration = false
#___________________________________________________________________________________________________
#Start and stop a state of damage immunity
func startParry()-> void:
	player.parry = true
func stopParry()-> void:
	player.parry = false
#Start and stop a state of damage reduction 
func startAbsorb()-> void:
	player.absorbing = true
func stopAbsorb()-> void:
	player.absorbing = false
func jump()-> void:
	player.jumping()
	player.jump_duration = false
func die()-> void:
	player.death_duration = false
	player.has_died = true 
	player.state = autoload.state_list.dead
func staggeredOver()-> void:
	player.staggered_duration = false
func getUp():
	player.knockeddown_duration = false

onready var weapon_woosh = $WeaponWoosh
func playSoundSwordWoosh()-> void:
	if weapon_woosh == null:
		pass
	else:
		weapon_woosh.play()
	
onready var weapon_hit = $WeaponHit
func playSoundSwordHit()-> void:
	if weapon_hit == null:
		pass
	else:
		weapon_hit.play()
#___________________________________________________________________________________________________
func dealDMG(victim,aggro_power,damage_type,damage)-> void:
		var random = rand_range(0,1)
		if victim  != player:
			if victim.is_in_group("Entity"):
				if victim.has_method("takeDamage"):
					victim.takeDamage(damage,aggro_power,player,stagger_chance,damage_type)
			else:
				if victim.has_method("getChopped"):
					victim.getChopped(damage,player)
					

#___________________________________________________________________________________________________
#Ranged Functions to call in the AnimationPlayer
func shootArrow():
	player.all_skills.shootArrow(autoload.quick_shot_damage)
func fullDrawShootArrow():
	player.all_skills.shootArrow(autoload.full_draw_damage)
