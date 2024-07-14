extends KinematicBody


onready var canvas:CanvasLayer = $Canvas
onready var stats:Node =  $Stats
onready var skills:Node =  $Skills
onready var debug:Control =  $Canvas/Debug


onready var name_label:Label3D = $Label3D
onready var popup_viewport:Viewport =   $Sprite3D/Viewport

var username: String
var entity_name:String = "Guest"
var species:String = "Human"
var is_player:bool = true 
var online_mode:bool = true

puppet var puppet_username: String
var is_in_combat:bool = false


var weapon_type = Autoload.weapon_type_list.fist
var genes
var stored_attacker:Node = null

onready var inventory_grid:GridContainer = $Canvas/Inventory/ScrollContainer/GridContainer
func _ready() -> void:
	loadData()
	removeBothersomeKeybinds()
	setEngineTicks(max_engine_FPS)
	setProcessFPS(max_processs_FPS)
	add_to_group("Entity")
	add_to_group("Player")
	colorUI(ui_color)
	colorUI2(ui_color2)
	update_visibility()
	$Name.text = entity_name
	menu.visible  = false
	connectInventoryButtons()


func removeBothersomeKeybinds()-> void:#Here just in case someone is using this as a template
	InputMap.action_erase_events("ui_accept")#avoids all the stupid ways you can click buttons or accept things by mistake
	InputMap.action_erase_events("ui_select")
	InputMap.action_erase_events("ui_focus_next")
	InputMap.action_erase_events("ui_focus_prev")

var max_engine_FPS:int = 24
var max_processs_FPS:int = 28
func setEngineTicks(ticks_per_second: int) -> void:
	Engine.iterations_per_second = ticks_per_second
func setProcessFPS(fps: int) -> void:
	Engine.target_fps = fps




func _physics_process(delta: float) -> void:
	gravity()
	climbStairs()
	climb()
	mouseMode()
	rotateMesh()
	movement(delta)
	camera_rotation()
	clickInputs()
	InputsInterface()
	LiftAndThrow()
	carryObject()
	behaviourTree()
	skillBarInputs()
	skills.updateCooldownLabel()
	skills.comboSystem()
	if Engine.get_physics_frames() % 3 == 0:
		uiColorShift()
	if Engine.get_physics_frames() % 6 == 0:
		ResourceBarsLabels()
	if Engine.get_physics_frames() % 28 == 0:
		if Input:
			displaySlotsLabel()
	

onready var animation:AnimationPlayer =  $DirectionControl/Character/AnimationPlayer
func firstLevelAnimations()-> void:#Momentary Delete Later
	if is_instance_valid(animation):
		if !is_on_floor():
			if flip_duration == true:
				animation.play("flip")
			else:
				if !is_on_wall():
					if movement_mode != "climb":
						if carried_body == null:
							animation.play("fall")
#		elif attacking == true:
#			baseAtkAnim()
		elif moving == true:
			if carried_body == null:
				match movement_mode:
					"walk":
						animation.play("walk")
					"climb":
						animation.play("climb")
					"vault":
						animation.play("vault")
					"run":
						animation.play("run")
					"sprint":
						animation.play("run")
					"sneak":
						animation.play("sneak walk")
					"crawl":
						animation.play("crawl")
					"stairs":
						animation.play("stairs")
			else:
				animation.play("carry walk")
		else:
			if carried_body == null:
				if crawling == true:
					animation.play("crawl idle",blend)
				elif sneaking == true:
					animation.play("sneak", 0.3)
				else:
					animation.play("idle", 0.3)
			else:
				animation.play("carry", 0.3)
		

func behaviourTree()-> void:
	if stats.health < 0: 
		is_in_combat = false
		skills.getInterrupted()
		clearParryAbsorb()
		stopBeingParlized()
		#warning_screen.modulate = Color(0, 0, 0, 1)
		#warning_screen.modulate.a = 1
		
		if stats.health >= -100:
			if moving == true:
				animation.play("downed walk",0.35)
				movement_speed = 1
				stats.health -= 1 * get_physics_process_delta_time()
				is_dead = false
			else:
				animation.play("downed idle",0.35)
				is_dead = false
									
		else:
			animation.play("dead",0.35)
			is_dead = true
	else:
		if knockeddown == true:
			clearParryAbsorb()
			if stats.health <= 0 :
				knockeddown = false
				staggered = false
			if parry == true:
				knockeddown = false
				staggered = false
			elif absorbing == true:
				knockeddown = false
			else:
				can_walk = false
				moving = false
				horizontal_velocity = direction * 0
				#genes.can_move = false
				if stats.health > 15:
					animation.play("knocked down",blend)
					#skill.getInterrupted()

		elif staggered== true:
			can_walk = false
			moving = false
			#genes.can_move = false
			animation.play("staggered",blend)
			#skill.getInterrupted()
		elif stunned_time>  0 and stats.health >0:
			#skill.getInterrupted()
			animation.play("staggered",blend)
			can_walk = false
			moving = false
			#genes.can_move = false
		else:
			activeActions()

var blend: float = 0.22

var stunned_time:float = 0
var hold_to_base_atk:bool = false #if true holding the base attack buttons continues a combo of attacks, releasing the button stops the attacks midway, if false it will just play the attack animation as if it was a normal skill
var base_atk_duration:bool = false
var base_atk2_duration:bool = false
var base_atk3_duration:bool = false
var base_atk4_duration:bool = false
var flip_duration:bool = false
var throw_rock_duration:bool= false
var stomp_duration:bool= false
var kick_duration:bool= false

var backstep_duration:bool= false
var frontstep_duration:bool= false
var leftstep_duration:bool= false
var rightstep_duration:bool= false

var dash_duration:bool= false

var slide_duration:bool= false


var dying:bool = false
var dead:bool = false


var staggered:bool = false
var knockeddown:bool = false


var overhead_slash_duration:bool = false
var overhead_slash_combo:bool = false

var rising_slash_duration:bool = false
var heart_trust_duration:bool = false
var cyclone_duration:bool = false

var cyclone_combo:bool = false

var whirlwind_duration:bool = false
var whirlwind_combo:bool = false


var silent_stab_active:bool = false
var garrote_active:bool = false


var parry:bool= false
var absorbing:bool = false


var taunt_duration:bool = false
var state = Autoload.state_list.idle

var attacking:bool = false
var is_dead:bool = false
func activeActions()->void:
	SkillQueueSystem()#DO NOT REMOVE THIS! it is neccessary to allow skill cancelling, skill cancelling doesn't work without skill queue, it has a toggle on off anyway for players that don't like it 
	if Input.is_action_pressed("Rclick"):
		switchWeaponFromHandToSideOrBack()
		state == Autoload.state_list.guard
		skills.skillCancel("throw_rock")

	if dash_duration == true:
		directionToCamera()
		moveTowardsDirection(skills.backstep_distance)
		animation.play("dash",0.3,1.25)
		
	elif silent_stab_active == true:
		directionToCamera()
		moveTowardsDirection(1)
		animation.play("punch",0.3,1)
		skills.skillCancel("silentStab")
	elif garrote_active == true:
		directionToCamera()
		moveTowardsDirection(1)
		animation.play("garrote",0.3,1)
		skills.skillCancel("garrote")
	

		
	
	elif slide_duration == true:
		automaticTargetAssist()
		directionToCamera()
		moveTowardsDirection(skills.backstep_distance)
		animation.play("slide",blend)


	elif backstep_duration == true:
		directionToCamera()
		moveTowardsDirection(-skills.backstep_distance)
		animation.play("backstep",blend,1)
		print("backstep_duration true")

	elif frontstep_duration == true:
		directionToCamera()
		moveTowardsDirection(+skills.backstep_distance)
		animation.play("frontstep",blend,1)
		
	elif leftstep_duration == true:
		is_aiming = true
		moveSidewaysDuringAnimation(skills.backstep_distance)
		direction = -camera.global_transform.basis.z
		animation.play("leftstep",blend,1)

	elif rightstep_duration == true:
		is_aiming = true
		moveSidewaysDuringAnimation(-skills.backstep_distance)
		direction = -camera.global_transform.basis.z
		animation.play("rightstep",blend,1)
		

	elif overhead_slash_duration == true:
		automaticTargetAssist()
		if skills.can_overhead_slash == true:
			if stats.resolve > skills.overhead_slash_cost:
				switchWeaponFromHandToSideOrBack()
				directionToCamera()
				clearParryAbsorb()
				moveTowardsDirection(skills.overhead_slash_distance)
				match weapon_type:
					Autoload.weapon_type_list.sword:
						if overhead_slash_combo == false:
							animation.play("overhead slash sword",blend, stats.melee_atk_speed - 0.15)
						else:
							animation.play("overhead slash sword",blend, stats.melee_atk_speed + skills.overhead_slash_combo_speed_bonus)
					Autoload.weapon_type_list.sword_shield:
						if overhead_slash_combo == false:
							animation.play("overhead slash sword",blend, stats.melee_atk_speed- 0.15)
						else:
							animation.play("overhead slash sword",blend, stats.melee_atk_speed + skills.overhead_slash_combo_speed_bonus)
					Autoload.weapon_type_list.dual_swords:
						if overhead_slash_combo == false:
							animation.play("overhead slash sword",blend, stats.melee_atk_speed- 0.15)
						else:
							animation.play("overhead slash sword",blend, stats.melee_atk_speed + skills.overhead_slash_combo_speed_bonus)
					Autoload.weapon_type_list.heavy:
						if overhead_slash_combo == false:
							animation.play("overhead slash heavy",blend, stats.melee_atk_speed- 0.25)
						else:
							animation.play("overhead slash heavy",blend, stats.melee_atk_speed + skills.overhead_slash_combo_speed_bonus)
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
		if skills.can_whirlwind == true:
			if stats.resolve > skills.whirlwind_cost:
				match weapon_type:
					Autoload.weapon_type_list.sword:
						animation.play("whirlwind sword",blend*1.5,stats.melee_atk_speed+ 0.15)
						moveTowardsDirection(skills.whirlwind_distance)
					Autoload.weapon_type_list.sword_shield:
						animation.play("whirlwind sword",blend*1.5,stats.melee_atk_speed+ 0.15)
						moveTowardsDirection(skills.whirlwind_distance)
					Autoload.weapon_type_list.dual_swords:
						animation.play("whirlwind sword",blend*1.5,stats.melee_atk_speed + 0.1)
						moveTowardsDirection(skills.whirlwind_distance)
					Autoload.weapon_type_list.heavy:
						animation.play("whirlwind heavy",blend*1.5,stats.melee_atk_speed+ 0.15)
						moveTowardsDirection(skills.whirlwind_distance)
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
		moveTowardsDirection(6)
		match weapon_type:
					Autoload.weapon_type_list.sword:
						animation.play("rising slash shield",blend, stats.melee_atk_speed + 0.35)
					Autoload.weapon_type_list.sword_shield:
						animation.play("rising slash shield",blend,stats.melee_atk_speed + 0.35)
					Autoload.weapon_type_list.dual_swords:
						animation.play("rising slash shield",blend, stats.melee_atk_speed + 0.33)
					Autoload.weapon_type_list.heavy:
						animation.play("rising slash heavy",blend,stats.melee_atk_speed + 0.35)
#Cyclone____________________________________________________________________________________________
	elif cyclone_duration == true:
		automaticTargetAssist()
		directionToCamera()
		switchWeaponFromHandToSideOrBack()
		clearParryAbsorb()
		if skills.can_cyclone == true:
			if stats.resolve > skills.cyclone_cost:
				moveTowardsDirection(skills.cyclone_motion)
				match weapon_type:
					Autoload.weapon_type_list.sword:
						if cyclone_combo == false:
							animation.play("cyclone sword",blend,stats.melee_atk_speed+ 0.25)
						else:
							animation.play("cyclone sword",blend,stats.melee_atk_speed+ 1)
					Autoload.weapon_type_list.sword_shield:
						if cyclone_combo == false:
							animation.play("cyclone sword",blend,stats.melee_atk_speed+ 0.25)
						else:
							animation.play("cyclone sword",blend,stats.melee_atk_speed+ 1)
					Autoload.weapon_type_list.dual_swords:
						if cyclone_combo == false:
							animation.play("cyclone sword",blend,stats.melee_atk_speed+ 0.25)
						else:
							animation.play("cyclone sword",blend,stats.melee_atk_speed+ 1)
					Autoload.weapon_type_list.heavy:
						if cyclone_combo == false:
							animation.play("cyclone heavy",blend,stats.melee_atk_speed+ 0.15)
						else:
							animation.play("cyclone heavy",blend,stats.melee_atk_speed+ 0.95)
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
		if skills.can_heart_trust == true:
				match weapon_type:
					Autoload.weapon_type_list.sword:
						animation.play("heart trust sword",blend*1.5,stats.melee_atk_speed+ 0.55)
						moveTowardsDirection(4)
					Autoload.weapon_type_list.sword_shield:
						animation.play("heart trust sword",blend*1.5,stats.melee_atk_speed+ 0.35)
						moveTowardsDirection(3)
					Autoload.weapon_type_list.dual_swords:
						animation.play("heart trust sword",blend*1.5,stats.melee_atk_speed + 0.1)
						moveTowardsDirection(3.3)
					Autoload.weapon_type_list.heavy:
						animation.play("heart trust sword",blend*1.5,stats.melee_atk_speed + 0.15)
						moveTowardsDirection(6)
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
		moving = false
		if weapon_type == Autoload.weapon_type_list.heavy:
			animation.play("taunt heavy",blend + 0.1,stats.ferocity)
		else:
			animation.play("taunt",blend+ 0.1,stats.ferocity)
			
#__________________IF THE PLAYER DECIDED TO PLAY WITH HOLD OFF, 1 CLICK = 1 BASE ATTTACK__________
	elif throw_rock_duration == true:
		direction = -camera.global_transform.basis.z
		can_walk = false
		animation.play("throw rock",blend,stats.range_atk_speed)
		moveTowardsDirection(0)
		
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
			Autoload.weapon_type_list.dual_swords:
				animation.play("combo(dual)",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			Autoload.weapon_type_list.heavy:
				if long_base_atk == true:
					animation.play("combo(heavy)",blend,stats.melee_atk_speed + skills.combo_extr_speed)
					moveTowardsDirection(skills.combo_distance)

	elif base_atk4_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		match weapon_type:
			Autoload.weapon_type_list.dual_swords:
				animation.play("combo(dual)",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			Autoload.weapon_type_list.heavy:
				if long_base_atk == true:
					animation.play("combo(heavy)",blend,stats.melee_atk_speed + skills.combo_extr_speed)
					moveTowardsDirection(skills.combo_distance)

	elif stomp_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		
		animation.play("stomp",blend,stats.melee_atk_speed * 1.2)
		moveTowardsDirection(2)
	elif kick_duration == true:
		automaticTargetAssist()
		directionToCamera()
		clearParryAbsorb()
		animation.play("kick",blend,stats.agility)
		moveTowardsDirection(0)
	else:
		skillState()

func skillState() -> void:
	if skill_bar_input == "none":
		firstLevelAnimations()
	else:
		match skill_bar_input:
			"1":
				var slot = $Canvas/Skillbar/GridContainer/Slot1/Icon
				skills(slot)
			"2":
				var slot = $Canvas/Skillbar/GridContainer/Slot2/Icon
				skills(slot)
			"3":
				var slot = $Canvas/Skillbar/GridContainer/Slot3/Icon
				skills(slot)
			"4":
				var slot = $Canvas/Skillbar/GridContainer/Slot4/Icon
				skills(slot)
			"5":
				var slot = $Canvas/Skillbar/GridContainer/Slot5/Icon
				skills(slot)
			"6":
				var slot = $Canvas/Skillbar/GridContainer/Slot6/Icon
				skills(slot)
			"7":
				var slot = $Canvas/Skillbar/GridContainer/Slot7/Icon
				skills(slot)
			"8":
				var slot = $Canvas/Skillbar/GridContainer/Slot8/Icon
				skills(slot)
			"9":
				var slot = $Canvas/Skillbar/GridContainer/Slot9/Icon
				skills(slot)
			"0":
				var slot = $Canvas/Skillbar/GridContainer/Slot0/Icon
				skills(slot)
			"Q":
				var slot = $Canvas/Skillbar/GridContainer/SlotQ/Icon
				skills(slot)
			"E":
				var slot = $Canvas/Skillbar/GridContainer/SlotE/Icon
				skills(slot)
			"Z":
				var slot = $Canvas/Skillbar/GridContainer/SlotZ/Icon
				skills(slot)
			"X":
				var slot = $Canvas/Skillbar/GridContainer/SlotX/Icon
				skills(slot)
			"C":
				var slot = $Canvas/Skillbar/GridContainer/SlotC/Icon
				skills(slot)
			"R":
				var slot = $Canvas/Skillbar/GridContainer/SlotR/Icon
				skills(slot)
			"F":
				var slot = $Canvas/Skillbar/GridContainer/SlotF/Icon
				skills(slot)
			"T":
				var slot = $Canvas/Skillbar/GridContainer/SlotT/Icon
				skills(slot)
			"V":
				var slot = $Canvas/Skillbar/GridContainer/SlotV/Icon
				skills(slot)
			"G":
				var slot = $Canvas/Skillbar/GridContainer/SlotG/Icon
				skills(slot)
			"B":
				var slot = $Canvas/Skillbar/GridContainer/SlotB/Icon
				skills(slot)
			"Y":
				var slot = $Canvas/Skillbar/GridContainer/SlotY/Icon
				skills(slot)
			"H":
				var slot = $Canvas/Skillbar/GridContainer/SlotH/Icon
				skills(slot)
			"N":
				var slot = $Canvas/Skillbar/GridContainer/SlotN/Icon
				skills(slot)
			"M":
				var slot = $Canvas/Skillbar/GridContainer/SlotM/Icon
				skills(slot)
			"F1":
				var slot = $Canvas/Skillbar/GridContainer/SlotF1/Icon
				skills(slot)
			"F2":
				var slot = $Canvas/Skillbar/GridContainer/SlotF2/Icon
				skills(slot)
			"F3":
				var slot = $Canvas/Skillbar/GridContainer/SlotF3/Icon
				skills(slot)
			"F4":
				var slot = $Canvas/Skillbar/GridContainer/SlotF4/Icon
				skills(slot)
			"F5":
				var slot = $Canvas/Skillbar/GridContainer/SlotF5/Icon
				skills(slot)
func SkillQueueSystem()-> void:
	if skills.queue_skills == true:
		if skill_bar_input == "1":
			var slot = $Canvas/Skillbar/GridContainer/Slot1/Icon
			skills(slot)
		elif skill_bar_input == "2":
			var slot = $Canvas/Skillbar/GridContainer/Slot2/Icon
			skills(slot)
		elif skill_bar_input == "3":
			var slot = $Canvas/Skillbar/GridContainer/Slot3/Icon
			skills(slot)
		elif skill_bar_input == "4":
			var slot = $Canvas/Skillbar/GridContainer/Slot4/Icon
			skills(slot)
		elif skill_bar_input == "5":
			var slot = $Canvas/Skillbar/GridContainer/Slot5/Icon
			skills(slot)
		elif skill_bar_input == "6":
			var slot = $Canvas/Skillbar/GridContainer/Slot6/Icon
			skills(slot)
		elif skill_bar_input == "7":
			var slot = $Canvas/Skillbar/GridContainer/Slot7/Icon
			skills(slot)
		elif skill_bar_input == "8":
			var slot = $Canvas/Skillbar/GridContainer/Slot8/Icon
			skills(slot)
		elif skill_bar_input == "9":
			var slot = $Canvas/Skillbar/GridContainer/Slot9/Icon
			skills(slot)
		elif skill_bar_input == "0":
			var slot = $Canvas/Skillbar/GridContainer/Slot0/Icon
			skills(slot)
		elif skill_bar_input == "Q":
			var slot = $Canvas/Skillbar/GridContainer/SlotQ/Icon
			skills(slot)
		elif skill_bar_input == "E":
			var slot = $Canvas/Skillbar/GridContainer/SlotE/Icon
			skills(slot)
		elif skill_bar_input == "Z":
			var slot = $Canvas/Skillbar/GridContainer/SlotZ/Icon
			skills(slot)
		elif skill_bar_input == "X":
			var slot = $Canvas/Skillbar/GridContainer/SlotX/Icon
			skills(slot)
		elif skill_bar_input == "C":
			var slot = $Canvas/Skillbar/GridContainer/SlotC/Icon
			skills(slot)
		elif skill_bar_input == "R":
			var slot = $Canvas/Skillbar/GridContainer/SlotR/Icon
			skills(slot)
		elif skill_bar_input == "F":
			var slot = $Canvas/Skillbar/GridContainer/SlotF/Icon
			skills(slot)
		elif skill_bar_input == "T":
			var slot = $Canvas/Skillbar/GridContainer/SlotT/Icon
			skills(slot)
		elif skill_bar_input == "V":
			var slot = $Canvas/Skillbar/GridContainer/SlotV/Icon
			skills(slot)
		elif skill_bar_input == "G":
			var slot = $Canvas/Skillbar/GridContainer/SlotG/Icon
			skills(slot)
		elif skill_bar_input == "B":
			var slot = $Canvas/Skillbar/GridContainer/SlotB/Icon
			skills(slot)
		elif skill_bar_input == "Y":
			var slot = $Canvas/Skillbar/GridContainer/SlotY/Icon
			skills(slot)
		elif skill_bar_input == "H":
			var slot = $Canvas/Skillbar/GridContainer/SlotH/Icon
			skills(slot)
		elif skill_bar_input == "N":
			var slot = $Canvas/Skillbar/GridContainer/SlotN/Icon
			skills(slot)
		elif skill_bar_input == "M":
			var slot = $Canvas/Skillbar/GridContainer/SlotM/Icon
			skills(slot)
		elif skill_bar_input == "F1":
			var slot = $Canvas/Skillbar/GridContainer/SlotF1/Icon
			skills(slot)
		elif skill_bar_input == "F2":
			var slot = $Canvas/Skillbar/GridContainer/SlotF2/Icon
			skills(slot)
		elif skill_bar_input == "F3":
			var slot = $Canvas/Skillbar/GridContainer/SlotF3/Icon
			skills(slot)
		elif skill_bar_input == "F4":
			var slot = $Canvas/Skillbar/GridContainer/SlotF4/Icon
			skills(slot)
		elif skill_bar_input == "F5":
			var slot = $Canvas/Skillbar/GridContainer/SlotF5/Icon
			skills(slot)



onready var l_click_slot =  $Canvas/Skillbar/SlotLClick
onready var r_click_slot = $Canvas/Skillbar/SlotRClick

func skills(slot)-> void:
	if slot == null:
		print("slot null")
	else:
		
		print("slot not null")
		if slot.texture != null:
##Dash_______________________________________________________________________________________________
#			if slot.texture.resource_path == Icons.dash.get_path() and dash_duration == false:
#					if skills.can_dash == false:
#						dash_duration  = false
#						returnToIdleBasedOnWeaponType()
#					else:
#						if stats.resolve <= skills.dash_cost:
#							returnToIdleBasedOnWeaponType()
#							dash_duration = false
#							skills.interruptBaseAtk()
#						else:
#							stats.resolve -= skills.dash_cost
#							dash_duration = true
#							if skill_cancelling == true:
#								skills.skillCancel("dash")
##Slide______________________________________________________________________________________________
#			if slot.texture.resource_path == Icons.slide.get_path():
#				if skills.can_slide == false:
#					slide_duration  = false
#					returnToIdleBasedOnWeaponType()
#				else:
#					slide_duration = true
#					skills.interruptBaseAtk()
#					if skill_cancelling == true:
#						skills.skillCancel("slide")
#Backstep______________________________________________________________________________________________
			if slot.texture.resource_path == Icons.garrote.get_path():
				if slot.get_parent().get_node("CD").text == "":
					garrote_active = true
					garroteTarget()
					skills.skillCancel("garrote")
				else:
					garrote_active = false
					returnToIdleBasedOnWeaponType()

			if slot.texture.resource_path == Icons.silent_stab.get_path():
				if slot.get_parent().get_node("CD").text == "":
					silent_stab_active = true
					skills.skillCancel("silentStab")
				else:
					returnToIdleBasedOnWeaponType()
					
					
#			if slot.texture.resource_path == Icons.backstep.get_path():
#				if skills.can_backstep == false:
#					returnToIdleBasedOnWeaponType()
#					frontstep_duration = false
#					backstep_duration = false
#					leftstep_duration = false
#					rightstep_duration = false
#					debug.active_action = "trying to backstep"
#				else:
#					debug.active_action = "backstep"
#					debug.last_skills = "backstep"
#					skills.interruptBaseAtk()
#					if Input.is_action_pressed("front"):
#						frontstep_duration = true
#						debug.active_action = "frontstep"
#						debug.last_skills = "frontstep"
#					elif Input.is_action_pressed("right"):
#						rightstep_duration = true
#						debug.active_action = "rightstep"
#						debug.last_skills = "rightstep"
#					elif Input.is_action_pressed("left"):
#						leftstep_duration = true
#						debug.active_action = "leftstep"
#						debug.last_skills = "leftstep"
#					else:
#						backstep_duration = true
#						debug.active_action = "backstep"
#						debug.last_skills = "backstep"
#					if skill_cancelling == true:
#						debug.active_action = "backstep"
#						debug.last_skills = "backstep"
#						skills.skillCancel("backstep")
#Lclick and Rclick__________________________________________________________________________________
#fist
#			elif slot.texture.resource_path == Icons.punch.get_path():
#				if hold_to_base_atk == true:
#					animation.play("fist hold",blend,stats.melee_atk_speed + 0.15)
#					directionToCamera()
#					moveTowardsDirection(2.5)
#				else:
#					base_atk_duration = true
#					is_in_combat = true
#
#			elif slot.texture.resource_path == Icons.punch2.get_path():
#				if hold_to_base_atk == false:
#					base_atk2_duration = true
#					is_in_combat = true
#
#			elif slot.texture.resource_path == Icons.stomp.get_path():
#				if skills.can_stomp == false:
#					stomp_duration = false
#					returnToIdleBasedOnWeaponType()
#				else:
#					stomp_duration = true
#				is_in_combat = true
#				switchWeaponFromHandToSideOrBack()
#				skills.skillCancel("stomp")
#_________________________________________Kick______________________________________________________
			elif slot.texture.resource_path == Icons.kick.get_path():
				debug.active_action = "kick"
				if skills.can_kick == false:
					kick_duration = false
					debug.active_action = "can't kick"
					debug.last_skills = "can't kick"
					returnToIdleBasedOnWeaponType()
				else:
				#	if kick_icon.points >0:
						if stats.resolve > skills.kick_cost:
							kick_duration = true
							is_in_combat = true
							switchWeaponFromHandToSideOrBack()
							skills.skillCancel("kick")
							
#
#			elif slot.texture.resource_path == Icons.throw_rock.get_path():
#				if hold_to_base_atk == false:
#					throw_rock_duration = true
#					is_in_combat = true
#				else:
#					moving = false
#					can_walk = false
#					is_in_combat = true
#					direction = -camera.global_transform.basis.z
#					moveTowardsDirection(0)
#					animation.play("throw rock",blend,stats.range_atk_speed + 0.15)
##sword
#
#			elif slot.texture.resource_path == Icons.vanguard_icons["combo_switch"].get_path():
#				if skills.can_combo_switch == true: 
#					skills.comboSwitchCD()
#
#
#
#			elif slot.texture.resource_path == Icons.vanguard_icons["base_atk"].get_path():
#				if hold_to_base_atk == true:
#					directionToCamera()
#					baseAtkAnim()
#				else:
#					base_atk_duration = true
#			elif slot.texture.resource_path == Icons.vanguard_icons["base_atk2"].get_path():
#				if hold_to_base_atk == false:
#					base_atk2_duration = true
#					base_atk3_duration = true
#					base_atk4_duration = true
#
#			elif slot.texture.resource_path == Icons.vanguard_icons["guard_sword"].get_path():
#				if stats.resolve > 0:
#					moving = false
#					can_walk = false
#					is_in_combat = true
#					stats.resolve -= 1 * get_physics_process_delta_time()
#					if weapon_type == Icons.weapon_type_list.dual_swords:
#						animation.play("dual block",blend)
#					else:
#						animation.play("sword block",blend)
#				else:
#					returnToIdleBasedOnWeaponType()
#			elif slot.texture.resource_path == Icons.vanguard_icons["guard_shield"].get_path():
#				if stats.resolve > 0:
#					moving = false
#					can_walk = false
#					stats.resolve -= 1 * get_physics_process_delta_time()
#					animation.play("shield block",blend)
#				else:
#					returnToIdleBasedOnWeaponType()
##bow 
#			elif slot.texture.resource_path == Icons.quick_shot.get_path():
#				if weapon_type == Icons.weapon_type_list.bow:
#					is_aiming = true
#					can_walk = false
#					genes.can_move = false
#					is_in_combat = true
#					if moving == false:
#						animation.play("shoot",blend,stats.range_atk_speed + 0.4)
#
##melee weapon skills
##__________________________________________  overhead slash    _____________________________________
#			elif slot.texture.resource_path == Icons.vanguard_icons["sunder"].get_path():
#				if overhead_icon.points >0:
#					if skills.can_overhead_slash == true:
#						if stats.resolve > skills.overhead_slash_cost:
#							if weapon_type != Icons.weapon_type_list.fist:
#								overhead_slash_duration = true
#								is_in_combat = true
#								if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
#									skills.skillCancel("sunder")
#							else:
#								returnToIdleBasedOnWeaponType()
#								overhead_slash_duration = false
#						else:
#							returnToIdleBasedOnWeaponType()
#							overhead_slash_duration = false
#					else:
#						returnToIdleBasedOnWeaponType()
#						overhead_slash_duration = false
##___________________________________________________________________________________________________
#			elif slot.texture.resource_path == Icons.vanguard_icons["taunt"].get_path():
#					if taunt_icon.points >0:
#						if skills.can_taunt == true:
#							if stats.resolve > skills.taunt_cost:
#								taunt_duration = true
#								moving = false
#								can_walk = false
#								is_in_combat = true
#								if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
#									skills.skillCancel("taunt")
#							else:
#								returnToIdleBasedOnWeaponType()
#								taunt_duration = false
#						else:
#							returnToIdleBasedOnWeaponType()
#							taunt_duration = false
#					else:
#						returnToIdleBasedOnWeaponType()
#						taunt_duration = false
##_________________________________________ rising slash ____________________________________________
#			elif slot.texture.resource_path == Icons.vanguard_icons["rising_slash"].get_path():
#					if rising_icon.points >0:
#						if skills.can_rising_slash == true:
#							if stats.resolve > skills.rising_slash_cost:
#								if weapon_type != Icons.weapon_type_list.fist:
#									rising_slash_duration = true
#									is_in_combat = true
#									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
#										skills.skillCancel("rising_slash")
#									else:
#										pass
#							else:
#								returnToIdleBasedOnWeaponType()
#								rising_slash_duration = false
#						else:
#							returnToIdleBasedOnWeaponType()
#							rising_slash_duration = false
#					else:
#						returnToIdleBasedOnWeaponType()
#						rising_slash_duration = false
##_________________________________________  cyclone   ______________________________________________
#			elif slot.texture.resource_path == Icons.vanguard_icons["cyclone"].get_path():
#					if cyclone_icon.points >0 :
#						if skills.can_cyclone == true:
#							if stats.resolve > skills.cyclone_cost:
#								if weapon_type != Icons.weapon_type_list.fist:
#									cyclone_duration = true
#									is_in_combat = true
#									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
#										skills.skillCancel("cyclone")
#							else:
#								returnToIdleBasedOnWeaponType()
#								cyclone_duration = false
#						else:
#							returnToIdleBasedOnWeaponType()
#							cyclone_duration = false
#					else:
#						returnToIdleBasedOnWeaponType()
#						cyclone_duration = false
##__________________________________________ Whirlwind _____________________________________________
#			elif slot.texture.resource_path == Icons.vanguard_icons["whirlwind"].get_path():
#					if whirlwind_icon.points >0 :
#						if skills.can_whirlwind == true:
#							if stats.resolve > skills.whirlwind_cost:
#								if weapon_type != Icons.weapon_type_list.fist:
#									whirlwind_duration = true
#									is_in_combat = true
#									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
#										skills.skillCancel("whirlwind")
#							else:
#								returnToIdleBasedOnWeaponType()
#								whirlwind_duration = false
#						else:
#							returnToIdleBasedOnWeaponType()
#							whirlwind_duration = false
#					else:
#						returnToIdleBasedOnWeaponType()
#						whirlwind_duration = false
##__________________________________________ Heart Trust ____________________________________________
#			elif slot.texture.resource_path == Icons.vanguard_icons["heart_trust"].get_path():
#					if heart_trust_icon.points >0 :
#						if skills.can_heart_trust == true:
#							if stats.resolve > skills.heart_trust_cost:
#								if weapon_type != Icons.weapon_type_list.fist:
#									heart_trust_duration = true
#									if skill_cancelling == true:#Putting all of thise in a function with an exception doesn't work properly, like animationCancelException(cyclone_duration)
#										skills.skillCancel("heart_trust")
#							else:
#								returnToIdleBasedOnWeaponType()
#								heart_trust_duration = false
#						else:
#							returnToIdleBasedOnWeaponType()
#							heart_trust_duration = false
#					else:
#						returnToIdleBasedOnWeaponType()
#						heart_trust_duration = false
#
##ranged bow skills
#			elif slot.texture.resource_path == Icons.full_draw.get_path():
#				if weapon_type == Icons.weapon_type_list.bow:
#					is_aiming = true
#					can_walk = false
#					genes.can_move = false
#					animation.play("full draw",0.3,stats.range_atk_speed)
#
#
#
#			elif slot.texture.resource_path == stats.grappling_hook.get_path():
#				if skills.can_grappling_hook == true:
#					direction = -camera.global_transform.basis.z
#					hookEnemies()
#					skills.grapplingHookCD()
#
#
#
##consumables________________________________________________________________________________________
			elif slot.texture.resource_path == Icons.red_potion.get_path():
				slot.get_parent().displayQuantity()
				for child in inventory_grid.get_children():
					if child.is_in_group("Inventory"):
						var index_str = child.get_name().split("InvSlot")[1]
						var index = int(index_str)
						var button = inventory_grid.get_node("InvSlot" + str(index))
						button = inventory_grid.get_node("InvSlot" + str(index))
						if stats.health < stats.max_health:
							Autoload.consumeRedPotion(self,button,inventory_grid,true,slot.get_parent())
						if stats.health > stats.max_health:
							stats.health = stats.max_health 

#skills in skills-tree
onready var all_skills = $UI/GUI/SkillTrees
onready var kick_icon =  $Canvas/Skills/Skill3/Icon
onready var taunt_icon = $UI/GUI/SkillTrees/Vanguard/skill6/Icon
onready var cyclone_icon = $UI/GUI/SkillTrees/Vanguard/skill5/Icon
onready var overhead_icon = $UI/GUI/SkillTrees/Vanguard/skill2/Icon
onready var rising_icon = $UI/GUI/SkillTrees/Vanguard/skill4/Icon
onready var whirlwind_icon = $UI/GUI/SkillTrees/Vanguard/skill1/Icon
onready var heart_trust_icon = $UI/GUI/SkillTrees/Vanguard/skill3/Icon




func baseAtkAnim()-> void:
	match weapon_type:
		Autoload.weapon_type_list.fist:
			if long_base_atk == true:
				animation.play("punch",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("punch",blend,stats.melee_atk_speed)
		Autoload.weapon_type_list.sword:
			if long_base_atk == true:
				animation.play("combo sword",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("cleave sword",blend,stats.melee_atk_speed)
				moveTowardsDirection(skills.cleave_distance)
		Autoload.weapon_type_list.dual_swords:
			var dual_wield_compensation:float = 1.105 #People have the feeling that two swords should be faster, not realistic, but it breaks their "game feel" 
			if long_base_atk == true:
				animation.play("combo(dual)",blend,stats.melee_atk_speed + skills.combo_extr_speed * dual_wield_compensation)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("cleave dual",blend,stats.melee_atk_speed * dual_wield_compensation)
				moveTowardsDirection(skills.cleave_distance)
		Autoload.weapon_type_list.heavy:
			if long_base_atk == true:
				animation.play("combo(heavy)",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("cleave",blend,stats.melee_atk_speed)
				moveTowardsDirection(skills.cleave_distance)

var skill_cancelling:bool = true#this only works with the SkillQueueSystem() and serves to interupt skills with other skills 


func stopBeingParlized():
	pass
func clearParryAbsorb():
	pass

# Toggle the hold_to_base_atk variable and change the color of BaseAtkMode accordingly
func _on_BaseAtkMode_pressed():
	hold_to_base_atk = !hold_to_base_atk
	switchButtonTextures()

			
func returnToIdleBasedOnWeaponType():
	match weapon_type:
			Autoload.weapon_type_list.fist:
				animation.play("idle fist",0.3)
			Autoload.weapon_type_list.sword:
				animation.play("idle sword",0.3)
			Autoload.weapon_type_list.dual_swords:
				animation.play("idle sword",0.3)
			Autoload.weapon_type_list.bow:
				animation.play("idle bow",0.3)
			Autoload.weapon_type_list.heavy:
				animation.play("idle heavy")

func moveSidewaysDuringAnimation(speed):
	if !is_on_wall():
		horizontal_velocity = -camera.global_transform.basis.x * speed 

var sprint_animation_speed: float = 1
var anim_cancel:bool = true #If true using abilities and skills interupts base attacks or other animations

var direction_assist:bool = false
func automaticTargetAssist() ->void:
	if direction_assist == true:
		rotateTowardsEnemy()



#_______________________________________________Combat______________________________________________
"""
@Ceisri
Documentation String: 
	rotateTowardsEnemy() is a very simple and straight forward function that finds the closest entity in the entire game 
	and rtoates the player towards that entity when the function is called, the rotation is done using direction 
	the variable direction_assist is not going to be used directly in rotateTowardsEnemy() but inside all attacks. 
	if enabled, all attacks will automatically call automaticTargetAssist()
"""


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
	if Input.is_action_pressed("autoturn"):
		rotateTowardsEnemy()
		
		


#___________________________________________________________________________________________________
#Movement and physics
var gravity_force: float = 20
func gravity():
	if gravity_active == true:
		if is_in_combat == false:
			if not is_on_floor():
					vertical_velocity += Vector3.DOWN * gravity_force  * get_physics_process_delta_time()
			else: 
				vertical_velocity = -get_floor_normal() * gravity_force / 2.5
		else:#inside of combat situations,to avoid climbing on enemies by mistake, now you have to jump on the enemy first to start climbing
			if not is_on_floor():
				vertical_velocity += Vector3.DOWN * gravity_force * get_physics_process_delta_time()
			else: 
				vertical_velocity = -get_floor_normal() * gravity_force / 2.5
				

# Movement variables
var direction: Vector3 = Vector3()
var horizontal_velocity: Vector3 = Vector3()
var vertical_velocity: Vector3 = Vector3()
var movement: Vector3 = Vector3()



var angular_acceleration: float = 3.25
var acceleration: float = 15.0
var moving:bool = false
var movement_mode:String = "walk"
var walk_speed: float = 3.0
var sprint_speed:float = 10
var default_sprint_speed:float = 10 
var max_sprint_speed:float = 15
var run_speed:float = 7.5
var jump_strength:float = 6
var movement_speed: float = 0.0
var jump_count = 0
var max_jumps = 2

# Movement variables
var joystick_direction: Vector3 = Vector3()
var joystick_active: bool = false
var sneak_toggle:bool = false
var sneaking:bool = false
var crawling:bool = false

onready var upper_collision:CollisionShape = $UpperCollision
onready var middle_collision:CollisionShape = $MidCollision
var can_walk:bool = false

#Movement section___________________________________________________________________________________
func movement(delta: float) -> void:
	var h_rot = camera_v.global_transform.basis.get_euler().y
	movement_speed = 0.0
	moving = false

	var input_direction = Vector3(
		Input.get_action_strength("left") - Input.get_action_strength("right"),
		0,
		Input.get_action_strength("front") - Input.get_action_strength("back")
	)
	if garrote_active == false:
		if input_direction.length() > 0:
			direction = input_direction.rotated(Vector3.UP, h_rot).normalized()
			moving = true
			movement_speed = walk_speed
		elif joystick_active:
			direction = -joystick_direction.rotated(Vector3.UP, h_rot).normalized()
			moving = true
			movement_speed = walk_speed
	
	if moving == true:
		if carried_body == null:
			if Input.is_action_pressed("sprint"):
				debug.active_action = "sprinting"
				is_in_combat = false
				movement_speed = sprint_speed
				movement_mode = "sprint"
				if sprint_speed < max_sprint_speed:
					sprint_speed += 0.005 * stats.agility
				elif sprint_speed > max_sprint_speed:
					sprint_speed = max_sprint_speed
			elif Input.is_action_pressed("run"):
				debug.active_action = "running"
				sprint_speed = default_sprint_speed
				movement_mode = "run"
				movement_speed = run_speed
			elif sneaking == true:
				debug.active_action = "sneaking"
				sprint_speed = default_sprint_speed
				movement_mode = "sneak"
				movement_speed = walk_speed * 0.5
			elif crawling == true:
				debug.active_action = "crawl"
				sprint_speed = default_sprint_speed
				movement_mode = "crawl"
				movement_speed = walk_speed * 0.25
			else: # Walk State and speed
				if stats.health >0:
					debug.active_action = "walking"
					sprint_speed = default_sprint_speed
					movement_speed = walk_speed 
					movement_mode = "walk"
				else:
					debug.active_action = "downed moving"
					sprint_speed = default_sprint_speed
					movement_speed = walk_speed * 0.3
					movement_mode = "downed moving"
		else:
			sprint_speed = default_sprint_speed
			movement_speed = walk_speed 
			movement_mode = "walk"
	if sneak_toggle == true:
		if Input.is_action_just_pressed("sneak"):
			sneaking = !sneaking
	if Input.is_action_just_pressed("crawl"):
		crawling = !crawling
	
	if sneak_toggle == false:
		if Input.is_action_pressed("sneak"):
			sneaking = true
		else:
			sneaking = false
	if jump_count < 1:
		if carried_body == null:
			if is_on_floor():
				if Input.is_action_just_pressed("jump"):
					debug.active_action = "jumping"
					jump_count += 1
					vertical_velocity = Vector3.UP * jump_strength
			else:
				if Input.is_action_just_pressed("jump"):
					debug.active_action = "double jumping"
					jump_count += 1
					vertical_velocity = Vector3.UP * jump_strength
					flip_duration = true
					
	movementCollisions()
	if is_on_floor():
		jump_count = 0
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)

func movementCollisions()-> void:
	if crawling == true:
		middle_collision.disabled = true
		upper_collision.disabled = true
	elif sneaking == true:
		middle_collision.disabled = false
		upper_collision.disabled = true
	else:
		middle_collision.disabled = false
		upper_collision.disabled = false

func _on_SneakToggle_pressed() -> void:
	sneak_toggle = !sneak_toggle


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
func dodgeIframe() -> void:
	if state == Autoload.state_list.slide or backstep_duration == true or frontstep_duration == true or leftstep_duration == true or rightstep_duration == true or dash_duration == true:
		set_collision_layer(6) 
		set_collision_mask(6) 
	else:
		set_collision_layer(1) 
		set_collision_mask(1)   
		
func doublePressToDash()-> void:
	pass
#	if stats.resolve >= skills.dash_cost:
#		if dash_countback > 0:
#			dash_timerback += get_physics_process_delta_time()
#		if dash_timerback >= double_press_time:
#			dash_countback = 0
#			dash_timerback = 0.0
#		if Input.is_action_just_pressed("backward"):
#			dash_countback += 1
#		if dash_countback == 2 and dash_timerback < double_press_time:
#			dash_duration = true
#			resolve -= skills.dash_cost
#
#
#		if dash_countforward > 0:
#			dash_timerforward += get_physics_process_delta_time()
#		if dash_timerforward >= double_press_time:
#			dash_countforward = 0
#			dash_timerforward = 0.0
#		if Input.is_action_just_pressed("forward"):
#			dash_countforward += 1
#		if dash_countforward == 2 and dash_timerforward < double_press_time:
#			dash_duration = true
#			resolve -= skills.dash_cost
#
#		if dash_countleft > 0:
#			dash_timerleft += get_physics_process_delta_time()
#		if dash_timerleft >= double_press_time:
#			dash_countleft = 0
#			dash_timerleft = 0.0
#		if Input.is_action_just_pressed("left"):
#			dash_countleft += 1
#		if dash_countleft == 2 and dash_timerleft < double_press_time:
#			dash_duration = true
#			resolve -= skills.dash_cost
#
#		if dash_countright > 0:
#			dash_timerright += get_physics_process_delta_time()
#		if dash_timerright >= double_press_time:
#			dash_countright = 0
#			dash_timerright = 0.0
#		if Input.is_action_just_pressed("right"):
#			dash_countright += 1
#		if dash_countright == 2 and dash_timerright < double_press_time :
#			dash_duration = true
#			resolve -= skills.dash_cost


var is_on_stairs:bool = false
func climbStairs()-> void:
	if skill_bar_input == "none":
		if moving:
			if climb_ray.is_colliding():
				if is_on_wall():
					if is_on_floor():
						vertical_velocity = Vector3.UP * (stats.strength * 3)
						horizontal_velocity = direction * walk_speed * 2
						is_on_stairs  = true
 

var is_swimming:bool = false
var wall_incline
var is_wall_in_range:bool = false
var gravity_active:bool = true
onready var head_ray =  $DirectionControl/HeadRay
onready var climb_ray =  $DirectionControl/ClimbRay
func climb()-> void:
	if skill_bar_input == "none":
		if carried_body == null:
			if climb_ray.is_colliding() and is_on_wall():
				if moving == true and not Input.is_action_pressed("sprint") and not Input.is_action_pressed("run") and not Input.is_action_pressed("sneak"):
					gravity_active = false
					checkWallInclination()
					flip_duration = false
					if not head_ray.is_colliding() and not is_wall_in_range:#vaulting
						if  not is_on_floor():
							movement_mode = "vault"
							animation.play("vault",blend)
							vertical_velocity = Vector3.UP * (stats.strength * 3)
					elif not is_wall_in_range:#normal climb
						movement_mode = "climb"
						animation.play("climb",blend)
						vertical_velocity = Vector3.UP * (stats.strength * 3)
					else:
						movement_mode = "climb incline"
						vertical_velocity = Vector3.UP * (stats.strength * 1.25 + (stats.agility * 0.15))
						horizontal_velocity = direction * walk_speed
				else:
					gravity_active = true 
			else:
				gravity_active = true 


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
var can_move:bool = false
func moveTowardsDirection(speed):
	if !is_on_wall():
		if can_move == true:
			horizontal_velocity = direction * speed 
		
# These are connected from the joystick multidirectional addon 
func _on_joystick_multidirectionnal_update_pos(pos):
	joystick_direction = Vector3(pos.x, 0, pos.y).normalized()
	joystick_active = true

func _on_joystick_multidirectionnal_stop_update_pos(pos):
	joystick_active = false
	joystick_direction = Vector3()


var is_aiming:bool = false
onready var direction_control:Spatial = $DirectionControl
func rotateMesh() -> void:
	direction_control.rotation.y = lerp_angle(direction_control.rotation.y, atan2(direction.x, direction.z) - rotation.y, get_physics_process_delta_time() * angular_acceleration)
func directionToCamera():#put this on attacks 
	if aiming_mode =="camera":
		direction = -camera.global_transform.basis.z



#Camera/Mouse seciont_______________________________________________________________________________
onready var camera_h: Spatial = $CameraRoot/Horizontal
onready var camera_v: Spatial = $CameraRoot/Horizontal/Vertical
onready var camera: Camera =  $CameraRoot/Horizontal/Vertical/Camera
var camrot_h: float = 0.0
var camrot_v: float = 0.0
var cam_v_max: float = 200.0
var cam_v_min: float = -125.0
var h_sensitivity: float = 0.1
var v_sensitivity: float = 0.1
var h_acceleration: float = 10.0
var v_acceleration: float = 10.0
var cursor_visible:bool = false
var aiming_mode:String = "directional"

func mouseMode()-> void:
	if Input.is_action_just_pressed("ESC"):	# Toggle mouse mode
		cursor_visible =!cursor_visible
	if !cursor_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
var zoom_speed: float = 0.1
func Zoom(zoom_direction : float)-> void:
	# Adjust the camera's position based on the zoom direction
	camera.translation.y += zoom_direction * zoom_speed
	camera.translation.z -= zoom_direction * (zoom_speed * 2)
func camera_rotation() -> void:
	if !cursor_visible:
		camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
		camera_h.rotation_degrees.y = lerp(camera_h.rotation_degrees.y, camrot_h, get_physics_process_delta_time() * h_acceleration)
		camera_v.rotation_degrees.x = lerp(camera_v.rotation_degrees.x, camrot_v, get_physics_process_delta_time() * v_acceleration)
func unstuck():
	translation = Vector3(0, 1, 0)




#Combat_____________________________________________________________________________________________
"""
@Ceisri
Documentation String: 
isFacingSelf() returns whether or not the rotation angle between the player and their adversary is
within a certain value. Play around with it. It also checks if you have additional directional nodes. 
For example, in my game, enemies don't have a DirectionControl node but players do. 
Remove or keep it depending on your necessities. In my game, the threshold for flank attacks is 30 degrees,
Keep in mind it must be converted from 0.0 to 1.0, to give you a few  examples:

- isFacingSelf(enemy,0.5) returns true only if you are attacking from behind, good for backstabs 
- isFacingSelf(enemy,0.0) returns true if you are attacking from behind or from the sides, good for flank attacks


which means that when the player and adversary are face to face, their rotation degrees 
are between 160 and 180. But when the player is directly behind the adversary, their rotation degree
is between 0 and 15. In your game, it might be exactly the other way around depending on how you 
orient your nodes. Just in case, there's debug.backstab_threshold = angle_between so you can test 
everything.
"""

func isFacingSelf(body:Node, threshold: float) -> bool:
	# Get the global position of the calling object (self)
	var self_global_transform = get_global_transform()
	var self_position = self_global_transform.origin
	# Get the global position of the body
	var body_position = body.global_transform.origin
	# Calculate the direction vector from the calling object (self) to the body
	var direction_to_body = (body_position - self_position).normalized()
	# Get the facing direction of the body from its Mesh node
	var facing_direction = Vector3.ZERO
	var direcion_node = body.get_node("DirectionControl")
	if direcion_node:
		facing_direction = direcion_node.global_transform.basis.z.normalized()
	else:# If DirectionControl node is not found, use the default facing direction of the body
		facing_direction = body.global_transform.basis.z.normalized()
	# Calculate the dot product between the body's facing direction and the direction to the calling object (self)
	var dot_product = facing_direction.dot(direction_to_body)

	var angle_between = rad2deg(acos(dot_product))
	debug.backstab_treshold=  angle_between
	# If the dot product is greater than a certain threshold, consider the body is facing the calling object (self)
	return dot_product >= threshold



#Input__section______________________________________________________________________________________
func _input(event):
		if event is InputEventMouseMotion:
			camrot_h -= event.relative.x * h_sensitivity
			camrot_v += event.relative.y * v_sensitivity
		#Scrollwheel zoom in and out 		
		if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
			# Zoom in when scrolling up
			Zoom(-1)
		elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
			# Zoom out when scrolling down
			Zoom(1)
func clickInputs():#Momentary Delete Later
	if !cursor_visible:
		if Input.is_action_pressed("Lclick"):
			attacking = true
		else: 
			attacking = false
var is_fullscreen :bool  = false
func InputsInterface()-> void:
	if Input.is_action_just_pressed("fullscreen"):
		is_fullscreen = !is_fullscreen
		OS.set_window_fullscreen(is_fullscreen)
		saveGame()
	if Input.is_action_just_pressed("Menu"):
		menu.visible = !menu.visible
		
	if Input.is_action_just_pressed("Debug"):
		debug.visible = !debug.visible
		
	if Input.is_action_just_pressed("Skills"):
		skills_professions.visible = !skills_professions.visible
		
		
		
var skill_bar_input:String = "none"
func skillBarInputs():
	if Input.is_action_pressed("1"):
		skill_bar_input = "1"
	elif Input.is_action_pressed("2"):
		skill_bar_input = "2"
	elif Input.is_action_pressed("3"):
		skill_bar_input = "3"
	elif Input.is_action_pressed("4"):
		skill_bar_input = "4"
	elif Input.is_action_pressed("5"):
		skill_bar_input = "5"
	elif Input.is_action_pressed("6"):
		skill_bar_input = "6"
	elif Input.is_action_pressed("7"):
		skill_bar_input = "7"
	elif Input.is_action_pressed("8"):
		skill_bar_input = "8"
	elif Input.is_action_pressed("9"):
		skill_bar_input = "9"
	elif Input.is_action_pressed("0"):
		skill_bar_input = "0"
	elif Input.is_action_pressed("Q"):
		skill_bar_input = "Q"
	elif Input.is_action_pressed("E"):
		skill_bar_input = "E"
	elif Input.is_action_pressed("Z"):
		skill_bar_input = "Z"
	elif Input.is_action_pressed("X"):
		skill_bar_input = "X"
	elif Input.is_action_pressed("C"):
		skill_bar_input = "C"
	elif Input.is_action_pressed("R"):
		skill_bar_input = "R"
	elif Input.is_action_pressed("F"):
		skill_bar_input = "F"
	elif Input.is_action_pressed("T"):
		skill_bar_input = "T"
	elif Input.is_action_pressed("V"):
		skill_bar_input = "V"
	elif Input.is_action_pressed("G"):
		skill_bar_input = "G"
	elif Input.is_action_pressed("B"):
		skill_bar_input = "B"
	elif Input.is_action_pressed("Y"):
		skill_bar_input = "Y"
	elif Input.is_action_pressed("H"):
		skill_bar_input = "H"
	elif Input.is_action_pressed("N"):
		skill_bar_input = "N"
	elif Input.is_action_pressed("M"):
		skill_bar_input = "M"
	elif Input.is_action_pressed("F1"):
		skill_bar_input = "F1"
	elif Input.is_action_pressed("F2"):
		skill_bar_input = "F2"
	elif Input.is_action_pressed("F3"):
		skill_bar_input = "F3"
	elif Input.is_action_pressed("F4"):
		skill_bar_input = "F4"
	elif Input.is_action_pressed("F5"):
		skill_bar_input = "F5"


	else:
		skill_bar_input = "none"

var long_base_atk:bool = false
func _on_baseatkswitch_pressed():
	long_base_atk = !long_base_atk


#SaveGame___________________________________________________________________________________________

func saveGame()->void:
	for entity in get_tree().get_nodes_in_group("Entity"):
		entity.saveData()
		
	for node in Root.get_children():
		if node.has_method("saveData"):
			node.saveData()

	for node in $Canvas/Skillbar/GridContainer.get_children():
		if node.has_method("saveData"):
			node.saveData()
			
		if node.has_node("Icon"):
			if node.get_node("Icon").has_method("saveData"):
				node.get_node("Icon").saveData()
		
		elif node.has_node("icon"):
			debug.error_message = "icon named with lower case I, fix that " + str(node.name)
			
	saveInventoryData()
	
var slot: String = "1"
var save_directory: String = "user://saves/" + entity_name
var save_path: String = save_directory +  "save.dat" 
func saveData():
	var data = {
		"position": translation,
		"health": stats.health,
		"max_health": stats.max_health,
		
		"skillbar.rect_position": skillbar.rect_position,
		"skill_bar_mode": skill_bar_mode,
		"ui_color": ui_color,
		"ui_color2": ui_color2,
		"shifting_ui_colors": shifting_ui_colors,
		"shifting_ui_colors2": shifting_ui_colors2,
		}
	var dir = Directory.new()
	if !dir.dir_exists(save_directory):
		dir.make_dir_recursive(save_directory)
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "P@paB3ar6969")
	if error == OK:
		file.store_var(data)
		file.close()
		
func loadData():
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, "P@paB3ar6969")
		if error == OK:
			var data_file = file.get_var()
			file.close()
			if "position" in data_file:
				translation = data_file["position"]

			if "health" in data_file:
				stats.health = data_file["health"]
			if "max_health" in data_file:
				stats.max_health = data_file["max_health"]


			if "skillbar.rect_position" in data_file:
				skillbar.rect_position = data_file["skillbar.rect_position"]
			if "skill_bar_mode" in data_file:
				skill_bar_mode = data_file["skill_bar_mode"]
			if "ui_color" in data_file:
				ui_color = data_file["ui_color"]
			if "ui_color2" in data_file:
				ui_color2 = data_file["ui_color2"]


			if "shifting_ui_colors" in data_file:
				shifting_ui_colors = data_file["shifting_ui_colors"]
			if "shifting_ui_colors2" in data_file:
				shifting_ui_colors2 = data_file["shifting_ui_colors2"]
				
func saveInventoryData():
	# Call savedata() function on each child of inventory_grid that belongs to the group "Inventory"
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.get_node("Icon").has_method("saveData"):
				child.get_node("Icon").saveData()
#Graphic interface__________________________________________________________________________________
onready var entity_graphic_interface:Control = $UI/EnemyUI
onready var entity_ui_tween:Tween = $UI/EnemyUI/Tween
onready var entity_health_bar:TextureProgress = $UI/EnemyUI/ProgressBar
onready var entity_health_label:Label =  $UI/EnemyUI/HPLabel
onready var entity_ae_bar:TextureProgress = $UI/GUI/EnemyUI/AE
onready var entity_ae_label:Label =$UI/GUI/EnemyUI/AE/AElab

onready var entity_ne_bar:TextureProgress = $UI/GUI/EnemyUI/NE
onready var entity_ne_label:Label = $UI/GUI/EnemyUI/NE/NElab
onready var entity_re_bar:TextureProgress = $UI/GUI/EnemyUI/RE
onready var entity_re_label:Label = $UI/GUI/EnemyUI/RE/RElab

onready var entity_frontdef_label:Label = $UI/EnemyUI/FrontDefLabel
onready var entity_flankdef_label:Label = $UI/EnemyUI/FlankDefLabel
onready var entity_backdef_label:Label = $UI/EnemyUI/BackDefLabel

onready var ray:RayCast = $CameraRoot/Horizontal/Vertical/Camera/Aim

onready var entity_pos_label:Label =  $UI/EnemyUI/Position
var fade_duration: float = 0.3


onready var threat_label:Label = $UI/EnemyUI/ThreatLabel
var stored_victim:KinematicBody = null
var time_to_show_store_victim:int = 0

func showEnemyStats()-> void:
	if stored_victim != null and time_to_show_store_victim > 0:
		var body =  stored_victim
		if Engine.get_physics_frames() % 3 == 0:# Again this is here only to reduce the refresh rate and boost performance 
			entity_graphic_interface.modulate.a = 1.0
			entity_health_bar.value =stored_victim.stats.health
			entity_health_bar.max_value = stored_victim.stats.max_health
			entity_health_label.text = "HP:" + str(round(stored_victim.stats.health* 100) / 100) + "/" + str(stored_victim.stats.max_health)
			var rounded_position = Vector3(
				round(stored_victim.global_transform.origin.x * 10) / 10,
				round(stored_victim.global_transform.origin.y * 10) / 10,
				round(stored_victim.global_transform.origin.z * 10) / 10
			)
			var coordinates:String = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]
			entity_pos_label.text = coordinates
			showEntityIntel(body)
			
			if stored_victim.has_method("displayThreatInfo"):
				stored_victim.displayThreatInfo(threat_label)
			else:
				threat_label.text = ""
		if Engine.get_physics_frames() % 24 == 0:
			if time_to_show_store_victim > 0:
				time_to_show_store_victim -= 1
			else:
				entity_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				entity_ui_tween.start()
	else:
		if ray.is_colliding():
			var body = ray.get_collider()
			if body != null:
				if body != self:
					if body.is_in_group("Entity") and body != self:
						# Instantly turn alpha to maximum
						entity_graphic_interface.modulate.a = 1.0
						entity_health_bar.value = body.stats.health
						entity_health_bar.max_value = body.stats.max_health
						entity_health_label.text = "HP:" + str(round(body.stats.health* 100) / 100) + "/" + str(body.stats.max_health)
						var rounded_position = Vector3(
							round(body.global_transform.origin.x * 10) / 10,
							round(body.global_transform.origin.y * 10) / 10,
							round(body.global_transform.origin.z * 10) / 10
						)
						var coordinates:String = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]
						entity_pos_label.text = coordinates
						
						showEntityIntel(body)
						
						if body.has_method("displayThreatInfo"):
							body.displayThreatInfo(threat_label)
						else:
							threat_label.text = ""
					else:
						# Start tween to fade out
						entity_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
						entity_ui_tween.start()
				else:
					# Start tween to fade out
					entity_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
					entity_ui_tween.start()
			else:
				# Start tween to fade out
				entity_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0,fade_duration/3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				entity_ui_tween.start()
 

func showEntityIntel(body)-> void:#show this if the playe has enough perception or other stats, players will be able to see these enemy info just by looking at them 
	entity_frontdef_label.text ="front defense: "+ str(body.stats.front_defense)
	entity_flankdef_label.text ="flank defense: "+ str(body.stats.flank_defense)
	entity_backdef_label.text ="back defense: "+ str(body.stats.back_defense)
	
	


#simple pick up and throw code, with a few considerations, thrown objects can glitch thru the floor if spammed
#avoid it by increasing the floor collisions layers and masks...you've got 64 of them in total, use them. 
#the thrown object moves using the same movement code in the player's func movement()
#just make sure to add some vertical velocity to the object right before throwing, else nothind bad is going to happen
#it just works better in third person this way. 


var carried_body: KinematicBody = null
var hold_offset: Vector3 = Vector3(0,1.516,0.585)
var throw_force: float = 25.0 # Adjust the throw force as needed
var max_pickup_distance: float = 2.5 # Maximum distance to allow picking up objects
onready var detector_area:Area = $DirectionControl/DetectorArea
func LiftAndThrow() -> void:
	# don't just use if carried_body:.... check if it's actually not null otherwise you risk crashes when players spam or do some other stupid stuff
	if carried_body != null: 
		var throw_direction = (carried_body.global_transform.origin - camera.global_transform.origin).normalized()
		if Input.is_action_just_pressed("Lclick"):
			carried_body.vertical_velocity = Vector3.UP * 0.3
			carried_body.move_and_slide(throw_direction * throw_force)
			carried_body.direction = throw_direction
			carried_body.thrown = true
			carried_body.thrower = self
			carried_body = null
		if Input.is_action_just_pressed("pickup"):
			carried_body.set_collision_layer(1) 
			carried_body.set_collision_mask(1) 
			carried_body = null

	else:
		var bodies = detector_area.get_overlapping_bodies()
		for body in bodies:
			if Input.is_action_just_pressed("pickup"):
				if body and body != self and body.is_in_group("Liftable"):
					var distance_to_body = body.global_transform.origin.distance_to(global_transform.origin)
					if distance_to_body <= max_pickup_distance:
						body.thrower = self
						body.set_collision_layer(1) 
						body.set_collision_mask(1) 
						carried_body = body
						if body.is_in_group("Entity"):
							body.is_being_held = true
						
func carryObject() -> void:
	if carried_body != null:
		carried_body.set_collision_layer(6) 
		carried_body.set_collision_mask(6) 
		# Calculate the forward vector from direction_control
		var forward_vector = direction_control.global_transform.basis.z

		# Set the position of carried_body
		carried_body.translation = direction_control.global_transform.origin + forward_vector * hold_offset.z + Vector3(0, hold_offset.y, 0)
		
		# Set the rotation of carried_body to match direction_control
		carried_body.rotation = direction_control.rotation

	if garrote_victim != null:
		garrote_victim.set_collision_layer(6) 
		garrote_victim.set_collision_mask(6) 

		# Calculate the forward vector from direction_control
		var forward_vector = direction_control.global_transform.basis.z
		var right_vector = direction_control.global_transform.basis.x  # Right direction

		# Set the position of garrote_victim
		var desired_distance = 0.4  # Adjust the desired distance as needed
		var side_offset = -0.2  # Adjust the side offset as needed

		# Apply the forward and side offsets
		garrote_victim.translation = direction_control.global_transform.origin + forward_vector * desired_distance + right_vector * side_offset + Vector3(0, 0, 0)
		
		# Set the rotation of garrote_victim to match direction_control
		garrote_victim.rotation = direction_control.rotation




var garrote_victim: KinematicBody = null
var garrote_offset: Vector3 = Vector3(0,1.516,0.585)
func garroteTarget() -> void:
	if garrote_victim == null:
		var bodies = detector_area.get_overlapping_bodies()
		for body in bodies:
			if body and body != self and body.is_in_group("Entity"):
				if body.stats.health > 0:
					if isFacingSelf(body, 0.5):
						body.set_collision_layer(1) 
						body.set_collision_mask(1) 
						garrote_victim = body
						garrote_victim.garroted = true
						if body != garrote_victim:
							body.garroted = false
						return  # Exit the function once a victim is found




func switchWeaponFromHandToSideOrBack():
	pass






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
					#pullEnemy(distance, body, 0.5 + (distance * 0.01))
			
			
				# @Ceisri 
				# Managed to make this work, except sometimes the hook pulls the player thru collisions
				# not gonna bother with it for now, the function is found at "res://scripts/DeprecatedScripts/GrapplingHook.gd"
				#else:
					#pullPlayer((distance * 0.01),(distance * 0.01))



func switchButtonTextures()->void:
	var button= $UI/GUI/SkillBar/BaseAtkMode
	var new_texture_path = "res://Game button Autoload/hold_to_atk.png" if hold_to_base_atk else "res://Game button icons/click_to_atk.png"
	var new_texture = load(new_texture_path)
	button.texture_normal = new_texture
	
	var button1= $UI/GUI/SkillBar/SkillQueue
	var new_texture_path1 = "res://Game button icons/start_skill_queue.png" if skills.queue_skills else "res://Game button icons/stop_skil_queue.png"
	var new_texture1 = load(new_texture_path1)
	button1.texture_normal = new_texture1



#____________________________________GRAPHICAL INTERFACE AND SETTINGS_______________________________
onready var patternL:TextureRect = $Canvas/Skillbar/PatternL
onready var patternR:TextureRect =  $Canvas/Skillbar/PatternR
onready var patternL2:TextureRect = $Canvas/Skillbar/PatternL2
onready var patternR2:TextureRect =   $Canvas/Skillbar/PatternR2

onready var keybinds_button:TextureButton = $Canvas/Menu/Keybinds
onready var rgb_button:TextureButton =  $Canvas/Menu/RGBButton
onready var color_ui_button:TextureButton = $Canvas/Menu/ColorUIButton
onready var exit_button:TextureButton = $Canvas/Menu/ExitGameButton
onready var close_button:TextureButton = $Canvas/Menu/CloseButton
onready var skillbar_background:TextureRect = $Canvas/Skillbar/Background
onready var icon_background:TextureRect = $Canvas/Skillbar/icon_bg
onready var icon_background2:TextureRect = $Canvas/Skillbar/icon_bg2
onready var icon_background3:TextureRect = $Canvas/Skillbar/icon_bg3
onready var icon_background4:TextureRect = $Canvas/Skillbar/icon_bg4
onready var icon_background5:TextureRect = $Canvas/Skillbar/icon_bg5
onready var icon_background6:TextureRect = $Canvas/Skillbar/icon_bg6
onready var icon_background7:TextureRect = $Canvas/Skillbar/icon_bg7

onready var icon_background8:TextureRect = $Canvas/Skillbar/UI_list/icon_bg
onready var icon_background9:TextureRect = $Canvas/Skillbar/UI_list/icon_bg2
onready var icon_background10:TextureRect = $Canvas/Skillbar/UI_list/icon_bg3
onready var icon_background11:TextureRect = $Canvas/Skillbar/UI_list/icon_bg4
onready var icon_background12:TextureRect = $Canvas/Skillbar/UI_list/icon_bg5
onready var icon_background13:TextureRect = $Canvas/Skillbar/icon_bg6
onready var skills_bg:TextureRect = $Canvas/Skills/Backgrund
onready var patternSL:TextureRect = $Canvas/Skills/PatternL
onready var patternSL2:TextureRect = $Canvas/Skills/PatternL2
onready var patternSR:TextureRect = $Canvas/Skills/PatternR
onready var patternSR2:TextureRect = $Canvas/Skills/PatternR2

onready var patternIL:TextureRect = $Canvas/Inventory/PatternL
onready var patternIR:TextureRect = $Canvas/Inventory/PatternR
onready var inventory_bg:TextureRect = $Canvas/Inventory/Backgrund




func colorInterfaceBGPatterns(color)-> void:
	keybinds_button.modulate = color
	rgb_button.modulate = color
	color_ui_button.modulate = color
	exit_button.modulate = color
	close_button.modulate = color
	skillbar_background.modulate = color
	icon_background.modulate = color
	skills_bg.modulate = color
	inventory_bg.modulate = color

onready var frame:TextureRect = $Canvas/Menu/Frame
onready var frame2:TextureRect = $Canvas/Menu/Frame2
onready var frame3:TextureRect = $Canvas/Menu/Frame3
onready var frame4:TextureRect = $Canvas/Menu/Frame4
onready var frame5:TextureRect = $Canvas/Menu/Frame5
onready var frame6:TextureRect = $Canvas/Menu/Frame6
onready var frame7:NinePatchRect = $Canvas/Skillbar/Frame
onready var frame8:TextureRect = $Canvas/Skillbar/ENBarFrame
onready var frame9:TextureRect = $Canvas/Skillbar/HPBarFrame
onready var frame10:TextureRect = $Canvas/Skills/CloseSkills/Frame

onready var sett_button:TextureButton = $Canvas/Skillbar/Settings
onready var skillbar_visi_button:TextureButton = $Canvas/Skillbar/SkillBarVisibility
onready var help_button:TextureButton = $Canvas/Skillbar/HelpButton
onready var info_button:TextureButton = $Canvas/Skillbar/InfoButton
onready var bug_button:TextureButton = $Canvas/Skillbar/BugButton
onready var edit_skill_keybinds_button:TextureButton = $Canvas/Skillbar/EditSkillbarKeybinds
onready var skill_button:TextureButton = $Canvas/Skillbar/UI_list/SkillsButton
onready var quest_button:TextureButton = $Canvas/Skillbar/UI_list/QuestsButton
onready var char_button:TextureButton = $Canvas/Skillbar/UI_list/CharacterButton
onready var loot_button:TextureButton = $Canvas/Skillbar/UI_list/LootButton
onready var inv_button:TextureButton = $Canvas/Skillbar/UI_list/InvButton
onready var open_ui_button:TextureButton = $Canvas/Skillbar/OpenUIButton
onready var drag_ui_button:TextureButton = $Canvas/Skillbar/DragUI
onready var frameS1:TextureRect = $Canvas/Skills/Frame1
onready var frameS2:TextureRect = $Canvas/Skills/Frame2
onready var frameS3:TextureRect = $Canvas/Skills/Frame3
onready var frameI:TextureRect = $Canvas/Inventory/Frame
onready var cls_skills_icon:TextureButton = $Canvas/Skills/CloseSkills

onready var classes_grid:GridContainer = $Canvas/Skills/ClassList/GridContainer
onready var profess_grid:GridContainer = $Canvas/Skills/ProfessionList/GridContainer


func colorInterfaceFrames(color)-> void:
	frame.modulate = color
	frame2.modulate = color
	frame3.modulate = color
	frame4.modulate = color
	frame5.modulate = color
	frame6.modulate = color
	frame7.modulate = color
	frame8.modulate = color
	frame9.modulate = color
	frame.modulate = color

	frameS1.modulate = color
	frameS2.modulate = color
	frameS3.modulate = color
	
	frameI.modulate = color
	
	cls_skills_icon.modulate = color

	sett_button.modulate = color
	skillbar_visi_button.modulate = color
	help_button.modulate = color
	info_button.modulate = color
	bug_button.modulate = color
	edit_skill_keybinds_button.modulate = color
	
	skill_button.modulate = color
	quest_button.modulate = color
	char_button.modulate = color
	loot_button.modulate = color
	inv_button.modulate = color
	open_ui_button.modulate = color
	drag_ui_button.modulate = color
	close_inv.modulate = color
	
	patternSL.modulate = color
	patternSL2.modulate = color
	patternSR.modulate = color
	patternSR2.modulate = color
	patternL.modulate = color
	patternR.modulate = color
	patternL2.modulate = color
	patternR2.modulate = color
	patternIL.modulate = color
	patternIR.modulate = color
	
	split_selected.modulate = color
	combine_selected.modulate = color
	stack_up_selected.modulate = color
	order_slots.modulate = color
	order_down_slots.modulate = color
	
	for child in classes_grid.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in profess_grid.get_children():
		child.get_node("SkillFrame").modulate = color
	
var ui_color = Color(1, 1, 1, 1) # Default to white
# Function to update UI colors based on color
func colorUI(color: Color)-> void:
	colorInterfaceBGPatterns(color)
	ui_color = color
	
var ui_color2 = Color(1, 1, 1, 1) # Default to white
func colorUI2(color: Color)-> void:
	colorInterfaceFrames(color)
	ui_color2 = color


var shifting_ui_colors: bool = false
var shifting_ui_colors2: bool = false
var button_press_state: int = 0

func _on_RGBButton_pressed()-> void:
	button_press_state += 1
	
	if button_press_state == 1:
		shifting_ui_colors = true
		shifting_ui_colors2 = true
	elif button_press_state == 2:
		shifting_ui_colors = true
		shifting_ui_colors2 = false
	elif button_press_state == 3:
		shifting_ui_colors = false
		shifting_ui_colors2 = false
		button_press_state = 0  # Reset state to cycle again

func uiColorShift() -> void:
	var color = ui_color
	if shifting_ui_colors == true:
		var time = OS.get_ticks_msec() / 1000.0
		var r = 0.5 + 0.5 * sin(time)
		var g = 0.5 + 0.5 * sin(time + PI / 3)
		var b = 0.5 + 0.5 * sin(time + 2 * PI / 3)
		color = Color(r, g, b)
		colorInterfaceBGPatterns(color)
	else:
		colorUI(ui_color)
	var color2 = ui_color2
	if shifting_ui_colors2 == true:
		var time = OS.get_ticks_msec() / 1000.0
		# Calculate the opposite color based on the first color's RGB values
		var r2 = 1.0 - (0.5 + 0.5 * sin(time))
		var g2 = 1.0 - (0.5 + 0.5 * sin(time + PI / 3))
		var b2 = 1.0 - (0.5 + 0.5 * sin(time + 2 * PI / 3))
		color2 = Color(r2, g2, b2)
		colorInterfaceFrames(color2)
	else:
		colorUI2(ui_color2)
# Handle color change event from the color picker
func _on_UIColorPicker_color_changed(color)-> void:
	colorUI(color)


func _on_UIColorPicker2_color_changed(color)-> void:
	colorUI2(color)

		
onready var gui_color_picker = $Canvas/Menu/UIColorPicker
onready var gui_color_picker2 = $Canvas/Menu/UIColorPicker2
func _on_ColorUIButton_pressed()-> void:
	gui_color_picker.visible  = !gui_color_picker.visible 
	gui_color_picker2.visible  = !gui_color_picker2.visible 



onready var menu:Control = $Canvas/Menu
func _on_Settings_pressed()-> void:
	menu.visible = !menu.visible
func _on_LootButton_pressed():
	loot.visible = !loot.visible


func _on_InvButton_pressed():
	inventory.visible = !inventory.visible


func _on_CloseButton_pressed()-> void:
	menu.visible = false
	
func _on_ExitGameButton_pressed()-> void:
	get_tree().quit()






var skill_bar_mode: String = "normal"

func _on_SkillBarVisibility_pressed()-> void:
	if skill_bar_mode == "normal":
		skill_bar_mode = "partial"
	elif skill_bar_mode == "partial":
		skill_bar_mode = "invisible"
	elif skill_bar_mode == "invisible":
		skill_bar_mode = "minimal"
	elif skill_bar_mode == "minimal":
		skill_bar_mode = "frame"
	elif skill_bar_mode == "frame":
		skill_bar_mode = "background"
	else:
		skill_bar_mode = "normal"

	update_visibility()

func update_visibility()-> void:
	if skill_bar_mode == "normal":
		frame7.visible = true
		skillbar_background.visible = true
		patternL.visible = true
		patternR.visible = true
		patternL2.visible = true
		patternR2.visible = true
	elif skill_bar_mode == "partial":
		frame7.visible = false
		skillbar_background.visible = true
		patternL.visible = true
		patternR.visible = true
		patternL2.visible = true
		patternR2.visible = true
	elif skill_bar_mode == "invisible":
		frame7.visible = false
		skillbar_background.visible = false
		patternL.visible = false
		patternR.visible = false
		patternL2.visible = false
		patternR2.visible = false
	elif skill_bar_mode == "minimal":
		frame7.visible = true
		skillbar_background.visible = true
		patternL.visible = false
		patternR.visible = false
		patternL2.visible = false
		patternR2.visible = false
	elif skill_bar_mode == "frame":
		frame7.visible = true
		skillbar_background.visible = false
		patternL.visible = false
		patternR.visible = false
		patternL2.visible = false
		patternR2.visible = false
	elif skill_bar_mode == "background":
		frame7.visible = false
		skillbar_background.visible = true
		patternL.visible = false
		patternR.visible = false
		patternL2.visible = false
		patternR2.visible = false
	


onready var skillbar:Control = $Canvas/Skillbar
onready var UI_list:Control = $Canvas/Skillbar/UI_list
func _on_OpenUIButton_pressed():
	UI_list.visible = !UI_list.visible 

onready var health_bar:TextureProgress = $Canvas/Skillbar/HPBar
onready var health_label:Label = $Canvas/Skillbar/HPlabel
func ResourceBarsLabels()-> void:
	health_bar.value = stats.health
	health_bar.max_value = stats.max_health
	health_label.text = "HP: "+ str(round(stats.health * 100/100)) + "/" + str(round(stats.max_health * 100/100))
	
	
onready var skills_professions:Control = $Canvas/Skills

func _on_CloseSkills_pressed():
	skills_professions.visible = false


func _on_SkillsButton_pressed():
	skills_professions.visible = !skills_professions.visible

func _on_BugButton_pressed():
	debug.visible = !debug.visible


func _on_GiveMeItems_pressed():
	Autoload.addStackableItem(inventory_grid,Icons.red_potion,100)
	Autoload.addStackableItem(inventory_grid,Icons.empty_potion,100)

func setInventoryOwner()->void:
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			child.get_node("Icon").player = self 

onready var split_selected:TextureButton = $Canvas/Inventory/SplitSelected
onready var combine_selected:TextureButton = $Canvas/Inventory/CombineSelected
onready var stack_up_selected:TextureButton = $Canvas/Inventory/StackUP
onready var order_slots:TextureButton = $Canvas/Inventory/OrderSlots
onready var order_down_slots:TextureButton = $Canvas/Inventory/OrderDownSlots
onready var close_inv:TextureButton = $Canvas/Inventory/CloseInventory
func connectInventoryButtons():
	split_selected.connect("pressed", self, "splitSelectedSlot")
	combine_selected.connect("pressed", self, "combineSelectedSlot")
	stack_up_selected.connect("pressed", self, "stackUP")
	order_slots.connect("pressed", self, "orderSlots")
	order_down_slots.connect("pressed", self, "orderDownSlots")
	close_inv.connect("pressed", self, "closeInv")
	
	#combine_slots_button.connect("pressed", self, "combineSlots")
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var index_str = child.get_name().split("InvSlot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "inventorySlotPressed", [index])
			child.connect("mouse_entered", self, "inventoryMouseEntered", [index])
			child.connect("mouse_exited", self, "inventoryMouseExited", [index])
			
			
var last_pressed_index: int = -1
var last_press_time: float = 0.0
var double_press_time_inv: float = 0.4
func inventorySlotPressed(index)->void:
	displaySlotsLabel()
	var button = inventory_grid.get_node("InvSlot" + str(index))
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture
	if icon_texture != null:
#		if icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
#				button.quantity = 0
		var current_time = OS.get_ticks_msec() / 1000.0
		if last_pressed_index == index and current_time - last_press_time <= double_press_time_inv:
			print("Inventory slot", index, "pressed twice")
			if icon_texture.get_path() == Icons.red_potion.get_path():
				if stats.health  < stats.max_health:
					Autoload.consumeRedPotion(self,button,inventory_grid,false,null)
				if stats.health >= stats.max_health:
					stats.health = stats.max_health


		else:
			print("Inventory slot", index, "pressed once")
		last_pressed_index = index
		debug.last_pressed_button = index
		last_press_time = current_time
		# Set the selected slot to the button that was just pressed
		selected_slot = button
		debug.selected_slot = index
		
		
var selected_slot:TextureButton = null
func splitSelectedSlot()->void:
	displaySlotsLabel()
	if selected_slot != null:
		debug.selected_slot = selected_slot
		var selected_icon = selected_slot.get_node("Icon")
		if selected_icon.texture != null:
			var original_quantity = selected_slot.quantity
			if original_quantity > 1:
				for child in inventory_grid.get_children():
					if child.is_in_group("Inventory"):
						var icon = child.get_node("Icon")
						if icon.texture == null:
							icon.texture = selected_icon.texture
							child.quantity += original_quantity / 2
							var new_quantity = original_quantity / 2  # Calculate the new quantity
							selected_slot.quantity = original_quantity - new_quantity  # Update the quantity of the first slot
							break


func combineSelectedSlot()->void:
	displaySlotsLabel()
	if selected_slot != null:
		debug.selected_slot = selected_slot
		var selected_icon = selected_slot.get_node("Icon")
		if selected_icon.texture != null:
			for child in inventory_grid.get_children():
				if child.is_in_group("Inventory") and child != selected_slot:
					var icon = child.get_node("Icon")
					if icon.texture == selected_icon.texture:
						selected_slot.quantity += child.quantity  # Add the quantities
						child.quantity = 0  # Reset the quantity of the combined slot
						icon.texture = null  # Clear the texture of the combined slot


func orderSlots() -> void:
	var slots_with_texture = []
	var slots_without_texture = []

	# Separate slots based on their icon texture
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var icon_texture = child.get_node("Icon").texture
			if icon_texture != null:
				slots_with_texture.append(child)
			else:
				slots_without_texture.append(child)

	# Reorder slots so that slots with texture come first
	var ordered_slots = []
	ordered_slots += slots_with_texture
	ordered_slots += slots_without_texture

	# Reposition the slots in the inventory_grid
	for i in range(ordered_slots.size()):
		var slot = ordered_slots[i]
		inventory_grid.move_child(slot, i)


func orderDownSlots()-> void:
	var slots_with_texture = []
	var slots_without_texture = []

	# Separate slots based on their icon texture
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var icon_texture = child.get_node("Icon").texture
			if icon_texture != null:
				slots_with_texture.append(child)
			else:
				slots_without_texture.append(child)

	# Reorder slots so that slots without texture come first
	var ordered_slots = []
	ordered_slots += slots_without_texture
	ordered_slots += slots_with_texture

	# Reposition the slots in the inventory_grid
	for i in range(ordered_slots.size()):
		var slot = ordered_slots[i]
		inventory_grid.move_child(slot, i)


func stackUP()->void:#Just like combineSelectedSlot but stops after one iteration,in case the player wants to combine only some stacks but not all
	if selected_slot != null:
		debug.selected_slot = selected_slot
		if selected_slot.is_in_group("Inventory"):
			var selected_icon = selected_slot.get_node("Icon")
			if selected_icon.texture != null:
				for child in inventory_grid.get_children():
					if child.is_in_group("Inventory") and child != selected_slot:
						var icon = child.get_node("Icon")
						if icon.texture == selected_icon.texture:
							selected_slot.quantity += child.quantity  # Add the quantities
							child.quantity = 0  # Reset the quantity of the combined slot
							icon.texture = null  # Clear the texture of the combined slot
							break


func combineSlots()->void:
	var combined_items = {}  # Dictionary to store combined items
# Define weapon set paths
	var not_stackable = [
		
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
			if item_path != not_stackable:
				if item_path in combined_items:
					child.quantity = combined_items[item_path]

onready var slot_label:Label = $Canvas/Inventory/SlotsLAbel
func displaySlotsLabel()-> void:
	var empty_count = 0
	var total_slots = 0

	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			total_slots += 1
			var icon_texture = child.get_node("Icon").texture
			if icon_texture == null:
				empty_count += 1
	slot_label.text = str(empty_count) + "/" + str(total_slots)
onready var inventory:Control = $Canvas/Inventory
func closeInv()-> void:
	inventory.visible = false



onready var loot:Control = $Canvas/Loot
func _on_CloseLoot_pressed():
	loot.visible = false

