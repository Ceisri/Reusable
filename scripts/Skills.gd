extends Node

onready var player:KinematicBody = get_parent()
onready var grid: GridContainer =  $"../Canvas/Skillbar/GridContainer"
var demon_distance: float = 10.0 
var summon_cooldown: float = 0.15 
var last_summon_time: float = 0.0 

func comboSystem():
	var current_time = OS.get_ticks_msec() / 1000.0
	if player.cyclone_combo:
		# Check if time has passed have passed since the combo was started
		if current_time - cyclone_combo_start_time >= 1.5:
			player.cyclone_combo = false

	if player.overhead_slash_combo:
		if current_time - overhead_slash_start_time>= 2.25:
			player.overhead_slash_combo = false




func updateCooldownLabel() -> void:
	var current_time = OS.get_ticks_msec() / 1000.0
	for child in grid.get_children():
		var icon = child.get_node("Icon")

		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.backstep.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateBackstep(label,backstep_cooldown,current_time,last_backstep_time)
				modulateIcon(icon,backstep_cooldown,current_time,last_backstep_time)



		elif icon != null and icon.texture != null and icon.texture.resource_path == Icons.kick.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateKick(label,kick_cooldown,current_time,last_kick_time)
				modulateIcon(icon,kick_cooldown,current_time,last_kick_time)


func modulateIcon(icon, cooldown, current_time, last_time) -> void:
	# Interpolate the texture albedo from red to white based on the cooldown
	var cooldown_ratio = (current_time - last_time) / cooldown
	cooldown_ratio = clamp(cooldown_ratio, 0.0, 1.0)
	
	var red_color = Color(1, 0, 0)
	var white_color = Color(1, 1, 1)
	
	var interpolated_color = Color(
		lerp(red_color.r, white_color.r, cooldown_ratio),
		lerp(red_color.g, white_color.g, cooldown_ratio),
		lerp(red_color.b, white_color.b, cooldown_ratio),
		lerp(red_color.a, white_color.a, cooldown_ratio)
	)
	
	# Assuming the icon is a Sprite or similar with a modulate property
	icon.modulate = interpolated_color


var combo_distance: float = 4# the move distance of base of base attacks when long_base_atk is true 
var cleave_distance: float = 5 # the move distance of base of base attacks  when long_base_atk is false
var combo_extr_speed: float = 0.15 # when long_base_atk is true the player does a 4 hit base attack, compensate by making it faster
var combo_switch_description: String = "switch between short and long combo mode, in short mode your base attack combo ends at with second attack, activating all related combos, on long combo it will end with the forth attack"
var combo_switch_cooldown: float =  1
var last_combo_switch_time: float = 0.0 
var can_combo_switch:bool = true
func comboSwitchCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_combo_switch_time >= combo_switch_cooldown:
		last_combo_switch_time = current_time
		player.long_base_atk = !player.long_base_atk
func updateLabelComboSwitch(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_combo_switch = false
		label.text = str(round(remaining_cooldown))
	else:
		label.text = ""
		can_combo_switch = true

		
		
		
		
var can_drink_potion: bool = true
func updateLabelPotion(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_drink_potion = false
		label.text = str(round(remaining_cooldown))
	else:
		label.text = ""
		can_drink_potion = true
var can_fury_strike: bool = false
func updateLabelFuryStrike(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	#print("remaining_cooldown:", remaining_cooldown)
	if remaining_cooldown!= 0:
		can_fury_strike = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_fury_strike = true
		
#___________________________________________________________________________________________________
var dash_cooldown: float = 2
var last_dash_time: float = 0.0 
var dash_cost: float = 10
func dashCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_dash_time >= dash_cooldown:
			last_dash_time = current_time
			activateComboCyclone()
			activateComboWhirlwind()
var can_dash: bool = false
func updateDash(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_dash = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_dash = true
#___________________________________________________________________________________________________
var slide_cooldown: float = 5
var last_slide_time: float = 0.0 
var slide_cost: float = 10
func slideCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_slide_time >= slide_cooldown:
		last_slide_time = current_time


var can_slide: bool = false
func updateSlide(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_slide = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_slide = true
#___________________________________________________________________________________________________
var backstep_distance: float = 9
var backstep_cooldown: float = 6
var last_backstep_time: float = 0.0 
func backstepCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_backstep_time >= backstep_cooldown:
		last_backstep_time = current_time
var can_backstep: bool = true
func updateBackstep(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_backstep = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_backstep = true
#___________________________________________________________________________________________________
var stomp_description: String = "Stomp the ground beneath you dealing extra damage to KNOCKED DOWN enemies"
var stomp_dmg: float = 5
var stomp_dmg_proportion: float = 2.5

var stomp_cooldown: float = 6
var last_stomp_time: float = 0.0 
func stompCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_stomp_time >= stomp_cooldown:
		last_stomp_time = current_time

var can_stomp: bool = false
func updateStomp(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_stomp = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_stomp = true
#___________________________________________________________________________________________________
var kick_description: String = "+5% damage per skill level, kick your foes knocking them down if their balance attribute is below 3 or their health is too low"
var kick_dmg: float = 5
var kick_dmg_proportion: float = 0.5
var kick_cost: float = 7
var kick_cooldown: float = 6
var last_kick_time: float = 0.0 

func kickCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_kick_time >= kick_cooldown:
		last_kick_time = current_time

var can_kick: bool = false
func updateKick(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_kick = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_kick = true
#___________________________________________________________________________________________________
var overhead_slash_distance: float = 6
var overhead_slash_cooldown: float = 2.5
var last_overhead_slash_time: float = 0.0 
var overhead_slash_cost: float = 7
var overhead_slash_description: String = "+6% compounding extra damage per skill level.\nDamage increased by both SLASH DAMAGE and BLUNT DAMAGE stats\nStrike foes in front of you in the head,\nThis skill activates faster and guarantees to stagger foes after the following: Cyclone, Desperate Slash, Heart Trust,Rising slash or the last hit of base attack"
var overhead_slash_damage: float = 12
var overhead_slash_dmg_proportion: float = 0.06
var overhead_slash_start_time: float = 0.0
func overheadSlashCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_overhead_slash_time >= overhead_slash_cooldown:
		if player.resolve >=overhead_slash_cost:
			activateComboWhirlwind()
			last_overhead_slash_time = current_time
var can_overhead_slash: bool = false
func updateOverheadSlash(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_overhead_slash = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_overhead_slash = true
var overhead_slash_combo_speed_bonus = 0.85 #1 = 100% extra speed
func activateComboOverheadslash():
	player.overhead_slash_combo = true
	overhead_slash_start_time = OS.get_ticks_msec() / 1000.0
#___________________________________________________________________________________________________
var rising_slash_cooldown: float = 5
var last_rising_slash_time: float = 0.0 
var rising_slash_description: String = "+4% compounding extra damage per skill level.\nHit foes in front of you with an upward slash staggering them"
var rising_slash_cost: float = 7
var rising_slash_damage: float = 5
var rising_slash_dmg_proportion: float = 0.04
func risingSlashCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_rising_slash_time >= rising_slash_cooldown:
		if player.resolve >=rising_slash_cost:
			activateComboCyclone()
			activateComboOverheadslash()
			last_rising_slash_time = current_time
			
var can_rising_slash: bool = false
func updateRising(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_rising_slash = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_rising_slash = true
#___________________________________________________________________________________________________
var heart_trust_cooldown: float = 20
var last_heart_trust_time: float = 0.0 
var heart_trust_cost: float = 7
var heart_trust_dmg: float =  18
var heart_trust_bleed_duration: float = 7
var heart_trust_description: String = "5% compounding extra damage per skill level.\nstab foes in front, causing them to bleed for: "
var heart_trust_dmg_proportion: float = 0.05
func HeartTrustCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_heart_trust_time >= heart_trust_cooldown:
		if player.resolve >=heart_trust_cost:
			activateComboOverheadslash()
			last_heart_trust_time = current_time
var can_heart_trust: bool = false
func updateHeartTrust(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_heart_trust = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_heart_trust = true
#___________________________________________________________________________________________________
var taunt_cooldown: float =  30
var last_taunt_time: float = 0.0 
var taunt_cost: float = 7
func tauntCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_taunt_time >= taunt_cooldown:
		if player.resolve >=taunt_cost:
			last_taunt_time = current_time
var can_taunt: bool = false
func updateTaunt(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_taunt = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_taunt = true
#___________________________________________________________________________________________________

var cyclone_damage: float = 7
var cyclone_cooldown: float = 2
var cyclone_cost: float = 4.5
var cyclone_motion: float = 6
var cyclone_description: String = "\n+5% compounding extra damage per skill level.\nSpin and slash foes around you in an area attack, each foe can be hit up to 2 times.\nThis skill activates faster and guarantees to stagger foes after the following:  Dodge slide, 4th hit of base attack, Rising slash"
var cyclone_combo_start_time:float = 0.0
var last_cyclone_time: float = 0.0 
func cycloneCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_cyclone_time >= cyclone_cooldown:
		activateComboOverheadslash()
		last_cyclone_time = current_time
var can_cyclone: bool = false
func updateLabelCyclone(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	#print("remaining_cooldown:", remaining_cooldown)
	if remaining_cooldown!= 0:
		can_cyclone = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_cyclone = true
func activateComboCyclone():
	player.cyclone_combo = true
	cyclone_combo_start_time = OS.get_ticks_msec() / 1000.0

#___________________________________________________________________________________________________
var whirlwind_cooldown: float = 7
var whirlwind_distance: float = 7
var whirlwind_cost:float = 6.0
var whirlwind_damage: float = 3.0
var whirlwind_damage_multiplier:float = 1.0
var whirlwind_description: String = "+5% compounding extra damage per skill level.\n+1 damage per 3% missing health.\nSlice foes around you, dealing higher damage the less health you have and Knocking down all foes hit unless their balance attribute is too high, or their health is lower than the PRE-MITIGATION damage of this attack"
var last_whirlwind_time: float = 0.0 
var whirlwind_combo_start_time: float =  0.0
func whirlwindCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_whirlwind_time >= whirlwind_cooldown:
		activateComboOverheadslash()
		last_whirlwind_time = current_time
var can_whirlwind:bool = false
func updateWhirlwind(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_whirlwind = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_whirlwind = true
func activateComboWhirlwind():
	player.whirlwind_combo = true
	whirlwind_combo_start_time = OS.get_ticks_msec() / 1000.0
#___________________________________________________________________________________________________
var counter_cooldown: float = 3
var last_counter_time: float = 0.0 
var counter_cost: float = 5
func counterStrike()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_counter_time >= counter_cooldown:
		last_counter_time = current_time
		
		
var grappling_hook_cooldown: float = 1
var last_grappling_hook_time: float = 0.0 
var can_grappling_hook:bool = false
func grapplingHookCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_grappling_hook_time >= grappling_hook_cooldown:
		last_grappling_hook_time = current_time
		
		
func updateGrapplingHook(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_grappling_hook = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_grappling_hook = true

		
#___________________________________________________________________________________________________
#var arrow: PackedScene = preload("res://Equipment/Arrows/Iron/Arrow_Iron.tscn")
#var vertical_spawn_offset: float = 0.8
#func shootArrow(arrow_damage):
#	var camera = player.camera 
#	var player_global_transform: Transform = player.global_transform
#	var arrow_instance: KinematicBody
#	var player_direction = player.direction
#	var camera_transform: Transform = camera.global_transform
#	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
#	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
#	var player_forward: Vector3 = player_global_transform.basis.z.normalized()
#
#	var camera_global_transform: Transform = camera.global_transform
#	var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
#	var shoot_position: Vector3 = player.global_transform.origin + camera_forward * 0.5
#	shoot_position.y += vertical_spawn_offset + 1
#	var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
#	# Shoot the first bullet towards where the camera is looking at
#	arrow_instance = arrow.instance()
#	arrow_instance.direction = camera_forward
#	arrow_instance.instigator = player
#	arrow_instance.summoner = player
#	arrow_instance.damage =  arrow_damage * player.strength 
#	get_tree().current_scene.add_child(arrow_instance)
#	arrow_instance.global_transform.origin = shoot_position
#
#var rock: PackedScene = preload("res://EnvironmentDecorations/throwable rock/throwable rock.tscn")
#
#func throwRock(damage):
#	var camera = player.camera 
#	var player_global_transform: Transform = player.global_transform
#	var rock_instance: KinematicBody
#	var player_direction = player.direction
#	var camera_transform: Transform = camera.global_transform
#	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
#	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
#	var player_forward: Vector3 = player_global_transform.basis.z.normalized()
#
#	var camera_global_transform: Transform = camera.global_transform
#	var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
#	var shoot_position: Vector3 = player.global_transform.origin + camera_forward * 0.5
#	shoot_position.y += vertical_spawn_offset + 1
#	var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
#	# Shoot the first bullet towards where the camera is looking at
#	rock_instance = rock.instance()
#	rock_instance.direction = camera_forward
#	rock_instance.instigator = player
#	rock_instance.summoner = player
#	rock_instance.damage =  damage * player.strength 
#	get_tree().current_scene.add_child(rock_instance)
#	rock_instance.global_transform.origin = shoot_position

var potion_cooldown: float = 3
var last_potion_time: float = 0.0 

func potion():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_potion_time >= potion_cooldown:
		last_counter_time = current_time

#___________________________________________________________________________________________________




var queue_skills:bool = true #this is only for people with disabilities or if the game ever goes online to help with high ping, as of now it can't be used by itself until I revamp the skill cancel system  


func _ready()->void:
	connect("pressed", self , "pressed")

func pressed()->void:
	queue_skills = !queue_skills
	player.switchButtonTextures()


#call this function and write in the string which skill to NOT  be cancelled, all the others 
#will go in cooldown if they are activated  as well as being turned off allowing for smooth skill cancelling 
func skillCancel(string:String)->void:
	if player.skill_cancelling == true:
		match string:
			"none":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"throw_rock":
				interruptBackstep()
				interruptBaseAtk()
#				if player.throw_rock_duration == true:
#					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"dash":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
#				if player.dash_duration == true:
#					player.skills.dashCD()
#					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"slide":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
#				if player.slide_duration == true:
#					player.skills.slideCD()
#					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"backstep":
	#			interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"stomp":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
#				if player.stomp_duration == true:
#					player.stomp_duration = false
#					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"sunder":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
#				if player.overhead_slash_duration == true:
#					player.skills.melee1CD()
#					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"rising_slash":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
#				if player.rising_slash_duration == true:
#					player.rising_slash_duration = false
#					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"cyclone":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
#				if player.cyclone_duration == true:
#					player.skills.cycloneCD()
#					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"whirlwind":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
#				if player.whirlwind_duration == true:
#					player.skills.whirlwindCD()
#					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"heart_trust":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
#				if player.heart_trust_duration == true:
#					player.skills.HeartTrustCD()
#					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"taunt":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
#				if player.taunt_duration == true:
#					player.skills.tauntCD()
#					player.taunt_duration = false
			"kick":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
#				if player.kick_duration == true:
#					player.kick_duration = false
#					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false
			"none":
				interruptBackstep()
				interruptBaseAtk()
				if player.throw_rock_duration == true:
					player.throw_rock_duration = false
				if player.slide_duration == true:
					player.skills.slideCD()
					player.slide_duration = false
				if player.dash_duration == true:
					player.skills.dashCD()
					player.dash_duration = false
				if player.stomp_duration == true:
					player.stomp_duration = false
					player.skills.stompCD()
				if player.kick_duration == true:
					player.kick_duration = false
					player.skills.kickCD()
				if player.overhead_slash_duration == true:
					player.skills.melee1CD()
					player.overhead_slash_duration = false
				if player.rising_slash_duration == true:
					player.rising_slash_duration = false
					player.skills.risingSlashCD()
				if player.heart_trust_duration == true:
					player.skills.HeartTrustCD()
					player.heart_trust_duration = false
				if player.cyclone_duration == true:
					player.skills.cycloneCD()
					player.cyclone_duration = false
				if player.whirlwind_duration == true:
					player.skills.whirlwindCD()
					player.whirlwind_duration = false
				if player.taunt_duration == true:
					player.skills.tauntCD()
					player.taunt_duration = false

func interruptBaseAtk():
	player.base_atk_duration = false
	player.base_atk2_duration = false
	player.base_atk3_duration = false
	player.base_atk4_duration = false
func interruptBackstep()->void:
	if player.leftstep_duration == true:
		player.skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.backstep_duration == true:
		player.skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.frontstep_duration == true :
		player.skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.rightstep_duration == true:
		player.skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
	if player.leftstep_duration == true:
		player.skills.backstepCD()
		player.backstep_duration = false
		player.frontstep_duration = false
		player.leftstep_duration = false
		player.rightstep_duration = false
		
func getInterrupted()->void:#Universal stop, call this when I'm stunned, staggered, dead, knocked down and so on 
	player.overhead_slash_combo = false
	player.whirlwind_combo = false
	player.cyclone_combo = false
	player.base_atk_duration = false
	player.base_atk2_duration = false
	player.throw_rock_duration = false
	
	interruptBackstep()
	interruptBaseAtk()
	if player.throw_rock_duration == true:
		player.throw_rock_duration = false
	if player.slide_duration == true:
		player.skills.slideCD()
		player.slide_duration = false
	if player.dash_duration == true:
		player.skills.dashCD()
		player.dash_duration = false
	if player.stomp_duration == true:
		player.stomp_duration = false
		player.skills.stompCD()
	if player.kick_duration == true:
		player.kick_duration = false
		player.skills.kickCD()
	if player.overhead_slash_duration == true:
		player.skills.melee1CD()
		player.overhead_slash_duration = false
	if player.rising_slash_duration == true:
		player.rising_slash_duration = false
		player.skills.risingSlashCD()
	if player.heart_trust_duration == true:
		player.skills.HeartTrustCD()
		player.heart_trust_duration = false
	if player.cyclone_duration == true:
		player.skills.cycloneCD()
		player.cyclone_duration = false
	if player.whirlwind_duration == true:
		player.skills.whirlwindCD()
		player.whirlwind_duration = false
	if player.taunt_duration == true:
		player.skills.tauntCD()
		player.taunt_duration = false
