extends KinematicBody
onready var player_mesh: Node = $Mesh
var animation : AnimationPlayer
var anim_tree : AnimationTree

var rng = RandomNumberGenerator.new()
var injured: bool = false
var blend: float = 0.25

# Condition States
var is_attacking = bool()
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()

onready var l_click_slot = $UI/GUI/SkillBar/GridContainer/LClickSlot
onready var r_click_slot = $UI/GUI/SkillBar/GridContainer/RClickSlot

func _ready():
	loadPlayerData()
	switchSexRace()
	setInventoryOwner()
	add_to_group("Player")
	add_to_group("Entity")
	connectUIButtons()
	connectInventoryButtons()
	connectSkillBarButtons()
	connectSkillTree()
	connectAttributeButtons()
	connectAttributeHovering()
	connectHoveredResistanceLabels()
	convertStats()
	closeAllUI()
	loadInventoryData()
	SwitchEquipmentBasedOnEquipmentIcons()
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)
	aim_label.text = aiming_mode
	current_race_gender.EquipmentSwitch()
	l_click_slot.switchAttackIcon()
func _on_SlowTimer_timeout():
	allResourcesBarsAndLabels()
	potionEffects()
	current_race_gender.EquipmentSwitch()
	saveSkillBarData()
	convertStats()
	money()
	hunger()
	hydration()	
	frameRate()	
	showStatusIcon()	
	displayLabels()
	regenStats()
	switchWeaponStances()
	l_click_slot.switchAttackIcon()
	r_click_slot.switchAttackIcon()


func _on_3FPS_timeout():
	$UI/GUI/Equipment/Attributes/AttributePoints.text = "Attributes points left: " + str(attribute)
# Calculate the sum of all spent attribute points
	var total_spent_attribute_points = spent_attribute_points_san + spent_attribute_points_wis + spent_attribute_points_mem + spent_attribute_points_int + spent_attribute_points_ins +spent_attribute_points_for + spent_attribute_points_str + spent_attribute_points_fur + spent_attribute_points_imp + spent_attribute_points_fer + spent_attribute_points_foc + spent_attribute_points_bal + spent_attribute_points_dex + spent_attribute_points_acc + spent_attribute_points_poi +spent_attribute_points_has + spent_attribute_points_agi + spent_attribute_points_cel + spent_attribute_points_fle + spent_attribute_points_def + spent_attribute_points_end + spent_attribute_points_sta + spent_attribute_points_vit + spent_attribute_points_res + spent_attribute_points_ten + spent_attribute_points_cha + spent_attribute_points_loy + spent_attribute_points_dip + spent_attribute_points_aut + spent_attribute_points_cou
	# Update the text in the UI/GUI
	$UI/GUI/Equipment/Attributes/AttributeSpent.text = "Attributes points Spent: " + str(total_spent_attribute_points)
	crafting()
	displayResources(hp_bar,hp_label,health,max_health,"HP")
	curtainsDown()
	SwitchEquipmentBasedOnEquipmentIcons()
	updateAllStats()
	switchShoulder()
	necromant.updateCooldownLabel()
func _physics_process(delta: float) -> void:
	$Debug.text = state
#	displayClock()
	convertStats()
	ChopTree()
	limitStatsToMaximum()
	cameraRotation()
	crossHair()
	crossHairResize()
	minimapFollow()
	miniMapVisibility()
	stiffCamera()
	walk()
	climbing()
	autoload.gravity(self)
	jump()
	dodgeIframe()
	dodgeBack()
	dodgeFront()
	dodgeLeft()
	dodgeRight()
	fullscreen()
	showEnemyStats()
	matchAnimationStates()
	animations()
	attack()
	doubleAttack()
	fallDamage()
	skillUserInterfaceInputs()
	addItemToInventory()
	positionCoordinates()
	MainWeapon()
	SecWeapon()
#_______________________________________________Basic Movement______________________________________
var h_rot 
var blocking = false
var is_in_combat = false
var enabled_climbing = false
var is_crouching = false
var is_sprinting = false
var sprint_speed = 10
const base_max_sprint_speed = 25
var max_sprint_speed = 25
var max_sprint_animation_speed = 2.5
func walk():
	h_rot = $Camroot/h.global_transform.basis.get_euler().y
	movement_speed = 0
	angular_acceleration = 3.25
	acceleration = 15
	# Movement input, state and mechanics
	if (Input.is_action_pressed("forward") ||  Input.is_action_pressed("backward") ||  Input.is_action_pressed("left") ||  Input.is_action_pressed("right")):
		direction = Vector3(Input.get_action_strength("left") - Input.get_action_strength("right"),
					0,
					Input.get_action_strength("forward") - Input.get_action_strength("backward"))
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		is_walking = true
	# Sprint input, state and speed
		if (Input.is_action_pressed("sprint")) and (is_walking == true): 
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
		elif Input.is_action_pressed("run"):
			sprint_speed = 10
			is_running = true 
			is_sprinting = false
			is_aiming = false
			is_crouching = false
			movement_speed = run_speed

		else: # Walk State and speed
			sprint_speed = 10
			sprint_animation_speed = 1
			#print(str(sprint_speed))
			movement_speed = walk_speed 
			is_sprinting = false
			is_running = false
			is_crouching = false
	else: 
		sprint_speed = 10
		is_walking = false
		is_sprinting = false
		is_running = false
		is_crouching = false
		
	autoload.movement(self)
#	physicsSauce()
#	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
#climbing section
var is_swimming = false
var wall_incline
var is_wall_in_range = false
var is_climbing = false
onready var head_ray = $Mesh/HeadRay
onready var climb_ray = $Mesh/ClimbRay
func climbing():
	if not is_swimming and strength > 0.99:
		if climb_ray.is_colliding() and is_on_wall():
			if Input.is_action_pressed("forward"):
					checkWallInclination()
					is_climbing = true
					is_swimming = false
					if not head_ray.is_colliding() and not is_wall_in_range:#vaulting
						state = "vaulting"
						vertical_velocity = Vector3.UP * 3 
					elif not is_wall_in_range:#normal climb
						state = "climbing"
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
func checkWallInclination():
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
export var  jump_animation_duration = 0
var jump_animation_max_duration = 3
var jump_mov_animation_duration = 0
var jump_mov_animation_max_duration = 3
func jump():
	#print("jump duration " + str(jump_animation_duration))
#	Jump input and Mechanics
	if Input.is_action_just_pressed("jump") and is_on_floor() and !is_walking:
		if jump_animation_duration == 0 or jump_animation_duration < 0 :
			jump_animation_duration += jump_animation_max_duration
			if jump_animation_duration < 0: 
				jump_animation_duration = 0
	elif jump_animation_duration != 0:
		if jump_animation_duration > 0: 
			jump_animation_duration -= 0.1
			if jump_animation_duration < 0: 
				jump_animation_duration = 0
	elif Input.is_action_pressed("jump") and is_on_floor() and is_walking and !is_sprinting:
		jumpUp()
	elif Input.is_action_pressed("jump") and is_on_floor() and is_walking and is_sprinting:
		horizontal_velocity = direction * 25
		jumpUp()
#var gravity_force = 9.8
#var velocity = Vector3()
#func gravity(delta): PLAYER GRAVITY MOVED TO GLOBAL AUTOLOAD
#	# Gravity mechanics and prevent slope-sliding
#	if not is_climbing:
#		if not is_on_floor(): 
#			vertical_velocity += Vector3.DOWN * gravity_force * 2 * delta
#		else: 
#			vertical_velocity = -get_floor_normal() * gravity_force / 2.5 #This must be always set 2.5 for climbing system to work 
var fall_damage = 0
var fall_distance = 0
var minimum_fall_distance = 0.5
func fallDamage():
	if state == "fall" and !is_climbing and !is_on_wall():
		#print("fall damage " + str(fall_damage))
		#print("fall distance " + str(fall_distance))
		fall_distance += 0.015
		if fall_distance > minimum_fall_distance: 
			fall_damage += (2.5 +(0.01 * max_health)) / agility
	else:
		if fall_distance > minimum_fall_distance: 
			takeDamage(fall_damage, 100, self, 0, "blunt")
			shake_camera(0.4,0.035,0.5,0.3)
		#print("hp " + str(health))
		fall_damage = 0
		fall_distance = 0 

# Physics value
var direction : Vector3 = Vector3()
var horizontal_velocity : Vector3 = Vector3()
var aim_turn = float()
var movement = Vector3()
var vertical_velocity = Vector3()
var movement_speed = int()
var angular_acceleration = int()
var acceleration = int()
#func physicsSauce():MOVED TO AUTOLOAD
#	movement.z = horizontal_velocity.z + vertical_velocity.z
#	movement.x = horizontal_velocity.x + vertical_velocity.x
#	movement.y = vertical_velocity.y
#	move_and_slide(movement, Vector3.UP)
#__________________________________________More action based movement_______________________________
# Dodge
export var double_press_time: float = 0.18
var dash_countback: int = 0
var dash_timerback: float = 0.0
# Dodge Left
var dash_countleft: int = 0
var dash_timerleft: float = 0.0
# Dodge right
var dash_countright: int = 0
var dash_timerright: float = 0.0
# Dodge forward
var dash_countforward: int = 0
var dash_timerforward: float = 0.0
# Dodge multidirection (not in strafe mode)
var dash_count1 : int = 0
var dash_timer1 : float = 0.0
var dash_count2 : int = 0
var dash_timer2 : float = 0.0
var dodge_animation_duration : float = 0
var dodge_animation_max_duration : float = 3
func dodgeBack():#Doddge when in strafe mode
		if dash_countback > 0:
			dash_timerback += get_physics_process_delta_time()
		if dash_timerback >= double_press_time:
			dash_countback = 0
			dash_timerback = 0.0
		if Input.is_action_just_pressed("backward"):
			dash_countback += 1
		if dash_countback == 2 and dash_timerback < double_press_time:
			if dodge_animation_duration == 0:
				dodge_animation_duration += dodge_animation_max_duration
		else:
			if dodge_animation_duration > 0: 
				dodge_animation_duration -= 0.1
			elif dodge_animation_duration < 0: 
					dodge_animation_duration = 0
func dodgeFront():#Dodge when in strafe mode
		if dash_countforward > 0:
			dash_timerforward += get_physics_process_delta_time()
		if dash_timerforward >= double_press_time:
			dash_countforward = 0
			dash_timerforward = 0.0
		if Input.is_action_just_pressed("forward"):
			dash_countforward += 1
		if dash_countforward == 2 and dash_timerforward < double_press_time:
			if dodge_animation_duration == 0:
				dodge_animation_duration += dodge_animation_max_duration
		else:
			if dodge_animation_duration > 0: 
				dodge_animation_duration -= 0.1 
			elif dodge_animation_duration < 0: 
					dodge_animation_duration = 0
		#print(str("dodge_animation_duration"+ str(dodge_animation_duration)))
func dodgeLeft():#Dodge when in strafe mode
		if dash_countleft > 0:
			dash_timerleft += get_physics_process_delta_time()
		if dash_timerleft >= double_press_time:
			dash_countleft = 0
			dash_timerleft = 0.0
		if Input.is_action_just_pressed("left"):
			dash_countleft += 1
		if dash_countleft == 2 and dash_timerleft < double_press_time:
			if dodge_animation_duration == 0:
				dodge_animation_duration += dodge_animation_max_duration
		else:
			if dodge_animation_duration > 0: 
				dodge_animation_duration -= 0.1
			elif dodge_animation_duration < 0: 
					dodge_animation_duration = 0
func dodgeRight():#Dodge when in strafe mode
		if dash_countright > 0:
			dash_timerright += get_physics_process_delta_time()
		if dash_timerright >= double_press_time:
			dash_countright = 0
			dash_timerright = 0.0
		if Input.is_action_just_pressed("right"):
			dash_countright += 1
		if dash_countright == 2 and dash_timerright < double_press_time :
			if dodge_animation_duration == 0:
				dodge_animation_duration += dodge_animation_max_duration
		else:
			if dodge_animation_duration > 0: 
				dodge_animation_duration -= 0.1
			elif dodge_animation_duration < 0: 
					dodge_animation_duration = 0
	#_____________________________________________________Camera_______________________________________
var is_aiming: bool = false
var camrot_h: float = 0
var camrot_v: float = 0
onready var parent = $".."
export var cam_v_max: float = 200 
export var cam_v_min: float = -125 
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

func shake_camera(duration: float, intensity: float, rand_x, rand_y):
	pass

func Zoom(zoom_direction : float):
	# Adjust the camera's position based on the zoom direction
	camera.translation.y += zoom_direction * zoom_speed
	camera.translation.z -= zoom_direction * (zoom_speed * 2)
	#print("z" + str(camera.translation.z) + " y" +str(camera.translation.y) )
func _on_Sensitivity_pressed():
	$Minimap/sensitivity_label.text = "cam sens: " + str(h_sensitivity)
	h_sensitivity += 0.025
func _on_SensitivityMin_pressed():
	h_sensitivity -= 0.025
	$Minimap/sensitivity_label.text = "cam sens: " + str(h_sensitivity)
func cameraRotation():
	if not cursor_visible:#MOUSE CAMERA
		camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
		camera_h.rotation_degrees.y = lerp(camera_h.rotation_degrees.y, camrot_h, get_physics_process_delta_time() * h_acceleration)
		camera_v.rotation_degrees.x = lerp(camera_v.rotation_degrees.x, camrot_v, get_physics_process_delta_time() * v_acceleration)
func _input(event):
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
func stiffCamera():
	if is_aiming and !is_climbing:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/h.rotation.y, get_physics_process_delta_time() * angular_acceleration)
#	elif is_climbing:
#		if direction != Vector3.ZERO and is_climbing:
#			player_mesh.rotation.y = -(atan2($ClimbRay.get_collision_normal().z,$ClimbRay.get_collision_normal().x) - PI/2)
	else: # Normal turn movement mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, get_physics_process_delta_time() * angular_acceleration)
func minimapFollow():# Update the position of the minimap camera
	minimap_camera.translation = Vector3(translation.x, translation.y + 30,translation.z)
onready var crosshair = $Camroot/h/v/Camera/Aim/Cross
onready var crosshair_tween = $Camroot/h/v/Camera/Aim/Cross/Tween
func crossHair():
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
func crossHairResize():
	# Define the target scale based on input action
	var target_scale = 1.0
	if Input.is_action_pressed("rclick"):
		target_scale = 0.6
	# Use Tween to smoothly transition the scale change
	crosshair_tween.interpolate_property(crosshair, "rect_scale", crosshair.rect_scale, Vector2(target_scale, target_scale), 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	crosshair_tween.start()

onready var minimap:Control = $UI/GUI/Portrait/MinimapHolder/Minimap
func miniMapVisibility():
	if Input.is_action_just_pressed("minimap"):
		minimap.visible = !minimap.visible
	
	
var lifesteal_pop = preload("res://UI/lifestealandhealing.tscn")	
func lifesteal(damage_to_take):
	if life_steal > 0:
		var text = lifesteal_pop.instance()
		var life_steal_ratio = damage_to_take * life_steal
		if health < max_health:
			health += life_steal_ratio
			text.amount = round(life_steal_ratio * 100)/ 100
			take_damage_view.add_child(text)
		elif health > max_health:
			health = max_health



var is_fullscreen :bool  = false
func fullscreen():
	if Input.is_action_just_pressed("fullscreen"):
		is_fullscreen = !is_fullscreen
		OS.set_window_fullscreen(is_fullscreen)
		saveGame()



	

#__________________________________Entitygraphical interface________________________________________
onready var entity_graphic_interface = $UI/GUI/EnemyUI
onready var entity_inspector 
onready var enemy_ui_tween =$UI/GUI/EnemyUI/Tween
onready var enemy_health_bar = $UI/GUI/EnemyUI/HP
onready var enemy_health_label = $UI/GUI/EnemyUI/HP/HPlab
onready var enemy_energy_bar = $UI/GUI/EnemyUI/EN
onready var enemy_energy_label =$UI/GUI/EnemyUI/EN/ENlab
onready var ray = $Camroot/h/v/Camera/Aim
var fade_duration : float = 0.3
func showEnemyStats():
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
					enemy_energy_bar.value = body.nefis
					enemy_energy_bar.max_value = body.max_nefis
					enemy_energy_label.text = "EP:" + str(round(body.nefis* 100) / 100) + "/" + str(body.max_nefis)
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




#______________________________________________Animations___________________________________________
var weapon_type: String = "fist" #fist, sword, dual_swords, sword_shield,two_handed, spear, staff
func switchWeaponStances()-> void:
	if right_hand != null and left_hand !=null:
		if right_hand.get_child_count() > 0:
			if left_hand.get_child_count() > 0:
				weapon_type = "dual_swords"
			elif left_hand.get_child_count() == 0:
				weapon_type = "sword"
		else:
			if left_hand.get_child_count() == 0:
				weapon_type = "fist"
		

var state: String = "idle"
func matchAnimationStates():
	if current_race_gender != null and animation != null:
		if is_instance_valid(animation):
			match state:
		#_______________________________attacking states________________________________
				"slide":
					var slide_blend = 0.3
					pass
					var slide_mov_speed = 15 + slide_blend + rand_range(3, 6)
					if !is_on_wall():
						horizontal_velocity = direction * slide_mov_speed
					movement_speed = int(slide_mov_speed)
				"base attack":
					current_race_gender.resetAllCombos()
					var slot = $UI/GUI/SkillBar/GridContainer/LClickSlot/Icon
					skills(slot)
				"guard":
					var slot = $UI/GUI/SkillBar/GridContainer/RClickSlot/Icon
					skills(slot)
				"guard walk":
						match weapon_type:
							"fist":
								pass #replace with actual animation
							"sword":
								pass
				"double attack":
					current_race_gender.resetAllCombos()
					match weapon_type:
						"fist":
							pass
						"sword":
							pass
					moveDuringAnimation(3)
				"guard attack":
					if resolve > 25:
						match weapon_type:
							"sword":
								pass
						moveDuringAnimation(3)
					else:
						pass
				"run attack":
					
					moveDuringAnimation(3)
				"sprint attack":
					
					moveDuringAnimation(3)
		#_________________________________walking states________________________________
				"walk":
					if is_in_combat:
						match weapon_type:
							"fist":
								pass
							"sword":
								pass
							"dual_swords":
								pass
					else:
						pass
				"crouch walk":
					pass
				"crouch":
					pass
		#movement 
				"sprint":
					current_race_gender.resetAllCombos()
					
				"run":
					current_race_gender.resetAllCombos()
					
				"jump":
					current_race_gender.resetAllCombos()
					
				"fall":
					current_race_gender.resetAllCombos()
					pass
				"climbing":
					pass
				"vaulting":
					pass
				"landing":
					pass
				"crawl":
					pass
				"crawl limit":
					pass
				"idle downed":
					pass
				"idle":
					
					current_race_gender.resetAllCombos()
					if is_in_combat:
						if weapon_type == "fist":
							pass
						else:
							pass
					else:
						pass
				#skillbar stuff
				"test1":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot1/Icon
					skills(slot)
				"test2":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot2/Icon
					skills(slot)
				"test3":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot3/Icon
					skills(slot)
				"test4":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot4/Icon
					skills(slot)
				"test5":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot5/Icon
					skills(slot)
				"test6":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot6/Icon
					skills(slot)
				"test7":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot7/Icon
					skills(slot)
				"test8":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot8/Icon
					skills(slot)
				"test9":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot9/Icon
					skills(slot)
				"test0":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot10/Icon
					skills(slot)
				"testQ":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot11/Icon
					skills(slot)
				"testE":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot12/Icon
					skills(slot)
				"testR":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot13/Icon
					skills(slot)
				"testT":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot14/Icon
					skills(slot)
				"testF":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot15/Icon
					skills(slot)
				"testG":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot16/Icon
					skills(slot)
				"testY":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot17/Icon
					skills(slot)
				"testH":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot18/Icon
					skills(slot)
				"testV":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot19/Icon
					skills(slot)
				"testB":
					var slot = $UI/GUI/SkillBar/GridContainer/Slot20/Icon
					skills(slot)
onready var necromant = $UI/GUI/SkillTrees/Background/Necromant
var fury_strike_duration: float = 0
func skills(slot):
	var l_click_slot: TextureButton = $UI/GUI/SkillBar/GridContainer/LClickSlot
	var r_click_slot: TextureButton = $UI/GUI/SkillBar/GridContainer/RClickSlot
	if slot != null:
			if slot.texture != null:
				if slot.texture.resource_path == "res://UI/graphics/SkillIcons/rush.png":
					pass
			
				elif slot.texture.resource_path == "res://UI/graphics/SkillIcons/selfheal.png":
					pass
			
				elif slot.texture.resource_path == autoload.summon_shadow.get_path():
			
					necromant.summonDemon()
				elif slot.texture.resource_path == autoload.dominion.get_path():	
					necromant.commandSwitch()
				elif slot.texture.resource_path == autoload.tribute.get_path():	
					necromant.tribute()
				elif slot.texture.resource_path == autoload.servitude.get_path():	
					necromant.areaSpell()
				elif slot.texture.resource_path == autoload.arcane_blast.get_path():	
					necromant.arcaneBlast()
#melee
				elif slot.texture.resource_path == autoload.punch.get_path():
				
					moveDuringAnimation(3)
					current_race_gender.fury_strike_combo =0
				elif slot.texture.resource_path == autoload.slash_sword.get_path():
					is_in_combat = true
					current_race_gender.fury_strike_combo =0
					match weapon_type:
						"sword":
						
							moveDuringAnimation(2)
						"dual_swords":
					
							moveDuringAnimation(1.5)
				elif slot.texture.resource_path == autoload.guard.get_path():
					if !is_walking:
					
						jump_animation_duration = 0 
					else:
	
						jump_animation_duration = 0 
#melee weapon skills
				elif slot.texture.resource_path == autoload.overhead_slash.get_path():
					if necromant.can_overhead_slash == true:
						if resolve > necromant.overhead_slash_cost:
							match weapon_type:
									"fist":
										anim_tree.set("parameters/asd/active",false)
									"sword":
										is_in_combat = true
										anim_tree.set("parameters/x/blend_amount",-1)
										anim_tree.set("parameters/speed/scale",melee_atk_speed)
										anim_tree.set("parameters/asd/active",true)
										moveDuringAnimation(1)
									"dual_swords":
										is_in_combat = true

										anim_tree.set("parameters/asd/active",false)

										moveDuringAnimation(2)

						else:
							anim_tree.set("parameters/asd/active",false)
					else:
						current_race_gender.fury_strike_combo =0
						anim_tree.set("parameters/asd/active",false)
				elif slot.texture.resource_path == autoload.fury_strike.get_path():
					if necromant.can_fury_strike == true:
						is_in_combat = true
						anim_tree.set("parameters/x/blend_amount",0)
						anim_tree.set("parameters/speed/scale",melee_atk_speed)
						anim_tree.set("parameters/asd/active",true)
						moveDuringAnimation(3)

				elif slot.texture.resource_path == autoload.cyclone.get_path():
					if necromant.can_cyclone == true:
						if resolve > necromant.cyclone_cost:
							is_in_combat = true
							anim_tree.set("parameters/x/blend_amount",1)
							anim_tree.set("parameters/speed/scale",melee_atk_speed)
							anim_tree.set("parameters/asd/active",true)
							moveDuringAnimation(3)
					else:
						anim_tree.set("parameters/asd/active",false)

				elif slot.texture.resource_path == autoload.guard_sword.get_path():
					is_in_combat = true
					current_race_gender.fury_strike_combo =0
					moveDuringAnimation(3)

				elif slot.texture.resource_path == autoload.base_attack_necromant.get_path():
					necromant.baseAttack() # placeholder
				elif slot.texture.resource_path == autoload.necro_guard.get_path():
					pass #necromance guard placeholder
				elif slot.texture.resource_path == autoload.necromant_switch.get_path():
					necromant.switchStance()# different stances or weapons switches base attacks
					l_click_slot.switchAttackIcon()
					r_click_slot.switchAttackIcon()
#consumables________________________________________________________________________________________
				elif slot.texture.resource_path == autoload.red_potion.get_path():
					slot.get_parent().displayQuantity()
					for child in inventory_grid.get_children():
						if child.is_in_group("Inventory"):
							var index_str = child.get_name().split("InventorySlot")[1]
							var index = int(index_str)
							var button = inventory_grid.get_node("InventorySlot" + str(index))
							button = inventory_grid.get_node("InventorySlot" + str(index))
							autoload.consumeRedPotion(self,button,inventory_grid,true,slot.get_parent())				
				else:
						pass
						
func moveDuringAnimation(speed):
	if !is_on_wall():
		if current_race_gender.can_move == true:
			horizontal_velocity = direction * speed
			movement_speed = speed
		elif current_race_gender.can_move == false:
			horizontal_velocity = direction * 0
			movement_speed = 0
var sprint_animation_speed : float = 1
func animations():
#on water
	if is_swimming:
		if is_walking:
			state = "swim"
		else:
			state = "idle water"
#on land
	elif dodge_animation_duration > 0 and resolve >0:
		resolve -= 0.2
		state = "slide"
		jump_animation_duration = 0 
	elif not is_on_floor() and not is_climbing and not is_swimming:
		state = "fall"
		jump_animation_duration = 0 
	elif double_atk_animation_duration > 0 and !cursor_visible: 
		state = "double attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("rclick") and Input.is_action_pressed("attack") and !cursor_visible:
		state = "guard attack"
		jump_animation_duration = 0 
		
	elif Input.is_action_pressed("rclick") and !cursor_visible:
		if !is_walking:
			state = "guard"
			jump_animation_duration = 0 
		else:
			state = "guard walk"
			jump_animation_duration = 0 
#attacks________________________________________________________________________
	elif Input.is_action_pressed("attack") and Input.is_action_pressed("run") and !cursor_visible: 
		state = "run attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("attack") and Input.is_action_pressed("sprint") and !cursor_visible: 
		state = "sprint attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("attack") and !cursor_visible:
			state = "base attack"
			jump_animation_duration = 0 

#_______________________________________________________________________________
			
#skills put these below the walk elif statment in case of keybinding bugs, as of now it works so no need
	elif Input.is_action_pressed("1"):
		state = "test1"
	elif Input.is_action_pressed("2"):
		state = "test2"
	elif Input.is_action_pressed("3"):
		state = "test3"
	elif Input.is_action_pressed("4"):
		state = "test4"
	elif Input.is_action_pressed("5"):
		state = "test5"
	elif Input.is_action_pressed("6"):
		state = "test6"
	elif Input.is_action_pressed("7"):
		state = "test7"
	elif Input.is_action_pressed("8"):
		state = "test8"
	elif Input.is_action_pressed("9"):
		state = "test9"
	elif Input.is_action_pressed("0"):
		state = "test0"
	elif Input.is_action_pressed("Q"):
		state = "testQ"
	elif Input.is_action_pressed("E"):
		state = "testE"
	elif Input.is_action_pressed("R"):
		state = "testR"
	elif Input.is_action_pressed("F"):
		state = "testF"
	elif Input.is_action_pressed("R"):
		state = "testR"
	elif Input.is_action_pressed("T"):
		state = "testT"
	elif Input.is_action_pressed("G"):
		state = "testG"
	elif Input.is_action_pressed("H"):
		state = "testH"
	elif Input.is_action_pressed("Y"):
		state = "testY"
	elif Input.is_action_pressed("V"):
		state = "testV"
	elif Input.is_action_pressed("B"):
		state = "testB" 
#_______________________________________________________________________________
		
	elif is_sprinting == true:
			state = "sprint"
			jump_animation_duration = 0 
	elif is_running:
			state = "run"
			jump_animation_duration = 0 
	elif is_walking:
			state = "walk"
			jump_animation_duration = 0 

	
	elif Input.is_action_pressed("crouch"):
		state = "crouch" 
		jump_animation_duration = 0 
	
	elif jump_animation_duration != 0:
		state = "jump"
	else:
		state = "idle"

#_______________________________________________Combat______________________________________________

func dodgeIframe():#apparently combat is too shitty without iframes, more realistic but as boring as watching olympic wrestling or judo, fucking utter ridiculous shit
	if state == "slide":
		set_collision_layer(6)  # Set to the desired collision layer
		set_collision_mask(6)   # Set to the desired collision mask
	else:
		set_collision_layer(1)  # Set to the original collision layer
		set_collision_mask(1)   # Set to the original collision mask

func attack():
	if Input.is_action_pressed("attack"):
		is_attacking = true
	else:
		is_attacking = false
#Double click to heavy attack_______________________________________________________________________
var double_atk_count: int = 0
var double_atk_timer: float = 0.0
var double_atk_animation_duration : float  = 0
var double_atk_animation_max_duration : float  = 2.208
func doubleAttack():
		if double_atk_count > 0:
			double_atk_timer += get_physics_process_delta_time()
		if double_atk_timer >= double_press_time:
			double_atk_count = 0
			double_atk_timer = 0.0
		if Input.is_action_just_pressed("attack"):
			double_atk_count += 1
		if double_atk_count == 2:
			if double_atk_animation_duration == 0:
				double_atk_animation_duration += double_atk_animation_max_duration
		else:
			if double_atk_animation_duration > 0: 
				double_atk_animation_duration -= 0.1 
			elif double_atk_animation_duration < 0: 
					double_atk_animation_duration = 0
func stopDoubleAttack():
	double_atk_animation_duration = 0
					
					

func stompKickDealDamage():
	var damage_type = "blunt"
	var damage = 10 + blunt_dmg 
	var damage_flank = damage + flank_dmg
	var critical_damage : float  = damage * critical_strength
	var critical_flank_damage : float  = damage_flank * critical_strength
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if enemy.has_method("applyEffect"):
					enemy.applyEffect(enemy,"bleeding", true)	
				pushEnemyAway(2, enemy,0.25)
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance:
						if isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,"acid")
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(critical_flank_damage,aggro_power,self,stagger_chance,"toxic")
					else:
						if isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,"heat")
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(damage_flank,aggro_power,self,stagger_chance,"jolt")

func pushEnemyAway(push_distance, enemy, push_speed):
	var direction_to_enemy = enemy.global_transform.origin - global_transform.origin
	direction_to_enemy.y = 0  # No vertical push
	direction_to_enemy = direction_to_enemy.normalized()
	var motion = direction_to_enemy * push_speed
	var acceleration_time = push_speed / 2.0
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = enemy.move_and_collide(motion)
	if collision: #this checks the dipshit hits a wall after you punch him 
		#the dipshit takes damage from being pushed into something
		#afterwards he is pushed back...like ball bouncing back but made of meat
		enemy.takeDamage(10, 100, self, 1, "bleed")
		# Calculate bounce-back direction
		var normal = collision.normal
		var bounce_motion = -4 * normal * normal.dot(motion) + motion
		# Move the enemy slightly away from the wall to avoid sticking
		enemy.translation += normal * 0.1 * collision.travel
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


func bouncheEnemy(push_distance, enemy, push_speed):
	var direction_to_enemy = enemy.global_transform.origin - global_transform.origin
	direction_to_enemy.y = 0  # No vertical push
	direction_to_enemy = direction_to_enemy.normalized()
	var acceleration_time = push_speed / 2.0  # Adjust as needed for faster or slower acceleration
	# Calculate distance for deceleration
	
	var motion = direction_to_enemy * push_speed
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = enemy.move_and_collide(motion)
	if collision: 
		# Extra collision handling if the enemy hits a wall after being pushed away
		enemy.takeDamage(10, 100, self, 1, "bleed")
	# Tween the movement over time with initial acceleration followed by instant stop
	tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(enemy, "translation", enemy.translation + motion * push_distance, enemy.translation, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, acceleration_time)
	tween.start()



func slideDealDamage():
	var damage_type: String = "blunt"
	var damage: float = 2.5
	var aggro_power : float = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					pushEnemyAway(1, enemy,0.25)
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,"heat")
					else:
						if isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(7,aggro_power,self,stagger_chance,"jolt")
				else:#jump attack kick slide
					pushEnemyAway(5, enemy,0.25)
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(30,aggro_power,self,stagger_chance,damage_type)
func PunchDealDamage1():
	var damage_type = "blunt"
	var damage = 10
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					pushEnemyAway(0.25, enemy,0.25)
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						if isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(damage * 1.5,aggro_power,self,stagger_chance,"jolt")
				else:#jump attack kick slide
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage *2,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(30,aggro_power,self,stagger_chance,damage_type)
func PunchDealDamage2():
	var damage_type = "blunt"
	var damage = 5
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				pushEnemyAway(0.25, enemy,0.25)
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						if isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(damage * 1.5,aggro_power,self,stagger_chance,"jolt")
				else:#jump attack kick slide
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage *2,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(30 ,aggro_power,self,stagger_chance,damage_type)
func PunchDealDamage3():
	var damage_type = "blunt"
	var damage = 15
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					pushEnemyAway(0.5, enemy,0.25)
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						if isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(30,aggro_power,self,stagger_chance,"jolt")
				else:#jump attack kick slide
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage *2,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage *2 ,aggro_power,self,stagger_chance,damage_type)
var jump_force : float  = 10
func jumpUp():#called on animation
	vertical_velocity = Vector3.UP * jump_force 
func jumpDown():#called on animation
	vertical_velocity = Vector3.UP * -jump_force

func speedlabel():
	$kmh.text = "km/h " + str(movement_speed)


var can_move: bool = false
func stopMovement():
	can_move = false
func startMovement():
	can_move = true 



onready var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_view  = $Mesh/TakeDamageView/Viewport
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type):
	if necromant.masochism >0:
		nefis += damage * 0.5
	var random = randf()
	var damage_to_take = damage
	var text = floatingtext_damage.instance()
	
	if damage_type == "slash":
		var mitigation: float
		if slash_resistance >= 0:
			mitigation = slash_resistance / (slash_resistance + 100.0)
		else:
			# For every negative point of slash resistance, add to damage to take directly
			damage_to_take += -slash_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "pierce":
		var mitigation: float
		if pierce_resistance >= 0:
			mitigation = pierce_resistance / (pierce_resistance + 100.0)
		else:
			damage_to_take += -pierce_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "blunt":
		var mitigation: float
		if blunt_resistance >= 0:
			mitigation = blunt_resistance / (blunt_resistance + 100.0)
		else:
			damage_to_take += -blunt_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "sonic":
		var mitigation: float
		if sonic_resistance >= 0:
			mitigation = sonic_resistance / (sonic_resistance + 100.0)
		else:
			damage_to_take += -sonic_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "heat":
		var mitigation: float
		if heat_resistance >= 0:
			mitigation = heat_resistance / (heat_resistance + 100.0)
		else:
			damage_to_take += -heat_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "cold":
		var mitigation: float
		if cold_resistance >= 0:
			mitigation = cold_resistance / (cold_resistance + 100.0)
		else:
			damage_to_take += -cold_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "jolt":
		var mitigation: float
		if jolt_resistance >= 0:
			mitigation = jolt_resistance / (jolt_resistance + 100.0)
		else:
			damage_to_take += -jolt_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "toxic":
		var mitigation: float
		if toxic_resistance >= 0:
			mitigation = toxic_resistance / (toxic_resistance + 100.0)
		else:
			damage_to_take += -toxic_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "acid":
		var mitigation: float
		if acid_resistance >= 0:
			mitigation = acid_resistance / (acid_resistance + 100.0)
		else:
			damage_to_take += -acid_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "bleed":
		var mitigation: float
		if bleed_resistance >= 0:
			mitigation = bleed_resistance / (bleed_resistance + 100.0)
		else:
			damage_to_take += -acid_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "neuro":
		var mitigation: float
		if neuro_resistance >= 0:
			mitigation = neuro_resistance / (neuro_resistance + 100.0)
		else:
			damage_to_take += -neuro_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "radiant":
		var mitigation: float
		if radiant_resistance >= 0:
			mitigation = radiant_resistance / (radiant_resistance + 100.0)
		else:
			damage_to_take += -radiant_resistance
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	if random < deflection_chance:
		damage_to_take = damage_to_take / 2
		text.status = "Deflected"
	else:
		if random < stagger_chance - stagger_resistance:
			staggered += 0.5
			text.status = "Staggered"

	health -= damage_to_take
	text.amount =round(damage_to_take * 100)/ 100
	text.state = damage_type
	take_damage_view.add_child(text)

func takeHealing(healing,healer):
	health += healing
	var text = floatingtext_damage.instance()
	text.amount =round(healing * 100)/ 100
	text.state = "healing"
	take_damage_view.add_child(text)
#__________________________________Combat UI____________________________________

onready var parry_icon = $UI/GUI/ParryIcon
var animation_duration = 500  # Animation duration in milliseconds
var start_time = 0
var total_elapsed_time = 0  # Total elapsed time since the animation started
var fading_in = true

func parryIcon():
	var parry_icon: TextureRect = $UI/GUI/ParryIcon
	var icon_duration: float = 0.5

	# Check if the tween is already active
	if not tween.is_active():
		# Modulating the alpha value over time
		tween.interpolate_property(parry_icon, "modulate:a", 1.0, 0.0, icon_duration,
									Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()


#_____________________________close buttons/inputs______________________________

var cursor_visible: bool = false
onready var keybinds: Control = $UI/GUI/Keybinds
onready var inventory: Control = $UI/GUI/Inventory
onready var crafting: Control = $UI/GUI/Crafting
onready var skill_trees: Control = $UI/GUI/SkillTrees
onready var character: Control = $UI/GUI/Equipment
onready var menu: Control = $UI/GUI/Menu
func skillUserInterfaceInputs():
	if Input.is_action_just_pressed("skills"):
		closeSwitchOpen(skill_trees)
		saveGame()
	elif Input.is_action_just_pressed("tab"):
		is_in_combat = !is_in_combat
		switchMainFromHipToHand()
		switchSecondaryFromHipToHand()
		saveGame()
	elif Input.is_action_just_pressed("mousemode") or Input.is_action_just_pressed("ui_cancel"):	# Toggle mouse mode
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
	elif Input.is_action_just_pressed("Crafting"):
		closeSwitchOpen(crafting)
		saveGame()
	elif Input.is_action_just_pressed("Character"):
		closeSwitchOpen(character)
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
func _on_OpenAllUI_pressed():
	closeSwitchOpen(character)
	closeSwitchOpen(crafting)
	closeSwitchOpen(inventory)
	closeSwitchOpen(skill_trees)
	saveGame()
	
func connectUIButtons():
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
func closeSwitchOpen(ui):
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
	crafting.visible = !$UI/GUI/Crafting.visible
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
onready var skills_list1 = $UI/GUI/SkillTrees/Background/SylvanSkills #placeholder
func _on_SkillTree1_pressed():
	closeSwitchOpen(skills_list1)
	saveSkillBarData()
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

#__________________________________Inventory____________________________________
#for this to work either preload all the item icons here or add the "AddItemToInventory.gd"
#as an autoload, i called it add_item in my project, and i used it to to compre the path 
#of icons, if the path matches with the icon i need, i do the effect of the specific item 
#i also use the same autoload to add items to inventory 
onready var inventory_grid = $UI/GUI/Inventory/ScrollContainer/InventoryGrid
onready var gui = $UI/GUI

func setInventoryOwner():
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
export var double_press_time_inv: float = 0.4

func inventorySlotPressed(index):
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture	
	if icon_texture != null:
		if  icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		var current_time = OS.get_ticks_msec() / 1000.0
		if last_pressed_index == index and current_time - last_press_time <= double_press_time_inv:
			print("Inventory slot", index, "pressed twice")


			if icon_texture.get_path() == autoload.red_potion.get_path():
				autoload.consumeRedPotion(self,button,inventory_grid,false,null)
			elif icon_texture.get_path() == autoload.strawberry.get_path():
					kilocalories +=1
					health += 5
					water += 2
					button.quantity -=1
			elif icon_texture.get_path() == autoload.raspberry.get_path():
					kilocalories += 4
					health += 3
					water += 3
					button.quantity -=1
			elif icon_texture.get_path() == autoload.beetroot.get_path():
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
func inventoryMouseEntered(index):
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://tooltip.tscn").instance()
	compareIconsShowToolTips(icon_texture,instance)

func inventoryMouseExited(index):
	deleteTooltip()

func callToolTip(instance,title, text):
		gui.add_child(instance)
		instance.showTooltip(title, text)
# Function to combine slots when pressed
func combineSlots():
	savePlayerData()
	saveSkillBarData()
	saveInventoryData()
	var combined_items = {}  # Dictionary to store combined items
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.stackable == true:
				var icon = child.get_node("Icon")
				if icon.texture != null:
					var item_path = icon.texture.get_path()
					if combined_items.has(item_path):
						combined_items[item_path] += child.quantity
						icon.texture = null  # Set texture to null for excess slots
						child.quantity = 0  # Reset quantity
					else:
						combined_items[item_path] = child.quantity
	# Update quantities based on combined_items
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var icon = child.get_node("Icon")
			var item_path = icon.texture.get_path() if icon.texture != null else null
			if item_path in combined_items:
				child.quantity = combined_items[item_path]

func splitFirstSlot():#Activated by button press
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
func connectSkillBarButtons():
	for child in skill_bar_grid.get_children():
		if child.is_in_group("Shortcut"):
			var index_str = child.get_name().split("Slot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "skillBarSlotPressed", [index])
			child.connect("mouse_entered", self, "skillBarMouseEntered", [index])
			child.connect("mouse_exited", self, "skillBarMouseExited", [index])
			
func skillBarMouseEntered(index):
	var button = skill_bar_grid.get_node("Slot" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://tooltipSkills.tscn").instance()
	compareIconsShowToolTips(icon_texture,instance)
	
func skillBarMouseExited(index):
	deleteTooltip()
	
	
#_____________________________________Skill trees_______________________________

func connectSkillTree():
	connectGenericSkillTee(necromant)
	connectGenericSkillTee($UI/GUI/SkillTrees/Background/Test)	


func connectGenericSkillTee(tree):
	for child in tree.get_children():
		if child.is_in_group("Skill"):
			var index_str = child.get_name().split("skill")[1]
			var index = int(index_str)
			child.connect("pressed", self, "skillPressed", [index])
			child.connect("mouse_entered", self, "skillMouseEntered", [tree, index]) # Pass 'tree' here
			child.connect("mouse_exited", self, "skillMouseExited", [index])
	
func skillMouseEntered(tree, index):
	var button = tree.get_node("skill" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://tooltipSkills.tscn").instance()
	compareIconsShowToolTips(icon_texture,instance)
func skillMouseExited(index):
	deleteTooltip()
	
func compareIconsShowToolTips(icon_texture,instance):
	if icon_texture != null:
		#skills
		if icon_texture.get_path() == autoload.arcane_blast.get_path():
			callToolTip(instance, "Arcane Blast", "base damage: 15        nefis cost: " + str(necromant.arcane_blast_cost) + "\nbonus damage: +10% maximum nefis\ndeals acid damage from the flanks and toxic damage from the front")
		elif icon_texture.get_path() == autoload.base_attack_necromant.get_path():
			callToolTip(instance, "base_attack_necromant", "placeholder")
		#consumablaes
		elif icon_texture.get_path() == autoload.red_potion.get_path():
			callToolTip(instance, "Red Potion", "+100 kcals +250 grams of water.\nHeals by 100 health instantly then by 10 every second, drinking more potions stacks the duration")
		#food
		elif icon_texture.get_path() == autoload.strawberry.get_path():
			callToolTip(instance,"Strawberry","+5 health points +9 kcals +24 grams of water")
		elif icon_texture.get_path() == autoload.raspberry.get_path():
			callToolTip(instance,"Raspberry","+3 health points +1 kcals +2 grams of water")
		elif icon_texture.get_path() == autoload.beetroot.get_path():
			callToolTip(instance,"beetroot","+15 health points +32 kcals +71.8 grams of water")
			#equipment icons
		elif icon_texture.get_path() == autoload.hat1.get_path():
			callToolTip(instance,"Farmer Hat","+3 blunt resistance.\n +6 heat resistance.\n +3 cold resistance.\n +6 radiant resistance.")
		elif icon_texture.get_path() == autoload.garment1.get_path():
			callToolTip(instance,"Farmer Jacket","+3 slash resistance.\n +1 pierce resistance.\n +12 heat resistance.\n +12 cold resistance.")
		elif icon_texture.get_path() == autoload.belt1.get_path():
			callToolTip(instance,"Farmer Belt","+3% balance.\n +1.1% charisma.")
		elif icon_texture.get_path() == autoload.glove1.get_path():
			callToolTip(instance,"Farmer Glove","+1 slash resistance.\n +1 blunt resistance.\n  +1 pierce resistance.\n +3 cold resistance.\n +5 jolt resistance.\n +3 acid resistance.")
		elif icon_texture.get_path() == autoload.pants1.get_path():
			callToolTip(instance,"Farmer Pants","+3 slash resistance.\n +1 pierce resistance.\n +12 heat resistance.\n +12 cold resistance.")
		elif icon_texture.get_path() == autoload.shoe1.get_path():
			callToolTip(instance,"Farmer Shoe","+1 slash resistance.\n +1 blunt resistance.\n +3 pierce resistance.\n +1 heat resistance.\n +6 cold resistance.\n +15 jolt resistance.\n")

		
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

func crafting():
	if crafting_slot1.texture != null:
		if crafting_slot1.texture.get_path() == "res://Alchemy ingredients/2.png":
			crafting_result.texture = preload("res://Processed ingredients/ground rosehip.png")
			$UI/GUI/Crafting/CraftingResultSlot.quantity = 2

#________________________________Add items to inventory_________________________
var loot_amount = 1
var chopping_power = 3
var chopping_efficiency = 1 
var pop_up_resource = preload("res://UI/floatingResource.tscn")
func ChopTree():
	var tree = ray.get_collider()
	if Input.is_action_just_pressed("attack"):
		if tree != null:
			if tree.is_in_group("tree"):
		#		tree.health -= chopping_power
				# Generate a random number between 0 and 1
				var random_value = randf()
				# 25% chance for wood
				if random_value < 0.2:
					loot_amount = rng.randi_range(1, 2)
					autoload.addStackableItem(inventory_grid,autoload.aubergine,loot_amount)
					autoload.addFloatingIcon(take_damage_view,autoload.aubergine,loot_amount)
				# 25% chance for acorn
				elif random_value < 0.4:
					loot_amount = rng.randi_range(5, 45)
					autoload.addStackableItem(inventory_grid,autoload.raspberry,loot_amount)
					autoload.addFloatingIcon(take_damage_view,autoload.raspberry,loot_amount)
				# 25% chance for branch
				elif random_value < 0.6:
					loot_amount = rng.randi_range(3, 5)
					autoload.addStackableItem(inventory_grid,autoload.potato,loot_amount)
					autoload.addFloatingIcon(take_damage_view,autoload.potato,loot_amount)
				elif random_value < 0.8:
					loot_amount = rng.randi_range(15, 25)
					autoload.addStackableItem(inventory_grid,autoload.onion,loot_amount)
					autoload.addFloatingIcon(take_damage_view,autoload.onion,loot_amount)
		# 25% chance for resin
				else:
					loot_amount = rng.randi_range(1, 5)
					autoload.addStackableItem(inventory_grid,autoload.beetroot,loot_amount)
					autoload.addFloatingIcon(take_damage_view,autoload.beetroot,loot_amount)



func addItemToInventory():
	pass
#	var items = $Mesh/Detector.get_overlapping_bodies()
#	for item in items:
#		if item.is_in_group("Mushroom1"):
#			add_item.addStackableItem(inventory_grid,add_item.rasberry_texture)
#			add_item.addStackableItem(inventory_grid,add_item.pants1)
#			add_item.addStackableItem(inventory_grid,add_item.hat1)
#			add_item.addStackableItem(inventory_grid,add_item.red_potion_texture)
#
#
#		if item.is_in_group("Mushroom2"):
#			add_item.addStackableItem(inventory_grid,add_item.strawberry_texture)
#			add_item.addStackableItem(inventory_grid,add_item.beetroot_texture)
#			add_item.addStackableItem(inventory_grid,add_item.rosehip_texture)
#			add_item.addStackableItem(inventory_grid,add_item.rasberry_texture)
#
#		if item.is_in_group("sword0"):
#			add_item.addNotStackableItem(inventory_grid,add_item.wood_sword_texture)
#			add_item.addNotStackableItem(inventory_grid,add_item.garment1)
#			add_item.addNotStackableItem(inventory_grid,add_item.shoe1)
func _on_GiveMeItems_pressed():
	coins += 55
	autoload.addStackableItem(inventory_grid,autoload.garlic,200)
	autoload.addFloatingIcon(take_damage_view,autoload.garlic,200)
	
	autoload.addStackableItem(inventory_grid,autoload.potato,200)
	autoload.addFloatingIcon(take_damage_view,autoload.potato,200)
	autoload.addStackableItem(inventory_grid,autoload.onion,200)
	autoload.addStackableItem(inventory_grid,autoload.carrot,200)
	autoload.addStackableItem(inventory_grid,autoload.corn,200)
	autoload.addStackableItem(inventory_grid,autoload.cabbage,200)
	autoload.addStackableItem(inventory_grid,autoload.bell_pepper,200)
	autoload.addStackableItem(inventory_grid,autoload.aubergine,200)
	autoload.addStackableItem(inventory_grid,autoload.tomato,200)

	
	autoload.addStackableItem(inventory_grid,autoload.raspberry,200)
	autoload.addStackableItem(inventory_grid,autoload.pants1,1)
	autoload.addStackableItem(inventory_grid,autoload.hat1,200)
	autoload.addStackableItem(inventory_grid,autoload.red_potion,200)
	autoload.addStackableItem(inventory_grid,autoload.strawberry,200)
	autoload.addStackableItem(inventory_grid,autoload.beetroot,200)
	autoload.addStackableItem(inventory_grid,autoload.rosehip,200)
	autoload.addStackableItem(inventory_grid,autoload.belt1,1)
	autoload.addStackableItem(inventory_grid,autoload.glove1,1)
	autoload.addNotStackableItem(inventory_grid,autoload.wood_sword)
	autoload.addNotStackableItem(inventory_grid,autoload.garment1)
	autoload.addNotStackableItem(inventory_grid,autoload.shoe1)
	autoload.addNotStackableItem(inventory_grid,autoload.staff1)
	autoload.addNotStackableItem(inventory_grid,autoload.torso_armor4)
	autoload.addNotStackableItem(inventory_grid,autoload.torso_armor2)
	autoload.addNotStackableItem(inventory_grid,autoload.torso_armor3)
	autoload.addNotStackableItem(inventory_grid,autoload.shoulder1)
	autoload.addNotStackableItem(inventory_grid,autoload.shoulder1)
	
#_____________________________________Currency______________________________________________________
onready var ethernium_label = $UI/GUI/Inventory/etherniumLabel
onready var silver_label = $UI/GUI/Inventory/silverLabel
onready var copper_label = $UI/GUI/Inventory/copperLabel

var coins = 0 

func money():
	var ethernium_coins = str(coins / 10000)  # 100 silver = 1 ethernium
	var silver_coins = str((coins % 10000) / 100)  # 100 copper = 1 silver
	var copper_coins = str(coins % 100)  # Remaining copper coins
	
	
	ethernium_label.text = ethernium_coins
	silver_label.text = silver_coins
	copper_label.text = copper_coins


	
	
	
#_____________________________________more GUI stuff________________________________________________
onready var fps_label: Label = $UI/GUI/Portrait/MinimapHolder/FPS
func frameRate():
	var current_fps = Engine.get_frames_per_second()
	var new_fps: float
	if current_fps > 59:
		new_fps = current_fps + 20
	elif current_fps > 39:
		new_fps = current_fps + 15
	elif current_fps > 34:
		new_fps = current_fps + 10
	elif current_fps > 29:
		new_fps = current_fps + 5
	else:
		new_fps = current_fps
	fps_label.text = str(new_fps)

func _on_FPS_pressed():
	savePlayerData()
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
#onready var time_label = $UI/GUI/Minimap/Time
#func displayClock():
#	# Get the current date and time
#	var datetime = OS.get_datetime()
#	# Display hour and minute in the label
#	time_label.text = "Time: %02d:%02d" % [datetime.hour, datetime.minute]	
onready var coordinates = $UI/GUI/Portrait/MinimapHolder/Coordinates
func positionCoordinates():
	var rounded_position = Vector3(
		round(global_transform.origin.x * 10) / 10,
		round(global_transform.origin.y * 10) / 10,
		round(global_transform.origin.z * 10) / 10
	)
	# Use %d to format integers without decimals
	coordinates.text = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]


#__________________________________Equipment Management____________________________
#Shoulders__________________________________________________________________________________________
var right_shoulder: Spatial = null
var left_shoulder: Spatial = null

onready var shoulder_r_icon = $UI/GUI/Equipment/EquipmentBG/PauldronR/Icon
onready var shoulder_l_icon = $UI/GUI/Equipment/EquipmentBG/PauldronL/Icon
var has_left_shoulder_pad = false 
var has_right_shoulder_pad = false 
var right_shoulder_pad:String = "null"
var left_shoulder_pad:String = "null"
var got_left_shoulder_pad:bool = false
var got_right_shoulder_pad:bool = false
func switchShoulder():
	match right_shoulder_pad:
		"1":
			instanceRightShoulder(autoload.shoulder_scene0)
		"0":    
			pass
		"2":    
			pass
		"3":
			pass
		"null":
			freeRightShoulderPad()
	match left_shoulder_pad:
		"1":
			 instanceLeftShoulder(autoload.shoulder_scene0)
		"0":    
			pass
		"2":    
			pass
		"3":
			pass
		"null":
			freeLeftShoulderPad()

func instanceRightShoulder(scene):
	if right_shoulder and scene:
		if got_right_shoulder_pad == false:
			var scene_instance = scene.instance()
			right_shoulder.add_child(scene_instance)
			got_right_shoulder_pad = true
func instanceLeftShoulder(scene):
	if left_shoulder and scene:
		if got_left_shoulder_pad == false:
			var scene_instance = scene.instance()
			left_shoulder.add_child(scene_instance)
			got_left_shoulder_pad = true
func freeRightShoulderPad():
	if right_shoulder and right_shoulder.get_child_count() > 0:
		right_shoulder.get_child(0).queue_free()
		got_right_shoulder_pad = false
func freeLeftShoulderPad():
	if left_shoulder and left_shoulder.get_child_count() > 0:
		left_shoulder.get_child(0).queue_free()
		got_left_shoulder_pad = false
		
		
	
#Main Weapon____________________________________________________________________
var right_hand:Spatial = null 
var right_hip :Spatial = null 
onready var detector = $Mesh/Detector
onready var main_weap_slot = $UI/GUI/Equipment/EquipmentBG/MainWeap
onready var main_weap_icon = $UI/GUI/Equipment/EquipmentBG/MainWeap/Icon


var staff1: PackedScene = preload("res://itemTest.tscn")
var current_weapon_instance: Node = null  
var main_weapon = "null"
var got_weapon = false
var sheet_weapon = false
var is_primary_weapon_on_hip = false
var is_chopping_trees = false
func switchMainFromHipToHand():
	if is_instance_valid(current_weapon_instance):
		if right_hand != null:
			if right_hip != null and current_weapon_instance != null:
				if is_in_combat or is_chopping_trees:
					if right_hand.get_child_count() == 0:
						if current_weapon_instance != null:
							if current_weapon_instance.get_parent() == right_hip:
								right_hip.remove_child(current_weapon_instance)
								right_hand.add_child(current_weapon_instance)
								is_primary_weapon_on_hip = false
				else:
						if right_hip.get_child_count() == 0:
							if current_weapon_instance != null:
								if current_weapon_instance.get_parent() == right_hand:
										right_hand.remove_child(current_weapon_instance)
										right_hip.add_child(current_weapon_instance)

func switchSecondaryFromHipToHand():
	if is_instance_valid(sec_current_weapon_instance):
		if is_in_combat:
			if left_hand and left_hand.get_child_count() == 0:
				if sec_current_weapon_instance != null and sec_current_weapon_instance.get_parent() == left_hip:
					left_hip.remove_child(sec_current_weapon_instance)
					left_hand.add_child(sec_current_weapon_instance)
					is_secondary_weapon_on_hip = false 
		else:
			if left_hip and left_hip.get_child_count() == 0:
				if sec_current_weapon_instance != null and sec_current_weapon_instance.get_parent() == left_hand:
					left_hand.remove_child(sec_current_weapon_instance)
					left_hip.add_child(sec_current_weapon_instance)
					is_secondary_weapon_on_hip = true


func addItemToCharacterSheet(icon,slot,texture):
	if icon.texture == null:
		icon.texture = texture
		slot.quantity = 1
		icon.savedata()

func fixInstance():
	if right_hand:
		right_hand.add_child(current_weapon_instance)
		current_weapon_instance.get_node("CollisionShape").disabled = true
		current_weapon_instance.scale = Vector3(100, 100, 100)
		got_weapon = true
func switchWeapon():
		
	match main_weapon:
		"sword0":
			if current_weapon_instance == null:
				current_weapon_instance = current_race_gender.sword0.instance()
				fixInstance()
				addItemToCharacterSheet(main_weap_icon,main_weap_slot,autoload.wood_sword)
		"sword1":    
			if current_weapon_instance == null:
				current_weapon_instance = current_race_gender.sword1.instance()
				fixInstance()
		"sword2":    
			if current_weapon_instance == null:
				current_weapon_instance = current_race_gender.sword2.instance()
				fixInstance()
		"staff1":
			addItemToCharacterSheet(main_weap_icon,main_weap_slot,autoload.staff1)
		"null":
			current_weapon_instance = null
			got_weapon = false
func removeWeapon():
	if got_weapon:
		right_hand.remove_child(current_weapon_instance)
		right_hip.remove_child(current_weapon_instance)
		got_weapon = false
func drop():
	if current_weapon_instance != null and Input.is_action_just_pressed("drop") and got_weapon:
		removeWeapon()
		right_hip.remove_child(current_weapon_instance)
		var drop_position = global_transform.origin + direction.normalized() * 1.0# Set the drop position
		current_weapon_instance.global_transform.origin = Vector3(drop_position.x - rand_range(0.3, 3), global_transform.origin.y + 0.2, drop_position.z + rand_range(1, 2))
		current_weapon_instance.scale = Vector3(1, 1, 1)# Set the scale of the dropped instance
		var collision_shape = current_weapon_instance.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
		get_tree().root.add_child(current_weapon_instance)
		main_weapon = "null"# Reset variables
		current_weapon_instance = null
		got_weapon = false
		main_weap_slot.item = "null"
		main_weap_icon.texture = null

func pickItemsMainHand():
	var bodies = $Mesh/Detector.get_overlapping_bodies()
	for body in bodies:
		if Input.is_action_pressed("collect"):
			if current_weapon_instance == null:
				if body.is_in_group("sword0") and not got_weapon:
					main_weapon = "sword0"
					got_weapon = true 
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword1") and not got_weapon:
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword3") and not got_weapon:
					body.queue_free()  # Remove the picked-up item from the floor
			elif current_weapon_instance != null and sec_current_weapon_instance == null:
				if body.is_in_group("sword0") and not got_sec_weapon and got_weapon:
					got_sec_weapon = true 
					secondary_weapon = "sword0"
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword1") and not got_sec_weapon:
					secondary_weapon = "sword1"
					got_sec_weapon = true  # Set the flag to prevent picking up multiple items simultaneously
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword3") and not got_sec_weapon:
					secondary_weapon = "sword1"
					got_sec_weapon = true 
					body.queue_free() 
func MainWeapon():
	switchMainFromHipToHand()
	pickItemsMainHand()
	switchWeapon()
	if Input.is_action_just_pressed("drop"):
		drop()
		main_weapon = "null"
#Secondary__________________________________________________________________________________________
var left_hand:Node=  null 
var left_hip: Node = null 
onready var sec_weap_slot = $UI/GUI/Equipment/EquipmentBG/SecWeap
onready var sec_weap_icon = $UI/GUI/Equipment/EquipmentBG/SecWeap/Icon
var sec_current_weapon_instance: Node = null  

var secondary_weapon = "null"
var got_sec_weapon = false
var is_secondary_weapon_on_hip = false 



func fixSecInstance():
	if left_hand:
		left_hand.add_child(sec_current_weapon_instance)
		sec_current_weapon_instance.get_node("CollisionShape").disabled = true
		sec_current_weapon_instance.scale = Vector3(100, 100, 100)
		got_sec_weapon = true
func switchSec():
	match secondary_weapon:
		"sword0":
			if sec_current_weapon_instance == null:
				sec_current_weapon_instance = current_race_gender.sword0.instance()
				fixSecInstance()
				addItemToCharacterSheet(sec_weap_icon,sec_weap_slot,autoload.wood_sword)
		"sword1":    
			if sec_current_weapon_instance == null:
				sec_current_weapon_instance = current_race_gender.sword1.instance()
				fixSecInstance()
		"sword2":    
			if sec_current_weapon_instance == null:
				sec_current_weapon_instance = current_race_gender.sword2.instance()
				fixSecInstance()
		"null":
			sec_current_weapon_instance = null
			got_sec_weapon = false
func pickUpShield():
	var bodies = detector.get_overlapping_bodies()
	for body in bodies:
		if Input.is_action_pressed("E"):
			if shield_currentInstance == null:
				if body.is_in_group("shield3") and not got_shield:
					has_shield0 = true
					got_shield = true
					body.queue_free()
func dropSec():
	if sec_current_weapon_instance != null and Input.is_action_just_pressed("drop") and got_sec_weapon:
		left_hand.remove_child(sec_current_weapon_instance)
		left_hip.remove_child(sec_current_weapon_instance)
		# Set the drop position
		var drop_position = global_transform.origin + direction.normalized() * 1.0
		sec_current_weapon_instance.global_transform.origin = Vector3(drop_position.x - rand_range(0, 3), global_transform.origin.y + 0.2, drop_position.z + rand_range(1, 3))
		# Set the scale of the dropped instance
		sec_current_weapon_instance.scale = Vector3(1, 1, 1)
		var collision_shape = sec_current_weapon_instance.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
		get_tree().root.add_child(sec_current_weapon_instance)
		# Reset variables
		secondary_weapon = "null"
		got_sec_weapon = false
		sec_current_weapon_instance = null
		sec_weap_icon.texture = null
		sec_weap_slot.item = "null"
func SecWeapon():
	switchSecondaryFromHipToHand()
	switchSec()
	if Input.is_action_just_pressed("drop"):
		dropSec()
		secondary_weapon = "null"
		got_sec_weapon = false
		sec_current_weapon_instance = null
		
func removeSecWeapon():
	if got_sec_weapon:
		left_hand.remove_child(sec_current_weapon_instance)
		left_hip.remove_child(sec_current_weapon_instance)
		got_sec_weapon = false
#Shield_____________________________________________________________________________________________
onready var attachment_s = $Mesh/Armature/Skeleton/HoldL2
var shield0: PackedScene = preload("res://itemTest.tscn")
var shield_currentInstance: Node = null 
var has_shield0 = false
var got_shield = false

func fixShieldInstance():
	attachment_s.add_child(shield_currentInstance)
	shield_currentInstance.get_node("CollisionShape").disabled = true
	shield_currentInstance.scale = Vector3(100, 100, 100)
	got_shield = true
func switchShield():
	if has_shield0:
		if shield_currentInstance == null:
			shield_currentInstance = shield0.instance()
			fixShieldInstance()

func dropShield():
	if shield_currentInstance != null and Input.is_action_just_pressed("drop"):
		attachment_s.remove_child(shield_currentInstance)
		# Set the drop position
		var drop_position = global_transform.origin + direction.normalized() * 1.0
		shield_currentInstance.global_transform.origin = Vector3(drop_position.x - rand_range(-0.3, 1), global_transform.origin.y + 0.2, drop_position.z + rand_range(-0.5, 0.88))
		# Set the scale of the dropped instance
		shield_currentInstance.scale = Vector3(1, 1, 1)
		var collision_shape = shield_currentInstance.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
		get_tree().root.add_child(shield_currentInstance)
		# Reset variables
		has_shield0 = false
		got_shield = false
		shield_currentInstance = null
func ShieldManagement():
	pickUpShield()
	switchShield()
	if Input.is_action_just_pressed("drop"):
		dropShield()
		has_shield0 = false

	
	
	
#____________________________________Equipment 2D_______________________________
func SwitchEquipmentBasedOnEquipmentIcons():
#__________________________main weapon__________________________________________
	if main_weap_icon != null:
		main_weap_icon.savedata()
		if main_weap_icon.texture != null:
			if main_weap_icon.texture.get_path() == autoload.wood_sword.get_path():
				main_weapon = "sword0"
				applyEffect(self, "sword0", true)
		elif main_weap_icon.texture == null:
			removeWeapon()
			main_weapon = "null"
			applyEffect(self, "sword0", false)
#__________________________sec weapon___________________________________________
	if sec_weap_icon != null:
		if sec_weap_icon.texture != null:
			if sec_weap_icon.texture.get_path() == autoload.wood_sword.get_path():
				secondary_weapon = "sword0"

		elif sec_weap_icon.texture == null:
			removeSecWeapon()
			secondary_weapon = "null"
#_______________________________head____________________________________________
	var helm_icon = $UI/GUI/Equipment/EquipmentBG/Helm/Icon
	if helm_icon != null:
		if helm_icon.texture != null:
			if helm_icon.texture.get_path() == autoload.hat1.get_path():
				head = "garment1"
		elif helm_icon.texture == null:
			head = "naked"
#_____________________________shoulder__________________________________________
	if shoulder_r_icon != null:
		if shoulder_r_icon.texture != null:
			if shoulder_r_icon.texture.get_path() == autoload.shoulder1.get_path():
				right_shoulder_pad = "1"
		elif shoulder_r_icon.texture == null:
			right_shoulder_pad = "null"
	if shoulder_l_icon != null:
		if shoulder_l_icon.texture != null:
			if shoulder_l_icon.texture.get_path() == autoload.shoulder1.get_path():
				left_shoulder_pad = "1"
		elif shoulder_l_icon.texture == null:
			left_shoulder_pad = "null"
#_______________________________chest___________________________________________
	var chest_icon = $UI/GUI/Equipment/EquipmentBG/BreastPlate/Icon
	if chest_icon != null:
		if chest_icon.texture != null:
			if chest_icon.texture.get_path() == autoload.garment1.get_path():
				torso = "garment1"
			elif chest_icon.texture.get_path() == autoload.torso_armor2.get_path():
				torso = "torso2"
			elif chest_icon.texture.get_path() == autoload.torso_armor3.get_path():
				torso = "torso3"
			elif chest_icon.texture.get_path() == autoload.torso_armor4.get_path():
				torso = "torso4"
		elif chest_icon.texture == null:
			torso = "naked"
#_______________________________belt___________________________________________
	var belt_icon = $UI/GUI/Equipment/EquipmentBG/Belt/Icon
	if belt_icon != null:
		if belt_icon.texture != null:
			if belt_icon.texture.get_path() == autoload.belt1.get_path():
				belt = "belt1"
		elif belt_icon.texture == null:
			belt = "naked"
#_______________________________legs____________________________________________
	var legs_icon = $UI/GUI/Equipment/EquipmentBG/Pants/Icon
	if legs_icon != null:
		if legs_icon.texture != null:
			if legs_icon.texture.get_path() == autoload.pants1.get_path():
				legs = "cloth1"
		elif legs_icon.texture == null:
			legs = "naked"
#_______________________________hands___________________________________________
	var hand_l_icon = $UI/GUI/Equipment/EquipmentBG/GloveL/Icon
	if hand_l_icon != null:
		if hand_l_icon.texture != null:
			if hand_l_icon.texture.get_path() == autoload.glove1.get_path():
				hand_l = "cloth1"
		elif hand_l_icon.texture == null:
			hand_l = "naked"
	var hand_r_icon = $UI/GUI/Equipment/EquipmentBG/GloveR/Icon
	if hand_r_icon != null:
		if hand_r_icon.texture != null:
			if hand_r_icon.texture.get_path() == autoload.glove1.get_path():
				hand_r = "cloth1"
		elif hand_r_icon.texture == null:
			hand_r = "naked"

#_______________________________feet____________________________________________
	var foot_r_icon = $UI/GUI/Equipment/EquipmentBG/ShoeR/Icon
	if foot_r_icon != null:
		if  foot_r_icon.texture != null:
			if  foot_r_icon.texture.get_path() == autoload.shoe1.get_path():
				foot_r = "cloth1"
		elif foot_r_icon.texture == null:
			foot_r = "naked"
			
	var foot_l_icon = $UI/GUI/Equipment/EquipmentBG/ShoeL/Icon
	if foot_l_icon != null:
		if  foot_l_icon.texture != null:
			if  foot_l_icon.texture.get_path() == autoload.shoe1.get_path():
				foot_l = "cloth1"
		elif foot_l_icon.texture == null:
			foot_l = "naked"


	var glove_icon = $UI/GUI/Equipment/EquipmentBG/GloveR/Icon
	var glove_l_icon = $UI/GUI/Equipment/EquipmentBG/GloveL/Icon
	$UI/GUI/Equipment/EquipmentBG/SecWeap/Icon.savedata()
	helm_icon.savedata()
	shoulder_l_icon.savedata()
	shoulder_r_icon.savedata()
	chest_icon.savedata()
	glove_icon.savedata()
	glove_l_icon.savedata()
	legs_icon.savedata()
	foot_l_icon.savedata()
	foot_r_icon.savedata()
	$UI/GUI/Equipment/EquipmentBG/Belt/Icon.savedata()
	$UI/GUI/Equipment/EquipmentBG/ThirdWeap/Icon.savedata()
	
#_____________________________________Equipment 3D______________________________
var head = "naked"
var torso = "naked"
var belt = "naked"
var legs = "naked"
var hand_l = "naked"
var hand_r = "naked"
var foot_l = "naked"
var foot_r = "naked"

#___________________________________Status effects______________________________
# Define effects and their corresponding stat changes
var effects = {
	"effect2": {"stats": { "extra_vitality": 2,"extra_agility": 0.05,}, "applied": false},
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
	#equipment effects______________________________________________________________________________
	"helm1": {"stats": {"blunt_resistance": 3,"heat_resistance": 6,"cold_resistance": 3,"radiant_resistance": 6}, "applied": false},
	"garment1": {"stats": {"slash_resistance": 3,"pierce_resistance": 1,"heat_resistance": 12,"cold_resistance": 12}, "applied": false},
	"belt1": {"stats": {"extra_balance": 0.03,"extra_charisma": 0.011 }, "applied": false},
	"pants1": {"stats": {"slash_resistance": 4,"pierce_resistance": 3,"heat_resistance": 6,"cold_resistance": 8}, "applied": false},
	"Lhand1": {"stats": {"slash_resistance": 1,"blunt_resistance": 1,"pierce_resistance": 1,"cold_resistance": 3,"jolt_resistance": 5,"acid_resistance": 3}, "applied": false},
	"Rhand1": {"stats": {"slash_resistance": 1,"blunt_resistance": 1,"pierce_resistance": 1,"cold_resistance": 3,"jolt_resistance": 5,"acid_resistance": 3}, "applied": false},
	"Lshoe1": {"stats": {"slash_resistance": 1,"blunt_resistance": 3,"pierce_resistance": 1,"heat_resistance": 1,"cold_resistance": 6,"jolt_resistance": 15}, "applied": false},
	"Rshoe1": {"stats": {"slash_resistance": 1,"blunt_resistance": 3,"pierce_resistance": 1,"heat_resistance": 1,"cold_resistance": 6,"jolt_resistance": 15}, "applied": false},
	"sword0": {"stats": { "extra_guard_dmg_absorbition": 0.3,"slash_dmg":12}, "applied": false}
}

# Function to apply or remove effects
func applyEffect(player: Node, effect_name: String, active: bool):

	if effects.has(effect_name):
		var effect = effects[effect_name]
		if active and not effect["applied"]:
			# Apply effect
			for stat_name in effect["stats"].keys():
				if stat_name in player:
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

onready var status_grid = $UI/GUI/Portrait/StatusGrid
func showStatusIcon():
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

	# Preload textures
	var dehydration_texture = preload("res://waterbubbles.png")
	var overhydration_texture = preload("res://waterbubbles.png")
	var bloated_texture = preload("res://UI/graphics/mushrooms/PNG/background/28.png")
	var hungry_texture = preload("res://DebuffIcons/Hungry.png")
	var bleeding_texture = preload("res://DebuffIcons/bleed.png")
	var stunned_texture = preload("res://DebuffIcons/stunned.png")
	var frozen_texture = preload("res://DebuffIcons/frozen.png")
	var blinded_texture = preload("res://DebuffIcons/blinded.png")
	var terrorized_texture = preload("res://DebuffIcons/terrorized.png")
	var scared_texture = preload("res://DebuffIcons/scared.png")
	var intimidated_texture = preload("res://DebuffIcons/intimidated.png")
	var rooted_texture = preload("res://DebuffIcons/chained.png")
	var blockbuffs_texture = preload("res://DebuffIcons/blockbuffs.png")
	var block_active_texture = preload("res://DebuffIcons/blockactiveskills.png") 
	var block_passive_texture = preload("res://DebuffIcons/blockpassive.png")
	var broken_defense_texture = preload("res://DebuffIcons/broken defense.png") 
	var bomb_texture = preload("res://DebuffIcons/bomb.png") 
	var heal_reduction_texture = preload("res://DebuffIcons/healreduction.png")
	var slow_texture = preload("res://DebuffIcons/slow.png")
	var burn_texture = preload("res://DebuffIcons/burn.png")
	var sleep_texture = preload("res://DebuffIcons/sleep.png")
	var weakness_texture = preload("res://DebuffIcons/weakness.png")
	var poisoned_texture = preload("res://DebuffIcons/poisoned.png")
	var confusion_texture = preload("res://DebuffIcons/confusion.png")
	var impaired_texture = preload("res://DebuffIcons/impaired.png")
	var lethargy_texture = preload("res://DebuffIcons/Cooldown increased.png")
	var red_potion_texture = preload("res://Potions/Red potion.png")
	# Apply status icons based on applied effects
	var applied_effects = [
		{"name": "dehydration", "texture": dehydration_texture, "modulation_color": Color(1, 0, 0)},
		{"name": "overhydration", "texture": overhydration_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bloated", "texture": bloated_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "hungry", "texture": hungry_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bleeding", "texture": bleeding_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "frozen", "texture": frozen_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "stunned", "texture": stunned_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blinded", "texture": blinded_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "terrorized", "texture": terrorized_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "scared", "texture": scared_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "intimidated", "texture": intimidated_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "rooted", "texture": rooted_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockbuffs", "texture": blockbuffs_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockactive", "texture": block_active_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockpassive", "texture": block_passive_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "brokendefense", "texture": broken_defense_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "healreduction", "texture": heal_reduction_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bomb", "texture": bomb_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "slow", "texture": slow_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "burn", "texture": burn_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "sleep", "texture": sleep_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "weakness", "texture": weakness_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "poisoned", "texture": poisoned_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "confused", "texture": confusion_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "impaired", "texture": impaired_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "lethargy", "texture": lethargy_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "redpotion", "texture": red_potion_texture, "modulation_color": Color(1, 1, 1)},
	]

	for effect in applied_effects:
		if effects.has(effect["name"]) and effects[effect["name"]]["applied"]:
			for icon in all_icons:
				if icon.texture == null:
					icon.texture = effect["texture"]
					icon.modulate = effect["modulation_color"]
					break  # Exit loop after applying status to the first available icon
#_________________________________Potion effects________________________________
func potionEffects():
	redPotion()
	
var red_potion_duration = 0
func redPotion():
	if effects.has("redpotion") and effects["redpotion"]["applied"]:
		if red_potion_duration >0:
			health += 10
			red_potion_duration -= 1
			applyEffect(self,"redpotion",true)
		else:
			applyEffect(self,"redpotion",false)
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
		applyEffect(self, "bloated", true)
	else:
		applyEffect(self, "bloated", false)
	if kilocalories < 0:
		applyEffect(self, "hungry", true)
	else:
		applyEffect(self, "hungry", false)

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
		applyEffect(self, "overhydration", true)
	elif water < 0:
		health -= 10 * elapsed_time
		applyEffect(self, "dehydration", true)
	elif water < max_water * 0.75:
		applyEffect(self, "dehydration", true)
	else:
		applyEffect(self, "overhydration", false)
		applyEffect(self, "dehydration", false)

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
var level: int = 100


const base_weight = 60
var weight = 60
const base_walk_speed = 6
var walk_speed = 3
const base_run_speed = 7
var run_speed = 7
const base_crouch_speed = 2
var crouch_speed = 2
const base_jumping_power = 20
var jumping_power = 20
const base_dash_power = 20
var dash_power = 20
var attribute = 1000

var defense =  10
const base_defense = 0

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
#leveling
var skill_points = 0

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

const base_charisma = 1 
var charisma: float = 1
var charisma_multiplier: float = 1 
var loyalty: float = 1 
var diplomacy: float = 1
var authority: float = 1
var courage: float = 1 


const base_melee_atk_speed: int = 1 
var melee_atk_speed: float = 1 
const base_ranged_atk_speed: int = 1 
var ranged_atk_speed: float = 1 
const base_casting_speed: int  = 1 
var critical_chance: float = 0.00
var critical_strength: float = 2.0
var stagger_chance: float = 0.00
var life_steal: float = 0
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


var stagger_resistance: float = 0.5
var deflection_chance : float = 0.33


var guard_dmg_absorbition: float = 1.5 #total damage taken will be divided by this when guarding
var extra_guard_dmg_absorbition:float
var total_guard_dmg_absorbition:float


var staggered = 0 
var base_flank_dmg : float = 10.0
var flank_dmg: float = 10.0 #extra damage to add to backstabs 

var extra_melee_atk_speed : float = 0


var slash_dmg: int = 0 
var pierce_dmg: int = 0
var blunt_dmg: int = 10
var sonic_dmg: int = 0
var heat_dmg: int = 0
var cold_dmg: int = 0
var jolt_dmg: int = 0
var toxic_dmg: int = 0
var acid_dmg: int = 0
var bleed_dmg: int = 0
var neuro_dmg: int = 0
var radiant_dmg: int = 0

var casting_speed: float = 1 

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


func regenStats():
	regenAefisNefis()
				

func regenAefisNefis():
	aefis = min(aefis + intelligence + wisdom, max_aefis)
	nefis = min(nefis + instinct, max_nefis)
	
	if water >= 0.75 * max_water and kilocalories >= 0.75 * max_kilocalories:
		breath = min(breath + 0.05, max_breath)
		resolve = min(resolve + 0.05, max_resolve)
		health = min(health + 0.05, max_health)




func limitStatsToMaximum():
	if health > max_health:
		health = max_health
	if resolve > max_resolve:
		resolve = max_resolve

func convertStats():
	resistanceMath()
	attackSpeedMath()
	flankDamageMath()
	updateCritical()
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
	total_guard_dmg_absorbition = extra_guard_dmg_absorbition + guard_dmg_absorbition
	
	stagger_chance = max(0, (total_impact - 1.00) * 0.45) +  max(0, (total_ferocity - 1.00) * 0.005) 
	
func flankDamageMath():
	flank_dmg = (base_flank_dmg * (total_ferocity + total_accuracy)) 

func attackSpeedMath():
	var bonus_universal_speed = (total_celerity -1) * 0.15
	var atk_speed_formula = (total_dexterity - scale_factor ) * 0.5 
	melee_atk_speed = base_melee_atk_speed + atk_speed_formula + bonus_universal_speed + extra_melee_atk_speed
	
	var atk_speed_formula_ranged = (total_strength -1) * 0.5
	ranged_atk_speed = base_ranged_atk_speed + atk_speed_formula_ranged + bonus_universal_speed
	
	var atk_speed_formula_casting = (total_instinct -1) * 0.35 + ((total_memory-1) * 0.05) + bonus_universal_speed
	casting_speed = base_casting_speed + atk_speed_formula_casting	
	
	
func resistanceMath():
	var additional_resistance: float  = 0
	var res_multiplier : float  = 0.5
	if total_resistance > 1:
		additional_resistance = res_multiplier * (total_resistance - 1)
	elif total_resistance < 1:
		additional_resistance = -res_multiplier * (1 - total_resistance)
	defense = base_defense + int(total_resistance * 10)
	max_health = (base_max_health * (total_vitality + additional_resistance)) * scale_factor
	max_breath = base_max_breath * (total_stamina  + additional_resistance)
	max_resolve = base_max_resolve * (total_tenacity + additional_resistance)


func updateCritical():
	var critical_chance = max(0, (total_accuracy - 1.00) * 0.5) +  max(0, (total_impact - 1.00) * 0.005) 
	var critical_strength = max(1.0, ((total_ferocity - 1) * 2))  # Ensure critical_strength is at least 1.0
	critical_chance_val.text = str(round(critical_chance * 100 * 1000) / 1000) + "%"
	critical_str_val.text = "x" + str(critical_strength)

func updateScaleRelatedAttributes():
	var scale_multiplication: float 
	scale_multiplication = base_charisma * (charisma_multiplier * 0.8699 * (scale_factor * 1.15))
	charisma = scale_multiplication 

func updateAefisNefis():
	var intelligence_portion = total_intelligence * 0.5
	var wisdom_portion = total_wisdom * 0.5

	max_aefis = base_max_aefis * (wisdom_portion + intelligence_portion)
	max_nefis = base_max_nefis * total_instinct

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
func allResourcesBarsAndLabels():
	displayResourcesRound(water_bar,water_label,water,max_water,"")
	displayResourcesRound(food_bar,food_label,kilocalories,max_kilocalories,"")
	displayResourcesRound(ne_bar,ne_label,nefis,max_nefis,"NE : ")
	displayResourcesRound(ae_bar,ae_label,aefis,max_aefis,"AE : ")
	displayResourcesRound(re_bar,re_label,resolve,max_resolve,"RE : ")
	displayResourcesRound(br_bar,br_label,breath,max_breath,"BH : ")
func displayResources(bar,label,value,max_value,acronim):
	label.text =  acronim + ": %.2f / %.2f" % [value,max_value]
	bar.value = value 
	bar.max_value = max_value 
func displayResourcesRound(bar,label,value,max_value,acronim):
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

func displayLabels():
	var cast_spd_label: Label = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/CastingSpeedValue
	displayStats(cast_spd_label,casting_speed)
	var ran_spd_label: Label = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/RangedSpeedValue
	displayStats(ran_spd_label,ranged_atk_speed)
	var atk_spd_label: Label = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/AtkSpeedValue
	displayStats(atk_spd_label,melee_atk_speed)
	var life_steal_label: Label = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/LifeStealValue
	displayStats(life_steal_label,life_steal)
	var stagger_chance_label: Label = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/StaggerChanceValue
	displayStats(stagger_chance_label,stagger_chance)
	
	
	var flank_dmg_label = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/FlankDMGValue
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
	#damages____________________________________________________________________
	var val_dmg_slash : Label = $UI/GUI/Equipment/DmgDef/Damages/Slaval
	displayStats(val_dmg_slash, slash_dmg)
	var val_dmg_blunt : Label = $UI/GUI/Equipment/DmgDef/Damages/Bluntval
	displayStats(val_dmg_blunt, blunt_dmg)
	var val_dmg_pierce : Label = $UI/GUI/Equipment/DmgDef/Damages/Pierceval
	displayStats(val_dmg_pierce, pierce_dmg)
	var val_dmg_sonic : Label = $UI/GUI/Equipment/DmgDef/Damages/Sonicval
	displayStats(val_dmg_sonic, sonic_dmg)
	var val_dmg_heat : Label = $UI/GUI/Equipment/DmgDef/Damages/Heatval
	displayStats(val_dmg_heat, heat_dmg)
	var val_dmg_cold : Label = $UI/GUI/Equipment/DmgDef/Damages/Coldval
	displayStats(val_dmg_cold, cold_dmg)
	var val_dmg_jolt : Label = $UI/GUI/Equipment/DmgDef/Damages/Joltval
	displayStats(val_dmg_jolt, jolt_dmg)
	var val_dmg_toxic : Label = $UI/GUI/Equipment/DmgDef/Damages/Toxicval
	displayStats(val_dmg_toxic, toxic_dmg)
	var val_dmg_acid : Label = $UI/GUI/Equipment/DmgDef/Damages/Acidval
	displayStats(val_dmg_acid, acid_dmg)
	var val_dmg_bleed : Label = $UI/GUI/Equipment/DmgDef/Damages/Bleedval
	displayStats(val_dmg_bleed, bleed_dmg)
	var val_dmg_neuro : Label = $UI/GUI/Equipment/DmgDef/Damages/Neuroval
	displayStats(val_dmg_neuro, neuro_dmg)
	var val_dmg_radiant : Label = $UI/GUI/Equipment/DmgDef/Damages/Radiantval
	displayStats(val_dmg_radiant, radiant_dmg)




func displayStats(label, value):
	var rounded_value = str(round(value * 1000) / 1000)
	label.text = rounded_value

func connectAttributeHovering():
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
func intHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func intExited():
	deleteTooltip()
func insHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func insExited():
	deleteTooltip()
func wisHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func wisExited():
	deleteTooltip()
func memHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func memExited():
	deleteTooltip()
func sanHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func sanExited():
	deleteTooltip()

func strHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func strExited():
	deleteTooltip()
func forceHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func forceExited():
	deleteTooltip()
func impHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func impExited():
	deleteTooltip()
func ferHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func ferExited():
	deleteTooltip()
func furHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func furExited():
	deleteTooltip()


func vitHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func vitExited():
	deleteTooltip()
func staHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func staExited():
	deleteTooltip()
func endHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func endExited():
	deleteTooltip()
func resHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func resExited():
	deleteTooltip()
func tenHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func tenExited():
	deleteTooltip()

func agiHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func agiExited():
	deleteTooltip()
func hasHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func hasExited():
	deleteTooltip()
func celHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func celExited():
	deleteTooltip()
func fleHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func fleExited():
	deleteTooltip()

func defHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func defExited():
	deleteTooltip()
func dexHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func dexExited():
	deleteTooltip()
func accHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func accExited():
	deleteTooltip()
func focHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func focExited():
	deleteTooltip()
func poiHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func poiExited():
	deleteTooltip()
func balHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func balExited():
	deleteTooltip()
	
func chaHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func chaExited():
	deleteTooltip()
func dipHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func dipExited():
	deleteTooltip()
func autHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func autExited():
	deleteTooltip()
func couHovered():
	var instance = preload("res://tooltip.tscn").instance()
	callToolTip(instance,"placeholder","holder placer")
func couExited():
	deleteTooltip()
func loyHovered():
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	callToolTip(instance, "Colt Resistance", tooltip_text)	
func joltResExited():
	deleteTooltip()
	
func toxicResHovered():
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var instance = preload("res://tooltip.tscn").instance()
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
	var result: Array = increaseAttribute(spent_attribute_points_int,intelligence)
	spent_attribute_points_int = result[0]
	intelligence = result[1]
	print(spent_attribute_points_int)
func minusInt():
	var result: Array = decreaseAttribute(spent_attribute_points_int,intelligence)
	spent_attribute_points_int = result[0]
	intelligence = result[1]
func plusIns():#instinct
	var result: Array = increaseAttribute(spent_attribute_points_ins,instinct)
	spent_attribute_points_ins = result[0]
	instinct = result[1]
	print(spent_attribute_points_ins)
func minusIns():
	var result: Array = decreaseAttribute(spent_attribute_points_ins,instinct)
	spent_attribute_points_ins = result[0]
	instinct = result[1]
func plusWis():#wisdom
	var result: Array = increaseAttribute(spent_attribute_points_wis,wisdom)
	spent_attribute_points_wis = result[0]
	wisdom = result[1]
	print(spent_attribute_points_wis)
func minusWis():
	var result: Array = decreaseAttribute(spent_attribute_points_wis,wisdom)
	spent_attribute_points_wis = result[0]
	wisdom = result[1]
func plusMem():#memory
	var result: Array = increaseAttribute(spent_attribute_points_mem,memory)
	spent_attribute_points_mem = result[0]
	memory = result[1]
	print(spent_attribute_points_mem)
func minusMem():
	var result: Array = decreaseAttribute(spent_attribute_points_mem,memory)
	spent_attribute_points_mem = result[0]
	memory = result[1]
func plusSan():#sanity
	var result: Array = increaseAttribute(spent_attribute_points_san,sanity)
	spent_attribute_points_san = result[0]
	sanity = result[1]
	print(spent_attribute_points_san)
func minusSan():
	var result: Array = decreaseAttribute(spent_attribute_points_san,sanity)
	spent_attribute_points_san = result[0]
	sanity = result[1]
func plusStr():#strength
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
	var result: Array = decreaseAttribute(spent_attribute_points_cha,charisma)
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




onready var critical_chance_val = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/CritChanceValue
onready var critical_str_val = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/CritDamageValue





func updateAllStats():
	updateAefisNefis()

	updateScaleRelatedAttributes()
	updateCritical()




#___________________________________________Save data system________________________________________
func saveGame():
	savePlayerData()
	saveInventoryData()
	saveSkillBarData()

var entity_name: String = "dai"
var slot: String = "1"
var save_directory: String
var save_path: String 
func savePlayerData():
	current_race_gender.savePlayerData()
	var data = {
		"sex": sex,
		"species":species,
		
		
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
		"charisma_multiplier":charisma_multiplier,
		"loyalty": loyalty,
		"diplomacy": diplomacy,
		"authority": authority,
		"courage": courage,
		
		"hair_color": hair_color,
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
			if "sex" in player_data:
				sex = player_data["sex"]
			if "species" in player_data:
				species = player_data["species"]
				
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
			if "charisma_multiplier" in player_data:
				charisma_multiplier = player_data["charisma_multiplier"]
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
			if "wraith" in player_data:
				necromant.summoned_demons = player_data["wraith"]
				
			if "hair_color" in player_data:
				hair_color = player_data["hair_color"]
				
func _on_pressme_pressed():
	health = 5
	breath = 5
	aefis = 5 
	nefis += 25
	resolve = 5 
	
func _on_pressme2_pressed():
	slash_resistance = rng.randi_range(-125, 125)
	pierce_resistance = rng.randi_range(-125, 125)
	blunt_resistance= rng.randi_range(-125, 125)
	sonic_resistance= rng.randi_range(-125, 125)
	heat_resistance= rng.randi_range(-125, 125)
	cold_resistance= rng.randi_range(-125, 125)
	jolt_resistance= rng.randi_range(-125, 125)
	toxic_resistance= rng.randi_range(-125, 125)
	acid_resistance= rng.randi_range(-125, 125)
	bleed_resistance= rng.randi_range(-125, 125)
	neuro_resistance= rng.randi_range(-125, 125)
	radiant_resistance= rng.randi_range(-125, 125)

var aiming_mode: String = "directional"
onready var aim_label: Label = $UI/GUI/Menu/AimingMode/AimLabel
func _on_AimingMode_pressed():
		if aiming_mode == "camera":
			aiming_mode = "directional"
			aim_label.text = aiming_mode
		else:
			aiming_mode = "camera"
			aim_label.text = aiming_mode
var species: String = "human"
var sex: String = "xx"
var current_race_gender: Node = null 

func switchSexRace():
	main_weapon = "null"
	secondary_weapon = "null"
	right_shoulder_pad = "null"
	left_shoulder_pad = "null"
	
	match sex:
		"xy":
			match species:
				"saurus":
					if current_race_gender != null:
						current_race_gender.queue_free() # Delete previous gender scene
					current_race_gender = autoload.saurus.instance()
					current_race_gender.player = self 
					raceInstacePreparations()
					InstanceRace()
				"human":
					if current_race_gender != null:
						current_race_gender.queue_free() # Delete previous gender scene
					current_race_gender = autoload.human_male.instance()
					current_race_gender.player = self 
					raceInstacePreparations()
					InstanceRace()
				"panthera":
					if current_race_gender != null:
						current_race_gender.queue_free() # Delete previous gender scene
					current_race_gender = autoload.panthera_male.instance()
					current_race_gender.player = self 
					raceInstacePreparations()
					InstanceRace()
				"sepris":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.sepris.instance()
					current_race_gender.player = self 
					raceInstacePreparations()
					InstanceRace()
				"bireas":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.bireas.instance()
					raceInstacePreparations()
					InstanceRace()
				"skeleton":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.skeleton.instance()
					raceInstacePreparations()
					InstanceRace()
				"kadosiel":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.kadosiel.instance()
					raceInstacePreparations()
					InstanceRace()
		"xx":
			match species:
				"saurus":
					if current_race_gender != null:
						current_race_gender.queue_free() # Delete previous gender scene
					current_race_gender = autoload.saurus.instance()
					raceInstacePreparations()
					InstanceRace()
				"human":
					if current_race_gender != null:
						current_race_gender.queue_free() # Delete previous gender scene
					current_race_gender = autoload.human_female.instance()
					raceInstacePreparations()
					InstanceRace()
				"panthera":
					if current_race_gender != null:
						current_race_gender.queue_free() # Delete previous gender scene
					current_race_gender = autoload.panthera_female.instance()
					raceInstacePreparations()
					InstanceRace()
				"sepris":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.sepris.instance()
					raceInstacePreparations()
					InstanceRace()
				"bireas":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.bireas.instance()
					raceInstacePreparations()
					InstanceRace()
				"skeleton":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.skeleton.instance()
					raceInstacePreparations()
					InstanceRace()
				"kadosiel":
					if current_race_gender != null:
						current_race_gender.queue_free()
					current_race_gender = autoload.kadosiel.instance()
					raceInstacePreparations()
					InstanceRace()
	if is_instance_valid(current_race_gender):
		right_hand = current_race_gender.right_hand
		left_hand = current_race_gender.left_hand
		right_hip = current_race_gender.left_hip
		left_hip = current_race_gender.right_hip
		left_shoulder = current_race_gender.shoulder_l
		right_shoulder = current_race_gender.shoulder_r
		var current_face_set = current_race_gender.face_set


func raceInstacePreparations():
	current_race_gender.player = self 
	current_race_gender.save_directory = save_directory
	current_race_gender.save_path = save_path + "colors.dat"
func InstanceRace():
	player_mesh.add_child(current_race_gender)

func _on_switchGender_pressed():
	
	current_race_gender.player = self 
	if sex == "xy":
		sex = "xx"
	else:
		sex = "xy"
	switchSexRace() # Call the function to change gender and update scene
	current_race_gender.EquipmentSwitch()


var species_list = ["sepris", "human","skeleton","panthera","bireas","saurus","kadosiel"]# Define the list of available species
var current_species_index = 0# Initialize the index of the current species
func _on_switchRace_pressed():
	current_species_index += 1# Increment the index to move to the next species
	if current_species_index >= species_list.size():# Wrap around to the beginning if reached the end of the list
		current_species_index = 0
	species = species_list[current_species_index]
	switchSexRace() # Call the function to change gender and update scene
	current_race_gender.EquipmentSwitch()
	current_race_gender.hairstyle = hair_list[current_hair_index]
	current_race_gender.face_set = face_list[current_face_index]

var hair_list = ["1", "2", "3","4","5","6","7","8",]
var current_hair_index = 0

func _on_switchhair_pressed():
	current_hair_index += 1  # Increment the index to move to the next hairstyle
	if current_hair_index >= hair_list.size():  # Wrap around to the beginning if reached the end of the list
		current_hair_index = 0  # Reset index to the beginning
	current_race_gender.hairstyle = hair_list[current_hair_index]
	current_race_gender.switchHair()
	colorhair()

var face_list = ["1", "2", "3", "4","5"]
var current_face_index = 0
func _on_switch_face_pressed():
	current_face_index += 1  # Increment the index to move to the next face
	if current_face_index >= face_list.size():  # Wrap around to the beginning if reached the end of the list
		current_face_index = 0  # Reset index to the beginning
	current_race_gender.face_set = face_list[current_face_index]
	current_race_gender.switchFace()

func _on_ArmorColorSwitch_pressed():
	current_race_gender.randomizeArmor()

func _on_SkinColorSwitch_pressed():
	current_race_gender._on_Button_pressed()

var hair_color_change = true 
var hair_color: Color = Color(1, 1, 1)  # Default color
func _on_ColorPicker_color_changed(color):
	if hair_color_change:
		if current_race_gender.current_hair_instance:
			# Assuming your hair models have a material with a color property
			var hair_material = current_race_gender.current_hair_instance.material_override
			if hair_material:
				# Set the color property of the material
				hair_material.albedo_color = color
				hair_material.flags_unshaded = true
				hair_color = color
				colorhair()

func colorhair():
	if current_race_gender.current_hair_instance:
		var original_material = current_race_gender.current_hair_instance.material_override	# Get the original material of the hair instance
		if original_material:# Check if the original material is not null
			var new_material = original_material.duplicate()# Duplicate the original material
			current_race_gender.current_hair_instance.material_override = new_material# Assign the new material to the hair instance
			new_material.albedo_color = hair_color# Set the color property of the new material

func _on_BlendshapeTest_pressed():
	current_race_gender.smile = rand_range(-2,+2)
	current_race_gender.current_face_instance.set("blend_shapes/Smile",current_race_gender.smile)
