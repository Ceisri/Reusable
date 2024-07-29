extends KinematicBody


onready var canvas:CanvasLayer = $Canvas
onready var stats:Node =  $Stats
onready var effects:Node = $Effects
onready var skills:Node =  $Skills
onready var debug:Control =  $Canvas/Debug
onready var skeleton:Skeleton  = null
onready var shadow:MeshInstance  = $shadow

onready var name_label:Label3D = $Name
onready var popup_viewport:Viewport = $Canvas/Skillbar/AddFloatingDamageHere/Viewport

export var save_data_password:String = "Nicole can be kind of a dick, especially on the last days of August of 2022"
var username: String
var entity_name:String 
var species:String = "Human"

var is_player:bool = true 
var online_mode:bool = true
var is_in_combat:bool = false


var weapon_type = Autoload.weapon_type_list.fist
var genes
var stored_attacker:Node = null
var character = null

onready var inventory_grid:GridContainer = $Canvas/Inventory/ScrollContainer/GridContainer
func _ready() -> void:
	initializeSkillbarSlots()
	loadTouchInputIcons()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	loading_screen.visible = true
	character = direction_control.get_node("Character")
	skeleton = direction_control.get_node("Character").get_node("Armature").get_node("Skeleton")
	loadData()
	loadInventorySlots()
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
	loot.visible  = false
	debug.visible  = false
	skills_civilian.visible  = false
	inventory.visible  = false
	connectInventoryButtons()
	connectSkillBarButtons()
	connectMenuButtons()
	connectShopButtons()
	connectAreas()
	action_history[OS.get_ticks_msec()] = active_action


	target_mode_control.visible = !keybinds_settings.visible
	target_mode_control.visible = !gui_color_picker2.visible
	

onready var loading_screen:TextureRect = $Canvas/LoadingScreen
onready var load_time_label:Label = $Canvas/LoadingScreen/LooadTimeLabel
onready var random_info_label:Label = $Canvas/LoadingScreen/RandomInfo
var loading_time:float = 1.0

func loadingScreen() -> void:
	var percentage_complete = ((100.0 - loading_time) / 100.0) * 100
	load_time_label.text = str(round(percentage_complete * 100) / 100.0) + "%"
	loading_time -= rand_range(0.25, 1.75)
	if loading_time <= 0:
		loading_screen.visible = false



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
	skillBarInputs()
	if debug.visible:
		$Label2.visible = true
		$Label2.text = "previous: " + previous_action
	else:
		$Label2.visible = false
	gravity()
	climbStairs()
	climb()
	mouseMode()
	rotateMesh()
	movement(delta)
	camera_rotation()
	InputsInterface()
	LiftAndThrow()
	carryObject()
	behaviourTree()
	doublePressToDash()
	skills.updateCooldownLabel()
	skills.comboSystem()
	#laserRayForTesting()
	manualTargetAssit()
	openShop()
	if Input.is_action_just_pressed("harvest"):
		harvestGather()
	if Engine.get_physics_frames() % 2 == 0:
		minimapFollowPlayer()
	if Engine.get_physics_frames() % 3 == 0:
		showEnemyStats()
		uiColorShift()
	if Engine.get_physics_frames() % 4 == 0:
		if loading_time > 0:
			loadingScreen()
	if Engine.get_physics_frames() % 6 == 0:
		ResourceBarsLabels()
		effects.showStatusIcon(
	$Canvas/Skillbar/StatusGrid/Icon1,
	$Canvas/Skillbar/StatusGrid/Icon2,
	$Canvas/Skillbar/StatusGrid/Icon3,
	$Canvas/Skillbar/StatusGrid/Icon4,
	$Canvas/Skillbar/StatusGrid/Icon5,
	$Canvas/Skillbar/StatusGrid/Icon6,
	$Canvas/Skillbar/StatusGrid/Icon7,
	$Canvas/Skillbar/StatusGrid/Icon8,
	$Canvas/Skillbar/StatusGrid/Icon9,
	$Canvas/Skillbar/StatusGrid/Icon10,
	$Canvas/Skillbar/StatusGrid/Icon11,
	$Canvas/Skillbar/StatusGrid/Icon12,
	$Canvas/Skillbar/StatusGrid/Icon13,
	$Canvas/Skillbar/StatusGrid/Icon14,
	$Canvas/Skillbar/StatusGrid/Icon15,
	$Canvas/Skillbar/StatusGrid/Icon16,
	$Canvas/Skillbar/StatusGrid/Icon17,
	$Canvas/Skillbar/StatusGrid/Icon18,
	$Canvas/Skillbar/StatusGrid/Icon19,
	$Canvas/Skillbar/StatusGrid/Icon20,
	$Canvas/Skillbar/StatusGrid/Icon21,
	$Canvas/Skillbar/StatusGrid/Icon22,
	$Canvas/Skillbar/StatusGrid/Icon23,
	$Canvas/Skillbar/StatusGrid/Icon24)
	if Engine.get_physics_frames() % 12 == 0:
		if debug.visible:
			$Label.visible = true
			laserRayForTesting()
			$Label.text = active_action
		else:
			$Label.visible = false
	if Engine.get_physics_frames() % 24 == 0:
		effects.effectManager()
	if Engine.get_physics_frames() % 28 == 0:
		if Input:
			displaySlotsLabel()
			displayClock()

	if Engine.get_physics_frames() % 100 == 0:
		if loading_time >0:
			Autoload.randomizeInfo(random_info_label)
		#getLoot(Items.blue_tip_grass,1,rand_range(0,100),"blue tip grass") #testing only

 
func _process(delta:float) -> void:
	var current_time = OS.get_ticks_msec()
	# Cleanup old entries from the action_history
	for timestamp in action_history.keys():
		if current_time - timestamp > 500: # 250 ms = 0.25 seconds
			action_history.erase(timestamp)
	
	# Update previous_action if we have a timestamp older than 0.25 seconds
	if action_history.size() > 0:
		var sorted_keys = action_history.keys()
		sorted_keys.sort()
		previous_action = action_history[sorted_keys[0]]
	else:
		previous_action = active_action
		
	shadow.rotateShadow()
	shadow.moveShadow()
	
	
var active_action:String = "none"
var previous_action:String
var action_history:Dictionary = {}

onready var animation:AnimationPlayer =  $DirectionControl/Character/AnimationPlayer
func firstLevelAnimations()-> void:
	if is_instance_valid(animation):
		if !is_on_floor():
			if active_action == "flip":
				animation.play("flip")
			else:
				if !is_on_wall():
					if movement_mode != "climb":
						if carried_body == null:
							animation.play("fall")
		elif moving:
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
				if crawling:
					animation.play("crawl idle",blend)
				elif crouching:
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
			if moving:
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
		if knockeddown:
			clearParryAbsorb()
			if stats.health <= 0 :
				knockeddown = false
				staggered = false
			if parry:
				knockeddown = false
				staggered = false
			elif absorbing:
				knockeddown = false
			else:
				can_walk = false
				moving = false
				horizontal_velocity = direction * 0
				#genes.can_move = false
				if stats.health > 15:
					animation.play("knocked down",blend)
					#skill.getInterrupted()

		elif staggered:
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
var dying:bool = false
var dead:bool = false
var staggered:bool = false
var knockeddown:bool = false
var parry:bool= false
var absorbing:bool = false
var attacking:bool = false
var is_dead:bool = false





func activeActions()->void:
	inputCancel()
	if Input.is_action_pressed("Rclick"):
		switchWeaponFromHandToSideOrBack()
		TargetAssist()
		skills.skillCancel("throw_rock")

	if active_action == "dash":
		directionToCamera()
		TargetAssist()
		moveTowardsDirection(skills.backstep_distance)
		animation.play("dash",0.3,1.25)
		
	elif active_action ==  "garrote":
		can_walk = false
		directionToCamera()
		moveTowardsDirection(1)
		garroteTarget()
		animation.play("garrote",0.3,1)
		skills.skillCancel("garrote")

	elif active_action == "silent stab":
		can_walk = true
		directionToCamera()
		TargetAssist()
		moveTowardsDirection(1)
		animation.play("punch",0.3,stats.melee_atk_speed)
		skills.skillCancel("silent stab")

	elif active_action == "lighting":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("lighting")
		
	elif active_action == "icicle scatter shot":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("icicle scatter shot")
		
	elif active_action == "arcane bolt":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("arcane bolt")
		
	elif active_action == "fireball":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,15)
		skills.skillCancel("fireball")

	elif active_action == "triple fireball":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("triple fireball")

	elif active_action == "immolate":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("immolate")

	elif active_action == "ring of fire":
		TargetAssist()
		can_walk = false
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("ring of fire")

	elif active_action == "wall of fire":
		TargetAssist()
		can_walk = false
		moveTowardsDirection(0)
		direction = -camera.global_transform.basis.z
		animation.play("quick shot",0.3,stats.melee_atk_speed)
		skills.skillCancel("wall of fire")
		

		
	elif active_action == "slide":
		TargetAssist()
		direction = -camera.global_transform.basis.z
		moveTowardsDirection(skills.backstep_distance)
		animation.play("slide",blend)

	elif active_action == "backstep":
		directionToCamera()
		moveTowardsDirection(-skills.backstep_distance)
		animation.play("backstep",blend,1)
		directionToCamera()
		clearParryAbsorb()
		animation.play("kick",blend,stats.agility)
		moveTowardsDirection(0)
	else:
		skillState()
		can_walk = true

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
			"RClick":
				var slot = $Canvas/Skillbar/GridContainer/SlotRClick/Icon
				skills(slot)
			"LClick":
				var slot = $Canvas/Skillbar/GridContainer/SlotLClick/Icon
				skills(slot)
			"TouchSkill1":
				var slot = $Canvas/TouchScreen/Skill1/TochScreen1/Icon
				skills(slot)
			"TouchSkill2":
				var slot = $Canvas/TouchScreen/Skill2/TochScreen2/Icon
				skills(slot)
			"TouchSkill3":
				var slot = $Canvas/TouchScreen/Skill3/TochScreen3/Icon
				skills(slot)
			"TouchSkill4":
				var slot = $Canvas/TouchScreen/Skill4/TochScreen4/Icon
				skills(slot)
			"TouchSkill5":
				var slot = $Canvas/TouchScreen/Skill5/TochScreen5/Icon
				skills(slot)
			"TouchSkill6":
				var slot = $Canvas/TouchScreen/Skill6/TochScreen6/Icon
				skills(slot)
			"TouchSkill7":
				var slot = $Canvas/TouchScreen/Skill7/TochScreen7/Icon
				skills(slot)
			"TouchSkill8":
				var slot = $Canvas/TouchScreen/Skill8/TochScreen8/Icon
				skills(slot)
			"TouchSkill9":
				var slot = $Canvas/TouchScreen/Skill9/TochScreen9/Icon
				skills(slot)
			"TouchATK":
				var slot = $Canvas/TouchScreen/BaseATK/IconBaseATK
				skills(slot)

func inputCancel()-> void:
	if can_input_cancel == true:
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


onready var l_click_slot = $Canvas/Skillbar/GridContainer/SlotLClick
onready var r_click_slot = $Canvas/Skillbar/GridContainer/SlotRClick

func skills(slot)-> void:
	if slot == null:
		pass
	else:
		if slot.texture != null:
			if slot.texture.resource_path == Icons.garrote.get_path():
				if slot.get_parent().get_node("CD").text != "":
					active_action = "none"
					returnToIdleBasedOnWeaponType()
				else:#This is needed to avoid bugs where holding the button ignores the cooldown once cause a double use of the skill
					if previous_action != "garrote":
						active_action = "garrote"
						skills.skillCancel("garrote")
					else:returnToIdleBasedOnWeaponType()
					
			if slot.texture.resource_path == Icons.grab.get_path():
					harvestGather()
			if slot.texture.resource_path == Icons.silent_stab.get_path():
				if slot.get_parent().get_node("CD").text != "":
					active_action = "none"
					returnToIdleBasedOnWeaponType()
				else:#This is needed to avoid bugs where holding the button ignores the cooldown once cause a double use of the skill
					if previous_action != "silent stab":
						active_action = "silent stab"
						skills.skillCancel("silent stab")
					else:returnToIdleBasedOnWeaponType()
					
			if slot.texture.resource_path == Icons.switch_element.get_path():
				if slot.get_parent().get_node("CD").text == "":
					skills.SwitchElementCD()
					l_click_slot.switchAttackIcon(self)
					$Canvas/TouchScreen/BaseATK.switchAttackIcon(self)

			if slot.texture.resource_path == Icons.lighting_shot.get_path():
				active_action = "lighting"
				
			if slot.texture.resource_path == Icons.fireball.get_path():
				active_action = "fireball"
				skills.skillCancel("fireball")
				
			if slot.texture.resource_path == Icons.icile_scatter_shot.get_path():
				active_action = "icicle scatter shot"
				skills.skillCancel("icicle scatter shot")

			if slot.texture.resource_path == Icons.arcane_bolt.get_path():
				active_action = "arcane bolt"
				skills.skillCancel("arcane bolt")


			if slot.texture.resource_path == Icons.triple_fireball.get_path():
				if slot.get_parent().get_node("CD").text != "":
					active_action = "none"
					returnToIdleBasedOnWeaponType()
				else:#This is needed to avoid bugs where holding the button ignores the cooldown once cause a double use of the skill
					if previous_action != "triple fireball":
						active_action = "triple fireball"
						skills.skillCancel("triple fireball")
					else:returnToIdleBasedOnWeaponType()

			if slot.texture.resource_path == Icons.immolate.get_path():
				if slot.get_parent().get_node("CD").text != "":
					active_action = "none"
					returnToIdleBasedOnWeaponType()
				else:#This is needed to avoid bugs where holding the button ignores the cooldown once cause a double use of the skill
					if previous_action != "immolate":
						active_action = "immolate"
						skills.skillCancel("immolate")
					else:returnToIdleBasedOnWeaponType()

			if slot.texture.resource_path == Icons.ring_of_fire.get_path():
				if slot.get_parent().get_node("CD").text != "":
					active_action = "none"
					returnToIdleBasedOnWeaponType()
				else:#This is needed to avoid bugs where holding the button ignores the cooldown once cause a double use of the skill
					if previous_action != "ring of fire":
						active_action = "ring of fire"
						skills.skillCancel("ring of fire")
					else:returnToIdleBasedOnWeaponType()

			if slot.texture.resource_path == Icons.wall_of_fire.get_path():
				if slot.get_parent().get_node("CD").text != "":
					active_action = "none"
					returnToIdleBasedOnWeaponType()
				else:#This is needed to avoid bugs where holding the button ignores the cooldown once cause a double use of the skill
					if previous_action != "wall of fire":
						active_action = "wall of fire"
						skills.skillCancel("wall of fire")
					else:returnToIdleBasedOnWeaponType()

##consumables________________________________________________________________________________________
			elif slot.texture.resource_path == Items.apothecary_list["red_potion"]["icon"].get_path():
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

			else:
				returnToIdleBasedOnWeaponType()

func baseAtkAnim()-> void:
	match weapon_type:
		Autoload.weapon_type_list.fist:
			if long_base_atk:
				animation.play("punch",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("punch",blend,stats.melee_atk_speed)
		Autoload.weapon_type_list.sword:
			if long_base_atk:
				animation.play("combo sword",blend,stats.melee_atk_speed + skills.combo_extr_speed)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("cleave sword",blend,stats.melee_atk_speed)
				moveTowardsDirection(skills.cleave_distance)
		Autoload.weapon_type_list.dual_swords:
			var dual_wield_compensation:float = 1.105 #People have the feeling that two swords should be faster, not realistic, but it breaks their "game feel" 
			if long_base_atk:
				animation.play("combo(dual)",blend,stats.melee_atk_speed + skills.combo_extr_speed * dual_wield_compensation)
				moveTowardsDirection(skills.combo_distance)
			else:
				animation.play("cleave dual",blend,stats.melee_atk_speed * dual_wield_compensation)
				moveTowardsDirection(skills.cleave_distance)
		Autoload.weapon_type_list.heavy:
			if long_base_atk:
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
#_______________________________________________Combat______________________________________________
#simple pick up and throw code, with a few considerations, thrown objects can glitch thru the floor if spammed
#avoid it by increasing the floor collisions layers and masks...you've got 64 of them in total, use them. 
#the thrown object moves using the same movement player's movement code
#just make sure to add some vertical velocity to the object right before throwing, else nothind bad is going to happen
#it just works better in third person this way. 
var carried_body: KinematicBody = null
var hold_offset: Vector3 = Vector3(0,1.516,0.585)
var throw_force: float = 25.0 # Adjust the throw force as needed
var max_pickup_distance: float = 2.5 # Maximum distance to allow picking up objects
onready var detector_area:Area = $DirectionControl/DetectorArea
func LiftAndThrow() -> void:
	#this prevents a bug that I can't care to fix where where the player walks inside the object 
	#before lifting it and ends up lifting itself up in the air infinitely togheter with the object
	if moving == false: 
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
				carried_body.thrown = false
				carried_body.thrower = null
				if carried_body.is_in_group("Entity"):
					carried_body.is_being_held = false
				carried_body = null
		else:
			var bodies = detector_area.get_overlapping_bodies()
			for body in bodies:
				if Input.is_action_just_pressed("pickup"):
					if body and body != self and body.is_in_group("Liftable"):
						var distance_to_body = body.global_transform.origin.distance_to(global_transform.origin)
						if distance_to_body <= max_pickup_distance:
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

#If the enemy model is not using mixamo and has normal rotation use this
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
#else use that 
#	if garrote_victim != null:
#		garrote_victim.set_collision_layer(6) 
#		garrote_victim.set_collision_mask(6) 
#
#		# Calculate the forward vector from direction_control
#		var forward_vector = direction_control.global_transform.basis.z
#		var right_vector = direction_control.global_transform.basis.x  # Right direction
#
#		# Set the position of garrote_victim
#		var desired_distance = 0.4  # Adjust the desired distance as needed
#		var side_offset = -0.2  # Adjust the side offset as needed
#
#		# Apply the forward and side offsets
#		garrote_victim.translation = direction_control.global_transform.origin + forward_vector * desired_distance + right_vector * side_offset + Vector3(0, 0, 0)
#
#		# Set the rotation of garrote_victim to match direction_control, inverted
#		garrote_victim.rotation.y = direction_control.rotation.y + PI  # Rotate 180 degrees around Y axis
#		garrote_victim.rotation.x = -direction_control.rotation.x  # Invert X rotation
#		garrote_victim.rotation.z = -direction_control.rotation.z  # Invert Z rotation

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

onready var hook_ray:RayCast = $CameraRoot/Horizontal/Vertical/Camera/Aim/hook_ray
onready var hook_mesh:MeshInstance = $CameraRoot/Horizontal/Vertical/Camera/Aim/hook
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

func laserRayForTesting() -> void:
	if Input.is_action_pressed("Lclick"):
		if ray.is_colliding():
			var body = ray.get_collider()
			if body != null:
				if body != self:
					if body.is_in_group("Entity"):
						body.stats.getHit(self,rand_range(5,15),Autoload.damage_type.cold,15,rand_range(0,5))
						body.get_node("Effects").bleed_duration = 5
	
"""
@Ceisri
Documentation String: 
	rotateTowardsEnemy() is a very simple and straight forward function that finds the closest entity in the entire game 
	and rtoates the player towards that entity when the function is called, the rotation is done using direction 
	the variable direction_assist is not going to be used directly in rotateTowardsEnemy() but inside all attacks. 
	if enabled, all attacks will automatically call automaticTargetAssist()
"""

#Force the player to look at the enemy, optional
var stored_victim:KinematicBody = null
func rotateTowardsEnemy() -> void:
	match target_mode:
		"Lowest Health":
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
					if distance < closest_distance and entity.get_node("Stats").health > 0:
						targets_in_range.append(entity)
			# Find the target with the lowest health or closest distance if health is the same
			for target in targets_in_range:
				if closest_target == null:
					closest_target = target
				elif target.get_node("Stats").health < closest_target.get_node("Stats").health:
					closest_target = target
				elif target.get_node("Stats").health == closest_target.get_node("Stats").health:
					var distance_to_target = global_transform.origin.distance_to(target.global_transform.origin)
					var distance_to_closest = global_transform.origin.distance_to(closest_target.global_transform.origin)
					if distance_to_target < distance_to_closest:
						closest_target = target
			# Set direction towards the target with the lowest health or closest distance
			if closest_target:
				direction = (closest_target.global_transform.origin - global_transform.origin).normalized()
		"Last Hit":
			if stored_victim:
				var distance = global_transform.origin.distance_to(stored_victim.global_transform.origin)
				if distance < 20.0 and stored_victim.get_node("Stats").health > 0:
					direction = (stored_victim.global_transform.origin - global_transform.origin).normalized()
		"Attacker":
			if stored_attacker:
				var distance = global_transform.origin.distance_to(stored_attacker.global_transform.origin)
				if distance < 20.0 and stored_attacker.get_node("Stats").health > 0:
					direction = (stored_attacker.global_transform.origin - global_transform.origin).normalized()


	
func manualTargetAssit() -> void:
	if Input.is_action_pressed("LockOn"):
		rotateTowardsEnemy()
func TargetAssist() ->void:
	if direction_assist:
		rotateTowardsEnemy()


#___________________________________________________________________________________________________
#Movement and physics
var gravity_force: float = 20
func gravity()->void:
	if gravity_active:
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
var sneak_toggle:bool = true
var crouching:bool = false
var crawling:bool = false

onready var upper_collision:CollisionShape = $UpperCollision
onready var middle_collision:CollisionShape = $MidCollision
var can_walk:bool = false
var press_count = 0
var auto_run:String = "still"
#Movement section___________________________________________________________________________________
func movement(delta: float) -> void:
	var h_rot = camera_v.global_transform.basis.get_euler().y
	movement_speed = 0.0
	moving = false

	var input_direction = Vector3(
		Input.get_action_strength("Left") - Input.get_action_strength("Right"),
		0,
		Input.get_action_strength("Front") - Input.get_action_strength("Back")
	)
	if can_walk:
		if active_action != "garrote":
			if input_direction.length() > 0:
				direction = input_direction.rotated(Vector3.UP, h_rot).normalized()
				moving = true
				movement_speed = walk_speed
			elif joystick_active:
				direction = -joystick_direction.rotated(Vector3.UP, h_rot).normalized()
				moving = true
				movement_speed = walk_speed

	if moving:
		if carried_body == null:
			if Input.is_action_pressed("Sprint"):
				debug.active_action = "sprinting"
				is_in_combat = false
				movement_speed = sprint_speed
				movement_mode = "sprint"
				if sprint_speed < max_sprint_speed:
					sprint_speed += 0.005 * stats.agility
				elif sprint_speed > max_sprint_speed:
					sprint_speed = max_sprint_speed
			elif Input.is_action_pressed("Run"):
				debug.active_action = "running"
				sprint_speed = default_sprint_speed
				movement_mode = "run"
				movement_speed = run_speed
			elif crouching:
				debug.active_action = "sneaking"
				sprint_speed = default_sprint_speed
				movement_mode = "sneak"
				movement_speed = walk_speed * 0.5
			elif auto_run == "sprint":
				debug.active_action = "sprinting"
				is_in_combat = false
				movement_speed = sprint_speed
				movement_mode = "sprint"
				if sprint_speed < max_sprint_speed:
					sprint_speed += 0.005 * stats.agility
				elif sprint_speed > max_sprint_speed:
					sprint_speed = max_sprint_speed
			elif auto_run == "run":
				debug.active_action = "running"
				sprint_speed = default_sprint_speed
				movement_mode = "run"
				movement_speed = run_speed
			elif crawling:
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

	if sneak_toggle == false:
		if Input.is_action_pressed("Crouch"):
			crouching = true
		else:
			crouching = false
		if Input.is_action_pressed("Crawl"):
			crawling = true
		else:
			crawling = false
	else:
		if Input.is_action_just_pressed("Crouch"):
			press_count = (press_count + 1) % 3
			if press_count == 0:
				crouching = false
				crawling = false
			elif press_count == 1:
				crouching = true
				crawling = false
			elif press_count == 2:
				crouching = false
				crawling = true

	if jump_count < 1:
		if carried_body == null:
			if is_on_floor():
				if crouching or crawling:
					if Input.is_action_just_pressed("Jump"):
						crouching = false
						crawling = false
				else:
					if Input.is_action_just_pressed("Jump"):
						debug.active_action = "jumping"
						jump_count += 1
						vertical_velocity = Vector3.UP * jump_strength
			else:
				if Input.is_action_just_pressed("Jump"):
					debug.active_action = "double jumping"
					jump_count += 1
					vertical_velocity = Vector3.UP * jump_strength
					active_action = "flip"

	movementCollisions()
	if is_on_floor():
		jump_count = 0
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)



func _on_Run_pressed():
	match auto_run:
		"still":
			auto_run = "run"
		"run":
			auto_run = "sprint"
		"sprint":
			auto_run = "still"



# These are connected from the joystick multidirectional addon 
func _on_joystick_multidirectionnal_update_pos(pos):
	joystick_direction = Vector3(pos.x, 0, pos.y).normalized()
	joystick_active = true

func _on_joystick_multidirectionnal_stop_update_pos(pos):
	joystick_active = false
	joystick_direction = Vector3()



func movementCollisions()-> void:
	if crawling:
		middle_collision.disabled = true
		upper_collision.disabled = true
	elif crouching:
		middle_collision.disabled = false
		upper_collision.disabled = true
	else:
		middle_collision.disabled = false
		upper_collision.disabled = false


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
	pass
#	if backstep_duration or frontstep_duration or leftstep_duration or rightstep_duration or dash_active:
#		set_collision_layer(6) 
#		set_collision_mask(6) 
#	else:
#		set_collision_layer(1) 
#		set_collision_mask(1)   
		
func doublePressToDash()-> void:
	if stats.resolve >= skills.dash_cost:
		if dash_countback > 0:
			dash_timerback += get_physics_process_delta_time()
		if dash_timerback >= double_press_time:
			dash_countback = 0
			dash_timerback = 0.0
		if Input.is_action_just_pressed("Back"):
			dash_countback += 1
		if dash_countback == 2 and dash_timerback < double_press_time:
			active_action = "dash"
			stats.resolve -= skills.dash_cost

		if dash_countforward > 0:
			dash_timerforward += get_physics_process_delta_time()
		if dash_timerforward >= double_press_time:
			dash_countforward = 0
			dash_timerforward = 0.0
		if Input.is_action_just_pressed("Front"):
			dash_countforward += 1
		if dash_countforward == 2 and dash_timerforward < double_press_time:
			active_action = "dash"
			stats.resolve -= skills.dash_cost

		if dash_countleft > 0:
			dash_timerleft += get_physics_process_delta_time()
		if dash_timerleft >= double_press_time:
			dash_countleft = 0
			dash_timerleft = 0.0
		if Input.is_action_just_pressed("Left"):
			dash_countleft += 1
		if dash_countleft == 2 and dash_timerleft < double_press_time:
			active_action = "dash"
			stats.resolve -= skills.dash_cost

		if dash_countright > 0:
			dash_timerright += get_physics_process_delta_time()
		if dash_timerright >= double_press_time:
			dash_countright = 0
			dash_timerright = 0.0
		if Input.is_action_just_pressed("Right"):
			dash_countright += 1
		if dash_countright == 2 and dash_timerright < double_press_time :
			active_action = "dash"
			stats.resolve -= skills.dash_cost


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
				if moving and not Input.is_action_pressed("Sprint") and not Input.is_action_pressed("Run") and not Input.is_action_pressed("Crouch")and not Input.is_action_pressed("Crawl"):
					gravity_active = false
					checkWallInclination()
					active_action = "none"
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
		if can_move:
			horizontal_velocity = direction * speed 



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
	if !cursor_visible:
		# Adjust the camera's position based on the zoom direction
		camera.translation.y += zoom_direction * zoom_speed
		camera.translation.z -= zoom_direction * (zoom_speed * 2)
func camera_rotation() -> void:
	if !cursor_visible:
		camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
		camera_h.rotation_degrees.y = lerp(camera_h.rotation_degrees.y, camrot_h, get_physics_process_delta_time() * h_acceleration)
		camera_v.rotation_degrees.x = lerp(camera_v.rotation_degrees.x, camrot_v, get_physics_process_delta_time() * v_acceleration)
func unstuck() -> void:
	translation = Vector3(0,15, 0)


#Minimap____________________________________________________________________________________________
onready var minimap_camera:Camera = $Canvas/MinimapHolder/ViewportContainer/Viewport/Camera
func minimapFollowPlayer() -> void:
	var player_position = global_transform.origin
	var height_above_player = 10.0 # Adjust this value as needed
	minimap_camera.global_transform.origin = Vector3(player_position.x, player_position.y + height_above_player, player_position.z)
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
	var direction_node = body.get_node("DirectionControl")
	
	if direction_node:
		facing_direction = direction_node.global_transform.basis.z.normalized()
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
		skills_civilian.visible = !skills_civilian.visible

	if  Input.is_action_just_pressed("Inventory"):
		inventory.visible = !inventory.visible

	if  Input.is_action_just_pressed("Loot"):
		loot.visible = !loot.visible


var can_input_cancel:bool = true 
var skill_bar_input:String = "none"
func skillBarInputs():
	if Input.is_action_just_pressed("1"):
		skill_bar_input = "1"
	elif Input.is_action_just_pressed("2"):
		skill_bar_input = "2"
	elif Input.is_action_just_pressed("3"):
		skill_bar_input = "3"
	elif Input.is_action_just_pressed("4"):
		skill_bar_input = "4"
	elif Input.is_action_just_pressed("5"):
		skill_bar_input = "5"
	elif Input.is_action_just_pressed("6"):
		skill_bar_input = "6"
	elif Input.is_action_just_pressed("7"):
		skill_bar_input = "7"
	elif Input.is_action_just_pressed("8"):
		skill_bar_input = "8"
	elif Input.is_action_just_pressed("9"):
		skill_bar_input = "9"
	elif Input.is_action_just_pressed("0"):
		skill_bar_input = "0"
	elif Input.is_action_just_pressed("Q"):
		skill_bar_input = "Q"
	elif Input.is_action_just_pressed("E"):
		skill_bar_input = "E"
	elif Input.is_action_just_pressed("Z"):
		skill_bar_input = "Z"
	elif Input.is_action_just_pressed("X"):
		skill_bar_input = "X"
	elif Input.is_action_just_pressed("C"):
		skill_bar_input = "C"
	elif Input.is_action_just_pressed("R"):
		skill_bar_input = "R"
	elif Input.is_action_just_pressed("F"):
		skill_bar_input = "F"
	elif Input.is_action_just_pressed("T"):
		skill_bar_input = "T"
	elif Input.is_action_just_pressed("V"):
		skill_bar_input = "V"
	elif Input.is_action_just_pressed("G"):
		skill_bar_input = "G"
	elif Input.is_action_just_pressed("B"):
		skill_bar_input = "B"
	elif Input.is_action_just_pressed("Y"):
		skill_bar_input = "Y"
	elif Input.is_action_just_pressed("H"):
		skill_bar_input = "H"
	elif Input.is_action_just_pressed("N"):
		skill_bar_input = "N"
	elif Input.is_action_just_pressed("F1"):
		skill_bar_input = "F1"
	elif Input.is_action_just_pressed("F2"):
		skill_bar_input = "F2"
	elif Input.is_action_just_pressed("F3"):
		skill_bar_input = "F3"
	elif Input.is_action_just_pressed("F4"):
		skill_bar_input = "F4"
	elif Input.is_action_just_pressed("F5"):
		skill_bar_input = "F5"
		
	elif Input.is_action_pressed("TouchSkill1"):
		skill_bar_input = "TouchSkill1"
	elif Input.is_action_pressed("TouchSkill2"):
		skill_bar_input = "TouchSkill2"
	elif Input.is_action_pressed("TouchSkill3"):
		skill_bar_input = "TouchSkill3"
	elif Input.is_action_pressed("TouchSkill4"):
		skill_bar_input = "TouchSkill4"
	elif Input.is_action_pressed("TouchSkill5"):
		skill_bar_input = "TouchSkill5"
	elif Input.is_action_pressed("TouchSkill6"):
		skill_bar_input = "TouchSkill6"
	elif Input.is_action_pressed("TouchSkill7"):
		skill_bar_input = "TouchSkill7"
	elif Input.is_action_pressed("TouchSkill8"):
		skill_bar_input = "TouchSkill8"
	elif Input.is_action_pressed("TouchSkill9"):
		skill_bar_input = "TouchSkill9"
		
		
	elif Input.is_action_pressed("TouchATK"):
		skill_bar_input = "TouchATK"
		
	elif Input.is_action_pressed("Lclick"):
		if !cursor_visible:
			skill_bar_input = "LClick"
	elif Input.is_action_pressed("Rclick"):
		if !cursor_visible:
			skill_bar_input = "RClick"
			
	else:
		skill_bar_input = "none"







var long_base_atk:bool = false
func _on_baseatkswitch_pressed():
	long_base_atk = !long_base_atk


#SaveGame___________________________________________________________________________________________
func saveGame()->void:
	for entity in get_tree().get_nodes_in_group("Entity"):
		if entity.has_method("saveData"):
			entity.saveData()
		
	for node in Root.get_children():
		if node.has_method("saveData"):
			node.saveData()
		elif node.has_node("Plant"):
			node.get_node("Plant").saveData()

	for node in get_parent().get_children():
		if node.has_method("saveData"):
			node.saveData()
		elif node.has_node("Plant"):
			node.get_node("Plant").saveData()
			
	for node in $Canvas/Skillbar/GridContainer.get_children():
		if node.has_method("saveData"):
			node.saveData()
			
		if node.has_node("Icon"):
			if node.get_node("Icon").has_method("saveData"):
				node.get_node("Icon").saveData()
		
		elif node.has_node("icon"):
			debug.error_message = "icon named with lower case I, fix that " + str(node.name)
			
	for touch_input in touch_inputs.get_children():
		for child in touch_input.get_children():
			if child.has_node("Icon"):
				var icon = child.get_node("Icon")
				icon.player = self 
				icon.save_dictionary = "user://Characters/" + entity_name + "/" 
				icon.saveData()
	saveInventoryData()
	
var slot: String = "1"

func saveData():
	var save_directory = "user://Characters/" + entity_name + "/"
	var save_path: String = save_directory +  "SavedData.dat" 
	var data = {
		"position": translation,
		"health": stats.health,
		"max_health": stats.max_health,



		"can_input_cancel":can_input_cancel,
		"direction_assist":direction_assist,
		"target_mode":target_mode,
		"touch_screen_inputs.visible":touch_screen_inputs.visible,
		"skillbar.visible":skillbar.visible,



		"entity_graphic_interface.rect_position":entity_graphic_interface.rect_position,



		"entity_graphic_RU.visible":entity_graphic_RU.visible,
		"entity_graphic_LU.visible":entity_graphic_LU.visible,
		"entity_graphic_RD.visible":entity_graphic_RD.visible,
		"entity_graphic_LD.visible":entity_graphic_LD.visible,
		"joystick_inputs.visible":joystick_inputs.visible,



		"touch_inputs_label.text":touch_inputs_label.text,
		"crouch_label.text":crouch_label.text,
		"target_mode_label.text":target_mode_label.text,
		"dir_assist_label.text":dir_assist_label.text,
		"input_cancel_label.text":input_cancel_label.text,



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
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, save_data_password)
	if error == OK:
		file.store_var(data)
		file.close()
		
func loadData():
	var save_directory = "user://Characters/" + entity_name + "/"
	var save_path: String = save_directory +  "SavedData.dat" 
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, save_data_password)
		if error == OK:
			var data_file = file.get_var()
			file.close()
			if "position" in data_file:
				translation = data_file["position"]

			if "health" in data_file:
				stats.health = data_file["health"]
			if "max_health" in data_file:
				stats.max_health = data_file["max_health"]


			if "can_input_cancel" in data_file:
				can_input_cancel = data_file["can_input_cancel"]
			if "direction_assist" in data_file:
				direction_assist = data_file["direction_assist"]
			if "target_mode" in data_file:
				target_mode = data_file["target_mode"]


			if "skillbar.visible" in data_file:
				skillbar.visible = data_file["skillbar.visible"]
			if "touch_screen_inputs.visible" in data_file:
				touch_screen_inputs.visible = data_file["touch_screen_inputs.visible"]
			if "joystick_inputs.visible" in data_file:
				joystick_inputs.visible = data_file["joystick_inputs.visible"]

			if "touch_inputs_label.text" in data_file:
				touch_inputs_label.text = data_file["touch_inputs_label.text"]
			if "crouch_label.text" in data_file:
				crouch_label.text = data_file["crouch_label.text"]
			if "target_mode_label.text" in data_file:
				target_mode_label.text = data_file["target_mode_label.text"]
			if "dir_assist_label.text" in data_file:
				dir_assist_label.text = data_file["dir_assist_label.text"]
			if "input_cancel_label.text" in data_file:
				input_cancel_label.text = data_file["input_cancel_label.text"]





			if "entity_graphic_interface.rect_position" in data_file:
				entity_graphic_interface.rect_position = data_file["entity_graphic_interface.rect_position"]

			if "entity_graphic_LU.visible" in data_file:
				entity_graphic_LU.visible = data_file["entity_graphic_LU.visible"]
			if "entity_graphic_RU.visible" in data_file:
				entity_graphic_RU.visible = data_file["entity_graphic_RU.visible"]
			if "entity_graphic_LD.visible" in data_file:
				entity_graphic_LD.visible = data_file["entity_graphic_LD.visible"]
			if "entity_graphic_RD.visible" in data_file:
				entity_graphic_RD.visible = data_file["entity_graphic_RD.visible"]

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
onready var entity_graphic_interface:Control =  $Canvas/EnemyUI
onready var entity_graphic_RU:Control = $Canvas/EnemyUI/Up
onready var entity_graphic_LU:Control = $Canvas/EnemyUI/UpL

onready var entity_graphic_RD:Control = $Canvas/EnemyUI/Down
onready var entity_graphic_LD:Control = $Canvas/EnemyUI/DownL


onready var entity_ui_tween:Tween =  $Canvas/EnemyUI/Tween
onready var entity_health_bar:TextureProgress = $Canvas/EnemyUI/Up/TextureProgress
onready var entity_health_label:Label = $Canvas/EnemyUI/Up/HPlabel

onready var entity_health_bar2:TextureProgress = $Canvas/EnemyUI/UpL/TextureProgress
onready var entity_health_label2:Label = $Canvas/EnemyUI/UpL/HPlabel

onready var entity_energy_bar:TextureProgress = $Canvas/EnemyUI/Down/TextureProgress
onready var entity_energy_label:Label =  $Canvas/EnemyUI/Down/EPlabel

onready var entity_frontdef_label:Label = $UI/EnemyUI/FrontDefLabel
onready var entity_backdef_label:Label = $UI/EnemyUI/BackDefLabel

onready var ray:RayCast = $CameraRoot/Horizontal/Vertical/Camera/Aim

onready var entity_pos_label:Label = $Canvas/EnemyUI/coordinates
var fade_duration: float = 0.3


onready var threat_label:Label = $Canvas/EnemyUI/Down/ExtraIntel/ThreatList
onready var threat_label2:Label =$Canvas/EnemyUI/DownL/ExtraIntel/ThreatList
var time_to_show_stored_victim:int = 0

func showEnemyBuffsDebuffs(body)->void:
	if body == null:
		print("body dissapeared for some reason at func showEnemyBuffsDebuffs(body)")
	else:
		if $Canvas/EnemyUI/Down.visible:
			if body.has_node("Effects"):
				body.get_node("Effects").showStatusIcon(
				$Canvas/EnemyUI/Down/StatusGrid/Icon1,
				$Canvas/EnemyUI/Down/StatusGrid/Icon2,
				$Canvas/EnemyUI/Down/StatusGrid/Icon3,
				$Canvas/EnemyUI/Down/StatusGrid/Icon4,
				$Canvas/EnemyUI/Down/StatusGrid/Icon5,
				$Canvas/EnemyUI/Down/StatusGrid/Icon6,
				$Canvas/EnemyUI/Down/StatusGrid/Icon7,
				$Canvas/EnemyUI/Down/StatusGrid/Icon8,
				$Canvas/EnemyUI/Down/StatusGrid/Icon9,
				$Canvas/EnemyUI/Down/StatusGrid/Icon10,
				$Canvas/EnemyUI/Down/StatusGrid/Icon11,
				$Canvas/EnemyUI/Down/StatusGrid/Icon12,
				$Canvas/EnemyUI/Down/StatusGrid/Icon13,
				$Canvas/EnemyUI/Down/StatusGrid/Icon14,
				$Canvas/EnemyUI/Down/StatusGrid/Icon15,
				$Canvas/EnemyUI/Down/StatusGrid/Icon16,
				$Canvas/EnemyUI/Down/StatusGrid/Icon17,
				$Canvas/EnemyUI/Down/StatusGrid/Icon18,
				$Canvas/EnemyUI/Down/StatusGrid/Icon19,
				$Canvas/EnemyUI/Down/StatusGrid/Icon20,
				$Canvas/EnemyUI/Down/StatusGrid/Icon21,
				$Canvas/EnemyUI/Down/StatusGrid/Icon22,
				$Canvas/EnemyUI/Down/StatusGrid/Icon23,
				$Canvas/EnemyUI/Down/StatusGrid/Icon24)
		
		if $Canvas/EnemyUI/DownL.visible:
			if body.has_node("Effects"):
				body.get_node("Effects").showStatusIcon(
				$Canvas/EnemyUI/DownL/StatusGrid/Icon1,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon2,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon3,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon4,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon5,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon6,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon7,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon8,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon9,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon10,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon11,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon12,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon13,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon14,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon15,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon16,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon17,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon18,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon19,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon20,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon21,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon22,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon23,
				$Canvas/EnemyUI/DownL/StatusGrid/Icon24)

func updateEnemyBarsLabels(body)-> void:
	entity_health_bar.value =body.stats.health
	entity_health_bar.max_value =body.stats.max_health
	entity_health_label.text = "HP:" + str(round(body.stats.health* 100) / 100) + "/" + str(body.stats.max_health)
	entity_health_bar2.value =body.stats.health
	entity_health_bar2.max_value =body.stats.max_health
	entity_health_label2.text = "HP:" + str(round(body.stats.health* 100) / 100) + "/" + str(body.stats.max_health)
	var rounded_position = Vector3(
		round(body.global_transform.origin.x * 10) / 10,
		round(body.global_transform.origin.y * 10) / 10,
		round(body.global_transform.origin.z * 10) / 10
	)
	var coordinates:String = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]
	entity_pos_label.text = coordinates	

onready var entity_res_slash:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Slash/label
onready var entity_res_blunt:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Blunt/label
onready var entity_res_pierce:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Pierce/label
onready var entity_res_sonic:Label =$Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Sonic/label
onready var entity_res_heat:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Heat/label
onready var entity_res_cold:Label =$Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Cold/label
onready var entity_res_jolt:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Jolt/label
onready var entity_res_toxic:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Toxic/label
onready var entity_res_acid:Label =$Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Acid/label
onready var entity_res_arcane:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Arcane/label
onready var entity_res_bleed:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Bleed/label
onready var entity_res_radiant:Label = $Canvas/EnemyUI/Down/ExtraIntel/ScrollContainer/GridContainer/Radiant/label

onready var entity_res_slash2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Slash/label
onready var entity_res_blunt2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Blunt/label
onready var entity_res_pierce2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Pierce/label
onready var entity_res_sonic2:Label =$Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Sonic/label
onready var entity_res_heat2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Heat/label
onready var entity_res_cold2:Label =$Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Cold/label
onready var entity_res_jolt2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Jolt/label
onready var entity_res_toxic2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Toxic/label
onready var entity_res_acid2:Label =$Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Acid/label
onready var entity_res_arcane2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Arcane/label
onready var entity_res_bleed2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Bleed/label
onready var entity_res_radiant2:Label = $Canvas/EnemyUI/DownL/ExtraIntel/ScrollContainer/GridContainer/Radiant/label

onready var entity_level:Label = $Canvas/EnemyUI/Up/LVL
onready var entity_level2:Label =$Canvas/EnemyUI/UpL/LVL

onready var entity_species:Label = $Canvas/EnemyUI/Down/Species
onready var entity_species2:Label = $Canvas/EnemyUI/DownL/Species
onready var entity_name_label:Label = $Canvas/EnemyUI/Name

onready var entity_str_label:Label = $Canvas/EnemyUI/Down/Strlbl
onready var entity_str_label2:Label = $Canvas/EnemyUI/DownL/Strlbl
onready var entity_int_label:Label = $Canvas/EnemyUI/Down/IntLbl
onready var entity_int_label2:Label = $Canvas/EnemyUI/DownL/IntLbl

onready var entity_defl_label:Label = $Canvas/EnemyUI/Down/DeflectLbl
onready var entity_defl_label2:Label = $Canvas/EnemyUI/DownL/DeflectLbl

onready var entity_speed_label:Label =  $Canvas/EnemyUI/Down/Speedbl
onready var entity_speed_label2:Label =  $Canvas/EnemyUI/DownL/Speedbl


func showEntityIntel(body)-> void:#show this if the player has enough perception or other stats, players will be able to see these enemy info just by looking at them 
	var enemy_stats = body.get_node("Stats")
	if body.entity_name != null:
		entity_name_label.text = str(body.entity_name)
	if entity_graphic_RU.visible:
		if body.has_method("displayThreatInfo"):
			body.displayThreatInfo(threat_label)
		else:
			threat_label.text = ""
		entity_species.text = "Species: " + str(body.species)
		entity_level.text = "level: " +  str(body.stats.level)
		
		entity_str_label.text = str(enemy_stats.strength)
		entity_int_label.text = str(enemy_stats.intelligence)
		entity_defl_label.text = str(enemy_stats.deflect_chance)
		entity_speed_label.text = str(enemy_stats.speed)
		
		entity_res_slash.text = str(enemy_stats.slash_resistance)
		entity_res_blunt.text = str(enemy_stats.blunt_resistance)
		entity_res_pierce.text = str(enemy_stats.pierce_resistance)
		entity_res_sonic.text = str(enemy_stats.sonic_resistance)
		entity_res_heat.text = str(enemy_stats.heat_resistance)
		entity_res_cold.text = str(enemy_stats.cold_resistance)
		entity_res_jolt.text = str(enemy_stats.jolt_resistance)
		entity_res_toxic.text = str(enemy_stats.toxic_resistance)
		entity_res_acid.text = str(enemy_stats.acid_resistance)
		entity_res_arcane.text = str(enemy_stats.arcane_resistance)
		entity_res_bleed.text = str(enemy_stats.bleed_resistance)
		entity_res_radiant.text = str(enemy_stats.radiant_resistance)

	if entity_graphic_LU.visible:
		if body.has_method("displayThreatInfo"):
			body.displayThreatInfo(threat_label2)
		else:
			threat_label.text = ""
		entity_species2.text = "Species: " + str(body.species)
		entity_level2.text = "level: " +  str(body.stats.level)
		
		entity_str_label2.text = str(enemy_stats.strength)
		entity_int_label2.text = str(enemy_stats.intelligence)
		entity_defl_label2.text = str(enemy_stats.deflect_chance)
		entity_speed_label2.text = str(enemy_stats.speed)
		
		entity_res_slash2.text = str(enemy_stats.slash_resistance)
		entity_res_blunt2.text = str(enemy_stats.blunt_resistance)
		entity_res_pierce2.text = str(enemy_stats.pierce_resistance)
		entity_res_sonic2.text = str(enemy_stats.sonic_resistance)
		entity_res_heat2.text = str(enemy_stats.heat_resistance)
		entity_res_cold2.text = str(enemy_stats.cold_resistance)
		entity_res_jolt2.text = str(enemy_stats.jolt_resistance)
		entity_res_toxic2.text = str(enemy_stats.toxic_resistance)
		entity_res_acid2.text = str(enemy_stats.acid_resistance)
		entity_res_arcane2.text = str(enemy_stats.arcane_resistance)
		entity_res_bleed2.text = str(enemy_stats.bleed_resistance)
		entity_res_radiant2.text = str(enemy_stats.radiant_resistance)
	
	
	
#	entity_frontdef_label.text ="front defense: "+ str(body.stats.front_defense)
#	entity_flankdef_label.text ="flank defense: "+ str(body.stats.flank_defense)
#	entity_backdef_label.text ="back defense: "+ str(body.stats.back_defense)

func showEnemyStats()-> void:
	if stored_victim != null and time_to_show_stored_victim > 0:
		entity_graphic_interface.modulate.a = 1.0
		showEnemyBuffsDebuffs(stored_victim)
		if Engine.get_physics_frames() % 3 == 0:# Again this is here only to reduce the refresh rate and boost performance 
			updateEnemyBarsLabels(stored_victim)
			updateEnemyBarsLabels(stored_victim)
			showEntityIntel(stored_victim)

		if Engine.get_physics_frames() % 24 == 0:
			if time_to_show_stored_victim > 0:
				time_to_show_stored_victim -= 1
			else:
				entity_ui_tween.interpolate_property(entity_graphic_interface, "modulate:a", entity_graphic_interface.modulate.a, 0.0, fade_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
				entity_ui_tween.start()
	else:
		if ray.is_colliding():
			var body = ray.get_collider()
			if body != null:
				if body != self:
					if body.is_in_group("Entity") and body != self:
						entity_graphic_interface.modulate.a = 1.0
						showEnemyBuffsDebuffs(body)
						updateEnemyBarsLabels(body)
						updateEnemyBarsLabels(body)
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



func switchWeaponFromHandToSideOrBack():
	pass


func switchButtonTextures()->void:
	var button= $UI/GUI/SkillBar/BaseAtkMode
	var new_texture_path = "res://Game button Autoload/hold_to_atk.png" if hold_to_base_atk else "res://Game button icons/click_to_atk.png"
	var new_texture = load(new_texture_path)
	button.texture_normal = new_texture
	
	var button1= $UI/GUI/SkillBar/SkillQueue
	var new_texture_path1 = "res://Game button icons/start_skill_queue.png" if can_input_cancel else "res://Game button icons/stop_skil_queue.png"
	var new_texture1 = load(new_texture_path1)
	button1.texture_normal = new_texture1



#____________________________________GRAPHICAL INTERFACE AND SETTINGS_______________________________



#Skill tree, classes and civilian section
onready var knight:Control = $Canvas/Skills/Knight
onready var assasin:Control = $Canvas/Skills/Assasin
onready var scout:Control = $Canvas/Skills/Scout
onready var elementalist:Control = $Canvas/Skills/Elementalist
onready var commoner:Control = $Canvas/Skills/Commoner




func _on_Knight_pressed():
	showSkillTreeHideOters(knight)

func _on_Assasin_pressed():
	showSkillTreeHideOters(assasin)

func _on_Scout_pressed():
	showSkillTreeHideOters(scout)
	
func _on_Elementalist_pressed():
	showSkillTreeHideOters(elementalist)

func showSkillTreeHideOters(skill_tree_to_show):
	var skill_trees = [knight, assasin, scout,elementalist]
	for tree in skill_trees:
		tree.visible = false
	skill_tree_to_show.visible = true


onready var patternL:TextureRect = $Canvas/Skillbar/PatternL
onready var patternR:TextureRect =  $Canvas/Skillbar/PatternR
onready var patternL2:TextureRect = $Canvas/Skillbar/PatternL2
onready var patternR2:TextureRect =   $Canvas/Skillbar/PatternR2


onready var skillbar_background:TextureRect = $Canvas/Skillbar/Background
onready var icon_background:TextureRect = $Canvas/Skillbar/icon_bg

onready var patternSL:TextureRect = $Canvas/Skills/PatternL
onready var patternSL2:TextureRect = $Canvas/Skills/PatternL2
onready var patternSR:TextureRect = $Canvas/Skills/PatternR
onready var patternSR2:TextureRect = $Canvas/Skills/PatternR2

onready var patternIL:TextureRect = $Canvas/Inventory/PatternL
onready var patternIR:TextureRect = $Canvas/Inventory/PatternR
onready var inventory_bg:TextureRect = $Canvas/Inventory/Backgrund
onready var loot_bg:TextureRect = $Canvas/Loot/Backgrund

onready var menu_button_bg1:TextureRect = $Canvas/Menu/TargetAssist/bg
onready var menu_button_bg2:TextureRect = $Canvas/Menu/TargetAssistMode/bg
onready var menu_button_bg3:TextureRect = $Canvas/Menu/ExitGame/bg
onready var menu_button_bg4:TextureRect = $Canvas/Menu/CloseMenu/bg
onready var menu_button_bg5:TextureRect = $Canvas/Menu/Keybinds/bg
onready var menu_button_bg6:TextureRect = $Canvas/Menu/SneakTogle/bg
onready var menu_button_bg7:TextureRect = $Canvas/Menu/ShiftingColors/bg
onready var menu_button_bg8:TextureRect = $Canvas/Menu/OpenInterfaceColorPicker/bg


func colorInterfaceBG(color)-> void:
	skillbar_background.modulate = color
	icon_background.modulate = color
	menu_button_bg1.modulate = color
	menu_button_bg2.modulate = color
	menu_button_bg3.modulate = color
	menu_button_bg4.modulate = color
	menu_button_bg5.modulate = color
	menu_button_bg6.modulate = color
	menu_button_bg7.modulate = color
	menu_button_bg8.modulate = color
	
	for child in menu.get_children():
		if child.has_node("bg"):
			child.get_node("bg").modulate = color
	for child in keybinds_settings.get_children():
		if child.has_node("bg"):
			child.get_node("bg").modulate = color
		
	for child in UI_list.get_children():
		child.get_node("bg").modulate = color

onready var menu_frame:TextureRect = $Canvas/Menu/Frame
onready var frame7:NinePatchRect = $Canvas/Skillbar/Frame
onready var frame8:TextureRect = $Canvas/Skillbar/EPBarFrame
onready var frame9:TextureRect = $Canvas/Skillbar/HPBarFrame

onready var sett_button:TextureButton = $Canvas/Skillbar/Settings
onready var skillbar_visi_button:TextureButton = $Canvas/Skillbar/SkillBarVisibility
onready var help_button:TextureButton = $Canvas/Skillbar/HelpButton
onready var info_button:TextureButton = $Canvas/Skillbar/InfoButton
onready var bug_button:TextureButton = $Canvas/Skillbar/BugButton
onready var edit_skill_keybinds_button:TextureButton = $Canvas/Skillbar/EditSkillbarKeybinds


onready var open_ui_button:TextureButton = $Canvas/Skillbar/OpenUIButton
onready var drag_ui_button:TextureButton = $Canvas/Skillbar/DragUI
onready var frameS1:TextureRect = $Canvas/Skills/Frame1
onready var frameS2:TextureRect = $Canvas/Skills/Frame2
onready var frameS3:TextureRect = $Canvas/Skills/Frame3
onready var frameI:TextureRect = $Canvas/Inventory/Frame
onready var frameL:TextureRect = $Canvas/Loot/Frame
onready var cls_skills_button:TextureButton = $Canvas/Skills/CloseSkills
onready var cls_loot_button:TextureButton = $Canvas/Loot/CloseLoot

onready var classes_grid:GridContainer = $Canvas/Skills/ClassList/GridContainer
onready var civilian_grid:GridContainer = $Canvas/Skills/CivilianList/GridContainer

onready var skill_button:TextureButton = $Canvas/Skillbar/UI_list/SkillsButtonHolder/button
onready var quest_button:TextureButton = $Canvas/Skillbar/UI_list/QuestsButtonHolder/button
onready var char_button:TextureButton = $Canvas/Skillbar/UI_list/CharacterButtonHolder/button
onready var loot_button:TextureButton = $Canvas/Skillbar/UI_list/LootButtonHolder/button
onready var inv_button:TextureButton = $Canvas/Skillbar/UI_list/InvButtonHolder/button
onready var map_button:TextureButton = $Canvas/Skillbar/UI_list/MapButtonHolder/button
onready var post_button:TextureButton = $Canvas/Skillbar/UI_list/PostButtonHolder/button
onready var elementalist_skill_grid:GridContainer= $Canvas/Skills/Elementalist/ElementalSkillList/ElementalSkillListGrid


func colorInterfaceFrames(color)-> void:
	menu_frame.modulate = color
	
	frame7.modulate = color
	frame8.modulate = color
	frame9.modulate = color

	frameS1.modulate = color
	frameS2.modulate = color
	frameS3.modulate = color
	
	frameI.modulate = color
	frameL.modulate = color
	
	cls_skills_button.modulate = color
	cls_loot_button.modulate = color

	sett_button.modulate = color
	skillbar_visi_button.modulate = color
	help_button.modulate = color
	info_button.modulate = color
	bug_button.modulate = color
	edit_skill_keybinds_button.modulate = color
	
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
	

	for child in keybinds_settings.get_children():
		if child.has_node("button"):
			child.get_node("button").modulate = color
	for child in menu.get_children():
		if child.has_node("button"):
			child.get_node("button").modulate = color
	for child in commoner.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in elementalist_skill_grid.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in scout.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in assasin.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in knight.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in UI_list.get_children():
		child.get_node("button").modulate = color
	for child in classes_grid.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in civilian_grid.get_children():
		child.get_node("SkillFrame").modulate = color
	for child in loot_grid.get_children():
		child.get_node("Frame").modulate = color


var ui_color = Color(1, 1, 1, 1) # Default to white
# Function to update UI colors based on color
func colorUI(color: Color)-> void:
	colorInterfaceBG(color)
	ui_color = color
	
var ui_color2 = Color(1, 1, 1, 1) # Default to white
func colorUI2(color: Color)-> void:
	colorInterfaceFrames(color)
	ui_color2 = color

onready var help_menu:Control = $Canvas/Help

#Skillbar 
func connectSkillBarButtons()->void:
	skill_button.connect("pressed", self, "openSkills")
	quest_button.connect("pressed", self, "openQeusts")
	char_button.connect("pressed", self, "openChar")
	loot_button.connect("pressed", self, "openLoot")
	inv_button.connect("pressed", self, "openInv")
	help_button.connect("pressed", self, "openHelp")
	

func _on_Settings_pressed()-> void:
	menu.visible = !menu.visible
func _on_LootButton_pressed()-> void:
	loot.visible = !loot.visible

func openHelp()-> void:
	help_menu.visible = !help_menu.visible
	popUpUI(help_menu,skillbar_tween)
	
func openSkills()-> void:
	skills_civilian.visible = !skills_civilian.visible
	popUpUI(skills_civilian,skillbar_tween)
func openInv()-> void:
	inventory.visible = !inventory.visible
	popUpUI(inventory,skillbar_tween)
func openLoot()-> void:
	loot.visible = !loot.visible
	popUpUI(loot,skillbar_tween)

var shifting_ui_colors: bool = false
var shifting_ui_colors2: bool = false
var button_press_state: int = 0

func interfaceShiftingColors()-> void:
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
	if shifting_ui_colors:
		var time = OS.get_ticks_msec() / 1000.0
		var r = 0.5 + 0.5 * sin(time)
		var g = 0.5 + 0.5 * sin(time + PI / 3)
		var b = 0.5 + 0.5 * sin(time + 2 * PI / 3)
		color = Color(r, g, b)
		colorInterfaceBG(color)
	else:
		colorUI(ui_color)
	var color2 = ui_color2
	if shifting_ui_colors2:
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


onready var menu:Control = $Canvas/Menu
onready var keybinds_settings:Control = $Canvas/Menu/KeybindEditingSection
onready var target_assist_button:TextureButton = $Canvas/Menu/TargetAssist/button
onready var target_assist_mode_button:TextureButton =  $Canvas/Menu/TargetAssistMode/button
onready var close_menu_button:TextureButton = $Canvas/Menu/CloseMenu/button
onready var exit_button:TextureButton = $Canvas/Menu/ExitGame/button
onready var open_ui_color_button:TextureButton = $Canvas/Menu/OpenInterfaceColorPicker/button
onready var rgb_button:TextureButton = $Canvas/Menu/ShiftingColors/button
onready var keybinds_button:TextureButton = $Canvas/Menu/Keybinds/button
onready var sneak_toggle_button:TextureButton = $Canvas/Menu/SneakTogle/button
onready var input_cancel_button:TextureButton = $Canvas/Menu/InputCancel/button
onready var touch_input_button:TextureButton = $Canvas/Menu/TouchInputs/button
onready var save_button:TextureButton = $Canvas/Menu/SaveGame/button
onready var unstuck_button:TextureButton = $Canvas/Menu/Unstuck/button

func connectMenuButtons()-> void:
	target_assist_button.connect("pressed", self, "targetAssistOnOff")
	target_assist_mode_button.connect("pressed", self, "targetAssistMode")
	close_menu_button.connect("pressed", self, "closeMenu")
	exit_button.connect("pressed", self, "exit")
	open_ui_color_button.connect("pressed", self, "openInterfaceColorPickers")
	rgb_button.connect("pressed", self, "interfaceShiftingColors")
	keybinds_button.connect("pressed", self, "openKeybindsSettings")
	sneak_toggle_button.connect("pressed", self, "sneakToggle")
	input_cancel_button.connect("pressed", self, "inputCancelToggle")
	touch_input_button.connect("pressed", self, "switchDesktopMobile")
	save_button.connect("pressed", self, "saveGame")
	unstuck_button.connect("pressed", self, "unstuck")


var direction_assist:bool = true # we use this in attacks to auto rotate the direction towards enemies 
onready var dir_assist_label:Label = $Canvas/Menu/TargetAssist/label
onready var target_mode_control:Control = $Canvas/Menu/TargetAssistMode
func targetAssistOnOff()-> void:
	direction_assist = !direction_assist
	if direction_assist:#remember to update this on _ready() too when changing it 
		dir_assist_label.text = "Target Assist: On" 
		target_mode_control.visible = true
	else:
		dir_assist_label.text = "Target Assist: Off" 
		target_mode_control.visible = false
var target_mode:String = "Last Hit"
onready var target_mode_label:Label = $Canvas/Menu/TargetAssistMode/label
func targetAssistMode()-> void:
	if target_mode == "Last Hit":
		target_mode = "Lowest Health"
	elif target_mode == "Lowest Health":
		target_mode = "Attacker"
	else:
		target_mode = "Last Hit"
	target_mode_label.text =  target_mode

onready var touch_screen_inputs:Control = $Canvas/TouchScreen
onready var touch_inputs_label:Label =  $Canvas/Menu/TouchInputs/label
onready var joystick_inputs:Node = $"Canvas/joystick multidirectionnal"
func switchDesktopMobile()-> void:
	skillbar.visible = !skillbar.visible
	touch_screen_inputs.visible =!touch_screen_inputs.visible
	if touch_screen_inputs.visible:
		touch_inputs_label.text = "Mobile Mode"
		entity_graphic_interface.rect_scale = Vector2(2.2,2.2)
		joystick_inputs.visible = true
	else:
		touch_inputs_label.text = "Desktop Mode"
		entity_graphic_interface.rect_scale = Vector2(1.1,1.1)
		joystick_inputs.visible = false



onready var gui_color_picker = $Canvas/Menu/UIColorPicker
onready var gui_color_picker2 = $Canvas/Menu/UIColorPicker2
func openInterfaceColorPickers()-> void:
	gui_color_picker.visible  = !gui_color_picker.visible 
	gui_color_picker2.visible  = !gui_color_picker2.visible
	target_mode_control.visible = !gui_color_picker2.visible

func openKeybindsSettings()-> void:
	keybinds_settings.visible = !keybinds_settings.visible
	target_mode_control.visible = !keybinds_settings.visible

onready var crouch_label:Label = $Canvas/Menu/SneakTogle/label
func sneakToggle() -> void:
	sneak_toggle = !sneak_toggle
	if sneak_toggle: #remember to update this on _ready() too when changing it 
		crouch_label.text =  "Crouch Toggle:On"
	else:
		crouch_label.text = "Crouch Toggle:Off"
onready var input_cancel_label:Label = $Canvas/Menu/InputCancel/label
func inputCancelToggle() -> void:
	can_input_cancel = !can_input_cancel
	if can_input_cancel:
		input_cancel_label.text = "Input Cancel:On"
	else:
		input_cancel_label.text = "Input Cancel:Off"

func closeMenu()-> void:
	menu.visible = false
func exit()-> void:
	saveGame()
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
onready var skillbar_tween:Tween = $Canvas/Skillbar/Tween
onready var UI_list:Control = $Canvas/Skillbar/UI_list
func _on_OpenUIButton_pressed():
	popUpUI(UI_list,skillbar_tween)
	UI_list.visible = !UI_list.visible 
	

onready var health_bar:TextureProgress = $Canvas/Skillbar/HPBar
onready var health_label:Label = $Canvas/Skillbar/HPlabel

func ResourceBarsLabels()-> void:
	health_bar.value = stats.health
	health_bar.max_value = stats.max_health
	health_label.text = "HP: "+ str(round(stats.health * 100/100)) + "/" + str(round(stats.max_health * 100/100))
	
	
onready var skills_civilian:Control = $Canvas/Skills

func _on_CloseSkills_pressed():
	skills_civilian.visible = false

func _on_SkillsButton_pressed():
	skills_civilian.visible = !skills_civilian.visible

func _on_BugButton_pressed():
	debug.visible = !debug.visible




#Interractions with NPCs____________________________________________________________________________
onready var shop:Control = $Canvas/Shop
onready var buy_button:TextureButton = $Canvas/Shop/Buy/button
onready var shop_grid:GridContainer = $Canvas/Shop/ScrollContainer/GridContainer
func connectShopButtons()->void:
	buy_button.connect("pressed", self, "buyItem")
	for child in $Canvas/Shop/ScrollContainer/GridContainer.get_children():
			var index_str = child.get_name().split("InvSlot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "shopSlotPressed", [index])
			child.connect("mouse_entered", self, "shopSlotEntered", [index])
			child.connect("mouse_exited", self, "inventoryMouseExited", [index])


func openShop() -> void:
	for body in detector_area.get_overlapping_bodies():
		if body.is_in_group("Vendor"):
			if Input.is_action_just_pressed("Interract"):
				shop.visible = true
				if body.is_in_group("Apothecary"):
					for item in Items.apothecary_list.values():
						Autoload.addIconToGrid(shop_grid, item["icon"])
				if body.is_in_group("Costermonger"):
					for item in Items.costermonger_list.values():
						Autoload.addIconToGrid(shop_grid, item["icon"])
				if body.is_in_group("Herbalist"):
					for item in Items.herbalist_list.values():
						Autoload.addIconToGrid(shop_grid, item["icon"])
	if moving:
		Autoload.removeIconFromGrid(shop_grid)
		shop.visible = false

func buyItem() -> void:
	var icon = selected_shop_slot.get_node("Icon")
	var icon_texture = icon.texture
	var item_name: String = "Unknown"
	var price: int = 0
	var item_icon: Texture = null
	var item_rarity: float = 0.0
	var found: bool = false

	# Check if the item is in the apothecary list
	for name in Items.apothecary_list.keys():
		if icon_texture.get_path() == Items.apothecary_list[name]["icon"].get_path():
			price = Items.apothecary_list[name]["price"]
			item_icon = Items.apothecary_list[name]["icon"]
			item_name = name
			item_rarity = Items.apothecary_list[name]["rarity"]
			found = true
			break

	# Check if the item is in the costermonger list
	if not found:
		for name in Items.costermonger_list.keys():
			if icon_texture.get_path() == Items.costermonger_list[name]["icon"].get_path():
				price = Items.costermonger_list[name]["price"]
				item_icon = Items.costermonger_list[name]["icon"]
				item_name = name
				item_rarity = Items.costermonger_list[name]["rarity"]
				found = true
				break

	# Check if the item is in the herbalist list
	if not found:
		for name in Items.herbalist_list.keys():
			if icon_texture.get_path() == Items.herbalist_list[name]["icon"].get_path():
				price = Items.herbalist_list[name]["price"]
				item_icon = Items.herbalist_list[name]["icon"]
				item_name = name
				item_rarity = Items.herbalist_list[name]["rarity"]
				found = true
				break

	if found:
		# Add the item to the inventory
		Autoload.addStackableItem(inventory_grid, item_icon, 1)
		# Assuming `getLoot` is a function that you use to handle loot, you should set the appropriate arguments
		getLoot(item_icon, 1, item_rarity, item_name)
	else:
		print("Unknown item path:", icon_texture.get_path())


	
	
	
var last_shop_pressed_index: int = -1
var selected_shop_slot: TextureButton = null
func shopSlotPressed(index) -> void:
	print("Button pressed at index:", index)

	var button = shop_grid.get_node("InvSlot" + str(index))
	if button == null:
		print("Button not found at index:", index)
		return

	var icon = button.get_node("Icon")
	if icon == null:
		print("Icon not found in button:", button.get_name())
		return

	var icon_texture = icon.texture
	if icon_texture == null:
		print("Icon texture is null in button:", button.get_name())
		return

	var price: int = 0
	var item_name: String = "Unknown"
	var found: bool = false
	
	# Check if the item is in the apothecary list
	for name in Items.apothecary_list.keys():
		if icon_texture.get_path() == Items.apothecary_list[name]["icon"].get_path():
			price = Items.apothecary_list[name]["price"]
			item_name = name
			found = true
			break
	
	# Check if the item is in the costermonger list
	if not found:
		for name in Items.costermonger_list.keys():
			if icon_texture.get_path() == Items.costermonger_list[name]["icon"].get_path():
				price = Items.costermonger_list[name]["price"]
				item_name = name
				found = true
				break
	
	# Check if the item is in the herbalist list
	if not found:
		for name in Items.herbalist_list.keys():
			if icon_texture.get_path() == Items.herbalist_list[name]["icon"].get_path():
				price = Items.herbalist_list[name]["price"]
				item_name = name
				found = true
				break

	if not found:
		print("Unknown item path:", icon_texture.get_path())
		$Canvas/Shop/Price.text = "Price: 0, Name: Unknown"
	else:
		$Canvas/Shop/Price.text = "Price: " + str(price) + ", Name: " + item_name

	# Set the selected slot to the button that was just pressed
	selected_shop_slot = button





#Inventory__________________________________________________________________________________________
func _on_GiveMeItems_pressed():
	Autoload.addStackableItem(inventory_grid,Items.apothecary_list["red_potion"]["icon"],100)
	Autoload.addStackableItem(inventory_grid,Items.apothecary_list["empty_potion"]["icon"],100)



onready var inventory_slot:PackedScene = load("res://Game/Interface/Scenes/InvSlot1.tscn")
func loadInventorySlots()-> void:
	for i in range(500):
		var new_slot = inventory_slot.instance()
		new_slot.name = "InvSlot" + str(i + 1)
		new_slot.get_node("Icon").player = self 
		new_slot.get_node("Icon").save_dictionary = "user://Characters/" + entity_name + "/" 
		inventory_grid.add_child(new_slot)


onready var skillbar_grid:GridContainer = $Canvas/Skillbar/GridContainer
func initializeSkillbarSlots()-> void:
	for child in skillbar_grid.get_children():
			child.get_node("Icon").player = self 
			child.get_node("Icon").save_dictionary = "user://Characters/" + entity_name + "/" 

onready var touch_inputs:Control = $Canvas/TouchScreen

func loadTouchInputIcons()-> void:
	for touch_input in touch_inputs.get_children():
		for child in touch_input.get_children():
			if child.has_node("Icon"):
				var icon = child.get_node("Icon")
				icon.player = self 
				icon.save_dictionary = "user://Characters/" + entity_name + "/" 
				icon.loadData()
			
onready var split_selected:TextureButton = $Canvas/Inventory/SplitSelected
onready var combine_selected:TextureButton = $Canvas/Inventory/CombineSelected
onready var stack_up_selected:TextureButton = $Canvas/Inventory/StackUP
onready var order_slots:TextureButton = $Canvas/Inventory/OrderSlots
onready var order_down_slots:TextureButton = $Canvas/Inventory/OrderDownSlots
onready var close_inv:TextureButton = $Canvas/Inventory/CloseInventory
func connectInventoryButtons()->void:
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
			if icon_texture.get_path() == Items.apothecary_list["red_potion"]["icon"].get_path():
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
			if child.stackable:
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
		total_slots += 1
		var icon_texture = child.get_node("Icon").texture
		if icon_texture == null:
			empty_count += 1
	slot_label.text = str(empty_count) + "/" + str(total_slots)
onready var inventory:Control = $Canvas/Inventory
func closeInv()-> void:
	inventory.visible = false

	
	
onready var loot_grid = $Canvas/Loot/ScrollContainer/GridContainer
onready var loot:Control = $Canvas/Loot
func _on_CloseLoot_pressed()->void:
	loot.visible = false



func _on_Trash_pressed()->void:
	for child in loot_grid.get_children():
		var icon_texture = child.get_node("Icon").texture
		icon_texture = null
		child.quantity = 0 
		

onready var time_label = $Canvas/Skillbar/Label
func displayClock()-> void:
	# Get the current date and time
	var date_time = OS.get_datetime()
	
	# Format the time string
	var formatted_time = "%02d:%02d" % [date_time.hour, date_time.minute]
	
	# Format the date string
	var formatted_date = "%02d/%02d/%d" % [date_time.day, date_time.month, date_time.year]
	
	# Update the label text with time on top and date below, align left
	time_label.text = formatted_time + "\n" + formatted_date
	

onready var tween_ui1: Tween = $TweensUI/Tween1
onready var tween_ui2: Tween = $TweensUI/Tween2
onready var tween_ui3: Tween = $TweensUI/Tween3

func getAvailableTween() -> Tween:
	if !tween_ui1.is_active():
		return tween_ui1
	elif !tween_ui2.is_active():
		return tween_ui2
	elif !tween_ui3.is_active():
		return tween_ui3
	else:
		return null

func popUIHit(node_to_pop: Node) -> void:
	var tween = getAvailableTween()
	if tween == null:
		print("No available tweens")
		return
	# Define the scale properties for tweening
	var initial_scale = Vector2(0.48,0.48)
	var target_scale = initial_scale * 1.2  # Scale up to 1.2 times the original
	# Stop any existing tweens on the node
	tween.stop_all()
	# Configure the tween to scale up and then back to initial scale
	tween.interpolate_property(node_to_pop, "rect_scale", initial_scale, target_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(node_to_pop, "rect_scale", target_scale, initial_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN, 0.1)
	# Start the tween
	tween.start()
	
func popUIHit2(node_to_pop: Node) -> void:
	var tween = getAvailableTween()
	if tween == null:
		print("No available tweens")
		return
	# Define the scale properties for tweening
	var initial_scale = Vector2(-0.48,0.48)
	var target_scale = initial_scale * 1.2  # Scale up to 1.2 times the original
	# Stop any existing tweens on the node
	tween.stop_all()
	# Configure the tween to scale up and then back to initial scale
	tween.interpolate_property(node_to_pop, "rect_scale", initial_scale, target_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(node_to_pop, "rect_scale", target_scale, initial_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN, 0.1)
	# Start the tween
	tween.start()
	
func popUI(node_to_pop:Node, tween: Tween) -> void:
	# Define the scale properties for tweening
	var initial_scale = node_to_pop.rect_scale
	var target_scale = Vector2(1.2, 1.2)  # Scale up to 1.2
	# Configure the tween to scale up and then back to initial scale
	tween.interpolate_property(node_to_pop, "rect_scale", initial_scale, target_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(node_to_pop, "rect_scale", target_scale, initial_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN)
	# Start the tween
	tween.start()
func popUpUI(node_to_pop: Node, tween: Tween) -> void:
	# Define the initial and target scale
	var initial_scale = Vector2(1, 1)  # Start from full size
	var target_scale = Vector2(0, 0)  # Scale down to zero
	# Configure the tween to scale down and then back to initial scale
	tween.interpolate_property(node_to_pop, "rect_scale", initial_scale, target_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.interpolate_property(node_to_pop, "rect_scale", target_scale, initial_scale, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN)

	# Start the tween
	tween.start()






#Gathering__________________________________________________________________________________________

onready var plant_area:Area = $Area
func connectAreas()-> void:
	plant_area.connect("area_entered", self, "plantAreaEntered")
	plant_area.connect("area_exited", self, "plantAreaExited")
	
func plantAreaEntered(area:Area)-> void:
	if area.has_node("Plant"):
		area.get_node("Plant").playerBack()
		debug.touched_grass = area
		print("active:true")	
	
	

func plantAreaExited(area)-> void:
	if area.has_node("Plant"):
		if area.get_node("Plant").size >= 1:
			area.get_node("Plant").playerLeft()
			print("active:false")

		
func harvestGather() -> void:
	for body in detector_area.get_overlapping_areas():
		if body.is_in_group("BlueTip"):
			var plant_size = body.get_node("Plant").size
			body.get_node("Plant").time_invisible = 5
			var quantity: int = 1
			var item_name: String = "blue_tip_grass"
			
			# Retrieve item and rarity from the list
			var item_data = Items.herbalist_list.get(item_name)
			if item_data:
				var item = item_data.icon
				var item_rarity: float = item_data.rarity
			
				if plant_size > 0.5:
					quantity += int((plant_size - 0.5) / 0.1)  # Increase quantity by 1 for every 0.1 unit above 0.5
				
				getLoot(item, quantity, item_rarity, item_name)
				processTheGathering(body)
			else:
				print("Item not found in herbalist_list: ", item_name)

func processTheGathering(body)->void:
	debug.harvested_item_size = body.get_node("Plant").size
	debug.harvested_item = body
	debug.debugHarvesting()
	body.get_node("CollisionShape").disabled = true
	body.visible = false
	body.get_node("Plant").size = 0

onready var tween_inv:Tween =  $Canvas/Skillbar/UI_list/InvButtonHolder/Tween
onready var inv_button_holder:Control = $Canvas/Skillbar/UI_list/InvButtonHolder
onready var resource_viewport:Viewport = $Canvas/Skillbar/AddFloatingIconsHere/Viewport
func getLoot(item, quantity, item_rarity, item_name)->void:
	Autoload.addStackableItem(inventory_grid, item, quantity)
	Autoload.addFloatingIcon(resource_viewport, item, quantity, item_rarity, item_name,self)

