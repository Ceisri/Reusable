"""
@Ceisri
Documentation String: 
My functions are writtenLikeThis(), while the ones default to the game engine are written_like_this().
Almost everything in the game is in this script, except preloads, dictionaries, skill cooldowns, etc.
Keybind editing and similar features are in their specific scripts. However, this script still includes 
thousands of lines for everything from combat to movement to UI. I only move things into different 
scripts if strictly necessary.
I use very_long_variable_names_that_are_very_descriptive but feel free to name yours how you prefer
as long as they are snake case.
If you are using any of this in your project keep in mind that due to Global.gd using a lot of preloads,
the game doesn't have the fastest loading time so try to avoid game games that are too 'instanced'
and rely more on 'open world' unless you find a better way and can make loading times faster.
"""



extends KinematicBody
var rng = RandomNumberGenerator.new()
var is_player:bool = true

func _ready()->void:
#	Icons.drawGlobalThreat(self)#For DEbugging purposes only, draws aggro from everything 
	loadPlayerData()
	switchSexRace()
	setInventoryOwner()
	setSkillTreeOwner()
	add_to_group("Player")
	add_to_group("Entity")
	connectUIButtons()
	connectInventoryButtons()
	connectSkillBarButtons()
	connectSkillTree()
	connectAttributeButtons()
	connectAttributeHovering()
	connectHoveredResistanceLabels()
	closeAllUI()
	loadInventoryData()
	loadSkillTreeData()
	SwitchEquipmentBasedOnEquipmentIcons()
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)
	aim_label.text = aiming_mode
	skills.EquipmentSwitch()
	l_click_slot.switchAttackIcon()
	colorBodyParts()
	switchButtonTextures()
	connectEquipment()
	stutterPrevention()
	struggle_button.text = "Struggle:" + str(struggles)+ " remaining"
	colorUI(ui_color)
	previous_position = global_transform.origin
	if direction_assist == true:
		dir_assist_check.pressed = true
	else:
		dir_assist_check.pressed = false
	

"""
@Ceisri
Documentation String:
The first time something transparent or heavy shaders are suddenly instanced, it lags this game; they call it shader stutter,
and it seems to be a problem that every game ever has. There are various solutions to prevent this. Sometimes,
it works if you instance the laggy things once before the player starts the game or as soon as the player starts.
As of now, the only things that cause perceivable stutter in this game are floating texts for damage, healing, and loot.
Hence, why stutterPrevention() so far is pretty empty.
"""

func stutterPrevention()->void:
	var text = Icons.floatingtext_damage.instance()
	text.status = "STUTTER PREVENTION"
	take_damage_view.add_child(text)

"""
@Ceisri
Documentation String: 
use if Engine.get_physics_frames() % frames_to_skip == 0: to decided where to put functions based on 
how often do you need refreshed, my engine physics are 24 by default, I guess because it is the minimum
to make the game feel good whilist matching the framerate of Hollywood movies there 
if Engine.get_physics_frames() % 2 == 0:
	functionToDo()
means that this specific function will be ran 12 times per second instead of 24.
By all means avoid elif in this specific case only use if statments 
"""
func _physics_process(delta: float) -> void:
	Icons.gravity(self)#Gravity stays first in the order else jumping doesn't work 
	all_skills.updateCooldownLabel()
	cameraRotation()
	crossHair()
	crossHairResize()
	miniMapVisibility()
	rotateMesh()
	dodgeIframe()
	doublePressToDash()
	fullscreen()
	showEnemyStats()
	behaviourTree()
	inputToState()
	attack()
	skillUserInterfaceInputs()
	jump()
	deathLife(delta)#Main function
	moveShadow()
	rotateShadow()
	canIWalk()
	uiColorShit()
	manualTargetAssit()
	if Engine.get_physics_frames() % 2 == 0: #12 frames per second
		lootBodies()
		miniMapVisibility()
		showEnemyStats()
		all_skills.updateCooldownLabel()
		debug()
		l_click_slot.switchAttackIcon()
		r_click_slot.switchAttackIcon()
		if debug_mode == true:
			print("2 frames passed")
	if Engine.get_physics_frames() % 6 == 0:#4 frames per second, 0.25 seconds between frames
		convertStats()
		curtainsDown()
		if debug_mode == true:
			print("6 frames passed")
	if Engine.get_physics_frames() % 12 == 0: #2 frames per second, 0.5 seconds between frames 
		positionCoordinates()
		updateAllStats()
		showAttributePoints()
		potionEffects()
		all_skills.ComboSystem()
		showStatusIcon()
		crafting()
		SwitchEquipmentBasedOnEquipmentIcons()
		if debug_mode == true:
			print("12 frames passed")
	if Engine.get_physics_frames() % 24 == 0: #1 frames per second, 1 second between frames
		displayLabels()
		experienceSystem()
		damage_effects_manager.effectDurations()
		allResourcesBarsAndLabels()
		money()
		waitTorReive()
		damage_effects_manager.regenerate()
		if debug_mode == true:
			print("24 frames passed")
	if Engine.get_physics_frames() % 48 == 0: #0.5 frames per second, 2 seconds between frames 
		frameRate()		
		if debug_mode == true:
			print("48 frames passed")
	if Engine.get_physics_frames() % 96 == 0: #0.25 frames per second, 4 seconds between frames
		hydration()
		hunger()
		displayClock()
		if debug_mode == true:
			print("96 frames passed")
	
	

onready var debug = $Debug
var debug_mode:bool = false
func _on_Debug_pressed():
	debug_mode = !debug_mode
	debug.visible = !debug.visible
func debug() -> void:
	var state_enum = Icons.state_list  # Access the enum from the singleton
	var state_value = state  # Get the current state value
	var state_name = state_enum.keys()[state_value]  # Convert enum to string

	var weapon_enum = Icons.weapon_type_list
	var weapon_value = weapon_type
	var weapon_name = weapon_enum.keys()[weapon_value]

	var main_weapon_enum = Icons.main_weap_list
	var main_weapon_value = main_weapon
	var main_weapon_name = main_weapon_enum.keys()[main_weapon_value]

	var sec_weapon_enum = Icons.sec_weap_list
	var sec_weapon_value = sec_weapon
	var sec_weapon_name = sec_weapon_enum.keys()[sec_weapon_value]
	# Prepare each line of the debug text separately
	var state_line = "\nState: " + state_name
	var weapon_line = "\nWeapon Stance: " + weapon_name
	var main_weapon_line = "\nRight Hand: " + main_weapon_name
	var sec_weapon_line = "\nLeft Hand: " + sec_weapon_name
	var stunned_line = "\nStunned: " + str(stunned_duration)
	var knockeddown_line = "\nKnocked Down: " + str(knockeddown_duration)
	var staggered_line = "\nStaggered: " + str(staggered_duration)
	var dir_assist = "\nDirection Assist: " + str(direction_assist)
	var long_base_atk_line = "\nLong Base Attack: " + str(long_base_atk) +"\n"+"\n"+"\n"
	# Add maximum engine physics frames and process frames
	var engine_frames_passed = "\nEngine ticks passed: " + str(Engine.get_physics_frames())
	var max_process_frames_line = "\nMax Process Frames: " + str(Engine.get_target_fps())
	var max_physics_frames_line = "\nPhysics ticks" + str(Engine.get_physics_interpolation_fraction())
	var num_nodes_line = "\nNumber of Nodes: " + str(get_tree().get_node_count())
	# Get dynamic memory usage using OS.get_dynamic_memory_usage()
	var dynamic_memory_bytes = OS.get_dynamic_memory_usage()
	# Convert bytes to megabytes (MB) and format to show values after the decimal point
	var dynamic_memory_mb = dynamic_memory_bytes / 1024.0 / 1024.0
	# Convert to string with two decimal places
	var dynamic_memory = "\nDynamic Memory: " + str(round(dynamic_memory_mb * 100) / 100) + " MB"
	# Get static memory usage using GDNative or external libraries
	var battery_line = "\nBattery left: " +str(OS.get_power_percent_left()) + "%"
	#Returns the number of logical CPU cores available on the host machine. 
	#On CPUs with HyperThreading enabled, this number will be greater than the number of physical CPU cores.
	var processor_count = "\nCPU cores free: " +str(OS.get_processor_count())
	var processor_name = "\nProcessor Name: " +str(OS.get_processor_name())
	#Returns the total number of available audio drivers.
	var audio_proc_count = "\nAudio drivers free: " +str(OS.get_audio_driver_count())
	var audio_name = "\nAudio drivers name: " +str(OS.get_audio_driver_name(1))
	var device_id = "\nDevice ID: " +str(OS.get_unique_id())
	var time_zone = "\nTimeZone: " + str(OS.get_time_zone_info())
	
	# Concatenate all lines into debug_text
	var debug_text = state_line+\
					weapon_line+\
					main_weapon_line+\
					sec_weapon_line+\
					stunned_line+\
					knockeddown_line+\
					staggered_line+\
					dir_assist+\
					long_base_atk_line+\
					max_process_frames_line+\
					num_nodes_line+\
					max_physics_frames_line+\
					engine_frames_passed+\
					dynamic_memory+\
					battery_line+\
					processor_count+\
					processor_name+\
					audio_proc_count+\
					audio_name+\
					device_id+\
					time_zone
	
	# Assign the constructed debug text to the Debug node's text property
	debug.text = debug_text

#________________________________Input-State-Animation-SkillBar System______________________________
var animation: AnimationPlayer
var blend: float = 0.22

var hold_to_base_atk:bool = false #if true holding the base attack buttons continues a combo of attacks, releasing the button stops the attacks midway, if false it will just play the attack animation as if it was a normal skill
var base_atk_duration:bool = false
var base_atk2_duration:bool = false
var base_atk3_duration:bool = false
var base_atk4_duration:bool = false

var throw_rock_duration:bool= false
var stomp_duration:bool= false
var kick_duration:bool= false

var backstep_duration:bool= false
var frontstep_duration:bool= false
var leftstep_duration:bool= false
var rightstep_duration:bool= false

var dash_duration:bool= false

var slide_duration:bool= false


var death_duration:bool = false

var staggered_duration:bool = false
var knockeddown_duration:bool = false


var overhead_slash_duration:bool = false
var overhead_slash_combo:bool = false
#___________________________________________________________________________________________________
var rising_slash_duration:bool = false
var heart_trust_duration:bool = false
#___________________________________________________________________________________________________
var cyclone_duration:bool = false
var cyclone_combo:bool = false
#___________________________________________________________________________________________________
var whirlwind_duration:bool = false
var whirlwind_combo:bool = false
#___________________________________________________________________________________________________

var taunt_duration:bool = false
var state = Icons.state_list.idle


func behaviourTree()-> void:
	if health < 0: 
		is_in_combat = false
		skill_queue.getInterrupted()
		clearParryAbsorb()
		stopBeingParlized()
		warning_screen.modulate = Color(0, 0, 0, 1)
		warning_screen.modulate.a = 1
		
		if health >= -100:
			if is_walking:
				animation.play("downed walk",0.35)
				movement_speed = 1
				health -= 1 * get_physics_process_delta_time()
				is_dead = false
			else:
				animation.play("downed idle",0.35)
				is_dead = false
									
		else:
			animation.play("dead",0.35)
			is_dead = true
	else:
		warning_screen.modulate.a = 0.0
		if skills == null or animation == null:
			print("mesh not instanced or animationPlayer not found")
		else:
			passiveActions()#this checks for stuns,staggers, knockdowns or other dis



func passiveActions()-> void:
	if knockeddown_duration == true:
		clearParryAbsorb()
		if health <= 0 :
			knockeddown_duration = false
			staggered_duration = false
		if parry == true:
			knockeddown_duration = false
			staggered_duration = false
		elif absorbing == true:
			knockeddown_duration = false
		else:
			can_walk = false
			is_walking = false
			horizontal_velocity = direction * 0
			skills.can_move = false
			if health > 15:
				animation.play("knocked down",blend)
				skill_queue.getInterrupted()

	elif staggered_duration == true:
		can_walk = false
		is_walking = false
		skills.can_move = false
		animation.play("staggered",blend)
		skill_queue.getInterrupted()
	elif stunned_duration > 0 and health >0:
		skill_queue.getInterrupted()
		Icons.gravity(self)
		animation.play("staggered",blend)
		can_walk = false
		is_walking = false
		skills.can_move = false
	else:
		activeActions()

func activeActions()->void:
	SkillQueueSystem()#DO NOT REMOVE THIS! it is neccessary to allow skill cancelling, skill cancelling doesn't work without skill queue, it has a toggle on off anyway for players that don't like it 
	if Input.is_action_pressed("rclick"):
		switchWeaponFromHandToSideOrBack()
		state == Icons.state_list.guard
		skill_queue.skillCancel("throw_rock")

	if dash_duration == true:
		directionToCamera()
		moveDuringAnimation(all_skills.backstep_distance)
		animation.play("dash",0.3,1.25)

	elif slide_duration == true:
		automaticTargetAssist()
		directionToCamera()
		moveDuringAnimation(all_skills.backstep_distance)
		animation.play("slide",blend)


	elif backstep_duration == true:
		directionToCamera()
		moveDuringAnimation(-all_skills.backstep_distance)
		animation.play("backstep",blend,1)

	elif frontstep_duration == true:
		directionToCamera()
		moveDuringAnimation(+all_skills.backstep_distance)
		animation.play("frontstep",blend,1)
		
	elif leftstep_duration == true:
		is_aiming = true
		moveSidewaysDuringAnimation(all_skills.backstep_distance)
		direction = -camera.global_transform.basis.z
		animation.play("leftstep",blend,1)

	elif rightstep_duration == true:
		is_aiming = true
		moveSidewaysDuringAnimation(-all_skills.backstep_distance)
		direction = -camera.global_transform.basis.z
		animation.play("rightstep",blend,1)
		
		
#Overhead Slash_________________________________________________________________________________
	elif overhead_slash_duration == true:
		automaticTargetAssist()
		if all_skills.can_overhead_slash == true:
			if resolve > all_skills.overhead_slash_cost:
				switchWeaponFromHandToSideOrBack()
				directionToCamera()
				clearParryAbsorb()
				moveDuringAnimation(all_skills.overhead_slash_distance)
				match weapon_type:
					Icons.weapon_type_list.sword:
						if overhead_slash_combo == false:
							animation.play("overhead slash sword",blend, melee_atk_speed - 0.15)
						else:
							animation.play("overhead slash sword",blend, melee_atk_speed + all_skills.overhead_slash_combo_speed_bonus)
					Icons.weapon_type_list.sword_shield:
						if overhead_slash_combo == false:
							animation.play("overhead slash sword",blend, melee_atk_speed- 0.15)
						else:
							animation.play("overhead slash sword",blend, melee_atk_speed + all_skills.overhead_slash_combo_speed_bonus)
					Icons.weapon_type_list.dual_swords:
						if overhead_slash_combo == false:
							animation.play("overhead slash sword",blend, melee_atk_speed- 0.15)
						else:
							animation.play("overhead slash sword",blend, melee_atk_speed + all_skills.overhead_slash_combo_speed_bonus)
					Icons.weapon_type_list.heavy:
						if overhead_slash_combo == false:
							animation.play("overhead slash heavy",blend, melee_atk_speed- 0.25)
						else:
							animation.play("overhead slash heavy",blend, melee_atk_speed + all_skills.overhead_slash_combo_speed_bonus)
			else:
				overhead_slash_duration = false
				returnToIdleBasedOnWeaponType()
		else:
			overhead_slash_duration = false
			returnToIdleBasedOnWeaponType()
#Whirlwind__________________________________________________________________________________________
	elif whirlwind_duration == true :
		automaticTargetAssist()
		directionToCamera()
		switchWeaponFromHandToSideOrBack()
		clearParryAbsorb()
		if all_skills.can_whirlwind == true:
			if resolve > all_skills.whirlwind_cost:
				match weapon_type:
					Icons.weapon_type_list.sword:
						animation.play("whirlwind sword",blend*1.5,melee_atk_speed+ 0.15)
						moveDuringAnimation(all_skills.whirlwind_distance)
					Icons.weapon_type_list.sword_shield:
						animation.play("whirlwind sword",blend*1.5,melee_atk_speed+ 0.15)
						moveDuringAnimation(all_skills.whirlwind_distance)
					Icons.weapon_type_list.dual_swords:
						animation.play("whirlwind sword",blend*1.5,melee_atk_speed + 0.1)
						moveDuringAnimation(all_skills.whirlwind_distance)
					Icons.weapon_type_list.heavy:
						animation.play("whirlwind heavy",blend*1.5,melee_atk_speed+ 0.15)
						moveDuringAnimation(all_skills.whirlwind_distance)
			else:
				whirlwind_duration = false
				returnToIdleBasedOnWeaponType()
		else:
			whirlwind_duration = false
			returnToIdleBasedOnWeaponType()
		
#Rising slash____________________________________________________________________________________
	elif rising_slash_duration == true:
		automaticTargetAssist()
		directionToCamera()
		switchWeaponFromHandToSideOrBack()
		clearParryAbsorb()
		moveDuringAnimation(6)
		match weapon_type:
					Icons.weapon_type_list.sword:
						animation.play("rising slash shield",blend, melee_atk_speed + 0.35)
					Icons.weapon_type_list.sword_shield:
						animation.play("rising slash shield",blend,melee_atk_speed + 0.35)
					Icons.weapon_type_list.dual_swords:
						animation.play("rising slash shield",blend, melee_atk_speed + 0.33)
					Icons.weapon_type_list.heavy:
						animation.play("rising slash heavy",blend,melee_atk_speed + 0.35)
#Cyclone____________________________________________________________________________________________
	elif cyclone_duration == true:
		automaticTargetAssist()
		directionToCamera()
		switchWeaponFromHandToSideOrBack()
		clearParryAbsorb()
		if all_skills.can_cyclone == true:
			if resolve > all_skills.cyclone_cost:
				moveDuringAnimation(all_skills.cyclone_motion)
				match weapon_type:
					Icons.weapon_type_list.sword:
						if cyclone_combo == false:
							animation.play("cyclone sword",blend,melee_atk_speed+ 0.25)
						else:
							animation.play("cyclone sword",blend,melee_atk_speed+ 1)
					Icons.weapon_type_list.sword_shield:
						if cyclone_combo == false:
							animation.play("cyclone sword",blend,melee_atk_speed+ 0.25)
						else:
							animation.play("cyclone sword",blend,melee_atk_speed+ 1)
					Icons.weapon_type_list.dual_swords:
						if cyclone_combo == false:
							animation.play("cyclone sword",blend,melee_atk_speed+ 0.25)
						else:
							animation.play("cyclone sword",blend,melee_atk_speed+ 1)
					Icons.weapon_type_list.heavy:
						if cyclone_combo == false:
							animation.play("cyclone heavy",blend,melee_atk_speed+ 0.15)
						else:
							animation.play("cyclone heavy",blend,melee_atk_speed+ 0.95)
			else:
				cyclone_duration = false
				returnToIdleBasedOnWeaponType()
		else:
			cyclone_duration = false
			returnToIdleBasedOnWeaponType()
#Heart trust____________________________________________________________________________________________
	elif heart_trust_duration == true:
		automaticTargetAssist()
		directionToCamera()
		switchWeaponFromHandToSideOrBack()
		clearParryAbsorb()
		if all_skills.can_heart_trust == true:
				match weapon_type:
					Icons.weapon_type_list.sword:
						animation.play("heart trust sword",blend*1.5,melee_atk_speed+ 0.55)
						moveDuringAnimation(4)
					Icons.weapon_type_list.sword_shield:
						animation.play("heart trust sword",blend*1.5,melee_atk_speed+ 0.35)
						moveDuringAnimation(3)
					Icons.weapon_type_list.dual_swords:
						animation.play("heart trust sword",blend*1.5,melee_atk_speed + 0.1)
						moveDuringAnimation(3.3)
					Icons.weapon_type_list.heavy:
						animation.play("heart trust sword",blend*1.5,melee_atk_speed + 0.15)
						moveDuringAnimation(6)
		else:
			heart_trust_duration = false
			returnToIdleBasedOnWeaponType()
#___________________________________________________________________________________________________
	elif taunt_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		switchWeaponFromHandToSideOrBack()
		can_walk = false
		is_walking = false
		if weapon_type == Icons.weapon_type_list.heavy:
			animation.play("taunt heavy",blend + 0.1,ferocity)
		else:
			animation.play("taunt",blend+ 0.1,ferocity)
			
#__________________IF THE PLAYER DECIDED TO PLAY WITH HOLD OFF, 1 CLICK = 1 BASE ATTTACK__________
	elif throw_rock_duration == true:
		direction = -camera.global_transform.basis.z
		can_walk = false
		animation.play("throw rock",blend,range_atk_speed)
		moveDuringAnimation(0)
		
	elif base_atk_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		baseAtkAnim()

	elif base_atk2_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		baseAtkAnim()

	elif base_atk3_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		match weapon_type:
			Icons.weapon_type_list.dual_swords:
				animation.play("combo(dual)",blend,melee_atk_speed + all_skills.combo_extr_speed)
				moveDuringAnimation(all_skills.combo_distance)
			Icons.weapon_type_list.heavy:
				if long_base_atk == true:
					animation.play("combo(heavy)",blend,melee_atk_speed + all_skills.combo_extr_speed)
					moveDuringAnimation(all_skills.combo_distance)

	elif base_atk4_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		match weapon_type:
			Icons.weapon_type_list.dual_swords:
				animation.play("combo(dual)",blend,melee_atk_speed + all_skills.combo_extr_speed)
				moveDuringAnimation(all_skills.combo_distance)
			Icons.weapon_type_list.heavy:
				if long_base_atk == true:
					animation.play("combo(heavy)",blend,melee_atk_speed + all_skills.combo_extr_speed)
					moveDuringAnimation(all_skills.combo_distance)

	elif stomp_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		
		animation.play("stomp",blend,melee_atk_speed * 1.2)
		moveDuringAnimation(2)
	elif kick_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		animation.play("kick",blend,agility)
		moveDuringAnimation(0)
	else:
		matchState()
		
func matchState()->void:
				match state:
					Icons.state_list.base_attack:
						is_in_combat = true
						directionToCamera()
						automaticTargetAssist()
						switchWeaponFromHandToSideOrBack()
						if weapon_type == Icons.weapon_type_list.bow:
							can_walk = false
						else:
							can_walk = true
						var slot = $UI/GUI/SkillBar/GridContainer/LClickSlot/Icon
						skills(slot)
					Icons.state_list.guard:
						switchWeaponFromHandToSideOrBack()
						var slot = $UI/GUI/SkillBar/GridContainer/RClickSlot/Icon
						skills(slot)
	#________________________________________movement states____________________________________________
					Icons.state_list.walk:
						clearParryAbsorb()
						walkAnimations()

					Icons.state_list.sprint:
						clearParryAbsorb()
						animation.play("run", 0,agility)
					Icons.state_list.run:
						clearParryAbsorb()
						animation.play("run",0,agility)
					Icons.state_list.climb:
						clearParryAbsorb()
						animation.play("climb cycle",blend, strength)
					Icons.state_list.idle:
						clearParryAbsorb()
						if is_in_combat:
							match weapon_type:
								Icons.weapon_type_list.fist:
									animation.play("idle fist",blend)
								Icons.weapon_type_list.sword:
									animation.play("idle sword",blend)
								Icons.weapon_type_list.sword_shield:
									animation.play("idle shield",blend)
								Icons.weapon_type_list.dual_swords:
									animation.play("idle sword",blend)
								Icons.weapon_type_list.bow:
									animation.play("idle bow",blend)
								Icons.weapon_type_list.heavy:
									animation.play("idle heavy",blend)
						else:
							animation.play("idle",0.2,1)

	#skillbar stuff_____________________________________________________________________________________
					Icons.state_list.skill1:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot1/Icon
						skills(slot)
					Icons.state_list.skill2:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot2/Icon
						skills(slot)
					Icons.state_list.skill3:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot3/Icon
						skills(slot)
					Icons.state_list.skill4:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot4/Icon
						skills(slot)
					Icons.state_list.skill5:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot5/Icon
						skills(slot)
					Icons.state_list.skill6:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot6/Icon
						skills(slot)
					Icons.state_list.skill7:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot7/Icon
						skills(slot)
					Icons.state_list.skill8:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot8/Icon
						skills(slot)
					Icons.state_list.skill9:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot9/Icon
						skills(slot)
					Icons.state_list.skill0:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot10/Icon
						skills(slot)
					Icons.state_list.skillQ:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot11/Icon
						skills(slot)
					Icons.state_list.skillE:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot12/Icon
						skills(slot)
					Icons.state_list.skillR:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot13/Icon
						skills(slot)
					Icons.state_list.skillT:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot14/Icon
						skills(slot)
					Icons.state_list.skillF:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot15/Icon
						skills(slot)
					Icons.state_list.skillG:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot16/Icon
						skills(slot)
					Icons.state_list.skillY:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot17/Icon
						skills(slot)
					Icons.state_list.skillH:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot18/Icon
						skills(slot)
					Icons.state_list.skillV:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot19/Icon
						skills(slot)
					Icons.state_list.skillB:
						var slot = $UI/GUI/SkillBar/GridContainer/Slot20/Icon
						skills(slot)
					Icons.state_list.jump:
						animation.play("jump",blend)
					Icons.state_list.fall:
						animation.play("fall",blend)

onready var l_click_slot = $UI/GUI/SkillBar/GridContainer/LClickSlot
onready var r_click_slot = $UI/GUI/SkillBar/GridContainer/RClickSlot
onready var skill_queue = $UI/GUI/SkillBar/SkillQueue


var long_base_atk:bool = false


func _on_baseatkswitch_pressed():
	long_base_atk = !long_base_atk

func skills(slot)-> void:
	if slot != null:
		if slot.texture != null:
#Dash_______________________________________________________________________________________________
			if slot.texture.resource_path == Icons.dash.get_path() and dash_duration == false:
					if all_skills.can_dash == false:
						dash_duration  = false
						returnToIdleBasedOnWeaponType()
					else:
						if resolve <= all_skills.dash_cost:
							returnToIdleBasedOnWeaponType()
							dash_duration = false
							skill_queue.interruptBaseAtk()
						else:
							resolve -= all_skills.dash_cost
							dash_duration = true
							if skill_cancelling == true:
								skill_queue.skillCancel("dash")
							
								
#Slide______________________________________________________________________________________________
			if slot.texture.resource_path == Icons.slide.get_path():
				if all_skills.can_slide == false:
					slide_duration  = false
					returnToIdleBasedOnWeaponType()
				else:
					slide_duration = true
					skill_queue.interruptBaseAtk()
					if skill_cancelling == true:
						skill_queue.skillCancel("slide")
#Backstep______________________________________________________________________________________________
			elif slot.texture.resource_path == Icons.backstep.get_path():
				if all_skills.can_backstep == false:
					returnToIdleBasedOnWeaponType()
					frontstep_duration = false
					backstep_duration = false
					leftstep_duration = false
					rightstep_duration = false
				else:
					skill_queue.interruptBaseAtk()
					if Input.is_action_pressed("forward"):
						frontstep_duration = true
					elif Input.is_action_pressed("right"):
						rightstep_duration = true	
					elif Input.is_action_pressed("left"):
						leftstep_duration = true
					else:
						backstep_duration = true
					if skill_cancelling == true:
						skill_queue.skillCancel("backstep")
#Lclick and Rclick__________________________________________________________________________________
#fist
			elif slot.texture.resource_path == Icons.punch.get_path():
				if hold_to_base_atk == true:
					animation.play("fist hold",blend,melee_atk_speed + 0.15)
					directionToCamera()
					moveDuringAnimation(2.5)
				else:
					base_atk_duration = true
					is_in_combat = true
						
			elif slot.texture.resource_path == Icons.punch2.get_path():
				if hold_to_base_atk == false:
					base_atk2_duration = true
					is_in_combat = true
#_________________________________________STOMP_____________________________________________________
			elif slot.texture.resource_path == Icons.stomp.get_path():
				if all_skills.can_stomp == false:
					stomp_duration = false
					returnToIdleBasedOnWeaponType()
				else:
					stomp_duration = true
				is_in_combat = true
				switchWeaponFromHandToSideOrBack()
				skill_queue.skillCancel("stomp")
#_________________________________________Kick______________________________________________________
			elif slot.texture.resource_path == Icons.kick.get_path():
				if all_skills.can_kick == false:
					kick_duration = false
					returnToIdleBasedOnWeaponType()
				else:
					if kick_icon.points >0:
						if resolve > all_skills.kick_cost:
							kick_duration = true
							is_in_combat = true
							switchWeaponFromHandToSideOrBack()
							skill_queue.skillCancel("kick")
							
#________________________________________THROW ROCKS________________________________________________
			elif slot.texture.resource_path == Icons.throw_rock.get_path():
				if hold_to_base_atk == false:
					throw_rock_duration = true
					is_in_combat = true
				else:
					is_walking = false
					can_walk = false
					is_in_combat = true
					direction = -camera.global_transform.basis.z
					moveDuringAnimation(0)
					animation.play("throw rock",blend,range_atk_speed + 0.15)
#sword

			elif slot.texture.resource_path == Icons.vanguard_icons["combo_switch"].get_path():
				if all_skills.can_combo_switch == true: 
					all_skills.comboSwitchCD()



			elif slot.texture.resource_path == Icons.vanguard_icons["base_atk"].get_path():
				if hold_to_base_atk == true:
					directionToCamera()
					baseAtkAnim()
				else:
					base_atk_duration = true
			elif slot.texture.resource_path == Icons.vanguard_icons["base_atk2"].get_path():
				if hold_to_base_atk == false:
					base_atk2_duration = true
					base_atk3_duration = true
					base_atk4_duration = true
					
			elif slot.texture.resource_path == Icons.vanguard_icons["guard_sword"].get_path():
				if resolve > 0:
					is_walking = false
					can_walk = false
					is_in_combat = true
					resolve -= 1 * get_physics_process_delta_time()
					if weapon_type == Icons.weapon_type_list.dual_swords:
						animation.play("dual block",blend)
					else:
						animation.play("sword block",blend)
				else:
					returnToIdleBasedOnWeaponType()
			elif slot.texture.resource_path == Icons.vanguard_icons["guard_shield"].get_path():
				if resolve > 0:
					is_walking = false
					can_walk = false
					resolve -= 1 * get_physics_process_delta_time()
					animation.play("shield block",blend)
					automaticTargetAssist()
				else:
					returnToIdleBasedOnWeaponType()
#bow 
			elif slot.texture.resource_path == Icons.quick_shot.get_path():
				if weapon_type == Icons.weapon_type_list.bow:
					is_aiming = true
					can_walk = false
					skills.can_move = false
					is_in_combat = true
					if is_walking == false:
						animation.play("shoot",blend,range_atk_speed + 0.4)

#melee weapon skills
#__________________________________________  overhead slash    _____________________________________
			elif slot.texture.resource_path == Icons.vanguard_icons["sunder"].get_path():
				if overhead_icon.points >0:
					if all_skills.can_overhead_slash == true:
						if resolve > all_skills.overhead_slash_cost:
							if weapon_type != Icons.weapon_type_list.fist:
								overhead_slash_duration = true
								is_in_combat = true
								if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
									skill_queue.skillCancel("sunder")
							else:
								returnToIdleBasedOnWeaponType()
								overhead_slash_duration = false
						else:
							returnToIdleBasedOnWeaponType()
							overhead_slash_duration = false
					else:
						returnToIdleBasedOnWeaponType()
						overhead_slash_duration = false
#___________________________________________________________________________________________________
			elif slot.texture.resource_path == Icons.vanguard_icons["taunt"].get_path():
					if taunt_icon.points >0:
						if all_skills.can_taunt == true:
							if resolve > all_skills.taunt_cost:
								taunt_duration = true
								is_walking = false
								can_walk = false
								is_in_combat = true
								if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
									skill_queue.skillCancel("taunt")
							else:
								returnToIdleBasedOnWeaponType()
								taunt_duration = false
						else:
							returnToIdleBasedOnWeaponType()
							taunt_duration = false
					else:
						returnToIdleBasedOnWeaponType()
						taunt_duration = false
#_________________________________________ rising slash ____________________________________________
			elif slot.texture.resource_path == Icons.vanguard_icons["rising_slash"].get_path():
					if rising_icon.points >0:
						if all_skills.can_rising_slash == true:
							if resolve > all_skills.rising_slash_cost:
								if weapon_type != Icons.weapon_type_list.fist:
									rising_slash_duration = true
									is_in_combat = true
									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
										skill_queue.skillCancel("rising_slash")
									else:
										pass
							else:
								returnToIdleBasedOnWeaponType()
								rising_slash_duration = false
						else:
							returnToIdleBasedOnWeaponType()
							rising_slash_duration = false
					else:
						returnToIdleBasedOnWeaponType()
						rising_slash_duration = false
#_________________________________________  cyclone   ______________________________________________
			elif slot.texture.resource_path == Icons.vanguard_icons["cyclone"].get_path():
					if cyclone_icon.points >0 :
						if all_skills.can_cyclone == true:
							if resolve > all_skills.cyclone_cost:
								if weapon_type != Icons.weapon_type_list.fist:
									cyclone_duration = true
									is_in_combat = true
									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
										skill_queue.skillCancel("cyclone")
							else:
								returnToIdleBasedOnWeaponType()
								cyclone_duration = false
						else:
							returnToIdleBasedOnWeaponType()
							cyclone_duration = false
					else:
						returnToIdleBasedOnWeaponType()
						cyclone_duration = false
#__________________________________________ Whirlwind _____________________________________________
			elif slot.texture.resource_path == Icons.vanguard_icons["whirlwind"].get_path():
					if whirlwind_icon.points >0 :
						if all_skills.can_whirlwind == true:
							if resolve > all_skills.whirlwind_cost:
								if weapon_type != Icons.weapon_type_list.fist:
									whirlwind_duration = true
									is_in_combat = true
									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
										skill_queue.skillCancel("whirlwind")
							else:
								returnToIdleBasedOnWeaponType()
								whirlwind_duration = false
						else:
							returnToIdleBasedOnWeaponType()
							whirlwind_duration = false
					else:
						returnToIdleBasedOnWeaponType()
						whirlwind_duration = false
#__________________________________________ Heart Trust ____________________________________________
			elif slot.texture.resource_path == Icons.vanguard_icons["heart_trust"].get_path():
					if heart_trust_icon.points >0 :
						if all_skills.can_heart_trust == true:
							if resolve > all_skills.heart_trust_cost:
								if weapon_type != Icons.weapon_type_list.fist:
									heart_trust_duration = true
									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
										skill_queue.skillCancel("heart_trust")
							else:
								returnToIdleBasedOnWeaponType()
								heart_trust_duration = false
						else:
							returnToIdleBasedOnWeaponType()
							heart_trust_duration = false
					else:
						returnToIdleBasedOnWeaponType()
						heart_trust_duration = false

#ranged bow skills
			elif slot.texture.resource_path == Icons.full_draw.get_path():
				if weapon_type == Icons.weapon_type_list.bow:
					is_aiming = true
					can_walk = false
					skills.can_move = false
					animation.play("full draw",0.3,range_atk_speed)
					
					
					
			elif slot.texture.resource_path == Icons.grappling_hook.get_path():
				if all_skills.can_grappling_hook == true:
					direction = -camera.global_transform.basis.z
					hookEnemies()
					all_skills.grapplingHookCD()
					
					

#consumables________________________________________________________________________________________
			elif slot.texture.resource_path == Icons.red_potion.get_path():
				slot.get_parent().displayQuantity()
				for child in inventory_grid.get_children():
					if child.is_in_group("Inventory"):
						var index_str = child.get_name().split("InventorySlot")[1]
						var index = int(index_str)
						var button = inventory_grid.get_node("InventorySlot" + str(index))
						button = inventory_grid.get_node("InventorySlot" + str(index))
						if health < max_health:
							Icons.consumeRedPotion(self,button,inventory_grid,true,slot.get_parent())
						if health > max_health:
							health = max_health 

func returnToIdleBasedOnWeaponType():
	match weapon_type:
			Icons.weapon_type_list.fist:
				animation.play("idle fist",0.3)
			Icons.weapon_type_list.sword:
				animation.play("idle sword",0.3)
			Icons.weapon_type_list.dual_swords:
				animation.play("idle sword",0.3)
			Icons.weapon_type_list.bow:
				animation.play("idle bow",0.3)
			Icons.weapon_type_list.heavy:
				animation.play("idle heavy")
func baseAtkAnim()-> void:
	match weapon_type:
		Icons.weapon_type_list.sword:
			if long_base_atk == true:
				animation.play("combo sword",blend,melee_atk_speed + all_skills.combo_extr_speed)
				moveDuringAnimation(all_skills.combo_distance)
			else:
				animation.play("cleave sword",blend,melee_atk_speed)
				moveDuringAnimation(all_skills.cleave_distance)
		Icons.weapon_type_list.dual_swords:
			var dual_wield_compensation:float = 1.105 #People have the feeling that two swords should be faster, not realistic, but it breaks their "game feel" 
			if long_base_atk == true:
				animation.play("combo(dual)",blend,melee_atk_speed + all_skills.combo_extr_speed * dual_wield_compensation)
				moveDuringAnimation(all_skills.combo_distance)
			else:
				animation.play("cleave dual",blend,melee_atk_speed * dual_wield_compensation)
				moveDuringAnimation(all_skills.cleave_distance)
		Icons.weapon_type_list.heavy:
			if long_base_atk == true:
				animation.play("combo(heavy)",blend,melee_atk_speed + all_skills.combo_extr_speed)
				moveDuringAnimation(all_skills.combo_distance)
			else:
				animation.play("cleave",blend,melee_atk_speed)
				moveDuringAnimation(all_skills.cleave_distance)


var previous_position = Vector3.ZERO
func walkAnimations() -> void:
	if Input.is_action_pressed("autoturn") and closest_target != null:
		if is_in_combat== true:
			if Input.is_action_pressed("right"):
				animation.play("strafeRCombat")
			elif Input.is_action_pressed("left"):
				animation.play("strafeLCombat")
			else:
				# Calculate direction to the closest target
				var to_target = (closest_target.global_transform.origin - global_transform.origin).normalized()
				# Calculate the current movement direction
				var current_position = global_transform.origin
				var movement_direction = (current_position - previous_position).normalized()
				
				# Update the previous position
				previous_position = current_position
				
				# Check if moving towards or away from the closest target
				if movement_direction.dot(to_target) > 0:
					animation.play("strafeFCombat")
				else:
					animation.play_backwards("strafeFCombat")

	else:
		if is_in_combat:
			match weapon_type:
				Icons.weapon_type_list.fist:
					animation.play("walk sword",0,1)
				Icons.weapon_type_list.bow: 
					animation.play("walk bow",0,1)	
				Icons.weapon_type_list.sword:
					animation.play("walk sword",0,1)
				Icons.weapon_type_list.sword_shield:
					animation.play("walk shield")
				Icons.weapon_type_list.dual_swords:
					animation.play("walk sword",0,1)
				Icons.weapon_type_list.heavy:
					animation.play("walk heavy",0,1)
		else:
			animation.play("walk",0,1)
							
var skill_cancelling:bool = true#this only works with the SkillQueueSystem() and serves to interupt skills with other skills 

func stopBeingParlized()-> void:
	staggered_duration = false
	knockeddown_duration = false
	stunned_duration = 0
# Toggle the hold_to_base_atk variable and change the color of BaseAtkMode accordingly
func _on_BaseAtkMode_pressed():
	hold_to_base_atk = !hold_to_base_atk
	switchButtonTextures()
func SkillQueueSystem()-> void:
	if skill_queue.queue_skills == true:
		if state == Icons.state_list.skill1:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot1/Icon
			skills(slot)
		if state == Icons.state_list.skill2:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot2/Icon
			skills(slot)
		if state == Icons.state_list.skill3:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot3/Icon
			skills(slot)
		if state == Icons.state_list.skill4:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot4/Icon
			skills(slot)
		if state == Icons.state_list.skill5:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot5/Icon
			skills(slot)
		if state == Icons.state_list.skill6:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot6/Icon
			skills(slot)
		if state == Icons.state_list.skill7:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot7/Icon
			skills(slot)
		if state == Icons.state_list.skill8:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot8/Icon
			skills(slot)
		if state == Icons.state_list.skill9:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot9/Icon
			skills(slot)
		if state == Icons.state_list.skill0:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot10/Icon
			skills(slot)
		if state == Icons.state_list.skillQ:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot11/Icon
			skills(slot)
		elif state == Icons.state_list.skillE:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot12/Icon
			skills(slot)
		if state == Icons.state_list.skillR:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot13/Icon
			skills(slot)
		if state == Icons.state_list.skillT:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot14/Icon
			skills(slot)
		if state == Icons.state_list.skillF:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot15/Icon
			skills(slot)
		if state == Icons.state_list.skillG:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot16/Icon
			skills(slot)
		if state == Icons.state_list.skillY:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot17/Icon
			skills(slot)
		if state == Icons.state_list.skillH:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot18/Icon
			skills(slot)
		if state == Icons.state_list.skillV:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot19/Icon
			skills(slot)
		if state == Icons.state_list.skillB:
			var slot = $UI/GUI/SkillBar/GridContainer/Slot20/Icon
			skills(slot)
func moveDuringAnimation(speed):
	if !is_on_wall():
		if skills.can_move == true:
			horizontal_velocity = direction * speed 
			movement_speed = speed
		elif skills.can_move == false:
			horizontal_velocity = direction * 0
			movement_speed = 0
func moveSidewaysDuringAnimation(speed):
	if !is_on_wall():
		horizontal_velocity = -camera.global_transform.basis.x * speed 
var sprint_animation_speed: float = 1
var anim_cancel:bool = true #If true using abilities and skills interupts base attacks or other animations
func inputToState():
	if  health < 0.001:
		state = Icons.state_list.downed
	elif health < -100:
		is_dead = true
	else:
#on water
		if is_swimming:
			state = Icons.state_list.swim

		elif not is_on_floor() and not is_climbing and not is_swimming:
			state = Icons.state_list.fall
	#attacks________________________________________________________________________________________
		elif Input.is_action_pressed("rclick") and !cursor_visible: #DON'T MOVE THIS, RCLICK STAYS FOR ANIM CANCEL
			if !is_walking:
				state = Icons.state_list.guard
			else:
				state = Icons.state_list.walk
		
		elif anim_cancel == false:#We check twice for "attack" input based on animation cancelling settings 
			if Input.is_action_pressed("attack") and !cursor_visible: 
				state = Icons.state_list.base_attack
	#skills put these below the walk elif statment in case of keybinding bugs, as of now it works so no need
		elif Input.is_action_pressed("1"):
				state = Icons.state_list.skill1
		elif Input.is_action_pressed("2"):
				state = Icons.state_list.skill2
		elif Input.is_action_pressed("3"):
				state = Icons.state_list.skill3
		elif Input.is_action_pressed("4"):
				state = Icons.state_list.skill4
		elif Input.is_action_pressed("5"):
				state = Icons.state_list.skill5
		elif Input.is_action_pressed("6"):
				state = Icons.state_list.skill6
		elif Input.is_action_pressed("7"):
				state = Icons.state_list.skill7
		elif Input.is_action_pressed("8"):
				state = Icons.state_list.skill8
		elif Input.is_action_pressed("9"):
				state = Icons.state_list.skill9
		elif Input.is_action_pressed("0"):
				state = Icons.state_list.skill0
		elif Input.is_action_pressed("Q"):
				state = Icons.state_list.skillQ
		elif Input.is_action_pressed("E"):
			state = Icons.state_list.skillE
		elif Input.is_action_pressed("R"):
				state = Icons.state_list.skillR
		elif Input.is_action_pressed("F"):
				state = Icons.state_list.skillF
		elif Input.is_action_pressed("R"):
				state = Icons.state_list.skillR
		elif Input.is_action_pressed("T"):
				state = Icons.state_list.skillT
		elif Input.is_action_pressed("G"):
				state = Icons.state_list.skillG
		elif Input.is_action_pressed("H"):
				state = Icons.state_list.skillH
		elif Input.is_action_pressed("Y"):
				state = Icons.state_list.skillY
		elif Input.is_action_pressed("V"):
				state = Icons.state_list.skillV
		elif Input.is_action_pressed("B"):
				state = Icons.state_list.skillB
				
				
		elif Input.is_action_pressed("attack") and !cursor_visible: 
			state = Icons.state_list.base_attack
	#_______________________________________________________________________________
			
		elif is_sprinting == true:
				state =  Icons.state_list.sprint
				
		elif is_running:
				state = Icons.state_list.run

		elif is_walking:
				state =  Icons.state_list.walk
		elif Input.is_action_pressed("forward") or Input.is_action_pressed("left") or  Input.is_action_pressed("right") or  Input.is_action_pressed("backward"):
				if Input.is_action_pressed("attack"):
					can_walk = false
				elif  Input.is_action_pressed("aim"):
					can_walk = false
				elif Input.is_action_pressed("rclick"):
					can_walk = false
				else:
					state =  Icons.state_list.walk
					can_walk = true
		elif Input.is_action_pressed("crouch"):
			state =  Icons.state_list.crouch
		else:
			if health >0:
				state =  Icons.state_list.idle

		
#_______________________________________________Combat______________________________________________
"""
@Ceisri
Documentation String: 
	rotateTowardsEnemy() is a very simple and straight forward function that finds the closest entity in the entire game 
	and rtoates the player towards that entity when the function is called, the rotation is done using direction 
	the variable direction_assist is not going to be used directly in rotateTowardsEnemy() but inside all attacks. 
	if enabled, all attacks will automatically call automaticTargetAssist()
"""

var closest_target = null
func rotateTowardsEnemy() -> void:
	var closest_target = null
	var closest_distance: float = 20.0

	# Get all nodes in the "Entity" group
	var entities = get_tree().get_nodes_in_group("Entity")

	# List to hold entities and their health within range
	var targets_in_range = []

	# Find targets within the closest distance and add to list
	for entity in entities:
		if entity != self:
			var distance = global_transform.origin.distance_to(entity.global_transform.origin)
			if distance < closest_distance and entity.health > 0:
				targets_in_range.append(entity)

	# Find the target with the lowest health or closest distance if health is the same
	for target in targets_in_range:
		if closest_target == null:
			closest_target = target
		elif target.health < closest_target.health:
			closest_target = target
		elif target.health == closest_target.health:
			var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
			var distance_to_closest = global_transform.origin.distance_to(closest_target.global_transform.origin)
			if distance_to_target < distance_to_closest:
				closest_target = target

	# Set direction towards the target with the lowest health or closest distance
	if closest_target:
		direction = (closest_target.global_transform.origin - global_transform.origin).normalized()




func manualTargetAssit() -> void:
	if is_in_combat == true:
		if Input.is_action_pressed("autoturn"):
			rotateTowardsEnemy()
		
		
var direction_assist:bool = false # we use this in attacks to auto rotate the direction towards enemies 
onready var dir_assist_check:CheckBox = $UI/GUI/Menu/DirectionAssist
func _on_DirectionAssist_toggled(button_pressed):
	if dir_assist_check.pressed == true:
		direction_assist = true
	else:
		direction_assist = false
	
	
func automaticTargetAssist() ->void:
	if direction_assist == true:
		rotateTowardsEnemy()
		

func attack()->void:
	if Input.is_action_pressed("attack"):
		is_attacking = true
	else:
		is_attacking = false


func pullEnemy(pull_distance, enemy, pull_speed)->void:
	var direction_to_enemy = global_transform.origin - enemy.global_transform.origin
	direction_to_enemy = direction_to_enemy.normalized()
	var motion = direction_to_enemy * pull_speed
	var acceleration_time = pull_speed / 2.0
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = enemy.move_and_collide(motion)
	
	hook_mesh.visible = true
	
	if collision: # this checks if the enemy hits a wall after being pulled
		enemy.takeDamage(10, 10, self, 1, "bleed") # the enemy takes damage from being pulled into something
		# Calculate bounce-back direction
		var normal = collision.normal
		var bounce_motion = -4 * normal * normal.dot(motion) + motion
		# Move the enemy slightly away from the wall to avoid sticking
		enemy.translation += normal * 0.1 * collision.travel # afterwards they are pushed back
		# Tween the bounce-back motion
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + bounce_motion * pull_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		# Tween the movement over time with initial acceleration followed by instant stop
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + motion * pull_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(enemy, "translation", enemy.translation + motion * pull_distance, enemy.translation + motion * (pull_distance - deceleration_distance), acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, acceleration_time)
		tween.start()




func _on_Tween_tween_completed(object, key)->void:
	hook_mesh.visible = false

onready var hook_ray:RayCast = $Camroot/h/v/Camera/Aim/hook_ray
onready var hook_mesh:MeshInstance = $Camroot/h/v/Camera/Aim/hook
func hookEnemies() -> void:
	var instigator:KinematicBody = self 
	if hook_ray.is_colliding():
		var body = hook_ray.get_collider()
		var distance = global_transform.origin.distance_to(body.global_transform.origin)
		if body != null:
			if body != self:
				if body.is_in_group("Entity"):
					if body.has_method("getKnockedDown"):
						if body.has_method("lookTarget"):
							body.lookTarget(12)
							if body.health >  body.max_health *  0.1:
								if body.balance < 3:
									body.getKnockedDown(instigator)
					pullEnemy(distance, body, 0.5 + (distance * 0.01))
				# @Ceisri 
				# Managed to make this work, except sometimes the hook pulls the player thru collisions
				# not gonna bother with it for now, the function is found at "res://scripts/DeprecatedScripts/GrapplingHook.gd"
				#else:
					#pullPlayer((distance * 0.01),(distance * 0.01))



func pushEnemyAway(push_distance, enemy, push_speed)->void:
	var direction_to_enemy = enemy.global_transform.origin - global_transform.origin
	direction_to_enemy.y = 0  # No vertical push
	direction_to_enemy = direction_to_enemy.normalized()
	var motion = direction_to_enemy * push_speed
	var acceleration_time = push_speed / 2.0
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = enemy.move_and_collide(motion)
	if collision: #this checks the enemy hits a wall after you punch him 
		enemy.takeDamage(10, 10, self, 1, "bleed")#the enemy takes damage from being pushed into something
		# Calculate bounce-back direction
		var normal = collision.normal
		var bounce_motion = -4 * normal * normal.dot(motion) + motion
		# Move the enemy slightly away from the wall to avoid sticking
		enemy.translation += normal * 0.1 * collision.travel#afterwards he is pushed back
		# Tween the bounce-back motion
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + bounce_motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		# Tween the movement over time with initial acceleration followed by instant stop
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(enemy, "translation", enemy.translation + motion * push_distance, enemy.translation + motion * (push_distance - deceleration_distance), acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, acceleration_time)
		tween.start()
		
		
func isFacingSelf(enemy: Node, threshold: float) -> bool:
	# Get the global transform of the enemy
	var enemy_global_transform = enemy.global_transform
	# Get the global position of the calling object (self)
	var self_global_transform = get_global_transform()
	var self_position = self_global_transform.origin
	# Get the global position of the enemy
	var enemy_position = enemy_global_transform.origin
	# Calculate the direction vector from the calling object (self) to the enemy
	var direction_to_enemy = (enemy_position - self_position).normalized()
	# Get the facing direction of the enemy from its Mesh node
	var enemy_facing_direction = Vector3.ZERO
	var enemy_mesh = enemy.get_node("Mesh")
	if enemy_mesh:
		enemy_facing_direction = enemy_mesh.global_transform.basis.z.normalized()
	else:# If Mesh node is not found, use the default facing direction of the enemy
		enemy_facing_direction = enemy_global_transform.basis.z.normalized()
	# Calculate the dot product between the enemy's facing direction and the direction to the calling object (self)
	var dot_product = -enemy_facing_direction.dot(direction_to_enemy)
	# If the dot product is greater than a certain threshold, consider the enemy is facing the calling object (self)
	return dot_product >= threshold
var parry: bool =  false
var absorbing: bool = false
func clearParryAbsorb()-> void:
	parry = false
	absorbing = false
	is_aiming = false

onready var damage_effects_manager = $"Damage&Effects"
func takeStagger(stagger_chance: float) -> void:
	damage_effects_manager.takeStagger(stagger_chance)
onready var damage_tween:Tween = $"Damage&Effects/Tween"
onready var warning_screen:TextureRect = $UI/GUI/WarningScreen
func damageEffects() -> void:
	# Set the initial transparency of the damage screen
	warning_screen.modulate.a = 0.0
	warning_screen.modulate = Color(1, 0, 0, 0)
	# Start the tween for the damage screen transparency
	damage_tween.interpolate_property(warning_screen, "modulate:a", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	damage_tween.interpolate_property(warning_screen, "modulate:a", 1.0, 0.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0.5) 
	# Start the tween
	damage_tween.start()


func takeDamage(damage:float, aggro_power:float, instigator:Node, stagger_chance:float, damage_type:String)-> void:
	knockeddown_duration = false #don't remove, it's here for "prevention", sometimes the enemies can permantly get you stuck in knockdown duration, no, using this here doesn't make the player immune
	staggered_duration = false#don't remove, it's here for "prevention", sometimes the enemies can permantly get you stuck in staggered duration, no, using this here doesn't make the player immune
	allResourcesBarsAndLabels()
	damage_effects_manager.takeDamagePlayer(damage, aggro_power, instigator, stagger_chance, damage_type)
	if damage > health * 0.10:
		damageEffects()

func getKnockedDown(instigator)-> void:#call this for skills that have a different knockdown chance
	var text = Icons.floatingtext_damage.instance()
	damage_effects_manager. getKnockedDownPlayer(instigator)
	text.status = "Knocked Down!"
	add_child(text)


func takeHealing(healing:float,healer:Node)-> void:
	damage_effects_manager.takeHealing(healing,healer)
	
var lifesteal_pop = preload("res://UI/lifestealandhealing.tscn")	
func lifesteal(damage_to_take)-> void:#This is called by the enemy's script when they take damage
	if health > max_health:
		health = max_health 
	damage_effects_manager.lifesteal(damage_to_take)

#_____________________________________DEATH AND LIFE STATE__________________________________________
onready var revival_label:Label =  $UI/GUI/SkillBar/ReviveLabel
onready var struggle_button:Button = $UI/GUI/SkillBar/Struggle
onready var revive_here:Button = $UI/GUI/SkillBar/ReviveHere
onready var revive_here_free:Button = $UI/GUI/SkillBar/ReviveHereFree
onready var revive_in_town:Button = $UI/GUI/SkillBar/ReviveInTown

var is_dead:bool = false
var revival_wait_time:int = 300
var struggles:int = 15
var revival_cost:int =  500
func waitTorReive()->void:
	if health <= 0 :
		revival_wait_time -= 1
func deathLife(delta)->void:
	hideShowDeath()
	if health >0:
		climbing()
		fieldOfView()
		is_dead = false
	else:
		skill_queue.getInterrupted()
		if revival_wait_time >0:
			revival_label.text = "Wait" + str(revival_wait_time) + " seconds"
		else:
			revival_label.text = "Free revival ready!"
func hideShowDeath()->void:
	if health <=0:
		knockeddown_duration = false
		staggered_duration = false
		stunned_duration = 0 
		can_walk = true
		state = Icons.state_list.downed
		stopBeingParlized()
		skill_queue.getInterrupted()
		revival_label.visible = true
		struggle_button.visible = true
		revive_here.visible = true
		revive_here.text = "Revive here(" + str(revival_cost/100) + "silver)"
		revive_here_free.visible = true
		revive_in_town.visible = true
		$UI/GUI/SkillBar/filler.visible = true

	else:
		revival_label.visible = false
		struggle_button.visible = false
		revive_here.visible = false
		revive_here_free.visible = false
		revive_in_town.visible = false
		$UI/GUI/SkillBar/filler.visible = false
func reviveHereFree()->void:
	if revival_wait_time <= 0:
		state  = Icons.state_list.idle
		health = max_health * 0.25
		resolve = max_resolve * 0.25
		nefis = max_nefis * 0.05
		aefis = max_aefis * 0.05
		breath = max_breath * 0.5
		kilocalories = max_kilocalories * 0.1
		water = max_water * 0.1
		revival_wait_time = 120
		struggles = 15
		staggered_duration = false
		Icons.gravity(self)
		is_dead = false
func reviveHere()->void:#Paid option
	if coins >= revival_cost:
		coins-= revival_cost
		state  = Icons.state_list.idle
		health = max_health * 0.5
		resolve = max_resolve * 0.5
		nefis = max_nefis 
		aefis = max_aefis 
		breath = max_breath 
		kilocalories = max_kilocalories 
		water = max_water 
		revival_wait_time = 120
		struggles = 15
		staggered_duration = false
		Icons.gravity(self)
		is_dead = false
func struggle()->void:
	if struggles >0:
		revival_wait_time -= rng.randi_range(1,6)
		struggles -= 1 
	struggle_button.text = "Struggle:" + str(struggles)+ " remaining"
	
func reviveInTown()->void:
	state  = Icons.state_list.idle
	health = max_health 
	resolve = max_resolve 
	nefis = max_nefis 
	aefis = max_aefis 
	breath = max_breath
	kilocalories = max_kilocalories 
	water = max_water 
	revival_wait_time = 120
	struggles = 5
	staggered_duration = false
	translation = Vector3(0,5, 0)
	can_walk = true
	Icons.gravity(self)
	is_dead = false




func canIWalk()->void:
	if is_dead == false:
		if stunned_duration == 0:
			if knockeddown_duration == false:
				if staggered_duration == false:
					if taunt_duration == false:
						walk() 
#Catprisbrey's open source template
#The template is pretty much the same, except there's no  auto-rotation, I personally don't like 
#Dark's souls movement system, also setting the direction based on camera is better for when 
#strafing/aiming mode is on, still left the original on even I never use anyway 						
var h_rot 
var is_in_combat = false
var enabled_climbing = false
var is_crouching = false
var is_sprinting = false
var sprint_speed = 10
const base_max_sprint_speed = 25
var max_sprint_speed = 25
var max_sprint_animation_speed = 2.5

var can_walk:bool = true 
var is_attacking = bool()
var is_walking = bool()
var is_running = bool()
func walk()->void:
	h_rot = $Camroot/h.global_transform.basis.get_euler().y
	movement_speed = 0
	angular_acceleration = 3.25
	acceleration = 15
	if can_walk == true:
		if (Input.is_action_pressed("forward") ||  Input.is_action_pressed("backward") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right")):
			direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
						0,
						Input.get_action_strength("forward") - Input.get_action_strength("backward"))
			direction = direction.rotated(Vector3.UP, h_rot).normalized()
			is_walking = true
		# Sprint input, state and speed
			if (Input.is_action_pressed("sprint")) and (is_walking == true) and is_in_combat == false and  health > 0:
				is_in_combat = false
				if sprint_speed < max_sprint_speed:
					sprint_speed += 0.005 * agility
					if sprint_animation_speed < max_sprint_animation_speed:
						sprint_animation_speed +=0.0005 * agility
						#print("sprint_an_speed " + str(sprint_animation_speed))
					elif sprint_animation_speed > max_sprint_animation_speed:
						sprint_animation_speed = max_sprint_animation_speed 
					#print(str(sprint_speed))
				elif sprint_speed > max_sprint_speed:
					sprint_speed = max_sprint_speed
				movement_speed = sprint_speed
				is_sprinting = true
				is_running = false
				is_aiming = false
				is_crouching = false

			elif Input.is_action_pressed("run")and is_in_combat == false and  health > 0:
				is_in_combat = false
				sprint_speed = 10
				is_running = true 
				is_sprinting = false
				is_aiming = false
				is_crouching = false
				movement_speed = run_speed
			else: # Walk State and speed
				if health >0:
					sprint_speed = 10
					sprint_animation_speed = 1
					#print(str(sprint_speed))
					movement_speed = walk_speed 
					is_sprinting = false
					is_running = false
					is_crouching = false
				else:
					movement_speed = walk_speed * 0.3
					is_sprinting = false
					is_running = false
					is_crouching = false
					
		else: 
			sprint_speed = 10
			is_walking = false
			is_sprinting = false
			is_running = false
			is_crouching = false

	else:
		sprint_speed = 10
		is_walking = false
		is_sprinting = false
		is_running = false
		is_crouching = false

	Icons.movement(self)

#climbing section
var is_swimming:bool = false
var wall_incline
var is_wall_in_range:bool = false
var is_climbing:bool = false
onready var head_ray = $Mesh/HeadRay
onready var climb_ray = $Mesh/ClimbRay
func climbing()-> void:
	if is_sprinting == false:
		if is_running == false:
			if not is_swimming and strength > 0.99:
				if climb_ray.is_colliding() and is_on_wall():
					if Input.is_action_pressed("forward"):
							checkWallInclination()
							is_climbing = true
							is_swimming = false
							if not head_ray.is_colliding() and not is_wall_in_range:#vaulting
								state = Icons.state_list.vault
								vertical_velocity = Vector3.UP * 3 
							elif not is_wall_in_range:#normal climb
								state = Icons.state_list.climb
								vertical_velocity = Vector3.UP * 3 
							else:
								vertical_velocity = Vector3.UP * (strength * 1.25 + (agility * 0.15))
								horizontal_velocity = direction * walk_speed
								if strength < 2:
									pass
									#animation_player_top.play("crawl incline cycle", blend)
								else:
									pass
									#animation_player_top.play("walk cycle", blend)
					else:
						is_climbing = false
				else:
					is_climbing = false
		else:
			is_climbing = false
func checkWallInclination()-> void:
	if get_slide_count() > 0:
		var collision_info = get_slide_collision(0)
		var normal = collision_info.normal
		if normal.length_squared() > 0:
			wall_incline = acos(normal.y)  # Calculate the inclination angle in radians
			wall_incline = rad2deg(wall_incline)  # Convert inclination angle to degrees
			if normal.x < 0:
				wall_incline = -wall_incline
			# Check if the wall inclination is within the specified range 
			is_wall_in_range = (wall_incline >= -60 and wall_incline <= 60)
		else:
			wall_incline = 0  # Set to 0 if the normal is not valid
			is_wall_in_range = false
	else:
		wall_incline = 0  # Set to 0 if there is no collision
		is_wall_in_range = false
func jump():
	if health > 0:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			vertical_velocity =  Vector3.UP * ((jumping_power * agility) * get_physics_process_delta_time())
var fall_damage:float = 10
var fall_distance:float = 0
var minimum_fall_distance:float = 0.5
var old_vel : float = 0.0

# Physics value
var direction : Vector3 = Vector3()
var horizontal_velocity : Vector3 = Vector3()
var aim_turn = float()
var movement = Vector3()
var vertical_velocity = Vector3()
var movement_speed = int()
var angular_acceleration = int()
var acceleration = int()
#__________________________________________More action based movement_______________________________
# Dodge
var double_press_time: float = 0.18
var slide_movement: float = 8.00 
var dash_countback: int = 0
var dash_timerback: float = 0.0
# Dodge Left
var dash_countleft: int = 0
var dash_timerleft: float = 0.0
# Dodge right
var dash_countright: int = 0
var dash_timerright: float = 0.0

var dash_countforward: int = 0
var dash_timerforward: float = 0.0
func dodgeIframe():
	if state == Icons.state_list.slide or backstep_duration == true or frontstep_duration == true or leftstep_duration == true or rightstep_duration == true or dash_duration == true:
		set_collision_layer(6) 
		set_collision_mask(6) 
	else:
		set_collision_layer(1) 
		set_collision_mask(1)   
		
func doublePressToDash()-> void:
	if resolve >= all_skills.dash_cost:
		if dash_countback > 0:
			dash_timerback += get_physics_process_delta_time()
		if dash_timerback >= double_press_time:
			dash_countback = 0
			dash_timerback = 0.0
		if Input.is_action_just_pressed("backward"):
			dash_countback += 1
		if dash_countback == 2 and dash_timerback < double_press_time:
			dash_duration = true
			resolve -= all_skills.dash_cost


		if dash_countforward > 0:
			dash_timerforward += get_physics_process_delta_time()
		if dash_timerforward >= double_press_time:
			dash_countforward = 0
			dash_timerforward = 0.0
		if Input.is_action_just_pressed("forward"):
			dash_countforward += 1
		if dash_countforward == 2 and dash_timerforward < double_press_time:
			dash_duration = true
			resolve -= all_skills.dash_cost

		if dash_countleft > 0:
			dash_timerleft += get_physics_process_delta_time()
		if dash_timerleft >= double_press_time:
			dash_countleft = 0
			dash_timerleft = 0.0
		if Input.is_action_just_pressed("left"):
			dash_countleft += 1
		if dash_countleft == 2 and dash_timerleft < double_press_time:
			dash_duration = true
			resolve -= all_skills.dash_cost

		if dash_countright > 0:
			dash_timerright += get_physics_process_delta_time()
		if dash_timerright >= double_press_time:
			dash_countright = 0
			dash_timerright = 0.0
		if Input.is_action_just_pressed("right"):
			dash_countright += 1
		if dash_countright == 2 and dash_timerright < double_press_time :
			dash_duration = true
			resolve -= all_skills.dash_cost
	#_____________________________________________________Camera_______________________________________
var is_aiming: bool = false
var camrot_h: float = 0
var camrot_v: float = 0
onready var parent = $".."
var cam_v_max: float = 200 
var cam_v_min: float = -125 
onready var camera_v =$Camroot/h/v
onready var camera_h =$Camroot/h
onready var camera = $Camroot/h/v/Camera
onready var minimap_camera = $UI/GUI/Portrait/MinimapHolder/Minimap/Viewport/Camera
var minimap_rotate: bool = false
var h_sensitivity: float = 0.1
var v_sensitivity: float = 0.1
var rot_speed_multiplier:float = .15 #reduce this to make the rotation radius larger
var h_acceleration: float  = 10
var v_acceleration: float = 10
var touch_start_position: Vector2 = Vector2.ZERO
var zoom_speed: float = 0.1
var mouse_sense: float = 0.1
var aiming_mode: String = "directional"
onready var aim_label: Label = $UI/GUI/Menu/AimingMode/AimLabel
func _on_AimingMode_pressed():
		if aiming_mode == "camera":
			aiming_mode = "directional"
			aim_label.text = aiming_mode
		else:
			aiming_mode = "camera"
			aim_label.text = aiming_mode
func directionToCamera():#put this on attacks 
	if aiming_mode =="camera":
		direction = -camera.global_transform.basis.z
func fieldOfView():
	if is_sprinting:
		if camera.fov < 110:
			camera.fov += 1 
	elif is_running:
		if camera.fov < 80:
			camera.fov += 2
		elif camera.fov > 80:
			camera.fov -= 1
	else:
		if camera.fov > 70:
			camera.fov -= 2
func Zoom(zoom_direction : float)-> void:
	# Adjust the camera's position based on the zoom direction
	camera.translation.y += zoom_direction * zoom_speed
	camera.translation.z -= zoom_direction * (zoom_speed * 2)
#	# Calculate the distance between the camera and the player
#	var distance = global_transform.origin.distance_to(camera.global_transform.origin)
#
#	# Scale the rays based on the distance (direct relationship)
#	ray.scale = Vector3(distance, distance, distance)
#	hook_ray.scale = Vector3(distance, distance, distance)
	
	#print("z" + str(camera.translation.z) + " y" +str(camera.translation.y) )
func _on_Sensitivity_pressed():
	$Minimap/sensitivity_label.text = "cam sens: " + str(h_sensitivity)
	h_sensitivity += 0.025
func _on_SensitivityMin_pressed():
	h_sensitivity -= 0.025
	$Minimap/sensitivity_label.text = "cam sens: " + str(h_sensitivity)
func cameraRotation()-> void:
	if not cursor_visible:#MOUSE CAMERA
		camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
		camera_h.rotation_degrees.y = lerp(camera_h.rotation_degrees.y, camrot_h, get_physics_process_delta_time() * h_acceleration)
		camera_v.rotation_degrees.x = lerp(camera_v.rotation_degrees.x, camrot_v, get_physics_process_delta_time() * v_acceleration)
func _input(event)-> void:
	if event is InputEventMouseMotion:
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity
		if minimap_rotate:
			minimap_camera.rotate_y(deg2rad(-event.relative.x * mouse_sense))
	if !skill_trees.visible:
		#Scrollwheel zoom in and out 		
		if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
			# Zoom in when scrolling up
			Zoom(-1)
		elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
			# Zoom out when scrolling down
			Zoom(1)
			
			
			
onready var player_mesh: Node = $Mesh
func rotateMesh()-> void:
	if is_aiming and !is_climbing:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/h.rotation.y, get_physics_process_delta_time() * angular_acceleration)
#	elif is_climbing:
#		if direction != Vector3.ZERO and is_climbing:
#			player_mesh.rotation.y = -(atan2($ClimbRay.get_collision_normal().z,$ClimbRay.get_collision_normal().x) - PI/2)
	else: # Normal turn movement mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, get_physics_process_delta_time() * angular_acceleration)


onready var crosshair = $Camroot/h/v/Camera/Aim/Cross
onready var crosshair_tween = $Camroot/h/v/Camera/Aim/Cross/Tween
func crossHair()-> void:
	if crosshair:
		if ray.is_colliding():
			var body = ray.get_collider()
			if body == self:
				crosshair.visible = false
			else:
				crosshair.visible = true
			if body.is_in_group("Enemy"):
				crosshair_tween.interpolate_property(crosshair, "modulate", crosshair.modulate, Color(0.85, 0, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				crosshair_tween.start()
			elif body.is_in_group("Entity"):
				if body.is_in_group("Servant"):
					if body.summoner != null:
						if body.summoner == self:
							crosshair_tween.interpolate_property(crosshair, "modulate", crosshair.modulate, Color(0,0.75, 0), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
							crosshair_tween.start()
				else:
					crosshair_tween.interpolate_property(crosshair, "modulate", crosshair.modulate, Color(0.6, 0.05, 0.8), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					crosshair_tween.start()
			else:
				crosshair_tween.interpolate_property(crosshair, "modulate", crosshair.modulate, Color(1, 1, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				crosshair_tween.start()
		else:
			crosshair_tween.interpolate_property(crosshair, "modulate", crosshair.modulate, Color(1, 1, 1), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			crosshair_tween.start()
func crossHairResize()-> void:
	# Define the target scale based on input action
	var target_scale:float = 1.0
	if Input.is_action_pressed("rclick"):
		target_scale = 0.6
	# Use Tween to smoothly transition the scale change
	crosshair_tween.interpolate_property(crosshair, "rect_scale", crosshair.rect_scale, Vector2(target_scale, target_scale), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	crosshair_tween.start()
onready var minimap:Control = $UI/GUI/Portrait/MinimapHolder/Minimap
func miniMapVisibility():
	if Input.is_action_just_pressed("minimap"):
		minimap.visible = !minimap.visible
var is_fullscreen :bool  = false
func fullscreen()-> void:
	if Input.is_action_just_pressed("fullscreen"):
		is_fullscreen = !is_fullscreen
		OS.set_window_fullscreen(is_fullscreen)
		saveGame()
#__________________________________Entity Graphical interface________________________________________
onready var entity_graphic_interface:Control = $UI/GUI/EnemyUI
onready var enemy_ui_tween:Tween =$UI/GUI/EnemyUI/Tween
onready var enemy_health_bar:TextureProgress = $UI/GUI/EnemyUI/HP
onready var enemy_health_label:Label = $UI/GUI/EnemyUI/HP/HPlab
onready var enemy_ae_bar:TextureProgress = $UI/GUI/EnemyUI/AE
onready var enemy_ae_label:Label =$UI/GUI/EnemyUI/AE/AElab

onready var enemy_ne_bar:TextureProgress = $UI/GUI/EnemyUI/NE
onready var enemy_ne_label:Label = $UI/GUI/EnemyUI/NE/NElab
onready var enemy_re_bar:TextureProgress = $UI/GUI/EnemyUI/RE
onready var enemy_re_label:Label = $UI/GUI/EnemyUI/RE/RElab

onready var entity_name_label:Label = $UI/GUI/EnemyUI/Name
onready var ray:RayCast = $Camroot/h/v/Camera/Aim
var fade_duration: float = 0.3
func showEnemyStats()-> void:
	if ray.is_colliding():
		var body = ray.get_collider()
		if body != null:
			if body != self:
				if body.has_method("showStatusIcon"):
						body.showStatusIcon(
			$UI/GUI/EnemyUI/StatusGrid/Icon1,
			$UI/GUI/EnemyUI/StatusGrid/Icon2,
			$UI/GUI/EnemyUI/StatusGrid/Icon3,
			$UI/GUI/EnemyUI/StatusGrid/Icon4,
			$UI/GUI/EnemyUI/StatusGrid/Icon5,
			$UI/GUI/EnemyUI/StatusGrid/Icon6,
			$UI/GUI/EnemyUI/StatusGrid/Icon7,
			$UI/GUI/EnemyUI/StatusGrid/Icon8,
			$UI/GUI/EnemyUI/StatusGrid/Icon9,
			$UI/GUI/EnemyUI/StatusGrid/Icon10,
			$UI/GUI/EnemyUI/StatusGrid/Icon11,
			$UI/GUI/EnemyUI/StatusGrid/Icon12,
			$UI/GUI/EnemyUI/StatusGrid/Icon13,
			$UI/GUI/EnemyUI/StatusGrid/Icon14,
			$UI/GUI/EnemyUI/StatusGrid/Icon15,
			$UI/GUI/EnemyUI/StatusGrid/Icon16,
			$UI/GUI/EnemyUI/StatusGrid/Icon17,
			$UI/GUI/EnemyUI/StatusGrid/Icon18,
			$UI/GUI/EnemyUI/StatusGrid/Icon19,
			$UI/GUI/EnemyUI/StatusGrid/Icon20,
			$UI/GUI/EnemyUI/StatusGrid/Icon21,
			$UI/GUI/EnemyUI/StatusGrid/Icon22,
			$UI/GUI/EnemyUI/StatusGrid/Icon23,
			$UI/GUI/EnemyUI/StatusGrid/Icon24
		)
				if body.is_in_group("Entity") and body != self:
					# Instantly turn alpha to maximum
					entity_graphic_interface.modulate.a = 1.0
					enemy_health_bar.value = body.health
					enemy_health_bar.max_value = body.max_health
					enemy_health_label.text = "HP:" + str(round(body.health* 100) / 100) + "/" + str(body.max_health)
					
					enemy_ae_bar.value = body.aefis
					enemy_ae_bar.max_value = body.max_aefis
					enemy_ae_label.text = "AE:" + str(round(body.aefis* 100) / 100) + "/" + str(body.max_aefis)
					
					enemy_ne_bar.value = body.nefis
					enemy_ne_bar.max_value = body.max_nefis
					enemy_ne_label.text = "NE:" + str(round(body.nefis* 100) / 100) + "/" + str(body.max_nefis)
					
					enemy_re_bar.value = body.resolve
					enemy_re_bar.max_value = body.max_resolve
					enemy_re_label.text = "RE:" + str(round(body.resolve* 100) / 100) + "/" + str(body.max_resolve)
					
					entity_name_label.text = body.entity_name
					
					var threat_label = $UI/GUI/EnemyUI/Threat
					if body.has_method("displayThreatInfo"):
						body.displayThreatInfo(threat_label)
					else:
						threat_label.text = ""
				else:
					# Start tween to fade out
					enemy_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					enemy_ui_tween.start()
			else:
				# Start tween to fade out
				enemy_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				enemy_ui_tween.start()
		else:
			# Start tween to fade out
			enemy_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0,fade_duration/3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			enemy_ui_tween.start()
			#print(str(fade_duration))

#PLAYER USER INTERFACE, BUTTONS, INVENTORY, SKILLBAR, SKILL TREES,EQUIPMENT, PORTRAIT, KEYBINDS AND WHATNOT
var cursor_visible: bool = false
onready var keybinds: Control = $UI/GUI/Keybinds
onready var inventory: Control = $UI/GUI/Inventory
onready var crafting: Control = $UI/GUI/Crafting
onready var skill_trees: Control = $UI/GUI/SkillTrees
onready var character: Control = $UI/GUI/Equipment
onready var menu: Control = $UI/GUI/Menu
func _on_Unstuck_pressed():
	staggered_duration = false
	translation = Vector3(0,5, 0)
	can_walk = true
	Icons.gravity(self)
	
	
func skillUserInterfaceInputs():
	$UI/GUI/CombatStats.visible = $UI/GUI/Equipment.visible
	if Input.is_action_just_pressed("skills"):
		closeSwitchOpen(skill_trees)
		saveGame()
	elif Input.is_action_just_pressed("tab"):
		saveGame()
		is_in_combat = !is_in_combat
		switchWeaponFromHandToSideOrBack()
		skill_queue.getInterrupted()

		
	elif Input.is_action_just_pressed("mousemode") or Input.is_action_just_pressed("ui_cancel"):	# Toggle mouse mode
		gearUp()
		saveGame()
		cursor_visible =!cursor_visible
	if !cursor_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("Inventory"):
		closeSwitchOpen(inventory)
		saveInventoryData()
		saveGame()
		gearUp()
	elif Input.is_action_just_pressed("Crafting"):
		closeSwitchOpen(crafting)
		saveGame()
	elif Input.is_action_just_pressed("Character"):
		closeSwitchOpen(character)
		gearUp()
		saveGame()
	elif Input.is_action_just_pressed("UI"):
		closeSwitchOpen(character)
		closeSwitchOpen(crafting)
		closeSwitchOpen(inventory)
		closeSwitchOpen(skill_trees)
		saveGame()
	elif Input.is_action_just_pressed("Menu"):
		closeSwitchOpen(menu)
		saveGame()
		
	
#skillbar buttons
func _on_Inventory_pressed():
	closeSwitchOpen(inventory)
	saveGame()
func _on_Character_pressed():
	closeSwitchOpen(character)
	saveGame()
func _on_Skills_pressed():
	closeSwitchOpen(skill_trees)
	saveGame()
func _on_Menu_pressed():
	closeSwitchOpen(menu)
	saveGame()
	closeUI(character)
	closeUI(skill_trees)
	closeUI(inventory)
	closeUI($UI/GUI/Crafting)
	closeUI($UI/GUI/CharacterEditor)
func _on_OpenAllUI_pressed():
	closeSwitchOpen(character)
	closeSwitchOpen(crafting)
	closeSwitchOpen(inventory)
	closeSwitchOpen(skill_trees)
	saveGame()
	$UI/GUI/CharacterEditor.visible = !$UI/GUI/CharacterEditor.visible
	
	

	
	
func connectUIButtons():
	revive_here.connect("pressed", self , "reviveHere")
	revive_in_town.connect("pressed", self , "reviveInTown")
	revive_here_free.connect("pressed", self , "reviveHereFree")
	struggle_button.connect("pressed", self , "struggle")
	var close_dmg: TextureButton = $UI/GUI/Equipment/DmgDef/Close
	if close_dmg != null:
		close_dmg.connect("pressed", self, "closeDamageTypes")
	var close_atts: TextureButton = $UI/GUI/Equipment/Attributes/Close
	if close_atts != null:
		close_atts.connect("pressed", self, "closeAtts")
	var open_dmg: TextureButton = $UI/GUI/Equipment/EquipmentBG/OpenDmgDef
	if open_dmg != null:
		 open_dmg.connect("pressed", self, "switchAttsStatsUI")
		
onready var dmg_ui: Control = $UI/GUI/Equipment/DmgDef	
onready var atts_ui: Control = $UI/GUI/Equipment/Attributes
var toggleCount:int  = 0
func switchAttsStatsUI():
	toggleCount += 1
	# Check if both UI elements are valid
	if dmg_ui != null and atts_ui != null:
		if toggleCount == 1:
			# First press: Show dmg_ui, hide atts_ui
			dmg_ui.visible = true
			atts_ui.visible = false
		elif toggleCount == 2:
			# Second press: Hide dmg_ui, show atts_ui
			dmg_ui.visible = false
			atts_ui.visible = true
		elif toggleCount == 3:
			# Third press: Hide both UI elements
			dmg_ui.visible = false
			atts_ui.visible = false
			toggleCount = 0  # Reset toggle count for next cycle
func closeDamageTypes():
	closeUI(dmg_ui)
func closeAtts():
	closeUI(atts_ui)
func closeUI(ui):
	if ui != null:
		ui.visible = false
func closeSwitchOpen(ui):#Forgot I had this but can be neat
	ui.visible = !ui.visible
func closeAllUI():
		character.visible = false 
		crafting.visible  = false
		inventory.visible = false
		skill_trees.visible = false
		keybinds.visible = false
		menu.visible = false
func _on_CloseSkillsTrees_pressed():
	skill_trees.visible = false
func _on_CraftingCloseButton_pressed():
	crafting.visible = false
	saveGame()
func _on_InventoryCloseButton_pressed():
	inventory.visible = false
	savePlayerData()
func _on_InventoryOpenCraftingSystemButton_pressed():
	crafting.visible = !crafting.visible
	saveSkillBarData()
	savePlayerData()
func _on_SkillTreeCloseButton_pressed():
	skill_trees.visible = false
	savePlayerData()
func _on_CharacterCloseButton_pressed():
	character.visible = false
	savePlayerData()
func _on_CloseMenu_pressed():
	menu.visible = false
	savePlayerData()
func _on_Keybinds_pressed():
	closeSwitchOpen(keybinds)
	savePlayerData()
func _on_Quit_pressed():
	saveInventoryData()
	saveGame()
	get_tree().quit()
func _on_InventorySaveButton_pressed():
	saveInventoryData()
	saveGame()

func saveInventoryData():
	# Call savedata() function on each child of inventory_grid that belongs to the group "Inventory"
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.get_node("Icon").has_method("savedata"):
				child.get_node("Icon").savedata()
func loadInventoryData():
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.get_node("Icon").has_method("loaddata"):
				child.get_node("Icon").loaddata()
func deleteInventoryData():
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			child.quantity = 0 
func saveSkillBarData():
	$UI/GUI/SkillBar/GridContainer/Slot1/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot2/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot3/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot4/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot5/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot6/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot7/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot8/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot9/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot10/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot11/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot12/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot13/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot14/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot15/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot16/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot17/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot18/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot19/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/Slot20/Icon.savedata()



#______________________________________skill tree system____________________________________________

func showSkillPoints()->void:
	if health >0:
		$UI/GUI/SkillTrees/Label.text = str("skill points: ")+ str(skill_points)
		$UI/GUI/SkillTrees/Label2.text =  str("points spent: ")+ str(skill_points_spent)

onready var vanguard_skill_tree: Control =  $UI/GUI/SkillTrees/Vanguard
onready var general_skill_tree: Control =  $UI/GUI/SkillTrees/Generalist
onready var reset_skills: Control = $UI/GUI/SkillTrees/ResetSkills


func _on_SkillTree0_pressed()->void:
	vanguard_skill_tree.visible = false
	general_skill_tree.visible = true
	
func _on_SkillTree1_pressed()->void:
	vanguard_skill_tree.visible = true
	general_skill_tree.visible = false


#skills in skills-tree
onready var all_skills = $UI/GUI/SkillTrees
onready var kick_icon = $UI/GUI/SkillTrees/Generalist/skill1/Icon
onready var taunt_icon = $UI/GUI/SkillTrees/Vanguard/skill6/Icon
onready var cyclone_icon = $UI/GUI/SkillTrees/Vanguard/skill5/Icon
onready var overhead_icon = $UI/GUI/SkillTrees/Vanguard/skill2/Icon
onready var rising_icon = $UI/GUI/SkillTrees/Vanguard/skill4/Icon
onready var whirlwind_icon = $UI/GUI/SkillTrees/Vanguard/skill1/Icon
onready var heart_trust_icon = $UI/GUI/SkillTrees/Vanguard/skill3/Icon
func connectGenericSkillTee(tree)->void:# this is called by connectSkillTree() to give the the "tree"
	for child in tree.get_children():
		if child.is_in_group("Skill"):
			var index_str = child.get_name().split("skill")[1]
			var index = int(index_str)
			child.connect("pressed", self, "skillPressed", [tree, index])
			child.connect("mouse_entered", self, "skillMouseEntered", [tree, index]) # Pass 'tree' here
			child.connect("mouse_exited", self, "skillMouseExited", [index])
	 # Correcting the connection for ResetSkills button
	reset_skills.connect("pressed", self, "resetSkills")
func connectSkillTree()->void:# connects all skill trees
	connectGenericSkillTee(vanguard_skill_tree)
	connectGenericSkillTee(general_skill_tree)
var skill_points_spent:int = 0 
func skillPressed(tree,index)->void:
	var button = tree.get_node("skill" + str(index))
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture	
	if icon_texture != null:
		spendSkillPoints(icon_texture_rect,button)
	saveGame()
	
func spendSkillPoints(icon_texture_rect,button)->void:
	if icon_texture_rect.points < 5:
		if skill_points >0:
			icon_texture_rect.points += 1 
			button.skillPoints()
			skill_points -= 1
			skill_points_spent +=  1
			
onready var gen_skill1 = $UI/GUI/SkillTrees/Generalist/skill1
onready var gen_skill_icon1 = $UI/GUI/SkillTrees/Generalist/skill1/Icon
func saveSkillTreeData()->void:
	for child in vanguard_skill_tree.get_children():
		if child.is_in_group("Skill"):
			if child.get_node("Icon").has_method("savedata"):
				child.get_node("Icon").savedata()
	gen_skill_icon1.savedata()
func loadSkillTreeData()->void:
	for child in vanguard_skill_tree.get_children():
		if child.is_in_group("Skill"):
			if child.get_node("Icon").has_method("loaddata"):
				child.get_node("Icon").loaddata()
				child.skillPoints()
	gen_skill_icon1.loaddata()
	gen_skill1.skillPoints()
				
func setSkillTreeOwner()->void:
	for child in vanguard_skill_tree.get_children():
		if child.is_in_group("Skill"):
			if child.get_node("Icon") == null:
				pass
			else:
				child.get_node("Icon").player = self 
func skillMouseEntered(tree, index)->void:
	var button = tree.get_node("skill" + str(index))
	if button.get_node("Icon") == null:
		pass
	else:
		var icon_texture = button.get_node("Icon").texture
		UniversalToolTip(icon_texture)
func skillMouseExited(index)->void:
	deleteTooltip()
func resetSkills()->void:
	for child in vanguard_skill_tree.get_children():
		if child.is_in_group("Skill"):
			child.get_node("Icon").points = 0 
			skill_points += skill_points_spent
			child.skillPoints()
			skill_points_spent = 0 
	for child in general_skill_tree.get_children():
		if child.is_in_group("Skill"):
			if child.get_node("Icon") == null:
				pass
			else:
				child.get_node("Icon").points = 0 
				skill_points += skill_points_spent
				child.skillPoints()
				skill_points_spent = 0 
			
			
			
func UniversalToolTip(icon_texture)->void:
	var instance = preload("res://Tooltips/tooltip.tscn").instance()
	var instance_skills = preload("res://Tooltips/tooltipSkills.tscn").instance()
	var instance_leftdown = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var instance_equipment = preload("res://Tooltips/tooltipEquipable.tscn").instance()
	if icon_texture != null:
		#consumablaes
		if icon_texture.get_path() == Icons.red_potion.get_path():
			callToolTip(instance, "Red Potion", Icons.red_potion_description)
		#food
		elif icon_texture.get_path() == Icons.strawberry.get_path():
			callToolTip(instance,"Strawberry","+5 health points +9 kcals +24 grams of water")
		elif icon_texture.get_path() == Icons.raspberry.get_path():
			callToolTip(instance,"Raspberry","+3 health points +1 kcals +2 grams of water")
		elif icon_texture.get_path() == Icons.beetroot.get_path():
			callToolTip(instance,"beetroot","+15 health points +32 kcals +71.8 grams of water")
			#equipment icons
#__________________________________EQUIPMENT DESCRIPTIONS HERE______________________________________

		elif icon_texture.get_path() == Icons.weapset1_icons["shield"].get_path():
			var title:String = "Wood Shield"
			var stat1:String = "Melee attack speed: " +str(Icons.weapset1_atk_speed["shield"])
			var stat2:String = "Guard protection: + " + str(Icons.shield_wood_absorb)
			var stat3:String = "slash/blunt/pierce resistance: + " + str(Icons.shield_wood_general_defense)
			var description:String = "A very basic shield, yet study and dependable"
			callToolTipEquip(instance_equipment,title, stat1, stat2, stat3,"","","", "", "",description)
		elif icon_texture.get_path() == Icons.weapset1_icons["sword"].get_path():
			var title:String = "Iron broad sword"
			var stat1:String = "base damage: "+ "+ " + str(Icons.sword_beginner_dmg)
			var stat2:String = "Guard protection: + " + str(Icons.sword_beginner_absorb)
			var stat3:String = "Melee attack speed: " +str(Icons.weapset1_atk_speed["sword"])
			var description:String = "Looks like something that was produced enmasse, will make do"
			callToolTipEquip(instance_equipment,title, stat1, stat2,stat3,"","","", "", "",description)

		elif icon_texture.get_path() == Icons.weapset1_icons["axe"].get_path():
			var title:String = "Iron axe"
			var stat1:String = "base damage: "+ "+ " + str(Icons.axe_beginner_dmg)
			var stat2:String = "Guard protection: + " + str(Icons.axe_beginner_absorb)
			var stat3:String = "Melee attack speed: " +str(Icons.weapset1_atk_speed["axe"])
			var description:String = "A very good tool"
			callToolTipEquip(instance_equipment,title, stat1, stat2, stat3,"","","", "", "",description)


#______________________________________SKILL DESCRIPTIONS HERE______________________________________
		elif icon_texture.get_path() == Icons.vanguard_icons["cyclone"].get_path():
			var base_damage: float = all_skills.cyclone_damage + total_dmg
			var points: int = cyclone_icon.points
			var damage_multiplier: float = 1.0
			var total_damage: float
			if points > 1:
				damage_multiplier += (points - 1) * 0.05
			total_damage = base_damage * damage_multiplier
			var total_value = str("Damage: ") + str(total_damage) + "per hit"
			var cost = "Cost: " + str(all_skills.cyclone_cost) + " resolve"
			var description: String = all_skills.cyclone_description
			var cooldown = str("Cooldown: ") + str(all_skills.cyclone_cooldown)+ str(" seconds")
			var extra:String = "AOE, Stagger, Movement"
			callToolTipSegmented(instance_skills,"cyclone",total_value,cost,extra,cooldown,description)
	
	
		elif icon_texture.get_path() == Icons.vanguard_icons["whirlwind"].get_path():
			var base_damage: float = all_skills.whirlwind_damage + total_dmg
			var points: int =  whirlwind_icon.points
			var health_ratio: float = float(health) / float(max_health)
			var missing_health_percentage: float = 1.0 - (float(health) / float(max_health))  # Missing health as a percentage
			var damage_multiplier: float = all_skills.whirlwind_damage_multiplier
			var total_damage: float
			if points > 1:
				damage_multiplier += (points - 1) * 0.05
			# Health-based additional damage
			var additional_damage_per_3_percent: float = 1.0
			var additional_damage: float = (missing_health_percentage / 0.03) * additional_damage_per_3_percent
			total_damage = (base_damage * damage_multiplier) + additional_damage
			var total_value = str("Damage: ") + str(total_damage) 
			var cost = "Cost: " + str(all_skills.whirlwind_cost) + " resolve"
			var description: String =  all_skills.whirlwind_description
			var cooldown = str("Cooldown: ") + str(all_skills.whirlwind_cooldown)+ str(" seconds")
			var extra:String = "Burst damage,AOE, situational"
			callToolTipSegmented(instance_skills,"Desperate Slash",total_value,cost,extra,cooldown,description)
		

		elif icon_texture.get_path() == Icons.vanguard_icons["sunder"].get_path():
			var base_damage: float = all_skills.overhead_slash_damage + total_dmg
			var points: int = overhead_icon.points
			var damage_multiplier: float = 1.0
			var total_damage: float
			if points > 1:
				damage_multiplier += (points - 1) * all_skills.overhead_slash_dmg_proportion
			total_damage = base_damage * damage_multiplier
			var total_value = str("Damage: ") + str(total_damage) 
			var cost = "Cost: " + str(all_skills.overhead_slash_cost) + " resolve"
			var description: String = all_skills.overhead_slash_description
			var cooldown = str("Cooldown: ") + str(all_skills.overhead_slash_cooldown)+ str(" seconds")
			var extra:String = "Damage"
			callToolTipSegmented(instance_skills,"Sunder",total_value,cost,extra,cooldown,description)
		
		elif icon_texture.get_path() == Icons.vanguard_icons["rising_slash"].get_path():
			var base_damage: float = all_skills.rising_slash_damage + total_dmg
			var points: int = rising_icon.points
			var damage_multiplier: float = 1.0
			var total_damage: float
			if points > 1:
				damage_multiplier += (points - 1) * all_skills.rising_slash_dmg_proportion
			total_damage = base_damage * damage_multiplier
			var total_value = str("Damage: ") + str(total_damage) 
			var cost = "Cost: " + str(all_skills.rising_slash_cost) + " resolve"
			var description: String = all_skills.rising_slash_description
			var cooldown = str("Cooldown: ") + str(all_skills.rising_slash_cooldown)+ str(" seconds")
			var extra:String = "Damage, Stagger"
			callToolTipSegmented(instance_skills,"Rising Slash",total_value,cost,extra,cooldown,description)
		
		
		elif icon_texture.get_path() == Icons.vanguard_icons["heart_trust"].get_path():
			var base_damage: float = all_skills.heart_trust_dmg + total_dmg
			var points: int = heart_trust_icon.points
			var damage_multiplier: float = 1.0
			var total_damage: float
			if points > 1:
				damage_multiplier += (points - 1) * all_skills.heart_trust_dmg_proportion
			total_damage = base_damage * damage_multiplier
			var total_value = str("Damage: ") + str(total_damage) 
			var cost = "Cost: " + str(all_skills.heart_trust_cost) + " resolve"
			var description: String = all_skills.heart_trust_description
			var cooldown = str("Cooldown: ") + str(all_skills.heart_trust_cooldown)+ str(" seconds")
			var extra:String = "Burst damage, Damage over time"
			callToolTipSegmented(instance_skills,"Heart Trust",total_value,cost,extra,cooldown,str(description) + str(all_skills.heart_trust_bleed_duration) + " seconds")
	
	
		elif icon_texture.get_path() == Icons.dash.get_path():
			pass
			
		elif icon_texture.get_path() == Icons.stomp.get_path():
			var base_damage: float = all_skills.stomp_dmg + total_dmg
			var total_damage: float  =all_skills.stomp_dmg + total_dmg
			var damage_to_knocked =  total_damage *all_skills.stomp_dmg_proportion
			var total_value = str("Damage: ") + str(total_damage) 
			var total_extr_value = "Damage to knocked down enemies : " + str(total_damage *all_skills.stomp_dmg_proportion)
			var description: String = all_skills.stomp_description
			var cooldown = str("Cooldown: ") + str(all_skills.stomp_cooldown)+ str(" seconds")
			var extra:String = "Burst damage, Situational"
			callToolTipSegmented(instance_skills,"Stomp",total_value,total_extr_value,cooldown,extra,str(description))

		elif icon_texture.get_path() == Icons.kick.get_path():
			var base_damage: float = all_skills.kick_dmg + total_dmg
			var points: int = kick_icon.points
			var damage_multiplier: float = 1.0
			var total_damage: float
			if points > 1:
				damage_multiplier += (points - 1) * all_skills.kick_dmg_proportion
			total_damage = base_damage * damage_multiplier
			var total_value = str("Damage: ") + str(total_damage) 
			var cost = "Cost: " + str(all_skills.kick_cost) + " resolve"
			var description: String = all_skills.kick_description
			var cooldown = str("Cooldown: ") + str(all_skills.kick_cooldown)+ str(" seconds")
			var extra:String = "Damage"
			callToolTipSegmented(instance_skills,"Kick",total_value,cost,extra,cooldown,description)

		elif icon_texture.get_path() == Icons.vanguard_icons["combo_switch"].get_path():
			var description: String = all_skills.combo_switch_description
			var cooldown = str("Cooldown: ") + str(all_skills.combo_switch_cooldown)+ str(" seconds")
			var extra:String = "Stance Switch"
			callToolTipSegmented(instance_skills,"Switch it up","","",extra,cooldown,description)
#_______________________________________Inventory system____________________________________________
#for this to work either preload all the item icons here or add the "Global.gd"
#as an Icons, i called it add_item in my project, and i used it to to compre the path 
#of icons, if the path matches with the icon i need, i do the effect of the specific item 
#i also use the same Icons to add items to inventory 
onready var inventory_grid = $UI/GUI/Inventory/ScrollContainer/InventoryGrid
onready var gui = $UI/GUI



func setInventoryOwner()->void:
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			child.get_node("Icon").player = self 
func connectInventoryButtons():
	$UI/GUI/Inventory/SplitFirstSlot.connect("pressed", self, "splitFirstSlot")
	var combine_slots_button = $UI/GUI/Inventory/CombineSlots
	combine_slots_button.connect("pressed", self, "combineSlots")
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var index_str = child.get_name().split("InventorySlot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "inventorySlotPressed", [index])
			child.connect("mouse_entered", self, "inventoryMouseEntered", [index])
			child.connect("mouse_exited", self, "inventoryMouseExited", [index])
var last_pressed_index: int = -1
var last_press_time: float = 0.0
var double_press_time_inv: float = 0.4
func inventorySlotPressed(index)->void:
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture
	gearUp()
	if icon_texture != null:
		if  icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		var current_time = OS.get_ticks_msec() / 1000.0
		if last_pressed_index == index and current_time - last_press_time <= double_press_time_inv:
			print("Inventory slot", index, "pressed twice")
			if icon_texture.get_path() == Icons.red_potion.get_path():
				Icons.consumeRedPotion(self,button,inventory_grid,false,null)
			elif icon_texture.get_path() == Icons.strawberry.get_path():
					kilocalories +=1
					health += 5
					water += 2
					button.quantity -=1
			elif icon_texture.get_path() == Icons.raspberry.get_path():
					kilocalories += 4
					health += 3
					water += 3
					button.quantity -=1
			elif icon_texture.get_path() == Icons.beetroot.get_path():
					kilocalories += 32
					health += 15
					water += 71.8
					button.quantity -=1
			elif icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		else:
			print("Inventory slot", index, "pressed once")
		last_pressed_index = index
		last_press_time = current_time
		savePlayerData()
#__Hover inventory slots
func inventoryMouseEntered(index)->void:
	gearUp()
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://Tooltips/tooltip.tscn").instance()
	UniversalToolTip(icon_texture)

func inventoryMouseExited(index)->void:
	gearUp()
	deleteTooltip()

func callToolTipSegmented(instance,title,total_value,base_value,cost,cooldown,description)->void:
		gui.add_child(instance)
		instance.showTooltip(title,total_value,base_value,cost,cooldown,description)
		
func callToolTipEquip(instance,title, stat1, stat2, stat3, stat4, stat5, stat6, stat7, stat8, stat9)->void:
		gui.add_child(instance)
		instance.showTooltip(title, stat1, stat2, stat3, stat4, stat5, stat6, stat7, stat8, stat9)
		
		
func callToolTip(instance,title,text)->void:
		gui.add_child(instance)
		instance.showTooltip(title,text)
# Function to combine slots when pressed
func combineSlots()->void:
	savePlayerData()
	saveSkillBarData()
	saveInventoryData()
	var combined_items = {}  # Dictionary to store combined items
# Define weapon set paths
	var not_stackable = [
		Icons.weapset1_icons["sword"].get_path(),
		Icons.weapset1_icons["axe"].get_path(),
		Icons.weapset1_icons["demo-hammer"].get_path(),
		Icons.weapset1_icons["greatmace"].get_path(),
		Icons.weapset1_icons["warhammer"].get_path(),
		Icons.weapset1_icons["greataxe"].get_path(),
		Icons.weapset1_icons["greatsword"].get_path(),
		Icons.weapset1_icons["shield"].get_path(),
	]
	# Iterate over children of the inventory grid
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.stackable == true:
				var icon = child.get_node("Icon")
				if icon.texture != null:
					var item_path = icon.texture.get_path()
					print("Checking item_path:", item_path)
					# Check if the item_path is not in weapset1_paths
					if not_stackable.has(item_path) == false:
						print("Combining item:", item_path)
						if combined_items.has(item_path):
							combined_items[item_path] += child.quantity
							icon.texture = null  # Set texture to null for excess slots
							child.quantity = 0  # Reset quantity
						else:
							combined_items[item_path] = child.quantity
					else:
						print("Item is part of weapset1_paths:", item_path)

	# Update quantities based on combined_items
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var icon = child.get_node("Icon")
			var item_path = icon.texture.get_path() if icon.texture != null else null
			if item_path != Icons.weapset1_icons["sword"].get_path() or item_path != Icons.weapset1_icons["axe"].get_path():
				if item_path in combined_items:
					child.quantity = combined_items[item_path]

func splitFirstSlot()->void:#Activated by button press
	savePlayerData()
	saveInventoryData()
	var first_slot = $UI/GUI/Inventory/ScrollContainer/InventoryGrid/InventorySlot1
	if first_slot.is_in_group("Inventory"):
		var first_icon = first_slot.get_node("Icon")
		if first_icon.texture != null:
			var original_quantity = first_slot.quantity
			if original_quantity > 1:
				for child in inventory_grid.get_children():
					if child.is_in_group("Inventory"):
						var icon = child.get_node("Icon")
						if icon.texture == null:
							icon.texture = first_icon.texture
							child.quantity += original_quantity / 2
							var new_quantity = original_quantity / 2  # Calculate the new quantity
							first_slot.quantity = original_quantity - new_quantity  # Update the quantity of the first slot
							break

#_____________________________________Skill_Bar_________________________________
onready var skill_bar_grid: GridContainer = $UI/GUI/SkillBar/GridContainer
func connectSkillBarButtons()->void:
	for child in skill_bar_grid.get_children():
		if child.is_in_group("Shortcut"):
			var index_str = child.get_name().split("Slot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "skillBarSlotPressed", [index])
			child.connect("mouse_entered", self, "skillBarMouseEntered", [index])
			child.connect("mouse_exited", self, "skillBarMouseExited", [index])
			
func skillBarMouseEntered(index)->void:
	var button = skill_bar_grid.get_node("Slot" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://Tooltips/tooltip.tscn").instance()
	UniversalToolTip(icon_texture)
	
func skillBarMouseExited(index)->void:
	deleteTooltip()
	
func _on_BaseAtkMode_mouse_entered()->void:
	var title:String = "Chain/Mechanical"
	var text:String = "Click to switch between modes:\nChain Mode: hold the click button to base attack\nMechanical mode:  tap the click button to base attack"
	var instance = preload("res://Tooltips/tooltip.tscn").instance()
	callToolTip(instance,title,text)
func _on_BaseAtkMode_mouse_exited()->void:
	deleteTooltip()
	
func _on_SkillQueue_mouse_entered()->void:
	var title:String = "Skill Cancel System"
	var text:String = "Click to switch between ON/OFF:\nWhen ON  you can interrupt your skills by activating other skills, the ones that get interrupted go on cooldown\nWhen OFF pressing other skills won't interrupt you, but external factors such as stuns, staggers, knockdowns or other effects might."
	var instance = preload("res://Tooltips/tooltip.tscn").instance()
	callToolTip(instance,title,text)
func _on_SkillQueue_mouse_exited()->void:
	deleteTooltip()
	


func _on_OpenAllUI_mouse_entered()->void:
	var title:String = "Open All Screens"
	var text:String = "Click to open:\nInventory,Character Sheet, Skill Trees,Crafting"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	callToolTip(instance,title,text)
func _on_OpenAllUI_mouse_exited()->void:
	gearUp()
	deleteTooltip()
	
	
func _on_Edit_mouse_entered()->void:
	var title:String = "Edit Skillbar Keybinds"
	var text:String = "Click to switch ON/OFF:\nWhen ON, clickin any skillbar slot will let you change the keybind for that slot,just click the slot you want once and then press any key\nMake sure to turn this OFF or you might change your keybinds by mistake"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	callToolTip(instance,title,text)
func _on_Edit_mouse_exited()->void:
	deleteTooltip()

	
func _on_Character_mouse_entered()->void:
	gearUp()
	var title:String = "Character Sheet"
	var text:String = "Click to open:\nYour character sheet with your equipment, stats and attributes"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	callToolTip(instance,title,text)
func _on_Character_mouse_exited()->void:
	deleteTooltip()
	
func _on_Menu_mouse_entered()->void:
	var title:String = "Menu"
	var text:String = "Opens Settins menu and Quitting interface"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	
	callToolTip(instance,title,text)
func _on_Menu_mouse_exited()->void:
	deleteTooltip()

func _on_Skills_mouse_entered()->void:
	var title:String = "Skill Trees"
	var text:String = "Click to open skill trees, and pick any skill from any skill tree to create your unique class archetype"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	callToolTip(instance,title,text)
func _on_Skills_mouse_exited()->void:
	deleteTooltip()

func _on_InventoryOpenCraftingSystemButton_mouse_entered()->void:
	var title:String = "Crafting"
	var text:String = "Click to open crafting menu\nDrag and drop items from acrosss your inventory into the crafting menu's slot in specific combinations to create new items"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	callToolTip(instance,title,text)
func _on_InventoryOpenCraftingSystemButton_mouse_exited()->void:
	deleteTooltip()

func _on_Inventory_mouse_entered()->void:
	var title:String = "Inventory"
	var text:String = "Click to open Inventory\nThe inventory has many slots containing items which you can move around, or click to activate.\nItems might be placed in the skillbar and can be consumed or activated from there using the specific keybinds.Use the Inventory buttons to delete items you don't need by  dragging them in the trash can, or click the split item's button to split in half the quantity of the items in the first slot, or press the combine button to merge all items similar items into a single stack"
	var instance = preload("res://Tooltips/tooltipSkillbar.tscn").instance()
	callToolTip(instance,title,text)
func _on_Inventory_mouse_exited()->void:
	deleteTooltip()


#______________________________________Crafting_________________________________

onready var crafting_slot1 = $UI/GUI/Crafting/CraftingGrid/craftingSlot1/Icon
onready var crafting_slot2 = $UI/GUI/Crafting/CraftingGrid/craftingSlot2/Icon
onready var crafting_slot3 = $UI/GUI/Crafting/CraftingGrid/craftingSlot3/Icon
onready var crafting_slot4 = $UI/GUI/Crafting/CraftingGrid/craftingSlot4/Icon
onready var crafting_slot5 = $UI/GUI/Crafting/CraftingGrid/craftingSlot5/Icon
onready var crafting_slot6 = $UI/GUI/Crafting/CraftingGrid/craftingSlot6/Icon
onready var crafting_slot7 = $UI/GUI/Crafting/CraftingGrid/craftingSlot7/Icon
onready var crafting_slot8 = $UI/GUI/Crafting/CraftingGrid/craftingSlot8/Icon
onready var crafting_slot9 = $UI/GUI/Crafting/CraftingGrid/craftingSlot9/Icon
onready var crafting_slot10 = $UI/GUI/Crafting/CraftingGrid/craftingSlot10/Icon
onready var crafting_slot11 = $UI/GUI/Crafting/CraftingGrid/craftingSlot11/Icon
onready var crafting_slot12 = $UI/GUI/Crafting/CraftingGrid/craftingSlot12/Icon
onready var crafting_slot13 = $UI/GUI/Crafting/CraftingGrid/craftingSlot13/Icon
onready var crafting_slot14 = $UI/GUI/Crafting/CraftingGrid/craftingSlot14/Icon
onready var crafting_slot15 = $UI/GUI/Crafting/CraftingGrid/craftingSlot15/Icon
onready var crafting_slot16 = $UI/GUI/Crafting/CraftingGrid/craftingSlot16/Icon
onready var crafting_result = $UI/GUI/Crafting/CraftingResultSlot/Icon
onready var icon = $UI/GUI/Crafting/CraftingResultSlot/Icon

func crafting()->void:
	if crafting_slot1.texture != null:
		if crafting_slot1.texture.get_path() == "res://Alchemy ingredients/2.png":
			crafting_result.texture = preload("res://Processed ingredients/ground rosehip.png")
			$UI/GUI/Crafting/CraftingResultSlot.quantity = 2

onready var take_damage_view = $"Damage&Effects/Viewport"


#________________________________Add items to inventory_________________________
onready var loot_table_node:Control = $UI/GUI/LootTable
onready var loot_grid:GridContainer =$UI/GUI/LootTable/ScrollContainer/LootGrid
func lootBodies()->void:
	if auto_loot == false:
		if is_walking == true:
			loot_table_node.visible = false
		else:
			if Input.is_action_just_pressed("collect"):
				var bodies = $Mesh/Detector.get_overlapping_bodies()
				for lootable in bodies:
					if lootable != self:
						if lootable.is_in_group("Lootable"):
							if lootable.can_be_looted == true:
								loot_table_node.visible = true
								if lootable.entity_holder.has_method("removeEquipment"):
									lootable.entity_holder.removeEquipment()


func receiveLootInLootTable(item,quantity)->void:#This is called by the players that use manual looting, it doesn't work with receiveDrops, either thiss or the other otherwise the loot is received twice 
	Icons.addStackableItem(loot_grid,item,quantity)

	
	
var auto_loot:bool = false
func receiveDrops(item,quantity)->void:#This is called by enemeis when they die or by quest givers or by gathering, works alone without neeeding to call lootBodies():
	Icons.addStackableItem(inventory_grid,item,quantity)
	Icons.addFloatingIcon(take_damage_view,item,quantity)
	

func _on_GiveMeItems_pressed()->void:#Only for debugging purposes
	coins += 550

	Icons.addStackableItem(inventory_grid,Icons.red_potion,50000)

	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["sword"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["axe"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["hammer"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["mace"])
	
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["greataxe"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["shield"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["greatsword"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["demo-hammer"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["greatmace"])
	Icons.addNotStackableItem(inventory_grid,Icons.weapset1_icons["warhammer"])
	
	Icons.addNotStackableItem(inventory_grid,Icons.garment1)
	Icons.addNotStackableItem(inventory_grid,Icons.boots1)

	Icons.addNotStackableItem(inventory_grid,Icons.torso_armor4)
	Icons.addNotStackableItem(inventory_grid,Icons.torso_armor2)
	Icons.addNotStackableItem(inventory_grid,Icons.torso_armor3)

	
	
	
	
	
	
	
#_____________________________________Currency______________________________________________________
onready var ethernium_label = $UI/GUI/Inventory/etherniumLabel
onready var silver_label = $UI/GUI/Inventory/silverLabel
onready var copper_label = $UI/GUI/Inventory/copperLabel

var coins = 0 

func money()->void:
	var ethernium_coins = str(coins / 10000)  # 100 silver = 1 ethernium
	var silver_coins = str((coins % 10000) / 100)  # 100 copper = 1 silver
	var copper_coins = str(coins % 100)  # Remaining copper coins
	
	
	ethernium_label.text = ethernium_coins
	silver_label.text = silver_coins
	copper_label.text = copper_coins



#____________________________________GRAPHICAL INTERFACE AND SETTINGS_______________________________
var ui_color = Color(1, 1, 1, 1) # Default to white

# Function to update UI colors based on color
func colorUI(color: Color) -> void:
	inv_background.modulate = color
	menu_frame.modulate = color
	skill_banner.modulate = color
	skill_background.modulate = color
	skill_tree_background.modulate = color
	equipment_bg.modulate = color
	attributes_background.modulate = color
	def_val_background.modulate = color
	loot_background.modulate = color
	enemy_background.modulate = color
	craft_background.modulate = color
	# Update stored color
	ui_color = color

var shifting_ui_colors:bool = true
func _on_ShiftColors_pressed():
	shifting_ui_colors = !shifting_ui_colors
func uiColorShit() -> void:
	var color = ui_color
	if shifting_ui_colors == true:
		# Example: Slowly change color continuously from red to blue to green and back to red
		var time = OS.get_ticks_msec() / 1000.0
		var r = 0.5 + 0.5 * sin(time)
		var g = 0.5 + 0.5 * sin(time + PI / 3)
		var b = 0.5 + 0.5 * sin(time + 2 * PI / 3)
		color = Color(r, g, b)
		
		inv_background.modulate = color
		menu_frame.modulate = color
		skill_banner.modulate = color
		skill_background.modulate = color
		skill_tree_background.modulate = color
		equipment_bg.modulate = color
		attributes_background.modulate = color
		def_val_background.modulate = color
		loot_background.modulate = color
		enemy_background.modulate = color
		craft_background.modulate = color
	else:
		colorUI(ui_color)

# Handle color change event from the color picker
func _on_UIColor_color_changed(color):
	colorUI(color)

onready var gui_color_picker = $UI/GUI/Menu/UIColor
func _on_ColorButton_pressed():
	gui_color_picker.visible  = !gui_color_picker.visible 


func switchButtonTextures()->void:
	var button= $UI/GUI/SkillBar/BaseAtkMode
	var new_texture_path = "res://Game button icons/hold_to_atk.png" if hold_to_base_atk else "res://Game button icons/click_to_atk.png"
	var new_texture = load(new_texture_path)
	button.texture_normal = new_texture
	
	var button1= $UI/GUI/SkillBar/SkillQueue
	var new_texture_path1 = "res://Game button icons/start_skill_queue.png" if skill_queue.queue_skills else "res://Game button icons/stop_skil_queue.png"
	var new_texture1 = load(new_texture_path1)
	button1.texture_normal = new_texture1
	
	
	
	


onready var fps_label: Label = $UI/GUI/Portrait/MinimapHolder/FPS
func frameRate()->void:
	var current_fps = Engine.get_frames_per_second()
	var new_fps: float
	if current_fps > 59:
		new_fps = current_fps 
	elif current_fps > 39:
		new_fps = current_fps
	elif current_fps > 34:
		new_fps = current_fps 
	elif current_fps > 29:
		new_fps = current_fps 
	else:
		new_fps = current_fps
	fps_label.text = str(new_fps)

func _on_FPS_pressed()->void:
	var current_fps = Engine.get_target_fps()
	# Define FPS mapping
	var fps_mapping = {
		10: 12,
		12: 15,
		15: 17,
		17: 20,
		20: 22,
		22: 25,
		25: 30,
		30: 35,
		35: 40,
		40: 60,
		60: 80,
		80: 15  # Wrap back to 15 if 80 FPS is reached
	}
	# Set target FPS
	if fps_mapping.has(current_fps):
		Engine.set_target_fps(fps_mapping[current_fps])


#_____________________________________Display Time/Location______________________________
onready var time_label = $UI/GUI/SkillBar/Time

func displayClock() -> void:
	# Get the current date and time
	var date_time = OS.get_datetime()
	
	# Format the time string
	var formatted_time = "%02d:%02d" % [date_time.hour, date_time.minute]
	
	# Format the date string
	var formatted_date = "%02d/%02d/%d" % [date_time.day, date_time.month, date_time.year]
	
	# Update the label text with time on top and date below, align left
	time_label.text = formatted_time + "\n" + formatted_date




onready var coordinates = $UI/GUI/Portrait/MinimapHolder/Coordinates
func positionCoordinates()->void:
	var rounded_position = Vector3(
		round(global_transform.origin.x * 10) / 10,
		round(global_transform.origin.y * 10) / 10,
		round(global_transform.origin.z * 10) / 10
	)
	# Use %d to format integers without decimals
	coordinates.text = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]

####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
####################################################################################################
#__________________________________Equipment Management____________________________
func gearUp()->void:	
	if is_instance_valid(skills):
		skills.EquipmentSwitch()

		
onready var main_weap_icon = $UI/GUI/Equipment/MainWeap/Icon
onready var sec_weap_icon = $UI/GUI/Equipment/SecWeap/Icon
onready var sec_wea_slot =$UI/GUI/Equipment/SecWeap
onready var legs_icon = $UI/GUI/Equipment/Pants/Icon
onready var helm_icon = $UI/GUI/Equipment/Helm/Icon

onready var chest_icon = $UI/GUI/Equipment/Chest/Icon
onready var feet_icon =$UI/GUI/Equipment/Feet/Icon
onready var glove_icon = $UI/GUI/Equipment/GloveR/Icon

onready var equipment_bg:TextureRect = $UI/GUI/Equipment/EquipmentBG
func connectEquipment()->void:
	main_weap_icon.connect("mouse_entered", self, "mainWeapMouseEntered")
	main_weap_icon.connect("mouse_exited", self, "mainWeapMouseExited")
	sec_weap_icon.connect("mouse_entered", self, "secWeapMouseEntered")
	sec_weap_icon.connect("mouse_exited", self, "secWeapMouseExited")
	
	feet_icon.connect("mouse_entered", self, "feetMouseEntered")
	feet_icon.connect("mouse_exited", self, "feetMouseExited")
	
	legs_icon.connect("mouse_entered", self, "legsMouseEntered")
	legs_icon.connect("mouse_exited", self, "legsMouseExited")
	
	chest_icon.connect("mouse_entered", self, "chestMouseEntered")
	chest_icon.connect("mouse_exited", self, "chestMouseExited")

	helm_icon.connect("mouse_entered", self, "helmMouseEntered")
	helm_icon.connect("mouse_exited", self, "helmMouseExited")

	glove_icon.connect("mouse_entered", self, "gloveMouseEntered")
	glove_icon.connect("mouse_exited", self, "gloveMouseExited")

	equipment_bg.connect("mouse_entered", self, "equipmentBackgroundMouseEntered")
	equipment_bg.connect("mouse_exited", self, "equipmentBackgroundMouseExited")
	
	
	
func equipmentBackgroundMouseEntered()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
func equipmentBackgroundMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func mainWeapMouseEntered()->void:
	gearUp()
	UniversalToolTip(main_weap_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func mainWeapMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func secWeapMouseEntered()->void:
	gearUp()
	UniversalToolTip(sec_weap_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func secWeapMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func legsMouseEntered()->void:
	gearUp()
	UniversalToolTip(legs_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func legsMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func chestMouseEntered()->void:
	gearUp()
	UniversalToolTip(chest_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func chestMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func feetMouseEntered()->void:
	gearUp()
	UniversalToolTip(feet_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func feetMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func helmMouseEntered()->void:
	gearUp()
	UniversalToolTip(helm_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func helmMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
#___________________________________________________________________________________________________
func gloveMouseEntered()->void:
	gearUp()
	UniversalToolTip(glove_icon.texture)
	SwitchEquipmentBasedOnEquipmentIcons()
func gloveMouseExited()->void:
	gearUp()
	deleteTooltip()
	SwitchEquipmentBasedOnEquipmentIcons()
	

# @Ceisri 
# Equipment System
# We check if the icon.texture of a specific equipment slot matches the texture path
# of an item. All the paths are found in Global.gd and accessed with Icons, which is a singleton.
# If the texture of the slot's icon matches, we activate an effect and deactivate other effects of similar equipment type.
# For example, if the primary weapon type is Icons.weapset1_icons["sword"], we set the primary weapon effect of that 
# specific weapon to true and turn off all the other primary weapon effects but not the secondary weapon effects,
# chest effects, boots effects, and so on.
# The 3D meshes are added directly as children of the skeleton. Where is the skeleton? At skills.skeleton.
# I tried adding the weapons as children of a bone attachment and setting it as current_weap_instance,
# then checking if it was null or not, checking the stats directly in the weapon instance, and so on, which also allowed
# for a system where the player could drop and pick up items from and on the ground. It wasn't very complicated,
# but this new system allows for "freedom." I can potentially hold as many weapons on me as possible,
# and have them on my back, side, or mix and match.
# Anyways for this to work, just make sure every equipment piece is rigged to that skelton,
# and when importing into the engine make sure it has the skin properties with the matching skeleton in the inspector

var weapon_type = Icons.weapon_type_list.fist
var main_weapon = Icons.main_weap_list.zero
var sec_weapon = Icons.sec_weap_list.zero
var head = "naked"
var torso = "naked"
var legs = "naked"
var hand_l = "naked"
var hand_r = "naked"
var feet = Icons.boots_list.set_1

func primaryWeapEffect(chosen: String) -> void:
	var effects: Array = [
		"weapset1_sword",
		"weapset1_hammer",
		"weapset1_mace2",
		"weapset1_axe",
		"weapset1_greatsword",
		"weapset1_greataxe",

		"weapset1_demo-hammer",
		"weapset1_greatmace",
		"weapset1_warhammer"
		# Add other effects as needed
	]
	for effect in effects:
		if effect != chosen:
			applyEffect(effect, false)
	applyEffect(chosen, true)
	
func secondaryWeapEffect(chosen: String) -> void:
	var effects: Array = [
		"weapset1_sword2",
		"weapset1_hammer2",
		"weapset1_mace2",
		"weapset1_axe2",
		"shield_wood_png",
		# Add other effects as needed
	]
	for effect in effects:
		if effect != chosen:
			applyEffect(effect, false)
	applyEffect(chosen, true)
	


func SwitchEquipmentBasedOnEquipmentIcons()-> void:
#main weapon____________________________________________________________________
	if sec_weap_icon.texture == null:
		sec_weapon = Icons.sec_weap_list.zero
		primaryWeapEffect("none")
	if main_weap_icon != null:
		if main_weap_icon.texture == null:
			sec_wea_slot.visible = true
			main_weapon = Icons.main_weap_list.zero
			primaryWeapEffect("none")
			weapon_type = Icons.weapon_type_list.fist
		else:
			if main_weap_icon.texture.get_path() == Icons.weapset1_icons["sword"].get_path():
				sec_wea_slot.visible = true
				main_weapon = Icons.main_weap_list.sword_beginner
				primaryWeapEffect("weapset1_sword")
				if sec_weap_icon.texture == null:
					sec_weapon = Icons.sec_weap_list.zero
					weapon_type = Icons.weapon_type_list.sword
			
			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["hammer"].get_path():
				sec_wea_slot.visible = true
				main_weapon = Icons.main_weap_list.hammer_beginner
				primaryWeapEffect("weapset1_hammer")
				if sec_weap_icon.texture == null:
					sec_weapon = Icons.sec_weap_list.zero
					weapon_type = Icons.weapon_type_list.sword
					
			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["mace"].get_path():
				sec_wea_slot.visible = true
				main_weapon = Icons.main_weap_list.mace_beginner
				primaryWeapEffect("weapset1_mace")
				if sec_weap_icon.texture == null:
					sec_weapon = Icons.sec_weap_list.zero
					weapon_type = Icons.weapon_type_list.sword
			
			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["axe"].get_path():
				sec_wea_slot.visible = true
				main_weapon = Icons.main_weap_list.axe_beginner
				primaryWeapEffect("weapset1_axe")
				if sec_weap_icon.texture == null:
					sec_weapon = Icons.sec_weap_list.zero
					weapon_type = Icons.weapon_type_list.sword
		
			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["greataxe"].get_path():
					main_weapon =  Icons.main_weap_list.greataxe_beginner
					primaryWeapEffect("weapset1_greataxe")
					secondaryWeapEffect("none")
					weapon_type = Icons.weapon_type_list.heavy
					sec_weapon = Icons.sec_weap_list.zero
					sec_wea_slot.visible = false

					
			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["greatsword"].get_path():
					main_weapon =  Icons.main_weap_list.greatsword_beginner
					primaryWeapEffect("weapset1_greatsword")
					secondaryWeapEffect("none")
					weapon_type = Icons.weapon_type_list.heavy
					sec_weapon = Icons.sec_weap_list.zero
					sec_wea_slot.visible = false

			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["demo-hammer"].get_path():
					main_weapon =  Icons.main_weap_list.demolition_hammer_beginner
					primaryWeapEffect("weapset1_demo-hammer")
					secondaryWeapEffect("none")
					weapon_type = Icons.weapon_type_list.heavy
					sec_weapon = Icons.sec_weap_list.zero
					sec_wea_slot.visible = false
					
			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["greatmace"].get_path():
					main_weapon =  Icons.main_weap_list.greatmace_beginner
					primaryWeapEffect("weapset1_greatmace")
					secondaryWeapEffect("none")
					weapon_type = Icons.weapon_type_list.heavy
					sec_weapon = Icons.sec_weap_list.zero
					sec_wea_slot.visible = false


			elif main_weap_icon.texture.get_path() == Icons.weapset1_icons["warhammer"].get_path():
					main_weapon =  Icons.main_weap_list.warhammer_beginner
					primaryWeapEffect("weapset1_warhammer")
					secondaryWeapEffect("none")
					weapon_type = Icons.weapon_type_list.heavy
					sec_weapon = Icons.sec_weap_list.zero
					sec_wea_slot.visible = false


			else:
				sec_wea_slot.visible = true
				main_weapon = Icons.main_weap_list.zero
				sec_weapon = Icons.sec_weap_list.zero
				primaryWeapEffect("none")
				weapon_type = Icons.weapon_type_list.fist
				
			
#sec weapon_____________________________________________________________________
			if sec_weap_icon == null:
				sec_weapon = Icons.sec_weap_list.zero
				secondaryWeapEffect("none")
			else:
				if sec_wea_slot.visible == false:
					sec_weapon = Icons.sec_weap_list.zero
					secondaryWeapEffect("none")
				else:
					if sec_weap_icon.texture == null:
						sec_weapon = Icons.sec_weap_list.zero
						secondaryWeapEffect("none")
					else:
						if sec_weap_icon.texture.get_path() == Icons.weapset1_icons["sword"].get_path():
							sec_weapon = Icons.sec_weap_list.sword_beginner
							secondaryWeapEffect("weapset1_sword2")
							weapon_type = Icons.weapon_type_list.dual_swords
						
						elif sec_weap_icon.texture.get_path() == Icons.weapset1_icons["hammer"].get_path():
							sec_weapon = Icons.sec_weap_list.hammer_beginner
							secondaryWeapEffect("weapset1_hammer2")
							weapon_type = Icons.weapon_type_list.dual_swords
							
						elif sec_weap_icon.texture.get_path() == Icons.weapset1_icons["mace"].get_path():
							sec_weapon = Icons.sec_weap_list.mace_beginner
							secondaryWeapEffect("weapset1_mace2")
							weapon_type = Icons.weapon_type_list.dual_swords	
					
						elif sec_weap_icon.texture.get_path() == Icons.weapset1_icons["axe"].get_path():
							sec_weapon = Icons.sec_weap_list.axe_beginner
							secondaryWeapEffect("weapset1_axe2")
							weapon_type = Icons.weapon_type_list.dual_swords	
					
						elif sec_weap_icon.texture.get_path() == Icons.weapset1_icons["shield"].get_path():
							sec_weapon = Icons.sec_weap_list.shield_beginner
							secondaryWeapEffect("shield_wood_png")
							weapon_type = Icons.weapon_type_list.sword_shield
							
						


#head___________________________________________________________________________
	if helm_icon != null:
		if helm_icon.texture != null:
			if helm_icon.texture.get_path() == Icons.hat1.get_path():
				head = "garment1"

		elif helm_icon.texture == null:
			head = "naked"

#_______________________________chest___________________________________________

	if chest_icon != null: #check if the icon and texture are null just to avoid crashes
		if chest_icon.texture != null:
			#the singleton Global.gd holds the preloads paths to various textures, match them to the specific armor icon
			if chest_icon.texture.get_path() == Icons.garment1.get_path():
				torso = "tunic0" # if they match set the variable Torso, legs, hands or whatever to a string or enum 
			elif chest_icon.texture.get_path() == Icons.torso_armor2.get_path():
				torso = "gambeson0"
			elif chest_icon.texture.get_path() == Icons.torso_armor3.get_path():
				torso = "chainmail0"
			elif chest_icon.texture.get_path() == Icons.torso_armor4.get_path():
				torso = "cuirass0"
		elif chest_icon.texture == null:
			torso = "naked"
#_______________________________legs____________________________________________
	
	if legs_icon != null:
		if legs_icon.texture != null:
			if legs_icon.texture.get_path() == Icons.pants1.get_path():
				legs = "pants0"
		elif legs_icon.texture == null:
			legs = "naked"


#_______________________________feet____________________________________________
	
	if feet_icon == null:
		feet = Icons.boots_list.set_0
	else:
		if  feet_icon.texture == null:
			feet = Icons.boots_list.set_0
		else:
			if  feet_icon.texture.get_path() == Icons.boots1.get_path():
				feet = Icons.boots_list.set_1
			elif feet_icon.texture.get_path() == Icons.boots1.get_path():
				feet = Icons.boots_list.set_2
				
				
				
	#REMINDER check for bugs, if none then move the savedata in savegame()
	sec_weap_icon.savedata()
	helm_icon.savedata()
	chest_icon.savedata()
	glove_icon.savedata()
	legs_icon.savedata()
	feet_icon.savedata()
	main_weap_icon.savedata()



func switchWeaponFromHandToSideOrBack()->void:
	if is_instance_valid(skills):
		skills.switchWeapon()



#@Ceisri
# This is used both for buffs, debuffs, item stats, consumable effects and whatelse...why is this not in a component? 
# because I'm delaying moving it to a component, other stuff to do now
var effects:Dictionary = { #Reminder to add extra_on_hit_resolve_regen to weapons
	"none": {"stats": {}, "applied": false},
#_______________________________________________Debuffs ____________________________________________
	"overhydration": {"stats": { "extra_vitality": -0.02,"extra_agility": -0.05,}, "applied": false},
	"dehydration": {"stats": { "extra_intelligence": -0.25,"extra_agility": -0.25,}, "applied": false},
	"bloated": {"stats": {"extra_intelligence": -0.02,"extra_agility": -0.15,}, "applied": false},
	"hungry": {"stats": {"extra_intelligence": -0.22,"extra_agility": -0.05,}, "applied": false},
	"bleeding": {"stats": {}, "applied": false},
	"stunned": {"stats": {}, "applied": false},
	"frozen": {"stats": {}, "applied": false},
	"blinded": {"stats": {}, "applied": false},
	"terrorized": {"stats": {}, "applied": false},
	"scared": {"stats": {}, "applied": false},
	"intimidated": {"stats": {}, "applied": false},
	"rooted": {"stats": {}, "applied": false},
	"blockbuffs": {"stats": {}, "applied": false},
	"blockactive": {"stats": {}, "applied": false},
	"blockpassive": {"stats": {}, "applied": false},
	"brokendefense": {"stats": {}, "applied": false},
	"healreduction": {"stats": {}, "applied": false},
	"bomb": {"stats": {}, "applied": false},
	"slow": {"stats": {}, "applied": false},
	"burn": {"stats": {}, "applied": false},
	"sleep": {"stats": {}, "applied": false},
	"weakness": {"stats": {}, "applied": false},
	"poisoned": {"stats": {}, "applied": false},
	"confused": {"stats": { "extra_intelligence": -0.75}, "applied": false},
	"impaired": {"stats": { "extra_dexterity": -0.25}, "applied": false},
	"lethargy": {"stats": {}, "applied": false},
	"redpotion": {"stats": {}, "applied": false},
	
#_________________________________________________Buffs ____________________________________________
	"berserk": {"stats": {"extra_intelligence": -0.5,"extra_balance": -0.5,"extra_agility": 0.5,"extra_melee_atk_speed": 1,"extra_range_atk_speed": 0.5,"extra_cast_atk_speed": 0.3,"extra_ferocity": 0.3,"extra_fury": 0.3,}, "applied": false},
	
	#equipment effects______________________________________________________________________________
	#Use thee respective names of item equipment png name in Icons, add a 2 at the end for secondary weapons
	
	"weapset1_sword": {"stats": {"extra_dmg": Icons.sword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.sword_beginner_absorb},
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["sword"], "applied": false},
	

	"weapset1_sword2": {"stats": {"extra_dmg": Icons.sword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.sword_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["sword"]}, "applied": false},
	
	"weapset1_hammer": {"stats": {"extra_dmg": Icons.sword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.sword_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["hammer"]}, "applied": false},
	
	"weapset1_hammer2": {"stats": {"extra_dmg": Icons.sword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.sword_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["hammer"]}, "applied": false},
	
	
	"weapset1_mace": {"stats": {"extra_dmg": Icons.sword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.sword_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["mace"]}, "applied": false},
	
	
	"weapset1_mace2": {"stats": {"extra_dmg": Icons.sword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.sword_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["mace"]}, "applied": false},
	
	
	"weapset1_axe": {"stats": {"extra_dmg": Icons.axe_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.axe_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["axe"]}, "applied": false},
	
	"weapset1_axe2": {"stats": {"extra_dmg": Icons.axe_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.axe_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["axe"]}, "applied": false},
	
	"weapset1_greatsword": {"stats": {"extra_dmg": Icons.greatsword_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.greatsword_beginner_absorb,
	"extra_on_hit_resolve_regen": 2.5,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["greatsword"]}, "applied": false},
	
	"weapset1_greataxe": {"stats": {"extra_dmg": Icons.greataxe_beginner_dmg,
	"extra_guard_dmg_absorbition": Icons.greataxe_beginner_absorb,
	"extra_on_hit_resolve_regen": 1,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["greataxe"]}, "applied": false},
	
	
	"weapset1_demo-hammer": {"stats": {"extra_dmg": Icons.demolition_hammer_beg_dmg,
	"extra_guard_dmg_absorbition": Icons.demolition_hammer_beg_absorb,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["demo-hammer"],
	"extra_on_hit_resolve_regen": 1,
	"extra_impact": Icons.demolition_hammer_beg_impact}, "applied": false},
	
	"weapset1_greatmace": {"stats": {"extra_dmg": Icons.greatmace_beg_dmg,
	"extra_guard_dmg_absorbition": Icons.greatmace_beg_absorb,
	"extra_melee_atk_speed": Icons.weapset1_atk_speed["greatmace"],
	"extra_on_hit_resolve_regen": 1,
	"extra_impact": Icons.greatmace_beg_impact}, "applied": false},
	
	"weapset1_warhammer": {"stats": {"extra_dmg": Icons.greatmace_beg_dmg,
	"extra_guard_dmg_absorbition": Icons.greatmace_beg_absorb,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["warhammer"],
	"extra_on_hit_resolve_regen": 1,
	"extra_impact": Icons.greatmace_beg_impact}, "applied": false},
	
	
	"shield_wood_png": {"stats": {"extra_guard_dmg_absorbition": Icons.shield_wood_absorb,
	"extra_melee_atk_speed":Icons.weapset1_atk_speed["shield"],
	"slash_resistance":Icons.shield_wood_general_defense,
	"blunt_resistance":Icons.shield_wood_general_defense,
	"pierce_resistance": Icons.shield_wood_general_defense,}, "applied": false},



}

# Function to apply or remove effects
func applyEffect(effect_name: String, active: bool)->void:
	var player = self 
	if effects.has(effect_name):
		var effect = effects[effect_name]
		if active and not effect["applied"]:
			# Apply effect
			for stat_name in effect["stats"].keys():
				player[stat_name] += effect["stats"][stat_name]
			effect["applied"] = true
		elif not active and effect["applied"]:
			# Remove effect
			for stat_name in effect["stats"].keys():
				if stat_name in player:
					player[stat_name] -= effect["stats"][stat_name]
			effect["applied"] = false
	else:
		print("Effect not found:", effect_name)



var stored_instigator:KinematicBody 
var bleeding_duration:float = 0
var stunned_duration:float = 0
var berserk_duration:float = 0 




func showStatusIcon()->void:
#	applyEffect(self, "bleeding", true)
#	applyEffect(self, "hungry", true)
#	applyEffect(self, "frozen", true)
#	applyEffect(self, "stunned", true)
#	applyEffect(self, "blinded", true)
#	applyEffect(self, "terrorized", true)
#	applyEffect(self, "scared", true)
#	applyEffect(self, "intimidated", true)
#	applyEffect(self, "rooted", true)
#	applyEffect(self, "blockbuffs", true)
#	applyEffect(self, "blockactive", true)
#	applyEffect(self, "blockpassive", true)
#	applyEffect(self, "brokendefense", true)
#	applyEffect(self, "healreduction", true)
#	applyEffect(self, "bomb", true)
#	applyEffect(self, "slow", true)
#	applyEffect(self, "burn", true)
#	applyEffect(self, "sleep", true)
#	applyEffect(self, "weakness", true)
#	applyEffect(self, "poisoned", true)
#	applyEffect(self, "confused", true)
#	applyEffect(self, "impaired", true)
#	applyEffect(self, "lethargy", true)
	var icon1 = $UI/GUI/Portrait/StatusGrid/Icon1
	var icon2 = $UI/GUI/Portrait/StatusGrid/Icon2
	var icon3 = $UI/GUI/Portrait/StatusGrid/Icon3
	var icon4 = $UI/GUI/Portrait/StatusGrid/Icon4
	var icon5 = $UI/GUI/Portrait/StatusGrid/Icon5
	var icon6 = $UI/GUI/Portrait/StatusGrid/Icon6
	var icon7 = $UI/GUI/Portrait/StatusGrid/Icon7
	var icon8 = $UI/GUI/Portrait/StatusGrid/Icon8
	var icon9 = $UI/GUI/Portrait/StatusGrid/Icon9
	var icon10 = $UI/GUI/Portrait/StatusGrid/Icon10
	var icon11 = $UI/GUI/Portrait/StatusGrid/Icon11
	var icon12 = $UI/GUI/Portrait/StatusGrid/Icon12
	var icon13 = $UI/GUI/Portrait/StatusGrid/Icon13
	var icon14 = $UI/GUI/Portrait/StatusGrid/Icon14
	var icon15 = $UI/GUI/Portrait/StatusGrid/Icon15
	var icon16 = $UI/GUI/Portrait/StatusGrid/Icon16
	var icon17 = $UI/GUI/Portrait/StatusGrid/Icon17
	var icon18 = $UI/GUI/Portrait/StatusGrid/Icon18
	var icon19 = $UI/GUI/Portrait/StatusGrid/Icon19
	var icon20 = $UI/GUI/Portrait/StatusGrid/Icon20
	var icon21 = $UI/GUI/Portrait/StatusGrid/Icon21
	var icon22 = $UI/GUI/Portrait/StatusGrid/Icon22
	var icon23 = $UI/GUI/Portrait/StatusGrid/Icon23
	var icon24 = $UI/GUI/Portrait/StatusGrid/Icon24
	# Reset all icons
	var all_icons = [icon1, icon2, icon3, icon4, icon5, icon6, icon7, icon8, icon9, icon10, icon11, icon12, icon13, icon14, icon15, icon16, icon17, icon18, icon19, icon20, icon21, icon22, icon23, icon24]
	for icon in all_icons:
		icon.texture = null
		icon.modulate = Color(1, 1, 1)


	# Apply status icons based on applied effects
	var applied_effects = [
		{"name": "dehydration", "texture": Icons.dehydration_texture, "modulation_color": Color(1, 0, 0)},
		{"name": "overhydration", "texture": Icons.overhydration_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bloated", "texture": Icons.bloated_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "hungry", "texture": Icons.hungry_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bleeding", "texture": Icons.bleeding_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "frozen", "texture": Icons.frozen_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "stunned", "texture": Icons.stunned_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blinded", "texture": Icons.blinded_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "terrorized", "texture": Icons.terrorized_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "scared", "texture": Icons.scared_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "intimidated", "texture": Icons.intimidated_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "rooted", "texture": Icons.rooted_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockbuffs", "texture": Icons.blockbuffs_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockactive", "texture": Icons.block_active_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockpassive", "texture": Icons.block_passive_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "brokendefense", "texture": Icons.broken_defense_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "healreduction", "texture": Icons.heal_reduction_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bomb", "texture": Icons.bomb_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "slow", "texture": Icons.slow_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "burn", "texture": Icons.burn_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "sleep", "texture": Icons.sleep_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "weakness", "texture": Icons.weakness_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "poisoned", "texture": Icons.poisoned_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "confused", "texture": Icons.confusion_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "impaired", "texture": Icons.impaired_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "lethargy", "texture": Icons.lethargy_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "redpotion", "texture": Icons.red_potion_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "berserk", "texture": Icons.berserk_texture, "modulation_color": Color(1, 1, 1)},
	]

	for effect in applied_effects:
		if effects.has(effect["name"]) and effects[effect["name"]]["applied"]:
			for icon in all_icons:
				if icon.texture == null:
					icon.texture = effect["texture"]
					icon.modulate = effect["modulation_color"]
					break  # Exit loop after applying status to the first available icon
#____________________Effects and their duration, activate or deactivate them here___________________
func potionEffects():
	redPotion()
	
var red_potion_duration = 0
func redPotion():
	if effects.has("redpotion") and effects["redpotion"]["applied"]:
		if red_potion_duration >0:
			health += 10
			red_potion_duration -= 1
			if health > max_health:
				health = max_health
			applyEffect("redpotion",true)
		else:
			applyEffect("redpotion",false)
			
			
func berserk(player: Node, effect_name: String, active: bool)->void:
	if effects.has("berserk") and effects["berserk"]["applied"]:
		if red_potion_duration >0:
			health += 10
			red_potion_duration -= 1
			applyEffect("redpotion",true)
		else:
			applyEffect("redpotion",false)
			
			
#_____________________________Hunger system and Hydration System___________________________
onready var kilocalories_label = $UI/GUI/Portrait/MinimapHolder/FoodLabel
onready var kilocalories_bar = $UI/GUI/Portrait/MinimapHolder/FoodBar
const base_kilocaries = 2000
var max_kilocalories = 2000
var kilocalories = 2000

var last_update_time: float = 0
var kilocalories_decrease_per_second: float = 0.023148 #kilocalories consumed per second

func hunger():
	var current_time = OS.get_ticks_msec() / 1000.0
	if last_update_time == 0:
		last_update_time = current_time
	var elapsed_time = current_time - last_update_time
	last_update_time = current_time
	# Calculate decrease based on elapsed time
	var decrease_amount = kilocalories_decrease_per_second * elapsed_time 
	if not health > max_health:
		if health > max_health * 0.5:
			if kilocalories > 0:
				kilocalories -= decrease_amount
				health += decrease_amount
		elif health < max_health * 0.5:
			if kilocalories > 0:
				kilocalories -= decrease_amount
				health += decrease_amount
	if is_sprinting:
		kilocalories -= decrease_amount * 7.196
	elif is_running:
		kilocalories -= decrease_amount * 5.038
	elif is_walking:
		kilocalories -= decrease_amount * 3.594 #walking consumes usually 3.594 more calories per second
	elif is_swimming:
		kilocalories -= decrease_amount * 6.5
	else:
		kilocalories -= decrease_amount
	if kilocalories > max_kilocalories * 1.15:
		applyEffect("bloated", true)
	else:
		applyEffect("bloated", false)
	if kilocalories < 0:
		applyEffect("hungry", true)
	else:
		applyEffect("hungry", false)

const base_water = 4000
var max_water = 4000
var water = 4000
var last_update_time_water: float = 0
var water_decrease_per_second: float = 0.045 #kilocalories consumed per second

func hydration():
	var current_time = OS.get_ticks_msec() / 1000.0
	if last_update_time_water == 0:
		last_update_time_water = current_time
	var elapsed_time = current_time - last_update_time_water
	last_update_time_water = current_time
	# Calculate decrease based on elapsed time
	var decrease_amount = water_decrease_per_second * elapsed_time 
	if water > -100:
		if not health > max_health:
			if health > max_health * 0.5:
				if water > 0:
					water -= decrease_amount
			elif health < max_health * 0.5:
				if water > 0:
					water -= decrease_amount
		if is_sprinting:
			water -= decrease_amount * 7.196
		elif is_running:
			water -= decrease_amount * 5.038
		elif is_walking:
			water -= decrease_amount * 3.594 #walking consumes usually 3.594 more calories per second
		elif is_swimming:
			water -= decrease_amount * 6.5
		else:
			water -= decrease_amount	

	if water > max_water * 1.15:
		applyEffect("overhydration", true)
	elif water < 0:
		health -= 10 * elapsed_time
		applyEffect("dehydration", true)
	elif water < max_water * 0.75:
		applyEffect("dehydration", true)
	else:
		applyEffect("overhydration", false)
		applyEffect("dehydration", false)

onready var black_screen = $UI/GUI/BlackScreen
onready var tween = $Camroot/h/v/Camera/Aim/Cross/Tween
func _on_Toilet2_pressed():
	if water > 500 or kilocalories > 125:
		kilocalories = kilocalories /2
		water = water/2
		if resolve > 25:
			resolve -= 25
		if breath > 30:
			breath -= 25
			
		if black_screen.modulate.a == 0: # If black screen is transparent
			# Tween to make black screen opaque
			tween.interpolate_property(black_screen, "modulate", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()

func curtainsDown():
	if black_screen.modulate.a == 1: # If black screen is opaque
		# Tween to make black screen transparent
		tween.interpolate_property(black_screen, "modulate", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

func _on_Toilet1_pressed():
	if water > 200:
		water -= 200
		if resolve > 5:
			resolve -= 5
		$Mesh/Piss.restart()
		var damage_type = "piss"
		var damage = 0
		var aggro_power = damage + 20
		var enemies = $Mesh/Piss.get_node("Area").get_overlapping_bodies()
		for enemy in enemies:
			if enemy.is_in_group("enemy"):
				enemy.applyEffect(enemy,"slow", true)
				if enemy.has_method("takeDamage"):
					if is_on_floor():
						#insert sound effect here
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)


#Stats__________________________________________________________________________
const base_weight = 60
var weight = 60
const base_walk_speed = 6
var walk_speed = 3
const base_run_speed = 7
var run_speed = 7
const base_crouch_speed = 2
var crouch_speed = 2
const base_jumping_power = 100
var jumping_power = 100
const base_dash_power = 20


var base_flank_dmg : float = 3.0
var flank_dmg: float =3.0 #extra damage to add to backstabs 

var base_dmg:float = 1
var extra_dmg:float = 0
var total_dmg:float = 1

var chopping_power:float = 1
var extra_chopping_power:float = 1
var total_chopping_power:float = 1

#magic energy systems 
const base_max_aefis = 100
var max_aefis = 100 
var aefis = 100 
#______________________
const base_max_nefis = 100
var max_nefis = 100 
var nefis = 100 
#_______________________
const base_max_vifis = 100
var max_vifis = 100 
var vifis = 100 

#health system 
const base_max_health = 100
var max_health = 100
var health = 100
#________________________


#additional combat energy systems
const base_max_resolve = 100
var max_resolve = 100
var resolve = 100
#__________________________
const base_max_breath = 100
var max_breath = 100
var breath = 100


var scale_factor = 1
#attributes 

var sanity: float  = 1
var wisdom: float = 1
var memory: float = 1
var intelligence: float = 1
var instinct: float = 1

var force: float = 1
var strength: float = 1
var impact: float = 1
var ferocity: float  = 1 
var fury: float = 1 

var accuracy: float = 1
var dexterity: float = 1
var poise: float = 1
var balance: float = 1
var focus: float = 1

var haste: float = 1
var agility: float = 1
var celerity: float = 1
var flexibility: float = 1
var deflection: float = 1

var endurance: float = 1
var stamina: float = 1
var vitality: float = 1
var resistance: float = 1
var tenacity: float = 1


var charisma: float = 1
var loyalty: float = 1 
var diplomacy: float = 1
var authority: float = 1
var courage: float = 1 


var threat_power:float = 0


var life_steal: float = 0.0
var exra_life_steal: float = 0.0
#resistances
var slash_resistance: int = 0 #50 equals 33.333% damage reduction 100 equals 50% damage reduction, 200 equals 66.666% damage reduction
var pierce_resistance: int = 0
var blunt_resistance: int = 0
var sonic_resistance: int = 0
var heat_resistance: int = 0
var cold_resistance: int = 0
var jolt_resistance: int = 0
var toxic_resistance: int = 0
var acid_resistance: int = 0
var bleed_resistance: int = 0
var neuro_resistance: int = 0
var radiant_resistance: int = 0


var stagger_resistance: float = 0.5 #0 to 100 in percentage, this is directly detracted to instigator.stagger_chance 
var deflection_chance : float = 0.33


var base_guard_dmg_absorbition: float = 2 #total damage taken will be divided by this when guarding
var extra_guard_dmg_absorbition:float
var guard_dmg_absorbition:float





var on_hit_resolve_regen:float = 1
var extra_on_hit_resolve_regen:float = 0
var total_on_hit_resolve_regen:float = 1

const base_melee_atk_speed: int = 1 
var melee_atk_speed: float = 1 
const base_range_atk_speed: int = 1 
var range_atk_speed: float = 1 
const base_casting_speed: int  = 1 
var casting_speed: float = 1 


var extra_melee_atk_speed : float = 0
var extra_range_atk_speed : float = 0
var extra_cast_atk_speed : float = 0



#equipment variables
var extra_sanity: float  = 0
var extra_wisdom: float = 0
var extra_memory: float = 0
var extra_intelligence: float = 0
var extra_instinct: float = 0

var extra_force: float = 0
var extra_strength: float = 0
var extra_impact: float = 0
var extra_ferocity: float  = 0
var extra_fury: float = 0

var extra_accuracy: float = 0
var extra_dexterity: float = 0
var extra_poise: float = 0
var extra_balance: float = 0
var extra_focus: float = 0

var extra_haste: float = 0
var extra_agility: float = 0
var extra_celerity: float = 0
var extra_flexibility: float = 0
var extra_deflection: float = 0

var extra_endurance: float = 0
var extra_stamina: float = 0
var extra_vitality: float = 0
var extra_resistance: float = 0
var extra_tenacity: float = 0


var extra_charisma : float = 0
var extra_loyalty : float = 0
var extra_diplomacy : float = 0
var extra_authority : float = 0
var extra_courage : float = 0


var total_sanity: float = 0
var total_wisdom: float = 0
var total_memory: float = 0
var total_intelligence: float = 0
var total_instinct: float = 0

var total_force: float = 0
var total_strength: float = 0
var total_impact: float = 0
var total_ferocity: float = 0
var total_fury: float = 0

var total_accuracy: float = 0
var total_dexterity: float = 0
var total_poise: float = 0
var total_balance: float = 0
var total_focus: float = 0

var total_haste: float = 0
var total_agility: float = 0
var total_celerity: float = 0
var total_flexibility: float = 0
var total_deflection: float = 0

var total_endurance: float = 0
var total_stamina: float = 0
var total_vitality: float = 0
var total_resistance: float = 0
var total_tenacity: float = 0

var total_charisma: float = 0
var total_loyalty: float = 0
var total_diplomacy: float = 0
var total_authority: float = 0
var total_courage: float = 0





func convertStats()->void:
	attackSpeedMath()
	flankDamageMath()
	baseDamageMath()
	rngStatsMath()
	resistanceMath()
	aefis = min(aefis + intelligence + wisdom, max_aefis)
	nefis = min(nefis + instinct, max_nefis)
		
		
	total_sanity = extra_sanity + sanity
	total_wisdom = extra_wisdom + wisdom
	total_memory = extra_memory + memory
	total_intelligence = extra_intelligence + intelligence
	total_instinct = extra_instinct + instinct

	total_force = extra_force + force
	total_strength = extra_strength + strength 
	total_impact = extra_impact + impact
	total_ferocity = extra_ferocity + ferocity
	total_fury = extra_fury + fury

	total_force = extra_force + force
	total_strength = extra_strength + strength
	total_impact = extra_impact + impact
	total_ferocity = extra_ferocity + ferocity
	total_fury = extra_fury + fury

	total_accuracy = extra_accuracy + accuracy
	total_dexterity = extra_dexterity + dexterity
	total_poise = extra_poise + poise
	total_balance = extra_balance + balance
	total_focus = extra_focus + focus

	total_haste = extra_haste + haste
	total_agility = extra_agility + agility
	total_celerity = extra_celerity + celerity
	total_flexibility = extra_flexibility + flexibility
	total_deflection = extra_deflection + deflection

	total_endurance = extra_endurance + endurance
	total_stamina = extra_stamina + stamina
	total_vitality = extra_vitality + vitality
	total_resistance = extra_resistance + resistance
	total_tenacity = extra_tenacity + tenacity

	total_charisma = extra_charisma + charisma
	total_loyalty = extra_loyalty + loyalty
	total_diplomacy = extra_diplomacy + diplomacy
	total_authority = extra_authority + authority
	total_courage = extra_courage + courage
	
	max_health = base_max_health * total_vitality
	max_sprint_speed = base_max_sprint_speed * total_agility
	run_speed = base_run_speed * total_agility
	guard_dmg_absorbition = extra_guard_dmg_absorbition + base_guard_dmg_absorbition
	
	total_on_hit_resolve_regen = on_hit_resolve_regen+ extra_on_hit_resolve_regen

	
var base_critical_chance: float = 12.5
var extra_critical_chance: float 
var critical_chance: float 

var base_critical_dmg: float = 2.0
var extra_critical_dmg: float 
var critical_dmg: float


var base_stagger_chance: float  = 5
var extra_stagger_chance: float
var stagger_chance: float 

var knockdown_chance: float = 10


func rngStatsMath()->void:
	critical_chance = (base_critical_chance + extra_critical_chance) * total_accuracy
	critical_dmg = (base_critical_dmg + extra_critical_dmg) * total_fury

	stagger_chance = (base_stagger_chance + extra_stagger_chance ) * total_force * 10






	
func _on_FlankDMG_mouse_entered()->void:
	var title:String = "Flank Damage"
	var text:String = "Non-Frontal attacks towards enemies deal extra flat flank damage\n. gain more flank damage by  from your ferocity attribute, accuracy attribute, from skills or equipment" 
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_FlankDMG_mouse_exited()->void:
	deleteTooltip()
	
func flankDamageMath()->void:
	flank_dmg = (base_flank_dmg * (total_ferocity + total_accuracy)) 



var base_dmg_type :String = "blunt" #this changes based on the weapon that is being used
func _on_BaseDMG_mouse_entered()->void:
	var title:String = "Base Damage"
	var text:String = "This is the base damage you do with physical attacks, wether melee or ranged by using throwables or bows, no effect on crossbows or other mechanical weapons, no effect on attacks which are purely based on Aefis or Nefis" 
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_BaseDMG_mouse_exited()->void:
	deleteTooltip()
func baseDamageMath()->void:
	total_dmg = (extra_dmg + base_dmg) * total_strength
	
func _on_Guard_Protection_mouse_entered()->void:
	var title:String = "Guard Protection"
	var text:String = "when guarding either with right click or other skills and abilities,damage taken is divided by " + str(guard_dmg_absorbition)
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_Guard_Protection_mouse_exited():
	deleteTooltip()


func attackSpeedMath()->void:
	var bonus_universal_speed = (total_celerity -1) * 0.15
	var atk_speed_formula = (total_dexterity - scale_factor ) * 0.5 
	melee_atk_speed = base_melee_atk_speed + atk_speed_formula + bonus_universal_speed + extra_melee_atk_speed
	
	var atk_speed_formula_range = (total_strength -1) * 0.5
	range_atk_speed = base_range_atk_speed + atk_speed_formula_range + bonus_universal_speed+ extra_range_atk_speed
	
	var atk_speed_formula_casting = (total_instinct -1) * 0.35 + ((total_memory-1) * 0.05) + bonus_universal_speed
	casting_speed = base_casting_speed + atk_speed_formula_casting	+ extra_cast_atk_speed






func _on_ReLabel_mouse_entered()->void:
	var title:String = "Resolve"
	var text:String = "Gain Resolve at a ratio of 100% your tenacity and 50% your resistance\n.Consume resolve to dodge, block and to use melee attacks" 
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_ReLabel_mouse_exited():
	deleteTooltip()
func _on_LifeBar_mouse_entered()->void:
	var title:String = "Life points"
	var text:String = "Gain life at a ratio of 100% your vitality and 50% your resistance and 100% of your height\n.Reaching 0 life points makes downed you lose all threat from neutral enemies when downed and can't do anything but crawl around,when downed you bleed every second losing more life points, reaching -100 results in death" 
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_LifeBar_mouse_exited():
	deleteTooltip()
	
	
func resistanceMath()->void:
	var additional_resistance: float  = 0
	var res_multiplier : float  = 0.5
	if total_resistance > 1:
		additional_resistance = res_multiplier * (total_resistance - 1)
	elif total_resistance < 1:
		additional_resistance = -res_multiplier * (1 - total_resistance)

	max_health = (base_max_health * (total_vitality + additional_resistance)) * scale_factor
	max_breath = base_max_breath * (total_stamina  + additional_resistance)
	max_resolve = base_max_resolve * (total_tenacity + additional_resistance)




func _on_AeBar_mouse_entered()->void:
	var title:String = "Aefis"
	var text:String = "Gain Aefis at a ratio of 50% your intelligence, 25% your wisdom and  25% your sanity\nYour body can harvest the free-flowing Aefis in the universe, a form of energy used for creation. This ethereal force can be channeled to shape reality, manifesting your deepest desires and forging powerful artifacts. Mastery of Aefis allows you to tap into limitless potential, altering the fabric of existence itself." 
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_AeBar_mouse_exited():
	deleteTooltip()
func _on_NeBar_mouse_entered()->void:
	var title:String = "Nefis"
	var text:String = "Gain Nefis at a ratio of 50% your instinct, 25% your fury and  25% your force\nYour body produces the free-flowing Nefis, a form of energy used for destruction and corruption. This dark force can be channeled to unravel reality, spreading chaos and forging weapons of immense power. Mastery of Nefis allows you to tap into its malevolent potential, altering the fabric of existence with devastating effects."
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,title,text)
func _on_NeBar_mouse_exited():
	deleteTooltip()

func updateAefisNefis()->void:
	var intelligence_portion = total_intelligence * 0.5
	var instinct_portion = total_instinct * 0.5
	var wisdom_portion = total_wisdom * 0.25
	var sanity_portion = total_sanity * 0.25
	var fury_portion = total_fury * 0.25 
	var force_portion = total_force * 0.25
	max_aefis = base_max_aefis * (wisdom_portion + intelligence_portion+ sanity_portion)
	max_nefis = base_max_nefis * (instinct_portion + force_portion + fury_portion)

onready var hp_bar = $UI/GUI/Portrait/LifeBar
onready var hp_label = $UI/GUI/Portrait/LifeLabel
onready var re_bar = $UI/GUI/Portrait/ReBar
onready var re_label = $UI/GUI/Portrait/ReLabel
onready var br_bar = $UI/GUI/Portrait/BrBar
onready var br_label = $UI/GUI/Portrait/BrLabel
onready var ae_bar = $UI/GUI/Portrait/AeBar
onready var ae_label = $UI/GUI/Portrait/AeLabel
onready var ne_bar = $UI/GUI/Portrait/NeBar
onready var ne_label = $UI/GUI/Portrait/NeLabel
onready var food_bar = $UI/GUI/Portrait/MinimapHolder/FoodBar
onready var food_label = $UI/GUI/Portrait/MinimapHolder/FoodLabel
onready var water_bar = $UI/GUI/Portrait/MinimapHolder/WaterBar
onready var water_label = $UI/GUI/Portrait/MinimapHolder/WaterLabel
func allResourcesBarsAndLabels()->void:
	displayResources(hp_bar,hp_label,health,max_health,"HP")
	displayResourcesRound(water_bar,water_label,water,max_water,"")
	displayResourcesRound(food_bar,food_label,kilocalories,max_kilocalories,"")
	displayResourcesRound(ne_bar,ne_label,nefis,max_nefis,"NE : ")
	displayResourcesRound(ae_bar,ae_label,aefis,max_aefis,"AE : ")
	displayResourcesRound(re_bar,re_label,resolve,max_resolve,"RE : ")
	displayResourcesRound(br_bar,br_label,breath,max_breath,"BH : ")
	
	
func displayResources(bar,label,value,max_value,acronim)->void:
	label.text =  acronim + ": %.2f / %.2f" % [value,max_value]
	bar.value = value 
	bar.max_value = max_value 
func displayResourcesRound(bar,label,value,max_value,acronim)->void:
	label.text =  acronim + str(round(value)) + "/" + str(round(max_value))
	bar.value = value 
	bar.max_value = max_value 


var attribute_increase_factor = 0.1
var minimum_att_value = 0.005
#Leveling compounding attributes 
var spent_attribute_points_san = 0
var spent_attribute_points_wis = 0
var spent_attribute_points_mem = 0
var spent_attribute_points_int = 0
var spent_attribute_points_ins = 0

var spent_attribute_points_for = 0
var spent_attribute_points_str = 0
var spent_attribute_points_fur = 0
var spent_attribute_points_imp = 0
var spent_attribute_points_fer = 0

var spent_attribute_points_foc = 0
var spent_attribute_points_bal = 0
var spent_attribute_points_dex = 0
var spent_attribute_points_acc = 0
var spent_attribute_points_poi = 0

var spent_attribute_points_has = 0
var spent_attribute_points_agi = 0
var spent_attribute_points_cel = 0
var spent_attribute_points_fle = 0
var spent_attribute_points_def = 0

var spent_attribute_points_end = 0
var spent_attribute_points_sta = 0
var spent_attribute_points_vit = 0
var spent_attribute_points_res = 0
var spent_attribute_points_ten = 0

var spent_attribute_points_cha = 0
var spent_attribute_points_loy = 0 
var spent_attribute_points_dip = 0
var spent_attribute_points_aut = 0
var spent_attribute_points_cou = 0

func displayLabels()->void:
	var cast_spd_label: Label = $UI/GUI/CombatStats/GridContainer/CastingSpeedValue
	displayStats(cast_spd_label,casting_speed)
	var ran_spd_label: Label = $UI/GUI/CombatStats/GridContainer/RangedSpeedValue
	displayStats(ran_spd_label,range_atk_speed)
	var atk_spd_label: Label =$UI/GUI/CombatStats/GridContainer/AtkSpeedValue
	displayStats(atk_spd_label,melee_atk_speed)
	var life_steal_label: Label = $UI/GUI/CombatStats/GridContainer/LifeStealValue
	displayStats(life_steal_label,life_steal)
	var stagger_chance_label: Label = $UI/GUI/CombatStats/GridContainer/StaggerChanceValue
	displayStats(stagger_chance_label,stagger_chance)
	
	
	var dmg_label = $UI/GUI/CombatStats/GridContainer/BaseDMGValue
	displayStats(dmg_label,total_dmg)
	
	var guard_label = $UI/GUI/CombatStats/GridContainer/GuardPROTValue
	displayStats(guard_label,guard_dmg_absorbition)
	
	
	var crits_label = $UI/GUI/CombatStats/GridContainer/CritChanceValue
	displayStats(crits_label,critical_chance)
	
	var flank_dmg_label =$UI/GUI/CombatStats/GridContainer/FlankDMGValue
	displayStats(flank_dmg_label,flank_dmg)
	
	
	var int_lab = $UI/GUI/Equipment/Attributes/Intelligence/value
	displayStats(int_lab, total_intelligence)
	var value_ins = $UI/GUI/Equipment/Attributes/Instinct/value
	var value_wis = $UI/GUI/Equipment/Attributes/Wisdom/value
	var value_mem = $UI/GUI/Equipment/Attributes/Memory/value
	var value_san = $UI/GUI/Equipment/Attributes/Sanity/value

	var value_strength = $UI/GUI/Equipment/Attributes/Strength/value	
	var value_force = $UI/GUI/Equipment/Attributes/Force/value
	var value_impact = $UI/GUI/Equipment/Attributes/Impact/value
	var value_ferocity = $UI/GUI/Equipment/Attributes/Ferocity/value
	var value_fury = $UI/GUI/Equipment/Attributes/Fury/value

	var value_accuracy = $UI/GUI/Equipment/Attributes/Accuracy/value
	var value_dexterity = $UI/GUI/Equipment/Attributes/Dexterity/value
	var value_poise = $UI/GUI/Equipment/Attributes/Poise/value
	var value_balance = $UI/GUI/Equipment/Attributes/Balance/value
	var value_focus = $UI/GUI/Equipment/Attributes/Focus/value
	var value_haste = $UI/GUI/Equipment/Attributes/Haste/value
	var value_agility = $UI/GUI/Equipment/Attributes/Agility/value
	var value_celerity = $UI/GUI/Equipment/Attributes/Celerity/value
	var value_flexibility = $UI/GUI/Equipment/Attributes/Flexibility/value

	var value_deflection = $UI/GUI/Equipment/Attributes/Deflection/value
	var value_endurance = $UI/GUI/Equipment/Attributes/Endurance/value
	var value_stamina = $UI/GUI/Equipment/Attributes/Stamina/value
	var value_vitality = $UI/GUI/Equipment/Attributes/Vitality/value
	var value_resistance = $UI/GUI/Equipment/Attributes/Resistance/value
	var value_tenacity = $UI/GUI/Equipment/Attributes/Tenacity/value


	var val_cha = $UI/GUI/Equipment/Attributes/Charisma/value
	displayStats(val_cha,total_charisma)
	var val_dip = $UI/GUI/Equipment/Attributes/Diplomacy/value
	displayStats(val_dip,total_diplomacy)
	var val_au = $UI/GUI/Equipment/Attributes/Authority/value
	displayStats(val_au,total_authority)	
	var val_cou = $UI/GUI/Equipment/Attributes/Courage/value
	displayStats(val_cou,total_courage)
	var val_loy = $UI/GUI/Equipment/Attributes/Loyalty/value
	displayStats(val_loy,total_loyalty)
	
	displayStats(value_ins,total_instinct)
	displayStats(value_wis,total_wisdom)
	displayStats(value_mem,total_memory)
	displayStats(value_san,total_sanity)
	displayStats(value_force,total_force)
	displayStats(value_strength,total_strength)
	displayStats(value_impact,total_impact)
	displayStats(value_ferocity,total_ferocity)
	displayStats(value_fury,total_fury)	
	displayStats(value_accuracy,total_accuracy)
	displayStats(value_dexterity,total_dexterity)
	displayStats(value_poise,total_poise)
	displayStats(value_balance,total_balance)
	displayStats(value_focus,total_focus)
	displayStats(value_haste,total_haste)
	displayStats(value_agility,total_agility)
	displayStats(value_celerity,total_celerity)
	displayStats(value_flexibility,total_flexibility)
	displayStats(value_deflection,total_deflection)
	displayStats(value_endurance,total_endurance)
	displayStats(value_stamina,total_stamina)
	displayStats(value_vitality,total_vitality)
	displayStats(value_resistance,total_resistance)
	displayStats(value_tenacity,total_tenacity)
	
	
	#resistances________________________________________________________________
	var val_slash : Label = $UI/GUI/Equipment/DmgDef/Defenses/Slaval
	displayStats(val_slash, slash_resistance)
	var val_blunt : Label = $UI/GUI/Equipment/DmgDef/Defenses/Bluntval
	displayStats(val_blunt, blunt_resistance)
	var val_pierce : Label = $UI/GUI/Equipment/DmgDef/Defenses/Pierceval
	displayStats(val_pierce, pierce_resistance)
	var val_sonic : Label = $UI/GUI/Equipment/DmgDef/Defenses/Sonicval
	displayStats(val_sonic, sonic_resistance)
	var val_heat : Label = $UI/GUI/Equipment/DmgDef/Defenses/Heatval
	displayStats(val_heat, heat_resistance)
	var val_cold : Label = $UI/GUI/Equipment/DmgDef/Defenses/Coldval
	displayStats(val_cold, cold_resistance)
	var val_jolt : Label = $UI/GUI/Equipment/DmgDef/Defenses/Joltval
	displayStats(val_jolt, jolt_resistance)
	var val_toxic : Label = $UI/GUI/Equipment/DmgDef/Defenses/Toxicval
	displayStats(val_toxic, toxic_resistance)
	var val_acid : Label = $UI/GUI/Equipment/DmgDef/Defenses/Acidval
	displayStats(val_acid, acid_resistance)
	var val_bleed : Label = $UI/GUI/Equipment/DmgDef/Defenses/Bleedval
	displayStats(val_bleed, bleed_resistance)
	var val_neuro : Label = $UI/GUI/Equipment/DmgDef/Defenses/Neuroval
	displayStats(val_neuro, neuro_resistance)
	var val_radiant : Label = $UI/GUI/Equipment/DmgDef/Defenses/Radiantval
	displayStats(val_radiant, radiant_resistance)


func showAttributePoints():
		$UI/GUI/Equipment/Attributes/AttributePoints.text = "Attributes points left: " + str(attribute)
	# Calculate the sum of all spent attribute points
		var total_spent_attribute_points = spent_attribute_points_san + spent_attribute_points_wis + spent_attribute_points_mem + spent_attribute_points_int + spent_attribute_points_ins +spent_attribute_points_for + spent_attribute_points_str + spent_attribute_points_fur + spent_attribute_points_imp + spent_attribute_points_fer + spent_attribute_points_foc + spent_attribute_points_bal + spent_attribute_points_dex + spent_attribute_points_acc + spent_attribute_points_poi +spent_attribute_points_has + spent_attribute_points_agi + spent_attribute_points_cel + spent_attribute_points_fle + spent_attribute_points_def + spent_attribute_points_end + spent_attribute_points_sta + spent_attribute_points_vit + spent_attribute_points_res + spent_attribute_points_ten + spent_attribute_points_cha + spent_attribute_points_loy + spent_attribute_points_dip + spent_attribute_points_aut + spent_attribute_points_cou
		# Update the text in the UI/GUI
		$UI/GUI/Equipment/Attributes/AttributeSpent.text = "Attributes points Spent: " + str(total_spent_attribute_points)


func displayStats(label, value)->void:
	var rounded_value = str(round(value * 1000) / 1000)
	label.text = rounded_value

func connectAttributeHovering()->void:
	var int_label: Label = $UI/GUI/Equipment/Attributes/Intelligence
	var ins_label = $UI/GUI/Equipment/Attributes/Instinct
	var wis_label = $UI/GUI/Equipment/Attributes/Wisdom
	var san_label = $UI/GUI/Equipment/Attributes/Sanity
	var mem_label = $UI/GUI/Equipment/Attributes/Memory
	var force_label = $UI/GUI/Equipment/Attributes/Force
	var str_label =$UI/GUI/Equipment/Attributes/Strength
	var imp_label =$UI/GUI/Equipment/Attributes/Impact
	var fer_label = $UI/GUI/Equipment/Attributes/Ferocity
	var fury_label = $UI/GUI/Equipment/Attributes/Fury
	
	var accuracy_label = $UI/GUI/Equipment/Attributes/Accuracy
	var dexterity_label = $UI/GUI/Equipment/Attributes/Dexterity
	var poise_label = $UI/GUI/Equipment/Attributes/Poise
	var balance_label = $UI/GUI/Equipment/Attributes/Balance
	var focus_label = $UI/GUI/Equipment/Attributes/Focus

	var haste_label = $UI/GUI/Equipment/Attributes/Haste
	var agility_label = $UI/GUI/Equipment/Attributes/Agility
	var celerity_label = $UI/GUI/Equipment/Attributes/Celerity
	var flexibility_label = $UI/GUI/Equipment/Attributes/Flexibility
	var deflection_label = $UI/GUI/Equipment/Attributes/Deflection

	var endurance_label = $UI/GUI/Equipment/Attributes/Endurance
	var stamina_label = $UI/GUI/Equipment/Attributes/Stamina
	var vitality_label = $UI/GUI/Equipment/Attributes/Vitality
	var resistance_label = $UI/GUI/Equipment/Attributes/Resistance
	var tenacity_label = $UI/GUI/Equipment/Attributes/Tenacity

	var charisma_label = $UI/GUI/Equipment/Attributes/Charisma
	var loyalty_label = $UI/GUI/Equipment/Attributes/Loyalty
	var diplomacy_label = $UI/GUI/Equipment/Attributes/Diplomacy
	var authority_label = $UI/GUI/Equipment/Attributes/Authority

	var courage_label = $UI/GUI/Equipment/Attributes/Courage	
	# Set mouse_filter for each label to stop mouse events
	int_label.mouse_filter = Control.MOUSE_FILTER_STOP
	ins_label.mouse_filter = Control.MOUSE_FILTER_STOP
	wis_label.mouse_filter = Control.MOUSE_FILTER_STOP
	san_label.mouse_filter = Control.MOUSE_FILTER_STOP
	mem_label.mouse_filter = Control.MOUSE_FILTER_STOP
	
	force_label.mouse_filter = Control.MOUSE_FILTER_STOP
	str_label.mouse_filter = Control.MOUSE_FILTER_STOP
	imp_label.mouse_filter = Control.MOUSE_FILTER_STOP
	fer_label.mouse_filter = Control.MOUSE_FILTER_STOP
	fury_label.mouse_filter = Control.MOUSE_FILTER_STOP
	
	haste_label.mouse_filter = Control.MOUSE_FILTER_STOP
	agility_label.mouse_filter = Control.MOUSE_FILTER_STOP
	celerity_label.mouse_filter = Control.MOUSE_FILTER_STOP
	flexibility_label.mouse_filter = Control.MOUSE_FILTER_STOP
	deflection_label.mouse_filter = Control.MOUSE_FILTER_STOP	
	
	accuracy_label.mouse_filter = Control.MOUSE_FILTER_STOP
	dexterity_label.mouse_filter = Control.MOUSE_FILTER_STOP
	poise_label.mouse_filter = Control.MOUSE_FILTER_STOP
	balance_label.mouse_filter = Control.MOUSE_FILTER_STOP
	focus_label.mouse_filter = Control.MOUSE_FILTER_STOP

	endurance_label.mouse_filter = Control.MOUSE_FILTER_STOP
	stamina_label.mouse_filter = Control.MOUSE_FILTER_STOP
	vitality_label.mouse_filter = Control.MOUSE_FILTER_STOP
	resistance_label.mouse_filter = Control.MOUSE_FILTER_STOP
	tenacity_label.mouse_filter = Control.MOUSE_FILTER_STOP

	charisma_label.mouse_filter = Control.MOUSE_FILTER_STOP
	loyalty_label.mouse_filter = Control.MOUSE_FILTER_STOP
	diplomacy_label.mouse_filter = Control.MOUSE_FILTER_STOP
	authority_label.mouse_filter = Control.MOUSE_FILTER_STOP
	courage_label.mouse_filter = Control.MOUSE_FILTER_STOP

	# Connect mouse entered and exited signals for Intelligence label
	int_label.connect("mouse_entered", self, "intHovered")
	int_label.connect("mouse_exited", self, "intExited")
	# Connect mouse entered and exited signals for Instinct label
	ins_label.connect("mouse_entered", self, "insHovered")
	ins_label.connect("mouse_exited", self, "insExited")
	# Connect mouse entered and exited signals for Wisdom label
	wis_label.connect("mouse_entered", self, "wisHovered")
	wis_label.connect("mouse_exited", self, "wisExited")
	# Connect mouse entered and exited signals for Memory label
	mem_label.connect("mouse_entered", self, "memHovered")
	mem_label.connect("mouse_exited", self, "memExited")	
	# Connect mouse entered and exited signals for Sanity label
	san_label.connect("mouse_entered", self, "sanHovered")
	san_label.connect("mouse_exited", self, "sanExited")

	# Connect mouse entered and exited signals for Strength label
	str_label.connect("mouse_entered", self, "strHovered")
	str_label.connect("mouse_exited", self, "strExited")
	# Connect mouse entered and exited signals for Force label
	force_label.connect("mouse_entered", self, "forceHovered")
	force_label.connect("mouse_exited", self, "forceExited")
	# Connect mouse entered and exited signals for Impact label
	imp_label.connect("mouse_entered", self, "impHovered")
	imp_label.connect("mouse_exited", self, "impExited")
	# Connect mouse entered and exited signals for Ferocity label
	fer_label.connect("mouse_entered", self, "ferHovered")
	fer_label.connect("mouse_exited", self, "ferExited")
	# Connect mouse entered and exited signals for Fury label
	fury_label.connect("mouse_entered", self, "furHovered")
	fury_label.connect("mouse_exited", self, "furExited")

	# Connect mouse entered and exited signals for Vitality label
	vitality_label.connect("mouse_entered", self, "vitHovered")
	vitality_label.connect("mouse_exited", self, "vitExited")
	# Connect mouse entered and exited signals for Stamina label
	stamina_label.connect("mouse_entered", self, "staHovered")
	stamina_label.connect("mouse_exited", self, "staExited")
	# Connect mouse entered and exited signals for Endurance label
	endurance_label.connect("mouse_entered", self, "endHovered")
	endurance_label.connect("mouse_exited", self, "endExited")	
	# Connect mouse entered and exited signals for Resistance label
	resistance_label.connect("mouse_entered", self, "resHovered")
	resistance_label.connect("mouse_exited", self, "resExited")
	# Connect mouse entered and exited signals for Tenacity label
	tenacity_label.connect("mouse_entered", self, "tenHovered")
	tenacity_label.connect("mouse_exited", self, "tenExited")

	# Connect mouse entered and exited signals for Agility label
	agility_label.connect("mouse_entered", self, "agiHovered")
	agility_label.connect("mouse_exited", self, "agiExited")
	# Connect mouse entered and exited signals for Haste label
	haste_label.connect("mouse_entered", self, "hasHovered")
	haste_label.connect("mouse_exited", self, "hasExited")
	# Connect mouse entered and exited signals for Celerity label
	celerity_label.connect("mouse_entered", self, "celHovered")
	celerity_label.connect("mouse_exited", self, "celExited")
	# Connect mouse entered and exited signals for Flexibility label
	flexibility_label.connect("mouse_entered", self, "fleHovered")
	flexibility_label.connect("mouse_exited", self, "fleExited")
	# Connect mouse entered and exited signals for Deflection label
	deflection_label.connect("mouse_entered", self, "defHovered")
	deflection_label.connect("mouse_exited", self, "defExited")
	
	# Connect mouse entered and exited signals for Dexterity label
	dexterity_label.connect("mouse_entered", self, "dexHovered")
	dexterity_label.connect("mouse_exited", self, "dexExited")
	# Connect mouse entered and exited signals for Accuracy label
	accuracy_label.connect("mouse_entered", self, "accHovered")
	accuracy_label.connect("mouse_exited", self, "accExited")	
	# Connect mouse entered and exited signals for Focus label
	focus_label.connect("mouse_entered", self, "focHovered")
	focus_label.connect("mouse_exited", self, "focExited")
	# Connect mouse entered and exited signals for Poise label
	poise_label.connect("mouse_entered", self, "poiHovered")
	poise_label.connect("mouse_exited", self, "poiExited")
	# Connect mouse entered and exited signals for Balance label
	balance_label.connect("mouse_entered", self, "balHovered")
	balance_label.connect("mouse_exited", self, "balExited")

	# Connect mouse entered and exited signals for Charisma label
	charisma_label.connect("mouse_entered", self, "chaHovered")
	charisma_label.connect("mouse_exited", self, "chaExited")
	# Connect mouse entered and exited signals for Diplomacy label
	diplomacy_label.connect("mouse_entered", self, "dipHovered")
	diplomacy_label.connect("mouse_exited", self, "dipExited")
	# Connect mouse entered and exited signals for Authority label
	authority_label.connect("mouse_entered", self, "autHovered")
	authority_label.connect("mouse_exited", self, "autExited")
	# Connect mouse entered and exited signals for Courage label
	courage_label.connect("mouse_entered", self, "couHovered")
	courage_label.connect("mouse_exited", self, "couExited")
	# Connect mouse entered and exited signals for Loyalty label
	loyalty_label.connect("mouse_entered", self, "loHovered")
	loyalty_label.connect("mouse_exited", self, "loyExited")
# Functions to handle mouse entering and exiting each label



func intHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"Intelligence","Increases the  rate at which you gain experience.\nIncreases your Aefis")
func intExited()->void:
	deleteTooltip()
func insHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"Instinct","Increases your Nefis")
func insExited()->void:
	deleteTooltip()
func wisHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func wisExited()->void:
	deleteTooltip()
func memHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func memExited()->void:
	deleteTooltip()
func sanHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"Sanity","Makes you more resistant to certain debuffs\nIncreases your Aefis")
func sanExited()->void:
	deleteTooltip()

func strHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func strExited()->void:
	deleteTooltip()
func forceHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","Increases your Nefis")
func forceExited()->void:
	deleteTooltip()
func impHovered()->void:
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func impExited():
	deleteTooltip()
func ferHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func ferExited():
	deleteTooltip()
func furHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func furExited():
	deleteTooltip()


func vitHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func vitExited():
	deleteTooltip()
func staHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func staExited():
	deleteTooltip()
func endHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func endExited():
	deleteTooltip()
func resHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func resExited():
	deleteTooltip()
func tenHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func tenExited():
	deleteTooltip()

func agiHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func agiExited():
	deleteTooltip()
func hasHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func hasExited():
	deleteTooltip()
func celHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func celExited():
	deleteTooltip()
func fleHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func fleExited():
	deleteTooltip()

func defHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func defExited():
	deleteTooltip()
func dexHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func dexExited():
	deleteTooltip()
func accHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func accExited():
	deleteTooltip()
func focHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func focExited():
	deleteTooltip()
func poiHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func poiExited():
	deleteTooltip()
func balHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func balExited():
	deleteTooltip()
	
func chaHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func chaExited():
	deleteTooltip()
func dipHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func dipExited():
	deleteTooltip()
func autHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func autExited():
	deleteTooltip()
func couHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func couExited():
	deleteTooltip()
func loyHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func loyExited():
	deleteTooltip()


func connectHoveredResistanceLabels():
	var slash_label = $UI/GUI/Equipment/DmgDef/Defenses/Slash
	slash_label.mouse_filter = Control.MOUSE_FILTER_STOP
	slash_label.connect("mouse_entered", self, "slashResHovered")
	slash_label.connect("mouse_exited", self, "slashResExited")
	var blunt_label = $UI/GUI/Equipment/DmgDef/Defenses/Blunt
	blunt_label.mouse_filter = Control.MOUSE_FILTER_STOP
	blunt_label.connect("mouse_entered", self, "bluntResHovered")
	blunt_label.connect("mouse_exited", self, "bluntResExited")
	var pierce_label = $UI/GUI/Equipment/DmgDef/Defenses/Pierce
	pierce_label.mouse_filter = Control.MOUSE_FILTER_STOP
	pierce_label.connect("mouse_entered", self, "pierceResHovered")
	pierce_label.connect("mouse_exited", self, "pierceResExited")
	var sonic_label = $UI/GUI/Equipment/DmgDef/Defenses/Sonic
	sonic_label.mouse_filter = Control.MOUSE_FILTER_STOP
	sonic_label.connect("mouse_entered", self, "sonicResHovered")
	sonic_label.connect("mouse_exited", self, "sonicResExited")
	var heat_label = $UI/GUI/Equipment/DmgDef/Defenses/Heat
	heat_label.mouse_filter = Control.MOUSE_FILTER_STOP
	heat_label.connect("mouse_entered", self, "heatResHovered")
	heat_label.connect("mouse_exited", self, "heatResExited")
	var cold_label = $UI/GUI/Equipment/DmgDef/Defenses/Cold
	cold_label.mouse_filter = Control.MOUSE_FILTER_STOP
	cold_label.connect("mouse_entered", self, "coldResHovered")
	cold_label.connect("mouse_exited", self, "coldResExited")
	var jolt_label = $UI/GUI/Equipment/DmgDef/Defenses/Jolt
	jolt_label.mouse_filter = Control.MOUSE_FILTER_STOP
	jolt_label.connect("mouse_entered", self, "joltResHovered")
	jolt_label.connect("mouse_exited", self, "joltResExited")
	var toxic_label = $UI/GUI/Equipment/DmgDef/Defenses/Toxic
	toxic_label.mouse_filter = Control.MOUSE_FILTER_STOP
	toxic_label.connect("mouse_entered", self, "toxicResHovered")
	toxic_label.connect("mouse_exited", self, "toxicResExited")
	var acid_label = $UI/GUI/Equipment/DmgDef/Defenses/Acid
	acid_label.mouse_filter = Control.MOUSE_FILTER_STOP
	acid_label.connect("mouse_entered", self, "acidResHovered")
	acid_label.connect("mouse_exited", self, "acidResExited")
	var bleed_label = $UI/GUI/Equipment/DmgDef/Defenses/Bleed
	bleed_label.mouse_filter = Control.MOUSE_FILTER_STOP
	bleed_label.connect("mouse_entered", self, "bleedResHovered")
	bleed_label.connect("mouse_exited", self, "bleedResExited")
	var neuro_label = $UI/GUI/Equipment/DmgDef/Defenses/Neuro
	neuro_label.mouse_filter = Control.MOUSE_FILTER_STOP
	neuro_label.connect("mouse_entered", self, "neuroResHovered")
	neuro_label.connect("mouse_exited", self, "neuroResExited")
	var radiant_label = $UI/GUI/Equipment/DmgDef/Defenses/Radiant
	radiant_label.mouse_filter = Control.MOUSE_FILTER_STOP
	radiant_label.connect("mouse_entered", self, "radiantResHovered")
	radiant_label.connect("mouse_exited", self, "radiantResExited")


func slashResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	# Calculate the mitigation
	var mitigation: float
	if slash_resistance >= 0:
		mitigation = slash_resistance / (slash_resistance + 100.0)
	else:
		# Calculate extra damage taken penalty
		var extra_damage_penalty = 1.0 - (-slash_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	# Set the tooltip text
	var tooltip_text: String
	if slash_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-slash_resistance) + " extra damage"
	# Call a function to display the tooltip
	callToolTip(instance, "Slash Resistance", tooltip_text)
func slashResExited():
	deleteTooltip()
	
func bluntResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if blunt_resistance >= 0:
		mitigation = blunt_resistance / (blunt_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-blunt_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if blunt_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-blunt_resistance) + " extra damage"
	callToolTip(instance, "Blunt Resistance", tooltip_text)
func bluntResExited():
	deleteTooltip()

func pierceResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if pierce_resistance >= 0:
		mitigation = pierce_resistance / (pierce_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-pierce_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if pierce_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-pierce_resistance) + " extra damage"
	callToolTip(instance, "Pierce Resistance", tooltip_text)
func pierceResExited():
	deleteTooltip()

func sonicResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if sonic_resistance >= 0:
		mitigation = sonic_resistance / (sonic_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-sonic_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if sonic_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-sonic_resistance) + " extra damage"
	callToolTip(instance, "Sonic Resistance", tooltip_text)
func sonicResExited():
	deleteTooltip()

func heatResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if heat_resistance >= 0:
		mitigation = heat_resistance / (heat_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-heat_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if heat_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-heat_resistance) + " extra damage"
	callToolTip(instance, "Heat Resistance", tooltip_text)
func heatResExited():
	deleteTooltip()

func coldResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if cold_resistance >= 0:
		mitigation = cold_resistance / (cold_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-cold_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if cold_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-cold_resistance) + " extra damage"
	callToolTip(instance, "Cold Resistance", tooltip_text)
func coldResExited():
	deleteTooltip()

func joltResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if jolt_resistance >= 0:
		mitigation = jolt_resistance / (jolt_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-jolt_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if cold_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-jolt_resistance) + " extra damage"
	callToolTip(instance, "Jolt Resistance", tooltip_text)	
func joltResExited():
	deleteTooltip()
	
func toxicResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if toxic_resistance >= 0:
		mitigation = toxic_resistance / (toxic_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-toxic_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if toxic_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-toxic_resistance) + " extra damage"
	callToolTip(instance, "Toxic Resistance", tooltip_text)
func toxicResExited():
	deleteTooltip()
	
func acidResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if acid_resistance >= 0:
		mitigation = acid_resistance / (acid_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-acid_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if acid_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-acid_resistance) + " extra damage"
	callToolTip(instance, "Acid Resistance", tooltip_text)
func acidResExited():
	deleteTooltip()


func bleedResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if bleed_resistance >= 0:
		mitigation = bleed_resistance / (bleed_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-bleed_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if bleed_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-bleed_resistance) + " extra damage"
	callToolTip(instance, "Bleed Resistance", tooltip_text)
func bleedResExited():
	deleteTooltip()

func neuroResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if neuro_resistance >= 0:
		mitigation = neuro_resistance / (neuro_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-neuro_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if neuro_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-neuro_resistance) + " extra damage"
	callToolTip(instance, "Neuro Resistance", tooltip_text)
func neuroResExited():
	deleteTooltip()

func radiantResHovered():
	var instance = preload("res://Tooltips/tooltipLeftDown.tscn").instance()
	var mitigation: float
	if radiant_resistance >= 0:
		mitigation = radiant_resistance / (radiant_resistance + 100.0)
	else:
		var extra_damage_penalty = 1.0 - (-radiant_resistance)
		mitigation = 1.0 - (1.0 / extra_damage_penalty)
	var tooltip_text: String
	if radiant_resistance >= 0:
		tooltip_text = "protection:  " + str(mitigation * 100) + "%"
	else:
		tooltip_text = "extra damage: " + str(-radiant_resistance) + " extra damage"
	callToolTip(instance, "Radiant Resistance", tooltip_text)
func radiantResExited():
	deleteTooltip()

	
func deleteTooltip():
	# Remove all children from the TextureButton
	for child in gui.get_children():
		if child.is_in_group("Tooltip"):
			child.queue_free()
func connectAttributeButtons():
   # Intelligence attribute
	var plus_int : Button = $UI/GUI/Equipment/Attributes/Intelligence/Plus
	var min_int : Button = $UI/GUI/Equipment/Attributes/Intelligence/Min
	if plus_int != null:
		plus_int.connect("pressed", self, "plusInt")
	if min_int != null:
		min_int.connect("pressed", self, "minusInt")
	# Instinct attribute
	var plus_ins = $UI/GUI/Equipment/Attributes/Instinct/Plus
	var min_ins = $UI/GUI/Equipment/Attributes/Instinct/Min
	plus_ins.connect("pressed", self, "plusIns")
	min_ins.connect("pressed", self, "minusIns")
	# Wisdom attribute
	var plus_wis = $UI/GUI/Equipment/Attributes/Wisdom/Plus
	var min_wis = $UI/GUI/Equipment/Attributes/Wisdom/Min
	plus_wis.connect("pressed", self, "plusWis")
	min_wis.connect("pressed", self, "minusWis")
	# Memory attribute
	var plus_mem = $UI/GUI/Equipment/Attributes/Memory/Plus
	var min_mem = $UI/GUI/Equipment/Attributes/Memory/Min
	plus_mem.connect("pressed", self, "plusMem")
	min_mem.connect("pressed", self, "minusMem")
	# Sanity attribute
	var plus_san: Button = $UI/GUI/Equipment/Attributes/Sanity/Plus
	var min_san: Button = $UI/GUI/Equipment/Attributes/Sanity/Min
	plus_san.connect("pressed", self, "plusSan")
	min_san.connect("pressed", self, "minusSan")

	# Strength attribute
	var plus_str: Button = $UI/GUI/Equipment/Attributes/Strength/Plus
	var min_str: Button = $UI/GUI/Equipment/Attributes/Strength/Min
	plus_str.connect("pressed", self, "plusStr")
	min_str.connect("pressed", self, "minusStr")
	# Force attribute
	var plus_for: Button = $UI/GUI/Equipment/Attributes/Force/Plus
	var min_for: Button = $UI/GUI/Equipment/Attributes/Force/Min
	plus_for.connect("pressed", self, "plusFor")
	min_for.connect("pressed", self, "minusFor")
	# Impact attributes
	var plus_imp = $UI/GUI/Equipment/Attributes/Impact/Plus
	var min_imp = $UI/GUI/Equipment/Attributes/Impact/Min
	plus_imp.connect("pressed", self, "plusImp")
	min_imp.connect("pressed", self, "minusImp")
	# Ferocity attribute
	var plus_fer = $UI/GUI/Equipment/Attributes/Ferocity/Plus
	var min_fer = $UI/GUI/Equipment/Attributes/Ferocity/Min
	plus_fer.connect("pressed", self, "plusFer")
	min_fer.connect("pressed", self, "minusFer")
	# Fury attribute
	var plus_fur = $UI/GUI/Equipment/Attributes/Fury/Plus
	var min_fur = $UI/GUI/Equipment/Attributes/Fury/Min
	plus_fur.connect("pressed", self, "plusFur")
	min_fur.connect("pressed", self, "minusFur")

	# Vitality attribute
	var plus_vitality = $UI/GUI/Equipment/Attributes/Vitality/Plus
	var min_vitality = $UI/GUI/Equipment/Attributes/Vitality/Min
	plus_vitality.connect("pressed", self, "plusVit")
	min_vitality.connect("pressed", self, "minusVit")	
	# Stamina attribute
	var plus_stamina = $UI/GUI/Equipment/Attributes/Stamina/Plus
	var min_stamina = $UI/GUI/Equipment/Attributes/Stamina/Min
	plus_stamina.connect("pressed", self, "plusSta")
	min_stamina.connect("pressed", self, "minusSta")
	# Endurance attribute
	var plus_endurance = $UI/GUI/Equipment/Attributes/Endurance/Plus
	var min_endurance = $UI/GUI/Equipment/Attributes/Endurance/Min
	plus_endurance.connect("pressed", self, "plusEnd")
	min_endurance.connect("pressed", self, "minusEnd")	
	# Resistance attribute
	var plus_resistance = $UI/GUI/Equipment/Attributes/Resistance/Plus
	var min_resistance = $UI/GUI/Equipment/Attributes/Resistance/Min
	plus_resistance.connect("pressed", self, "plusRes")
	min_resistance.connect("pressed", self, "minusRes")
	# Tenacity attribute
	var plus_tenacity = $UI/GUI/Equipment/Attributes/Tenacity/Plus
	var min_tenacity = $UI/GUI/Equipment/Attributes/Tenacity/Min
	plus_tenacity.connect("pressed", self, "plusTen")
	min_tenacity.connect("pressed", self, "minusTen")

	# Agility attribute
	var plus_agility = $UI/GUI/Equipment/Attributes/Agility/Plus
	var min_agility = $UI/GUI/Equipment/Attributes/Agility/Min
	plus_agility.connect("pressed", self, "plusAgi")
	min_agility.connect("pressed", self, "minusAgi")
	# Haste attribute
	var plus_haste = $UI/GUI/Equipment/Attributes/Haste/Plus
	var min_haste = $UI/GUI/Equipment/Attributes/Haste/Min
	plus_haste.connect("pressed", self, "plusHas")
	min_haste.connect("pressed", self, "minusHas")	
	# Celerity attribute
	var plus_celerity = $UI/GUI/Equipment/Attributes/Celerity/Plus
	var min_celerity = $UI/GUI/Equipment/Attributes/Celerity/Min
	plus_celerity.connect("pressed", self, "plusCel")
	min_celerity.connect("pressed", self, "minusCel")
	# Flexibility attribute
	var plus_flexibility = $UI/GUI/Equipment/Attributes/Flexibility/Plus
	var min_flexibility = $UI/GUI/Equipment/Attributes/Flexibility/Min
	plus_flexibility.connect("pressed", self, "plusFle")
	min_flexibility.connect("pressed", self, "minusFle")
	# Deflection attribute
	var plus_deflection = $UI/GUI/Equipment/Attributes/Deflection/Plus
	var min_deflection = $UI/GUI/Equipment/Attributes/Deflection/Min
	plus_deflection.connect("pressed", self, "plusDef")
	min_deflection.connect("pressed", self, "minusDef")
	
	# Dexterity attributes
	var plus_dex = $UI/GUI/Equipment/Attributes/Dexterity/Plus
	var min_dex = $UI/GUI/Equipment/Attributes/Dexterity/Min
	plus_dex.connect("pressed", self, "plusDex")
	min_dex.connect("pressed", self, "minusDex")
	# Accuracy attributes
	var plus_acc = $UI/GUI/Equipment/Attributes/Accuracy/Plus
	var min_acc = $UI/GUI/Equipment/Attributes/Accuracy/Min
	plus_acc.connect("pressed", self, "plusAcc")
	min_acc.connect("pressed", self, "minusAcc")
	# Focus attributes
	var plus_focus = $UI/GUI/Equipment/Attributes/Focus/Plus
	var min_focus = $UI/GUI/Equipment/Attributes/Focus/Min
	plus_focus.connect("pressed", self, "plusFoc")
	min_focus.connect("pressed", self, "minusFoc")	
	# Poise attributes
	var plus_poi = $UI/GUI/Equipment/Attributes/Poise/Plus
	var min_poi = $UI/GUI/Equipment/Attributes/Poise/Min
	plus_poi.connect("pressed", self, "plusPoi")
	min_poi.connect("pressed", self, "minusPoi")
	# Balance attributes
	var plus_bal = $UI/GUI/Equipment/Attributes/Balance/Plus
	var min_bal = $UI/GUI/Equipment/Attributes/Balance/Min
	plus_bal.connect("pressed", self, "plusBal")
	min_bal.connect("pressed", self, "minusBal")

	# Charisma attribute
	var plus_char = $UI/GUI/Equipment/Attributes/Charisma/Plus
	var min_char = $UI/GUI/Equipment/Attributes/Charisma/Min
	plus_char.connect("pressed", self, "plusCha")
	min_char.connect("pressed", self, "minusCha")
	# Diplomacy attribute
	var plus_dip = $UI/GUI/Equipment/Attributes/Diplomacy/Plus
	var min_dip = $UI/GUI/Equipment/Attributes/Diplomacy/Min
	plus_dip.connect("pressed", self, "plusDip")
	min_dip.connect("pressed", self, "minusDip")	
	# Authority attribute
	var plus_aut = $UI/GUI/Equipment/Attributes/Authority/Plus
	var min_aut = $UI/GUI/Equipment/Attributes/Authority/Min
	plus_aut.connect("pressed", self, "plusAut")
	min_aut.connect("pressed", self, "minusAut")
	# Courage attribute
	var plus_cou = $UI/GUI/Equipment/Attributes/Courage/Plus
	var min_cou = $UI/GUI/Equipment/Attributes/Courage/Min
	plus_cou.connect("pressed", self, "plusCou")
	min_cou.connect("pressed", self, "minusCou")
	# Loyalty attribute
	var plus_loy = $UI/GUI/Equipment/Attributes/Loyalty/Plus
	var min_loy = $UI/GUI/Equipment/Attributes/Loyalty/Min
	plus_loy.connect("pressed", self, "plusLoy")
	min_loy.connect("pressed", self, "minusLoy")
func plusInt():#intelligence
	convertStats()
	var result: Array = increaseAttribute(spent_attribute_points_int,intelligence)
	spent_attribute_points_int = result[0]
	intelligence = result[1]
	print(spent_attribute_points_int)
func minusInt():
	convertStats()
	var result: Array = decreaseAttribute(spent_attribute_points_int,intelligence)
	spent_attribute_points_int = result[0]
	intelligence = result[1]
func plusIns():#instinct
	convertStats()
	var result: Array = increaseAttribute(spent_attribute_points_ins,instinct)
	spent_attribute_points_ins = result[0]
	instinct = result[1]
	print(spent_attribute_points_ins)
func minusIns():
	convertStats()
	var result: Array = decreaseAttribute(spent_attribute_points_ins,instinct)
	spent_attribute_points_ins = result[0]
	instinct = result[1]
func plusWis():#wisdom
	convertStats()
	var result: Array = increaseAttribute(spent_attribute_points_wis,wisdom)
	spent_attribute_points_wis = result[0]
	wisdom = result[1]
	print(spent_attribute_points_wis)
func minusWis():
	convertStats()
	var result: Array = decreaseAttribute(spent_attribute_points_wis,wisdom)
	spent_attribute_points_wis = result[0]
	wisdom = result[1]
func plusMem():#memory
	convertStats()
	var result: Array = increaseAttribute(spent_attribute_points_mem,memory)
	spent_attribute_points_mem = result[0]
	memory = result[1]
	print(spent_attribute_points_mem)
func minusMem():
	convertStats()
	var result: Array = decreaseAttribute(spent_attribute_points_mem,memory)
	spent_attribute_points_mem = result[0]
	memory = result[1]
func plusSan():#sanity
	convertStats()
	var result: Array = increaseAttribute(spent_attribute_points_san,sanity)
	spent_attribute_points_san = result[0]
	sanity = result[1]
	print(spent_attribute_points_san)
func minusSan():
	convertStats()
	var result: Array = decreaseAttribute(spent_attribute_points_san,sanity)
	spent_attribute_points_san = result[0]
	sanity = result[1]
func plusStr():#strength
	convertStats()
	var result: Array = increaseAttribute(spent_attribute_points_str,strength)
	spent_attribute_points_str = result[0]
	strength = result[1]
	print(spent_attribute_points_str)
func minusStr():
	var result: Array = decreaseAttribute(spent_attribute_points_str,strength)
	spent_attribute_points_str = result[0]
	strength = result[1]
func plusFor():#force
	var result: Array = increaseAttribute(spent_attribute_points_for,force)
	spent_attribute_points_for = result[0]
	force = result[1]
	print(spent_attribute_points_for)
func minusFor():
	var result: Array = decreaseAttribute(spent_attribute_points_for,force)
	spent_attribute_points_for = result[0]
	force = result[1]
func plusImp():#impact
	var result: Array = increaseAttribute(spent_attribute_points_imp,impact)
	spent_attribute_points_imp = result[0]
	impact = result[1]
	print(spent_attribute_points_imp)
func minusImp():
	var result: Array = decreaseAttribute(spent_attribute_points_imp,impact)
	spent_attribute_points_imp = result[0]
	impact = result[1]
func plusFer():#ferocity
	var result: Array = increaseAttribute(spent_attribute_points_fer,ferocity)
	spent_attribute_points_fer = result[0]
	ferocity = result[1]
	print(spent_attribute_points_fer)
func minusFer():
	var result: Array = decreaseAttribute(spent_attribute_points_fer,ferocity)
	spent_attribute_points_fer = result[0]
	ferocity = result[1]
func plusFur():#fury
	var result: Array = increaseAttribute(spent_attribute_points_fur,fury)
	spent_attribute_points_fur = result[0]
	fury = result[1]
	print(spent_attribute_points_fur)
func minusFur():
	var result: Array = decreaseAttribute(spent_attribute_points_fur,fury)
	spent_attribute_points_fur = result[0]
	fury = result[1]
func plusVit():#vitality, for now it only increases health 
	var result: Array = increaseAttribute(spent_attribute_points_vit,vitality)
	spent_attribute_points_vit = result[0]
	vitality = result[1]
	print(spent_attribute_points_vit)
func minusVit():
	var result: Array = decreaseAttribute(spent_attribute_points_vit,vitality)
	spent_attribute_points_vit = result[0]
	vitality = result[1]
func plusSta():#stamina 
	var result: Array = increaseAttribute(spent_attribute_points_sta,stamina)
	spent_attribute_points_sta = result[0]
	stamina = result[1]
	print(spent_attribute_points_sta)
func minusSta():
	var result: Array = decreaseAttribute(spent_attribute_points_sta,stamina)
	spent_attribute_points_sta = result[0]
	stamina = result[1]
func plusEnd():#endurance
	var result: Array = increaseAttribute(spent_attribute_points_end,endurance)
	spent_attribute_points_end = result[0]
	endurance = result[1]
	print(spent_attribute_points_end)
func minusEnd():
	var result: Array = decreaseAttribute(spent_attribute_points_end,endurance)
	spent_attribute_points_end = result[0]
	endurance = result[1]
func plusRes():#resistance, it increases health, energy, resolve, defense at 1/3 value of other attributes
	var result: Array = increaseAttribute(spent_attribute_points_res,resistance)
	spent_attribute_points_res = result[0]
	resistance = result[1]
	print(spent_attribute_points_res)
func minusRes():
	var result: Array = decreaseAttribute(spent_attribute_points_res,resistance)
	spent_attribute_points_res = result[0]
	resistance = result[1]
func plusTen():#Tenacity
	var result: Array = increaseAttribute(spent_attribute_points_ten,tenacity)
	spent_attribute_points_ten = result[0]
	tenacity = result[1]
	print(spent_attribute_points_ten)
func minusTen():
	var result: Array = decreaseAttribute(spent_attribute_points_ten,tenacity)
	spent_attribute_points_ten = result[0]
	tenacity = result[1]
func plusAgi():#agility 
	var result: Array = increaseAttribute(spent_attribute_points_agi,agility)
	spent_attribute_points_agi = result[0]
	agility = result[1]
	print(spent_attribute_points_agi)
func minusAgi():
	var result: Array = decreaseAttribute(spent_attribute_points_agi,agility)
	spent_attribute_points_agi = result[0]
	agility = result[1]
func plusHas():#Haste
	var result: Array = increaseAttribute(spent_attribute_points_has,haste)
	spent_attribute_points_has = result[0]
	haste = result[1]
	print(spent_attribute_points_has)
func minusHas():
	var result: Array = decreaseAttribute(spent_attribute_points_has,haste)
	spent_attribute_points_has = result[0]
	haste = result[1]
func plusCel():#Celerety
	var result: Array = increaseAttribute(spent_attribute_points_cel,celerity)
	spent_attribute_points_cel = result[0]
	celerity = result[1]
	print(spent_attribute_points_cel)
func minusCel():
	var result: Array = decreaseAttribute(spent_attribute_points_cel,celerity)
	spent_attribute_points_cel = result[0]
	celerity = result[1]
	print(spent_attribute_points_cel)
#Flexibity.... this is mostly about taking less falling damage or when being knocked down by tackles 
func plusFle():
	var result: Array = increaseAttribute(spent_attribute_points_fle,flexibility)
	spent_attribute_points_fle = result[0]
	flexibility = result[1]
	print(spent_attribute_points_fle)
func minusFle():
	var result: Array = decreaseAttribute(spent_attribute_points_fle,flexibility)
	spent_attribute_points_fle = result[0]
	flexibility = result[1]
	print(spent_attribute_points_fle)
#Deflection
func plusDef():
	var result: Array = increaseAttribute(spent_attribute_points_def,deflection)
	spent_attribute_points_def = result[0]
	deflection = result[1]
	print(spent_attribute_points_def)
func minusDef():
	var result: Array = decreaseAttribute(spent_attribute_points_def,deflection)
	spent_attribute_points_def = result[0]
	deflection = result[1]
	print(spent_attribute_points_def)
#Dexterity
func plusDex():
	var result: Array = increaseAttribute(spent_attribute_points_dex,dexterity)
	spent_attribute_points_dex = result[0]
	dexterity = result[1]
	print(spent_attribute_points_dex)
func minusDex():
	var result: Array = decreaseAttribute(spent_attribute_points_dex,dexterity)
	spent_attribute_points_dex = result[0]
	dexterity = result[1]
	print(spent_attribute_points_dex)
#Accuracy
func plusAcc():
	var result: Array = increaseAttribute(spent_attribute_points_acc,accuracy)
	spent_attribute_points_acc = result[0]
	accuracy = result[1]
	print(spent_attribute_points_acc)
func minusAcc():
	var result: Array = decreaseAttribute(spent_attribute_points_acc,accuracy)
	spent_attribute_points_acc = result[0]
	accuracy = result[1]
	print(spent_attribute_points_acc)
#Focus
func plusFoc():
	var result: Array = increaseAttribute(spent_attribute_points_foc,focus)
	spent_attribute_points_foc = result[0]
	focus = result[1]
	print(spent_attribute_points_foc)
func minusFoc():
	var result: Array = decreaseAttribute(spent_attribute_points_foc,focus)
	spent_attribute_points_foc = result[0]
	focus = result[1]
	print(spent_attribute_points_foc)
#Poise 
func plusPoi():
	var result: Array = increaseAttribute(spent_attribute_points_poi,poise)
	spent_attribute_points_poi = result[0]
	poise = result[1]
	print(spent_attribute_points_poi)
func minusPoi():
	var result: Array = decreaseAttribute(spent_attribute_points_poi,poise)
	spent_attribute_points_poi = result[0]
	poise = result[1]
	print(spent_attribute_points_poi)
#Balance
func plusBal():
	var result: Array = increaseAttribute(spent_attribute_points_bal,balance)
	spent_attribute_points_bal = result[0]
	balance = result[1]
	print(spent_attribute_points_bal)
func minusBal():
	var result: Array = decreaseAttribute(spent_attribute_points_bal,balance)
	spent_attribute_points_bal = result[0]
	balance = result[1]
	print(spent_attribute_points_bal)
#Charisma 
func plusCha():
	var result: Array = increaseAttribute(spent_attribute_points_cha,charisma)
	spent_attribute_points_cha = result[0]
	charisma = result[1]
	print(spent_attribute_points_cha)
func minusCha():
	var result: Array = decreaseAttribute(spent_attribute_points_bal,charisma)
	spent_attribute_points_cha = result[0]
	charisma = result[1]
	print(spent_attribute_points_cha)
#Diplomancy 
func plusDip():
	var result: Array = increaseAttribute(spent_attribute_points_dip,diplomacy)
	spent_attribute_points_dip = result[0]
	diplomacy = result[1]
	print(spent_attribute_points_dip)
	
func minusDip():
	var result: Array = decreaseAttribute(spent_attribute_points_dip,diplomacy)
	spent_attribute_points_dip = result[0]
	diplomacy = result[1]
	print(spent_attribute_points_dip)
#Authority
func plusAut():
	var result: Array = increaseAttribute(spent_attribute_points_aut,authority)
	spent_attribute_points_aut = result[0]
	authority = result[1]
	print(spent_attribute_points_aut)
func minusAut():
	var result: Array = decreaseAttribute(spent_attribute_points_aut,authority)
	spent_attribute_points_aut = result[0]
	authority = result[1]
	print(spent_attribute_points_aut)
#Courage 
func plusCou():
	var result: Array = increaseAttribute(spent_attribute_points_cou, courage)
	spent_attribute_points_cou = result[0]
	courage = result[1]
	print(spent_attribute_points_cou)
func minusCou():
	var result: Array = decreaseAttribute(spent_attribute_points_cou, courage)
	spent_attribute_points_cou = result[0]
	courage = result[1]
	print(spent_attribute_points_cou)
#Loyalty
func plusLoy():
	var result: Array = increaseAttribute(spent_attribute_points_loy, loyalty)
	spent_attribute_points_loy = result[0]
	loyalty = result[1]
	print(spent_attribute_points_loy)
func minusLoy():
	var result: Array = decreaseAttribute(spent_attribute_points_loy, loyalty)
	spent_attribute_points_loy = result[0]
	loyalty = result[1]
	print(spent_attribute_points_loy)


func increaseAttribute(spent_attribute, x):
	if attribute > 0:
		if spent_attribute < 5:
			spent_attribute += 1
			attribute -= 1
			x += attribute_increase_factor
		elif spent_attribute < 10:
			spent_attribute += 1
			attribute -= 1
			x += attribute_increase_factor * 0.5
		elif spent_attribute < 15:
			spent_attribute += 1
			attribute -= 1
			x += attribute_increase_factor * 0.2
		elif spent_attribute < 20:
			spent_attribute += 1
			attribute -= 1
			x += attribute_increase_factor * 0.1
		elif spent_attribute < 25:
			spent_attribute += 1
			attribute -= 1
			x += attribute_increase_factor * 0.05
		else:
			spent_attribute += 1
			attribute -= 1
			x += attribute_increase_factor * 0.01
	return [spent_attribute, x]
			
func decreaseAttribute(spent_attribute,attribute_name):
	if attribute_name > 0.05:
		spent_attribute -= 1
		attribute += 1
		if spent_attribute < 5:
			attribute_name -= attribute_increase_factor
		elif spent_attribute < 10:
			attribute_name -= attribute_increase_factor * 0.5
		elif spent_attribute < 15:
			attribute_name -= attribute_increase_factor * 0.2
		elif spent_attribute < 20:
			attribute_name -= attribute_increase_factor * 0.1
		elif spent_attribute < 25:
			attribute_name -= attribute_increase_factor * 0.05
		else:
			attribute_name -= attribute_increase_factor * 0.01
	return [spent_attribute,attribute_name]










func updateAllStats():
	updateAefisNefis()	



#___________________________________________Save data system________________________________________
func saveGame():
	savePlayerData()
	saveInventoryData()
	saveSkillBarData()
	saveSkillTreeData()

var entity_name: String = "dai"
var slot: String = "1"
var save_directory: String
var save_path: String 
func savePlayerData():
	skills.savePlayerData()
	var data = {
		"aiming_mode":aiming_mode,
		"direction_assist":direction_assist,
		"hold_to_base_atk":hold_to_base_atk,
		
		"ui_color":ui_color,
		"shifting_ui_colors":shifting_ui_colors,
		
		"sex": sex,
		"species":species,
		"experience_points":experience_points,
		"experience_to_next_level":experience_to_next_level,
		"level":level,
		
		
		
		"position": translation,
		"camera.translation.y" : camera.translation.y,
		"camera.translation.z" : camera.translation.z,

		"health": health,
		"max_health": max_health,
		
		"breath": breath,
		"max_breath":max_breath,
		
		"resolve": resolve,
		"max_resolve": max_resolve,
		
		"aefis":aefis,
		"max_aefis": max_aefis,
		
		"nefis":nefis,
		"max_nefis": max_nefis,
		
		"kilocalories": kilocalories,
		"max_kilocalories": max_kilocalories,
		"water": water,
		"max_water": max_water,
#leveling 
		"skill_points":skill_points,
		"skill_points_spent":skill_points_spent,
		"attribute": attribute,
		"spent_attribute_points_str": spent_attribute_points_str,
		"spent_attribute_points_fur": spent_attribute_points_fur,
		"spent_attribute_points_imp": spent_attribute_points_imp,
		"spent_attribute_points_fer": spent_attribute_points_fer,
		"spent_attribute_points_res": spent_attribute_points_res,
		
		"spent_attribute_points_ten": spent_attribute_points_ten,
		"spent_attribute_points_acc": spent_attribute_points_acc,
		"spent_attribute_points_dex": spent_attribute_points_dex,
		"spent_attribute_points_poi": spent_attribute_points_poi,
		"spent_attribute_points_bal": spent_attribute_points_bal,
		
		"spent_attribute_points_foc": spent_attribute_points_foc,
		"spent_attribute_points_has": spent_attribute_points_has,
		"spent_attribute_points_agi": spent_attribute_points_agi,
		"spent_attribute_points_cel": spent_attribute_points_cel,
		"spent_attribute_points_fle": spent_attribute_points_fle,
		
		"spent_attribute_points_def": spent_attribute_points_def,
		"spent_attribute_points_end": spent_attribute_points_end,
		"spent_attribute_points_sta": spent_attribute_points_sta,
		"spent_attribute_points_vit": spent_attribute_points_vit,
		"spent_attribute_points_cha": spent_attribute_points_cha,
		
		"spent_attribute_points_loy": spent_attribute_points_loy,
		"spent_attribute_points_dip": spent_attribute_points_dip,
		"spent_attribute_points_aut": spent_attribute_points_aut,
		"spent_attribute_points_cou": spent_attribute_points_cou,
		"spent_attribute_points_int": spent_attribute_points_int,
		
		"spent_attribute_points_wis": spent_attribute_points_wis,
		"spent_attribute_points_san": spent_attribute_points_san,
		"spent_attribute_points_mem": spent_attribute_points_mem,
		"spent_attribute_points_ins": spent_attribute_points_ins,
		"spent_attribute_points_for": spent_attribute_points_for,

		
#Brain attributes
		"sanity": sanity,
		"wisdom" : wisdom,
		"memory": memory,
		"intelligence": intelligence,
		"instinct": instinct,
#Brute attributes
		"force": force,
		"strength": strength,
		"impact": impact,
		"ferocity": ferocity,
		"fury":fury,
#Precision attributes
		"accuracy": accuracy,
		"dexterity": dexterity,
		"poise": poise,
		"balance": balance,
		"focus": focus,
#Nimble attributes
		"haste": haste,
		"agility": agility,
		"celerity": celerity,
		"flexibility": flexibility,
		"deflection": deflection,
#Toughness attributes
		"endurance": endurance,
		"stamina": stamina,
		"vitality": vitality,

		"resistance": resistance,
		"tenacity": tenacity,
#Social attributes 

		"loyalty": loyalty,
		"diplomacy": diplomacy,
		"authority": authority,
		"courage": courage,
		
		"hair_color": hair_color,
		"right_eye_color":right_eye_color,
		"left_eye_color":left_eye_color,
		"hairstyle":hairstyle
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
			if "aiming_mode" in player_data:
				aiming_mode = player_data["aiming_mode"]
			if "direction_assist" in player_data:
				direction_assist = player_data["direction_assist"]


			if "hold_to_base_atk" in player_data:
				hold_to_base_atk = player_data["hold_to_base_atk"]
				
				
			if "ui_color" in player_data:
				ui_color = player_data["ui_color"]
			if "shifting_ui_colors" in player_data:
				shifting_ui_colors = player_data["shifting_ui_colors"]
				
				
			if "sex" in player_data:
				sex = player_data["sex"]
			if "species" in player_data:
				species = player_data["species"]
				
			if "experience_points" in player_data:
				experience_points = player_data["experience_points"]
			if "experience_to_next_level" in player_data:
				experience_to_next_level = player_data["experience_to_next_level"]


			if "level" in player_data:
				level = player_data["level"]


			if "position" in player_data:
				translation = player_data["position"]
			if "camera.translation.y" in player_data:
				camera.translation.y = player_data["camera.translation.y"]
			if "camera.translation.z" in player_data:
				camera.translation.z = player_data["camera.translation.z"]


			if "health" in player_data:
				health = player_data["health"]
			if "max_health" in player_data:
				max_health = player_data["max_health"]

			if "breath" in player_data:
				breath = player_data["breath"]
			if "max_breath" in player_data:
				max_breath = player_data["max_breath"]

			if "resolve" in player_data:
				resolve = player_data["resolve"]
			if "max_resolve" in player_data:
				max_resolve = player_data["max_resolve"]

			if "aefis" in player_data:
				aefis = player_data["aefis"]
			if "max_aefis" in player_data:
				max_aefis = player_data["max_aefis"]

			if "nefis" in player_data:
				nefis = player_data["nefis"]
			if "max_nefis" in player_data:
				max_nefis = player_data["max_nefis"]
#attributes 
			if "attribute" in player_data:
				attribute = player_data["attribute"]
			if "skill_points" in player_data:
				skill_points = player_data["skill_points"]
			if "skill_points_spent" in player_data:
				skill_points_spent = player_data["skill_points_spent"]
#brains 
			if "spent_attribute_points_int" in player_data:
				spent_attribute_points_int = player_data["spent_attribute_points_int"]
			if "spent_attribute_points_wis" in player_data:
				spent_attribute_points_wis = player_data["spent_attribute_points_wis"]
			if "spent_attribute_points_ins" in player_data:
				spent_attribute_points_ins = player_data["spent_attribute_points_ins"]
			if "spent_attribute_points_mem" in player_data:
				spent_attribute_points_mem = player_data["spent_attribute_points_mem"]
			if "spent_attribute_points_san" in player_data:
				spent_attribute_points_san = player_data["spent_attribute_points_san"]
#social 
			if "spent_attribute_points_cha" in player_data:
				spent_attribute_points_cha = player_data["spent_attribute_points_cha"]
			if "spent_attribute_points_cou" in player_data:
				spent_attribute_points_cou = player_data["spent_attribute_points_cou"]
			if "spent_attribute_points_loy" in player_data:
				spent_attribute_points_loy = player_data["spent_attribute_points_loy"]
			if "spent_attribute_points_dip" in player_data:
				spent_attribute_points_dip = player_data["spent_attribute_points_dip"]
			if "spent_attribute_points_aut" in player_data:
				spent_attribute_points_aut = player_data["spent_attribute_points_aut"]
#brawns
			if "spent_attribute_points_vit" in player_data:
				spent_attribute_points_vit = player_data["spent_attribute_points_vit"]
			if "spent_attribute_points_res" in player_data:
				spent_attribute_points_res = player_data["spent_attribute_points_res"]
			if "spent_attribute_points_ten" in player_data:
				spent_attribute_points_ten = player_data["spent_attribute_points_ten"]
			if "spent_attribute_points_end" in player_data:
				spent_attribute_points_end = player_data["spent_attribute_points_end"]
			if "spent_attribute_points_sta" in player_data:
				spent_attribute_points_sta = player_data["spent_attribute_points_sta"]
#brute
			if "spent_attribute_points_fur" in player_data:
				spent_attribute_points_fur = player_data["spent_attribute_points_fur"]
			if "spent_attribute_points_for" in player_data:
				spent_attribute_points_for = player_data["spent_attribute_points_for"]
			if "spent_attribute_points_imp" in player_data:
				spent_attribute_points_imp = player_data["spent_attribute_points_imp"]
			if "spent_attribute_points_fer" in player_data:
				spent_attribute_points_fer = player_data["spent_attribute_points_fer"]
			if "spent_attribute_points_str" in player_data:
				spent_attribute_points_str = player_data["spent_attribute_points_str"]
#precision
			if "spent_attribute_points_acc" in player_data:
				spent_attribute_points_acc = player_data["spent_attribute_points_acc"]
			if "spent_attribute_points_dex" in player_data:
				spent_attribute_points_dex = player_data["spent_attribute_points_dex"]
			if "spent_attribute_points_poi" in player_data:
				spent_attribute_points_poi = player_data["spent_attribute_points_poi"]
			if "spent_attribute_points_bal" in player_data:
				spent_attribute_points_bal = player_data["spent_attribute_points_bal"]
			if "spent_attribute_points_foc" in player_data:
				spent_attribute_points_foc = player_data["spent_attribute_points_foc"]
#nimbleness
			if "spent_attribute_points_has" in player_data:
				spent_attribute_points_has = player_data["spent_attribute_points_has"]
			if "spent_attribute_points_agi" in player_data:
				spent_attribute_points_agi = player_data["spent_attribute_points_agi"]
			if "spent_attribute_points_cel" in player_data:
				spent_attribute_points_cel = player_data["spent_attribute_points_cel"]
			if "spent_attribute_points_fle" in player_data:
				spent_attribute_points_fle = player_data["spent_attribute_points_fle"]
			if "spent_attribute_points_def" in player_data:
				spent_attribute_points_def = player_data["spent_attribute_points_def"]
#Brute attributes
			if "force" in player_data:
				force = player_data["force"]
			if "strength" in player_data:
				strength = player_data["strength"]
			if "impact" in player_data:
				impact = player_data["impact"]
			if "ferocity" in player_data:
				ferocity = player_data["ferocity"]
			if "fury" in player_data:
				fury = player_data["fury"]
			if "resistance" in player_data:
				resistance = player_data["resistance"]
			if "tenacity" in player_data:
				tenacity = player_data["tenacity"]
#Brain attributes
			if "sanity" in player_data:
				sanity = player_data["sanity"]
			if "wisdom" in player_data:
				wisdom = player_data["wisdom"]
			if "memory" in player_data:
				memory = player_data["memory"]
			if "intelligence" in player_data:
				intelligence = player_data["intelligence"]
			if "instinct" in player_data:
				instinct = player_data["instinct"]
#Precision attributes
			if "accuracy" in player_data:
				 accuracy = player_data["accuracy"]
			if "dexterity" in player_data:
				dexterity = player_data["dexterity"]
			if "poise" in player_data:
				poise = player_data["poise"]
			if "balance" in player_data:
				balance = player_data["balance"]
			if "focus" in player_data:
				focus  = player_data["focus"]
#Nimble attributes
			if "haste" in player_data:
				haste = player_data["haste"]
			if "agility" in player_data:
				 agility = player_data["agility"]
			if "flexibility" in player_data:
				flexibility = player_data["flexibility"]
			if "celerity" in player_data:
				celerity = player_data["celerity"]
			if "deflection" in player_data:
				deflection = player_data["deflection"]
#Toughness attributes
			if "endurance" in player_data:
				endurance = player_data["endurance"] 
			if "stamina" in player_data:
				stamina = player_data["stamina"]
			if "vitality" in player_data:
				vitality = player_data["vitality"]

#Social attributes 

			if "loyalty" in player_data:
				loyalty = player_data["loyalty"]
			if "diplomacy" in player_data:
				diplomacy = player_data["diplomacy"]
			if "authority" in player_data:
				authority = player_data["authority"]
			if "courage" in player_data:
				courage = player_data["courage"]

			if "vitality" in player_data:
				vitality = player_data["vitality"]

			if "kilocalories" in player_data:
				kilocalories = player_data["kilocalories"]

			if "max_kilocalories" in player_data:
				max_kilocalories = player_data["max_kilocalories"]

			if "water" in player_data:
				water = player_data["water"]

			if "max_water" in player_data:
				max_water = player_data["max_water"]
#			if "effects" in player_data:
#				effects = player_data["effects"]

			if "hairstyle" in player_data:
				hairstyle = player_data["hairstyle"]
			if "hair_color" in player_data:
				hair_color = player_data["hair_color"]
			if "right_eye_color" in player_data:
				right_eye_color = player_data["right_eye_color"]
			if "left_eye_color" in player_data:
				left_eye_color = player_data["left_eye_color"]


#_____________CHARACTER EDITING, SPECIES, SEX, BLEND SHAPES AND BONE EDITOR IN ANOTHER SCRIPT 
var species: String = "human"
var sex: String = "xx"
var skills: Node = null 

func switchSexRace():
	match sex:
		"xy":
			match species:
				"saurus":
					if skills != null:
						skills.queue_free() # Delete previous gender scene
					skills = Icons.saurus.instance()
					skills.player = self 
					raceInstacePreparations()
					InstanceRace()
				"human":
					if skills != null:
						skills.queue_free() # Delete previous gender scene
					skills = Icons.human_male.instance()
					skills.player = self 
					raceInstacePreparations()
					InstanceRace()
				"panthera":
					if skills != null:
						skills.queue_free() # Delete previous gender scene
					skills = Icons.panthera_male.instance()
					skills.player = self 
					raceInstacePreparations()
					InstanceRace()
				"sepris":
					if skills != null:
						skills.queue_free()
					skills = Icons.sepris.instance()
					skills.player = self 
					raceInstacePreparations()
					InstanceRace()
				"bireas":
					if skills != null:
						skills.queue_free()
					skills = Icons.bireas.instance()
					raceInstacePreparations()
					InstanceRace()
				"skeleton":
					if skills != null:
						skills.queue_free()
					skills = Icons.skeleton.instance()
					raceInstacePreparations()
					InstanceRace()
				"kadosiel":
					if skills != null:
						skills.queue_free()
					skills = Icons.kadosiel.instance()
					raceInstacePreparations()
					InstanceRace()
		"xx":
			match species:
				"saurus":
					if skills != null:
						skills.queue_free() # Delete previous gender scene
					skills = Icons.saurus.instance()
					raceInstacePreparations()
					InstanceRace()
				"human":
					if skills != null:
						skills.queue_free() # Delete previous gender scene
					skills = Icons.human_female.instance()
					raceInstacePreparations()
					InstanceRace()
				"panthera":
					if skills != null:
						skills.queue_free() # Delete previous gender scene
					skills = Icons.panthera_female.instance()
					raceInstacePreparations()
					InstanceRace()
				"sepris":
					if skills != null:
						skills.queue_free()
					skills = Icons.sepris.instance()
					raceInstacePreparations()
					InstanceRace()
				"bireas":
					if skills != null:
						skills.queue_free()
					skills = Icons.bireas.instance()
					raceInstacePreparations()
					InstanceRace()
				"skeleton":
					if skills != null:
						skills.queue_free()
					skills = Icons.skeleton.instance()
					raceInstacePreparations()
					InstanceRace()
				"kadosiel":
					if skills != null:
						skills.queue_free()
					skills = Icons.kadosiel.instance()
					raceInstacePreparations()
					InstanceRace()
	if is_instance_valid(skills):
		var current_face_set = skills.face_set
func raceInstacePreparations():
	skills.player = self 
	skills.save_directory = save_directory
	skills.save_path = save_path + "colors.dat"
func InstanceRace():
	player_mesh.add_child(skills)
func _on_switchGender_pressed():
	skills.player = self 
	if sex == "xy":
		sex = "xx"
	else:
		sex = "xy"
	switchSexRace() # Call the function to change gender and update scene
	skills.EquipmentSwitch()
var species_list = ["sepris", "human","skeleton","panthera","bireas","saurus","kadosiel"]# Define the list of available species
var current_species_index = 0# Initialize the index of the current species
func _on_switchRace_pressed():
	current_species_index += 1# Increment the index to move to the next species
	if current_species_index >= species_list.size():# Wrap around to the beginning if reached the end of the list
		current_species_index = 0
	species = species_list[current_species_index]
	switchSexRace() # Call the function to change gender and update scene
	skills.EquipmentSwitch()
	hairstyle = hair_list[current_hair_index]
	skills.face_set = face_list[current_face_index]
var hair_list = ["1", "2", "3","4","5"]
var current_hair_index = 0
func _on_switchhair_pressed():
	current_hair_index += 1  # Increment the index to move to the next hairstyle
	if current_hair_index >= hair_list.size():  # Wrap around to the beginning if reached the end of the list
		current_hair_index = 0  # Reset index to the beginning
	hairstyle = hair_list[current_hair_index]
	skills.switchEquipment()
	colorBodyParts()

var face_list = ["1", "2", "3", "4","5"]
var current_face_index = 0
func _on_switch_face_pressed():
	current_face_index += 1  # Increment the index to move to the next face
	if current_face_index >= face_list.size():  # Wrap around to the beginning if reached the end of the list
		current_face_index = 0  # Reset index to the beginning
	skills.face_set = face_list[current_face_index]
	skills.EquipmentSwitch()

func _on_ArmorColorSwitch_pressed():
	skills.randomizeArmor()

func _on_SkinColorSwitch_pressed():
	skills._on_Button_pressed()
	
	
var hairstyle: String = "1"
var hair_color_change:bool = true 
var hair_color: Color = Color(1, 1, 1)  # Default color
onready var iris_image = preload("res://player/human/fem/Faces/Iris.material")
var right_eye_color_change: bool = true 
var right_eye_color: Color = Color(1, 1, 1)  # Default color

var left_eye_color: Color = Color(1, 1, 1)  # Default color
var left_eye_color_change:bool = true
func _on_ColorPicker_color_changed(color: Color) -> void:
	if right_eye_color_change:
		right_eye_color = color
		colorBodyParts()
	if left_eye_color_change:
		left_eye_color = color
		colorBodyParts()
	if hair_color_change:
		hair_color = color
		colorBodyParts()
					
func colorBodyParts() -> void:
	if skills != null:
		if skills.right_eye != null:
			var right_eye = skills.right_eye
			var new_material = iris_image.duplicate()  # Duplicate the preloaded material to avoid modifying the original
			new_material.albedo_color = right_eye_color
			new_material.flags_unshaded = true
			right_eye.material_override = new_material  # Assign the new material to the right eye
	if skills != null:
		if skills.left_eye != null:
			var left_eye = skills.left_eye
			var new_material = iris_image.duplicate()  # Duplicate the preloaded material to avoid modifying the original
			new_material.albedo_color = left_eye_color
			new_material.flags_unshaded = true
			left_eye.material_override = new_material  # Assign the new material to the right eye
	if skills != null:
		if skills.skeleton != null:
			for child in skills.skeleton.get_children():
				if child.is_in_group("hair"):
					var material = child.mesh.surface_get_material(0) # Assuming only one surface
					material.albedo_color = hair_color

func _on_BlendshapeTest_pressed()->void:
	skills.smile = rand_range(-2,+2)
	skills.applyBlendShapes()

#________________________________________LEVELING SYSTEM____________________________________________
var experience_points: int = 0
var level: int = 1
var experience_to_next_level: int = 100  # Initial experience required to level up
onready var exper_label: Label = $UI/GUI/Portrait/MinimapHolder/XPS
var skill_points = 1
var attribute = 1

var exp_pop = preload("res://UI/experience_points_floater.tscn")	
func takeExperience(points)->void:
	var text = exp_pop.instance()
	text.amount = points
	experience_points += points * intelligence
	$"Damage&Effects/Viewport".add_child(text)
	
func experienceSystem()->void:
	while experience_points >= experience_to_next_level:
		experience_points -= experience_to_next_level
		level += 1
		skill_points += 1
		attribute += 1
		experience_to_next_level = int(experience_to_next_level * 1.2)
	
# Calculate the percentage of experience points
	var percentage: float = (float(experience_points) / float(experience_to_next_level)) * 100.0
	exper_label.text = "Level " + str(level) + "\nXP: " + str(experience_points) + "/" + str(experience_to_next_level) + " (" + str(round((percentage* 1)/1)) + "%)"


func _on_levelmeup_pressed()->void:
	experience_points += 500000000000000
	experience_points += 500000000000000




"""
@Ceisri
Documentation String: 
The following two functions 'rotateShadow()' and  'moveShadow()' check the x and z rotation
of the floor and the distance between it and the player then it corects the rotation and height of 
shadow_mesh so it matches the floor, which avoids jarring situations where the shadow phases thru the floor.
shadow_mesh is basically a plane with a transparent black spot texture to mimic a shadow.
The reason of this fake shadow system is to simply avoid performance costs that come with real shadows
"""
onready var shadow_mesh:MeshInstance = $shadow
onready var floor_ray_cast:RayCast = $CheckFloor

func rotateShadow() -> void:
	# Check if the object is currently on the floor
	if is_on_floor():
		# Force update the RayCast to ensure it's up-to-date with collisions
		floor_ray_cast.force_raycast_update()
		# Check if the RayCast is currently colliding with an object
		if floor_ray_cast.is_colliding():
			# Get the normal vector of the collision surface
			var floor_normal: Vector3 = floor_ray_cast.get_collision_normal()
			# Calculate the rotation axis to align with the floor normal
			var up_dir: Vector3 = Vector3.UP
			var rotation_axis: Vector3 = up_dir.cross(floor_normal).normalized()
			# Calculate the rotation angle to match the floor's inclination
			var rotation_angle: float = acos(up_dir.dot(floor_normal))
			# Create a quaternion for rotation based on axis and angle
			var rotation_quat: Quat = Quat(rotation_axis, rotation_angle)
			# Convert the quaternion rotation to Euler angles and apply it to the shadow_mesh
			shadow_mesh.rotation = rotation_quat.get_euler()

func moveShadow() -> void:
	if floor_ray_cast.is_colliding():
		# Get the collision point and set the shadow's position just above the ground
		var collision_point = floor_ray_cast.get_collision_point()
		if !is_on_floor():
			shadow_mesh.global_transform.origin = Vector3(collision_point.x, collision_point.y + 0.1, collision_point.z)
		else:
			shadow_mesh.global_transform.origin = Vector3(collision_point.x, collision_point.y + 0.055, collision_point.z)  

onready var inv_background = $UI/GUI/Inventory/InventoryBackground
onready var menu_frame  = $UI/GUI/Menu/MenuFrame
onready var skill_banner  = $UI/GUI/SkillBar/Banner
onready var skill_background  = $UI/GUI/SkillBar/background
onready var skill_tree_background  = $UI/GUI/SkillTrees/Background
onready var attributes_background = $UI/GUI/Equipment/Attributes/CharacterBackground
onready var def_val_background  = $UI/GUI/Equipment/DmgDef/CharacterBackground
onready var loot_background  = $UI/GUI/LootTable/Background
onready var enemy_background  = $UI/GUI/EnemyUI/BG
onready var craft_background  = $UI/GUI/Crafting/CraftingBackground



