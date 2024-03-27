extends KinematicBody
onready var player_mesh = $Mesh
onready var animation = $Mesh/Race/AnimationPlayer
var rng = RandomNumberGenerator.new()
var injured: bool = false
var blend: float = 0.25

# Condition States
var is_attacking = bool()
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()


func _ready():
	connectUIButtons()
	connectInventoryButtons()
	connectAttributeButtons()
	connectAttributeHovering()
	connectHoveredResistanceLabels()
	convertStats()
	loadPlayerData()
	closeAllUI()
	SwitchEquipmentBasedOnEquipmentIcons()
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)
func _on_SlowTimer_timeout():
	allResourcesBarsAndLabels()
	showEnemyStats()
	potionEffects()
	switchHead()
	switchTorso()
	switchFootL()
	switchFootR()
	switchLegs()
	convertStats()
	money()
	hunger()
	hydration()	
	frameRate()	
	showStatusIcon()	
	displayLabels()
	regenStats()
	
	
	

func _on_3FPS_timeout():


	crafting()
	displayResources(hp_bar,hp_label,health,max_health,"HP")
	curtainsDown()
	SwitchEquipmentBasedOnEquipmentIcons()
	updateAllStats()
func _physics_process(delta: float) -> void:
	$Debug.text = animation_state
#	displayClock()
	ChopTree()
	limitStatsToMaximum()
	cameraRotation(delta)
	crossHair()
	crossHairResize()
	minimapFollow()
	miniMapVisibility()
	stiffCamera(delta)
	walk(delta)
	climbing()
	gravity(delta)
	jump()
	dodgeBack(delta)
	dodgeFront(delta)
	dodgeLeft(delta)
	dodgeRight(delta)
	fullscreen()

	#showEnemyStats()
	matchAnimationStates()
	animations()
	attack()
	doubleAttack(delta)
	fallDamage()
	skillUserInterfaceInputs()
	addItemToInventory()
#	positionCoordinates()
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
func walk(delta):
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

	physicsSauce()
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)
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
						animation_state = "vaulting"
						vertical_velocity = Vector3.UP * 3 
					elif not is_wall_in_range:#normal climb
						animation_state = "climbing"
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
var jump_animation_duration = 0
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
var gravity_force = 9.8
func gravity(delta):
	# Gravity mechanics and prevent slope-sliding
	if not is_climbing:
		if not is_on_floor(): 
			vertical_velocity += Vector3.DOWN * gravity_force * 2 * delta
		else: 
			vertical_velocity = -get_floor_normal() * gravity_force / 2.5 #This must be always set 2.5 for climbing system to work 
var fall_damage = 0
var fall_distance = 0
var minimum_fall_distance = 0.5
func fallDamage():
	if animation_state == "fall" and !is_climbing and !is_on_wall():
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
func physicsSauce():
	# The Physics Sauce. Movement, gravity and velocity in a perfect dance.
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
#__________________________________________More action based movement_______________________________
# Dodge
export var double_press_time: float = 0.4
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
func dodgeBack(delta):#Doddge when in strafe mode
		if dash_countback > 0:
			dash_timerback += delta
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
func dodgeFront(delta):#Dodge when in strafe mode
		if dash_countforward > 0:
			dash_timerforward += delta
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
func dodgeLeft(delta):#Dodge when in strafe mode
		if dash_countleft > 0:
			dash_timerleft += delta
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
func dodgeRight(delta):#Dodge when in strafe mode
		if dash_countright > 0:
			dash_timerright += delta
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
func cameraRotation(delta):
	if not cursor_visible:
		camrot_v = clamp(camrot_v, cam_v_min, cam_v_max)
		#MOUSE CAMERA
		camera_h.rotation_degrees.y = lerp(camera_h.rotation_degrees.y, camrot_h, delta * h_acceleration)
		camera_v.rotation_degrees.x = lerp(camera_v.rotation_degrees.x, camrot_v, delta * v_acceleration)
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
func stiffCamera(delta: float):
	if is_aiming and !is_climbing:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)
#	elif is_climbing:
#		if direction != Vector3.ZERO and is_climbing:
#			player_mesh.rotation.y = -(atan2($ClimbRay.get_collision_normal().z,$ClimbRay.get_collision_normal().x) - PI/2)
	else: # Normal turn movement mechanics
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
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
		savePlayerData()



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
		if body.is_in_group("Entity") and body != self:
			# Instantly turn alpha to maximum
			entity_graphic_interface.modulate.a = 1.0
			enemy_health_bar.value = body.health
			enemy_health_bar.max_value = body.max_health
			enemy_health_label.text = "HP:" + str(round(body.health* 100) / 100) + "/" + str(body.max_health)
			enemy_energy_bar.value = body.energy
			enemy_energy_bar.max_value = body.max_energy
			enemy_energy_label.text = "EP:" + str(round(body.energy* 100) / 100) + "/" + str(body.max_energy)
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
	$UI/GUI/EnemyUI/StatusGrid/Icon20
)

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
var weapon_type: String = "fist"
var animation_state: String = "idle"
func matchAnimationStates():
	match animation_state:
#_______________________________attacking states________________________________
		"slide":
			var slide_blend = 0.3
			animation.play("slide",slide_blend)
			var slide_mov_speed = 15 + slide_blend + rand_range(3, 6)
			if !is_on_wall():
				horizontal_velocity = direction * slide_mov_speed
			movement_speed = int(slide_mov_speed)
		"base attack":
			animation.play("full combo cycle",0.3,1.25)
			if can_move == true:
				horizontal_velocity = direction * 3
				movement_speed = 3
			elif can_move == false:
				horizontal_velocity = direction * 0
				movement_speed = 0
		"double attack":
			if weapon_type == "fist":
				animation.play("high kick",0.3,1)
			if can_move and !is_on_wall():
				horizontal_velocity = direction * 7
				movement_speed = 7
			else:
				horizontal_velocity = direction * 0.3
				movement_speed = 0
		"guard attack":
			animation.play("stomp cycle",0.55,1)
			if can_move and !is_on_wall():
				horizontal_velocity = direction * 2
				movement_speed = 2
			else:
				horizontal_velocity = direction * 0.01
				movement_speed = 0
		"run attack":
			animation.play("low kick",0.3)#placeholder
			if can_move and !is_on_wall():
				horizontal_velocity = direction * 2
				movement_speed = 2
			else:
				horizontal_velocity = direction * 0.01
				movement_speed = 0
		"sprint attack":
			animation.play("stomp kick",0.3)#placeholder
			if can_move and !is_on_wall():
				horizontal_velocity = direction * 2
				movement_speed = 2
			else:
				horizontal_velocity = direction * 0.01
				movement_speed = 0
#__________________________________guarding states______________________________
		"guard":
			animation.play("guard",0.3)
		"guard walk":
			pass
#_________________________________walking states________________________________
		"walk":
			if is_in_combat:
				if weapon_type == "fist":
					animation.play("walk fist cycle",0,1)
			else:
				animation.play("walk cycle")
		"crouch walk":
			animation.play("walk crouch cycle")
		"crouch":
			animation.play("idle crouch",0.4)
#movement 
		"sprint":
			animation.play("run cycle", 0, sprint_animation_speed * agility)
		"run":
			animation.play("run cycle",0,agility)
		"jump":
			animation.play("jump",0.2, agility)
		"fall":
			animation.play("fall",0.3)
		"climbing":
			animation.play("climb cycle",blend, strength)
		"vaulting":
			animation.play("vaulting",0.7, strength)
		"landing":
			pass
		"crawl":
			animation.play("crawl cycle")
		"crawl limit":
			animation.play("crawl dying limit cycle")
		"idle downed":
			animation.play("idle downed", 0.35)
		"idle":
			if is_in_combat:
				if weapon_type == "fist":
					animation.play("barehanded idle",0.2,1)
			else:
				animation.play("idle cycle")
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
			var slot = $UI/GUI/SkillBar/GridContainer/Slot0/Icon
			skills(slot)
		"testQ":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotQ/Icon
			skills(slot)
		"testE":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotE/Icon
			skills(slot)
		"testR":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotR/Icon
			skills(slot)
		"testT":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotT/Icon
			skills(slot)
		"testF":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotF/Icon
			skills(slot)
		"testG":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotG/Icon
			skills(slot)
		"testY":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotY/Icon
			skills(slot)
		"testH":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotH/Icon
			skills(slot)
		"testV":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotV/Icon
			skills(slot)
		"testB":
			var slot = $UI/GUI/SkillBar/GridContainer/SlotB/Icon
			skills(slot)
func skills(slot):
	if slot != null:
			if slot.texture != null:
				if slot.texture.resource_path == "res://UI/graphics/SkillIcons/rush.png":
					animation.play("combo attack 2hander cycle", 0.35)
				elif slot.texture.resource_path == "res://UI/graphics/SkillIcons/selfheal.png":
					animation.play("crawl cycle", 0.35)
				else:
					pass
var sprint_animation_speed : float = 1
func animations():
#on water
	if is_swimming:
		if is_walking:
			animation_state = "swim"
		else:
			animation_state = "idle water"
#on land
	elif dodge_animation_duration > 0 and resolve >0:
		resolve -= 0.2
		animation_state = "slide"
		jump_animation_duration = 0 


	elif not is_on_floor() and not is_climbing and not is_swimming:
		animation_state = "fall"
		jump_animation_duration = 0 
	elif double_atk_animation_duration > 0 and !cursor_visible: 
		animation_state = "double attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("rclick") and Input.is_action_pressed("attack") and !cursor_visible:
		animation_state = "guard attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("rclick") and !cursor_visible:
		if !is_walking:
			animation_state = "guard"
			jump_animation_duration = 0 
		else:
			animation_state = "guard walk"
			jump_animation_duration = 0 
#attacks________________________________________________________________________
	elif Input.is_action_pressed("attack") and Input.is_action_pressed("run") and !cursor_visible: 
		animation_state = "run attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("attack") and Input.is_action_pressed("sprint") and !cursor_visible: 
		animation_state = "sprint attack"
		jump_animation_duration = 0 
	elif Input.is_action_pressed("attack") and !cursor_visible:
			animation_state = "base attack"
			jump_animation_duration = 0 
#_______________________________________________________________________________
			
#skills put these below the walk elif statment in case of keybinding bugs, as of now it works so no need
	elif Input.is_action_pressed("1"):
		animation_state = "test1"
	elif Input.is_action_pressed("2"):
		animation_state = "test2"
	elif Input.is_action_pressed("3"):
		animation_state = "test3"
	elif Input.is_action_pressed("4"):
		animation_state = "test4"
	elif Input.is_action_pressed("5"):
		animation_state = "test5"
	elif Input.is_action_pressed("6"):
		animation_state = "test6"
	elif Input.is_action_pressed("7"):
		animation_state = "test7"
	elif Input.is_action_pressed("8"):
		animation_state = "test8"
	elif Input.is_action_pressed("9"):
		animation_state = "test9"
	elif Input.is_action_pressed("0"):
		animation_state = "test0"
	elif Input.is_action_pressed("Q"):
		animation_state = "testQ"
	elif Input.is_action_pressed("E"):
		animation_state = "testE"
	elif Input.is_action_pressed("R"):
		animation_state = "testR"
	elif Input.is_action_pressed("F"):
		animation_state = "testF"
	elif Input.is_action_pressed("R"):
		animation_state = "testR"
	elif Input.is_action_pressed("T"):
		animation_state = "testT"
	elif Input.is_action_pressed("G"):
		animation_state = "testG"
	elif Input.is_action_pressed("H"):
		animation_state = "testY"
	elif Input.is_action_pressed("V"):
		animation_state = "testV"
	elif Input.is_action_pressed("B"):
		animation_state = "testB" 
#_______________________________________________________________________________
		
	elif is_sprinting == true:
			animation_state = "sprint"
			jump_animation_duration = 0 
	elif is_running:
			animation_state = "run"
			jump_animation_duration = 0 
	elif is_walking:
			animation_state = "walk"
			jump_animation_duration = 0 

	
	elif Input.is_action_pressed("crouch"):
		animation_state = "crouch" 
		jump_animation_duration = 0 
	
	elif jump_animation_duration != 0:
		animation_state = "jump"
	else:
		animation_state = "idle"


#_______________________________________________Combat______________________________________________

func attack():
	if Input.is_action_pressed("attack"):
		is_attacking = true
	else:
		is_attacking = false
#Double click to heavy attack_______________________________________________________________________
var double_atk_count: int = 0
var double_atk_timer: float = 0.0
var double_atk_animation_duration : float  = 0
var double_atk_animation_max_duration : float  = 1.125
func doubleAttack(delta):
		if double_atk_count > 0:
			double_atk_timer += delta
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
func stompKickDealDamage():
	shake_camera(0.2, 0.05, 0, 1)
	var damage_type = "blunt"
	var damage = 25
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			enemy.applyEffect(enemy,"effect1", true)
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance *2:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)



func slideDealDamage():
	var damage_type: String = "blunt"
	var damage: float = 2.5
	var aggro_power : float = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
				else:#jump attack kick slide
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage *2,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage *2 ,aggro_power,self,stagger_chance,damage_type)
func PunchDealDamage1():
	var damage_type = "blunt"
	var damage = 10
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
				else:#jump attack kick slide
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage *2,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage *2 ,aggro_power,self,stagger_chance,damage_type)
func PunchDealDamage2():
	var damage_type = "blunt"
	var damage = 5
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
				else:#jump attack kick slide
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage *2,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage *2 ,aggro_power,self,stagger_chance,damage_type)
func PunchDealDamage3():
	var damage_type = "blunt"
	var damage = 15
	var aggro_power = damage + 20
	var enemies = $Mesh/Detector.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
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



var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_view  = $Mesh/TakeDamageView/Viewport
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type):
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
		print(damage_to_take)

		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "pierce":
		var mitigation = pierce_resistance / (pierce_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "blunt":
		var mitigation = blunt_resistance / (blunt_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "sonic":
		var mitigation = sonic_resistance / (sonic_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "heat":
		var mitigation = heat_resistance / (heat_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "cold":
		var mitigation = cold_resistance / (cold_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
			
	elif damage_type == "jolt":
		var mitigation = jolt_resistance / (jolt_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "toxic":
		var mitigation = toxic_resistance / (toxic_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "acid":
		var mitigation = acid_resistance / (acid_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "bleed":
		var mitigation = bleed_resistance / (bleed_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "neuro":
		var mitigation = neuro_resistance / (neuro_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
		
	elif damage_type == "radiant":
		var mitigation = radiant_resistance / (radiant_resistance + 100.0)
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
	if animation_state == "guard":
		health -= (damage_to_take * 0.3)
		text.amount = ((damage_to_take * 0.3) * 100)/ 100
		text.status = "Guarded"
		text.state = damage_type
	else:
		health -= damage_to_take
		text.amount =round(damage_to_take * 100)/ 100
		text.state = damage_type
	take_damage_view.add_child(text)



#___________________________________close buttons/inputs_______________________________

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
		saveSkillBarData()
		savePlayerData()
	elif Input.is_action_just_pressed("tab"):
		is_in_combat = !is_in_combat
		switchMainFromHipToHand()
		switchSecondaryFromHipToHand()
		saveSkillBarData()
		savePlayerData()
	elif Input.is_action_just_pressed("mousemode") or Input.is_action_just_pressed("ui_cancel"):	# Toggle mouse mode
		saveInventoryData()
		saveSkillBarData()
		savePlayerData()
		cursor_visible =!cursor_visible
	if !cursor_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("Inventory"):
		closeSwitchOpen(inventory)
		saveInventoryData()
		saveSkillBarData()
		savePlayerData()
	elif Input.is_action_just_pressed("Crafting"):
		closeSwitchOpen(crafting)
		saveInventoryData()
		saveSkillBarData()
		savePlayerData()
	elif Input.is_action_just_pressed("Character"):
		closeSwitchOpen(character)
		savePlayerData()
	elif Input.is_action_just_pressed("UI"):
		closeSwitchOpen(character)
		closeSwitchOpen(crafting)
		closeSwitchOpen(inventory)
		closeSwitchOpen(skill_trees)
		savePlayerData()
	elif Input.is_action_just_pressed("Menu"):
		closeSwitchOpen(menu)
		savePlayerData()
#skillbar buttons
func _on_Inventory_pressed():
	closeSwitchOpen(inventory)
	savePlayerData()
func _on_Character_pressed():
	closeSwitchOpen(character)
	savePlayerData()
func _on_Skills_pressed():
	closeSwitchOpen(skill_trees)
	savePlayerData()
func _on_Menu_pressed():
	closeSwitchOpen(menu)
	savePlayerData()
func _on_OpenAllUI_pressed():
	closeSwitchOpen(character)
	closeSwitchOpen(crafting)
	closeSwitchOpen(inventory)
	closeSwitchOpen(skill_trees)
	savePlayerData()
	
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
	savePlayerData()
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
	savePlayerData()
	saveSkillBarData()
	get_tree().quit()
func _on_InventorySaveButton_pressed():
	saveInventoryData()
	savePlayerData()
	saveSkillBarData()
onready var skills_list1 = $UI/GUI/SkillTrees/Background/SylvanSkills
func _on_SkillTree1_pressed():
	closeSwitchOpen(skills_list1)
	saveSkillBarData()
	
func saveInventoryData():
	var inventory_grid = $UI/GUI/Inventory/ScrollContainer/InventoryGrid
	# Call savedata() function on each child of inventory_grid that belongs to the group "Inventory"
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.get_node("Icon").has_method("savedata"):
				child.get_node("Icon").savedata()
func saveSkillBarData():
	for child in $UI/GUI/SkillBar/GridContainer.get_children():
		if child.has_method("savedata"):
			child.savedata()

#__________________________________Inventory____________________________________
onready var inventory_grid = $UI/GUI/Inventory/ScrollContainer/InventoryGrid
onready var gui = $UI/GUI


func connectInventoryButtons():
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			var index_str = child.get_name().split("InventorySlot")[1]
			var index = int(index_str)
			child.connect("pressed", self, "_on_inventory_slot_pressed", [index])
			child.connect("mouse_entered", self, "_on_inventory_slot_mouse_entered", [index])
			child.connect("mouse_exited", self, "_on_inventory_slot_mouse_exited", [index])

var last_pressed_index: int = -1
var last_press_time: float = 0.0
export var double_press_time_inv: float = 0.4

func _on_inventory_slot_pressed(index):
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture_rect = button.get_node("Icon")
	var icon_texture = icon_texture_rect.texture	
	if icon_texture != null:
		if  icon_texture.get_path() == "res://UI/graphics/SkillIcons/empty.png":
				button.quantity = 0
		var current_time = OS.get_ticks_msec() / 1000.0
		if last_pressed_index == index and current_time - last_press_time <= double_press_time_inv:
			print("Inventory slot", index, "pressed twice")

			if icon_texture.get_path() == "res://UI/graphics/mushrooms/PNG/background/1.png":
					kilocalories += 22
					water += 92
					button.quantity -=1
			elif icon_texture.get_path() == "res://Potions/Red potion.png":
					kilocalories += 100
					health += 100
					water += 250
					applyEffect(self,"redpotion",true)
					red_potion_duration += 5
					button.quantity -=1
					add_item.addStackableItem(inventory_grid,add_item.empty_potion,1)
			elif icon_texture.get_path() == "res://Food Icons/Fruits/strawberry.png":
					kilocalories +=1
					health += 5
					water += 2
					button.quantity -=1
			elif icon_texture.get_path() == "res://Food Icons/Fruits/raspberries.png":
					kilocalories += 4
					health += 3
					water += 3
					button.quantity -=1
			elif icon_texture.get_path() == "res://Food Icons/Vegetables/beetroot.png":
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
func _on_inventory_slot_mouse_entered(index):
	var button = inventory_grid.get_node("InventorySlot" + str(index))
	var icon_texture = button.get_node("Icon").texture
	var instance = preload("res://tooltip.tscn").instance()
	if icon_texture != null:
		if icon_texture.get_path() == "res://Potions/Red potion.png":
			callToolTip(instance, "Red Potion", "+100 kcals +250 grams of water.\nHeals by 100 health instantly then by 10 every second, drinking more potions stacks the duration")
		
		
		elif icon_texture.get_path() == "res://Food Icons/Fruits/strawberry.png":
			callToolTip(instance,"Strawberry","+5 health points +9 kcals +24 grams of water")
		elif icon_texture.get_path() == "res://Food Icons/Fruits/raspberries.png":
			callToolTip(instance,"Raspberry","+3 health points +1 kcals +2 grams of water")
		elif icon_texture.get_path() == "res://Food Icons/Vegetables/beetroot.png":
			callToolTip(instance,"beetroot","+15 health points +32 kcals +71.8 grams of water")
			
			
		#equipment icons
		elif icon_texture.get_path() == "res://Equipment icons/hat1.png":
			callToolTip(instance,"Farmer Hat","+3 blunt resistance.\n +6 heat resistance.\n +3 cold resistance.\n +6 radiant resistance.")
		elif icon_texture.get_path() == "res://Equipment icons/garment1.png":
			callToolTip(instance,"Farmer Jacket","+3 slash resistance.\n +1 pierce resistance.\n +12 heat resistance.\n +12 cold resistance.")
		elif icon_texture.get_path() == "res://Equipment icons/belt1.png":
			callToolTip(instance,"Farmer Belt","+3 slash resistance.\n +1 pierce resistance.\n +12 heat resistance.\n +12 cold resistance.")
		elif icon_texture.get_path() == "res://Equipment icons/glove1.png":
			callToolTip(instance,"Farmer Glove","+3 slash resistance.\n +1 pierce resistance.\n +12 heat resistance.\n +12 cold resistance.")
		elif icon_texture.get_path() == "res://Equipment icons/pants1.png":
			callToolTip(instance,"Farmer Pants","+3 slash resistance.\n +1 pierce resistance.\n +12 heat resistance.\n +12 cold resistance.")
		elif icon_texture.get_path() == "res://Equipment icons/shoe1.png":
			callToolTip(instance,"Farmer Shoe","+1 slash resistance.\n +1 blunt resistance.\n +3 pierce resistance.\n +1 heat resistance.\n +6 cold resistance.\n +15 jolt resistance.\n")

			
func _on_inventory_slot_mouse_exited(index):
	for child in gui.get_children():
		if child.is_in_group("Tooltip"):
			child.queue_free()

func callToolTip(instance,title, text):
		gui.add_child(instance)
		instance.showTooltip(title, text)
# Function to combine slots when pressed
func _on_CombineSlots_pressed():
	savePlayerData()
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


func _on_SplitFirstSlot_pressed():
	savePlayerData()
	saveInventoryData()
	var first_slot = $UI/GUI/Inventory/ScrollContainer/InventoryGrid/InventorySlot1
	if first_slot.is_in_group("Inventory"):
		var first_icon = first_slot.get_node("Icon")
		if first_icon.texture != null:
			var original_quantity = first_slot.quantity
			if original_quantity > 1:
				var new_quantity = original_quantity / 2  # Calculate the new quantity
				first_slot.quantity = original_quantity - new_quantity  # Update the quantity of the first slot
				for child in inventory_grid.get_children():
					if child.is_in_group("Inventory"):
						var icon = child.get_node("Icon")
						if icon.texture == null:
							icon.texture = first_icon.texture
							child.quantity += original_quantity / 2
							break

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
onready var icon = $CraftingResultSlot/Icon

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
					add_item.addStackableItem(inventory_grid,add_item.aubergine,loot_amount)
					add_item.addFloatingIcon(take_damage_view,add_item.aubergine,loot_amount)
				# 25% chance for acorn
				elif random_value < 0.4:
					loot_amount = rng.randi_range(5, 45)
					add_item.addStackableItem(inventory_grid,add_item.raspberry,loot_amount)
					add_item.addFloatingIcon(take_damage_view,add_item.raspberry,loot_amount)
				# 25% chance for branch
				elif random_value < 0.6:
					loot_amount = rng.randi_range(3, 5)
					add_item.addStackableItem(inventory_grid,add_item.potato,loot_amount)
					add_item.addFloatingIcon(take_damage_view,add_item.potato,loot_amount)
				elif random_value < 0.8:
					loot_amount = rng.randi_range(15, 25)
					add_item.addStackableItem(inventory_grid,add_item.onion,loot_amount)
					add_item.addFloatingIcon(take_damage_view,add_item.onion,loot_amount)
		# 25% chance for resin
				else:
					loot_amount = rng.randi_range(1, 5)
					add_item.addStackableItem(inventory_grid,add_item.beetroot,loot_amount)
					add_item.addFloatingIcon(take_damage_view,add_item.beetroot,loot_amount)



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
	add_item.addStackableItem(inventory_grid,add_item.garlic,200)
	add_item.addFloatingIcon(take_damage_view,add_item.garlic,200)
	
	add_item.addStackableItem(inventory_grid,add_item.potato,200)
	add_item.addFloatingIcon(take_damage_view,add_item.potato,200)
	add_item.addStackableItem(inventory_grid,add_item.onion,200)
	add_item.addStackableItem(inventory_grid,add_item.carrot,200)
	add_item.addStackableItem(inventory_grid,add_item.corn,200)
	add_item.addStackableItem(inventory_grid,add_item.cabbage,200)
	add_item.addStackableItem(inventory_grid,add_item.bell_pepper,200)
	add_item.addStackableItem(inventory_grid,add_item.aubergine,200)
	add_item.addStackableItem(inventory_grid,add_item.tomato,200)

	
	add_item.addStackableItem(inventory_grid,add_item.raspberry,200)
	add_item.addStackableItem(inventory_grid,add_item.pants1,200)
	add_item.addStackableItem(inventory_grid,add_item.hat1,200)
	add_item.addStackableItem(inventory_grid,add_item.red_potion,200)
	add_item.addStackableItem(inventory_grid,add_item.strawberry,200)
	add_item.addStackableItem(inventory_grid,add_item.beetroot,200)
	add_item.addStackableItem(inventory_grid,add_item.rosehip,200)
	add_item.addStackableItem(inventory_grid,add_item.belt1,200)
	add_item.addStackableItem(inventory_grid,add_item.glove1,200)
	add_item.addNotStackableItem(inventory_grid,add_item.wood_sword)
	add_item.addNotStackableItem(inventory_grid,add_item.garment1)
	add_item.addNotStackableItem(inventory_grid,add_item.shoe1)
	
	
	
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
onready var fps_label = $UI/GUI/Portrait/MinimapHolder/FPS
func frameRate():
	var current_fps = Engine.get_frames_per_second()
	var new_fps = current_fps + 15
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
#onready var coordinates = $UI/GUI/Minimap/Coordinates
#func positionCoordinates():
#	var rounded_position = Vector3(
#		round(global_transform.origin.x * 10) / 10,
#		round(global_transform.origin.y * 10) / 10,
#		round(global_transform.origin.z * 10) / 10
#	)
#	# Use %d to format integers without decimals
#	coordinates.text = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]


#__________________________________Weapon Management____________________________
#Main Weapon____________________________________________________________________
onready var attachment_r = $Mesh/Race/Armature/Skeleton/HoldL
onready var attachment_hip = $Mesh/Race/Armature/Skeleton/Hip
onready var detector = $Mesh/Detector
onready var main_weap_slot = $UI/GUI/Equipment/EquipmentBG/MainWeap
onready var main_weap_icon = $UI/GUI/Equipment/EquipmentBG/MainWeap/Icon
var sword0: PackedScene = preload("res://itemTest.tscn")
var sword1: PackedScene = preload("res://itemTest.tscn")
var sword2: PackedScene = preload("res://itemTest.tscn")
var currentInstance: Node = null  
var main_weapon = "null"
var got_weapon = false
var sheet_weapon = false
var is_primary_weapon_on_hip = false
var is_chopping_trees = false
func switchMainFromHipToHand():
	if is_in_combat or is_chopping_trees:
		if attachment_r.get_child_count() == 0:
			if currentInstance != null and currentInstance.get_parent() == attachment_hip:
				# Rotate the weapon before adding it to the hand
				attachment_hip.remove_child(currentInstance)
				attachment_r.add_child(currentInstance)
				is_primary_weapon_on_hip = false
	else:
		if attachment_hip.get_child_count() == 0:
			if currentInstance != null and currentInstance.get_parent() == attachment_r:
				# Rotate the weapon before adding it to the hip
				attachment_r.remove_child(currentInstance)
				attachment_hip.add_child(currentInstance)
				#currentInstance.rotation_degrees = Vector3(-6.9,-2.105,-16)
				#currentInstance.translate(Vector3(0.049,0.019,-0.005))
				is_primary_weapon_on_hip = true

func addItemToCharacterSheet(icon,slot,texture,item):
	if icon.texture == null:
		icon.texture = texture
		slot.quantity = 1
		slot.item = item

func fixInstance():
	attachment_r.add_child(currentInstance)
	currentInstance.get_node("CollisionShape").disabled = true
	#currentInstance.scale = Vector3(100, 100, 100)
	got_weapon = true
func switch():
	match main_weapon:
		"sword0":
			if currentInstance == null:
				currentInstance = sword0.instance()
				fixInstance()
				addItemToCharacterSheet(main_weap_icon,main_weap_slot,add_item.wood_sword,"sword0")
		"sword1":    
			if currentInstance == null:
				currentInstance = sword1.instance()
				fixInstance()
		"sword2":    
			if currentInstance == null:
				currentInstance = sword2.instance()
				fixInstance()
		"null":
			currentInstance = null
			
			got_weapon = false
func removeWeapon():
	if got_weapon:
		attachment_r.remove_child(currentInstance)
		attachment_hip.remove_child(currentInstance)
		got_weapon = false
func drop():
	if currentInstance != null and Input.is_action_just_pressed("drop") and got_weapon:
		removeWeapon()
		attachment_hip.remove_child(currentInstance)
		# Set the drop position
		var drop_position = global_transform.origin + direction.normalized() * 1.0
		currentInstance.global_transform.origin = Vector3(drop_position.x - rand_range(0.3, 3), global_transform.origin.y + 0.2, drop_position.z + rand_range(1, 2))
		# Set the scale of the dropped instance
		currentInstance.scale = Vector3(1, 1, 1)
		var collision_shape = currentInstance.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
		get_tree().root.add_child(currentInstance)
		# Reset variables
		main_weapon = "null"
		currentInstance = null
		got_weapon = false
		main_weap_slot.item = "null"
		main_weap_icon.texture = null

func pickItemsMainHand():
	var bodies = $Mesh/Detector.get_overlapping_bodies()
	for body in bodies:
		if Input.is_action_pressed("collect"):
			#print(currentInstance)
			if currentInstance == null:
				if body.is_in_group("sword0") and not got_weapon:
					main_weapon = "sword0"
					got_weapon = true 
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword1") and not got_weapon:


					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword3") and not got_weapon:


					body.queue_free()  # Remove the picked-up item from the floor
			elif currentInstance != null and sec_currentInstance == null:
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
	switch()
	if Input.is_action_just_pressed("drop"):
		drop()
		main_weapon = "null"
#Secondary__________________________________________________________________________________________
onready var attachment_l = $Mesh/Race/Armature/Skeleton/HoldL2
onready var attachment_hip_sec = $Mesh/Race/Armature/Skeleton/Hip2
onready var sec_weap_slot = $UI/GUI/Character/Equipment/SecWeap
onready var sec_weap_icon = $UI/GUI/Character/Equipment/SecWeap/Icon
var sec_currentInstance: Node = null  

var secondary_weapon = "null"
var got_sec_weapon = false
var is_secondary_weapon_on_hip = false 
func switchSecondaryFromHipToHand():
	if is_in_combat:
		if attachment_l.get_child_count() == 0:
			if sec_currentInstance != null and sec_currentInstance.get_parent() == attachment_hip_sec:
				attachment_hip_sec.remove_child(sec_currentInstance)
				attachment_l.add_child(sec_currentInstance)
				is_secondary_weapon_on_hip = false 
	else:
		if attachment_hip_sec.get_child_count() == 0:
			if sec_currentInstance != null and sec_currentInstance.get_parent() == attachment_l:
				attachment_l.remove_child(sec_currentInstance)
				attachment_hip_sec.add_child(sec_currentInstance)
				is_secondary_weapon_on_hip = true
func fixSecInstance():
	attachment_l.add_child(sec_currentInstance)
	sec_currentInstance.get_node("CollisionShape").disabled = true
	#sec_currentInstance.scale = Vector3(100, 100, 100)
	got_sec_weapon = true
func switchSec():
	match secondary_weapon:
		"sword0":
			if sec_currentInstance == null:
				sec_currentInstance = sword0.instance()
				fixSecInstance()
				addItemToCharacterSheet(sec_weap_icon,sec_weap_slot,add_item.wood_sword,"sword0")
		"sword1":    
			if sec_currentInstance == null:
				sec_currentInstance = sword1.instance()
				fixSecInstance()
		"sword2":    
			if sec_currentInstance == null:
				sec_currentInstance = sword2.instance()
				fixSecInstance()
		"null":
			sec_currentInstance = null
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
	if sec_currentInstance != null and Input.is_action_just_pressed("drop") and got_sec_weapon:
		attachment_l.remove_child(sec_currentInstance)
		attachment_hip_sec.remove_child(sec_currentInstance)
		# Set the drop position
		var drop_position = global_transform.origin + direction.normalized() * 1.0
		sec_currentInstance.global_transform.origin = Vector3(drop_position.x - rand_range(0, 3), global_transform.origin.y + 0.2, drop_position.z + rand_range(1, 3))
		# Set the scale of the dropped instance
		sec_currentInstance.scale = Vector3(1, 1, 1)
		var collision_shape = sec_currentInstance.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
		get_tree().root.add_child(sec_currentInstance)
		# Reset variables
		secondary_weapon = "null"
		got_sec_weapon = false
		sec_currentInstance = null
		sec_weap_icon.texture = null
		sec_weap_slot.item = "null"
func SecWeapon():
	switchSecondaryFromHipToHand()
	switchSec()
	if Input.is_action_just_pressed("drop"):
		dropSec()
		secondary_weapon = "null"
		got_sec_weapon = false
		sec_currentInstance = null
		
func removeSecWeapon():
	if got_sec_weapon:
		attachment_l.remove_child(sec_currentInstance)
		attachment_hip_sec.remove_child(sec_currentInstance)
		got_sec_weapon = false
#Shield_____________________________________________________________________________________________
onready var attachment_s = $Mesh/Armature020/Skeleton/HoldL2
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
			if main_weap_icon.texture.get_path() == "res://0.png":
				main_weapon = "sword0"
				applyEffect(self, "effect2", true)
		elif main_weap_icon.texture == null:
			removeWeapon()
			main_weapon = "null"
			applyEffect(self, "effect2", false)
#__________________________sec weapon___________________________________________
	if sec_weap_icon != null:
		if sec_weap_icon.texture != null:
			if sec_weap_icon.texture.get_path() == "res://0.png":
				secondary_weapon = "sword0"
				applyEffect(self, "effect1", true)
		elif sec_weap_icon.texture == null:
			removeSecWeapon()
			secondary_weapon = "null"
			applyEffect(self, "effect1", false)	
#_______________________________head____________________________________________
	var helm_icon = $UI/GUI/Equipment/EquipmentBG/Helm/Icon
	if helm_icon != null:
		if helm_icon.texture != null:
			if helm_icon.texture.get_path() == "res://Equipment icons/hat1.png":
				head = "garment1"
		elif helm_icon.texture == null:
			head = "naked"

#_______________________________chest___________________________________________
	var chest_icon = $UI/GUI/Equipment/EquipmentBG/BreastPlate/Icon
	if chest_icon != null:
		if chest_icon.texture != null:
			if chest_icon.texture.get_path() == "res://Equipment icons/garment1.png":
				torso = "garment1"
		elif chest_icon.texture == null:
			torso = "naked"

#_______________________________legs____________________________________________
	var legs_icon = $UI/GUI/Equipment/EquipmentBG/Pants/Icon
	if legs_icon != null:
		if legs_icon.texture != null:
			if legs_icon.texture.get_path() == "res://Equipment icons/pants1.png":
				legs = "cloth1"
		elif legs_icon.texture == null:
			legs = "naked"

#_______________________________feet____________________________________________
	var foot_r_icon = $UI/GUI/Equipment/EquipmentBG/ShoeR/Icon
	if foot_r_icon != null:
		if  foot_r_icon.texture != null:
			if  foot_r_icon.texture.get_path() == "res://Equipment icons/shoe1.png":
				foot_r = "cloth1"
		elif foot_r_icon.texture == null:
			foot_r = "naked"
			
	var foot_l_icon = $UI/GUI/Equipment/EquipmentBG/ShoeL/Icon
	if foot_l_icon != null:
		if  foot_l_icon.texture != null:
			if  foot_l_icon.texture.get_path() == "res://Equipment icons/shoe1.png":
				foot_l = "cloth1"
		elif foot_l_icon.texture == null:
			foot_l = "naked"


	var glove_icon = $UI/GUI/Equipment/EquipmentBG/GloveR/Icon
	var glove_l_icon = $UI/GUI/Equipment/EquipmentBG/GloveL/Icon
	var shoulder_r_icon = $UI/GUI/Equipment/EquipmentBG/ShoeR/Icon
	var shoulder_l_icon = $UI/GUI/Equipment/EquipmentBG/ShoeL/Icon
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
func switchHead():
	var head0 = null
	var head1 = null
	match head:
		"naked":
			applyEffect(self,"helm1", false)
		"garment1":
			applyEffect(self,"helm1", true)
var torso = "naked"
func switchTorso():
	var torso0 = $Mesh/Race/Armature/Skeleton/Torso0
	var torso1 = $Mesh/Race/Armature/Skeleton/Torso1
	match torso:
		"naked":
			torso0.visible = true 
			torso1.visible = false
			applyEffect(self,"garment1", false)
		"garment1":
			torso0.visible = false
			torso1.visible = true
			applyEffect(self,"garment1", true)

var legs = "naked"
func switchLegs():
	var legs0 = $Mesh/Race/Armature/Skeleton/legs0
	var legs1 = $Mesh/Race/Armature/Skeleton/legs1
	match legs:
		"naked":
			legs0.visible = true 
			legs1.visible = false
			applyEffect(self,"pants1", false)
			
		"cloth1":
			legs0.visible = false
			legs1.visible = true	
			applyEffect(self,"pants1", true)
			
var foot_l = "naked"
func switchFootL():
	var feet0 = $Mesh/Race/Armature/Skeleton/feet0
	var feet1 = $Mesh/Race/Armature/Skeleton/feet1
	match foot_l:
		"naked":
			feet0.visible = true 
			feet1.visible = false
			applyEffect(self,"Lshoe1", false)
		"cloth1":
			feet0.visible = false
			feet1.visible = true
			applyEffect(self,"Lshoe1", true)
var foot_r = "naked"
func switchFootR():
	var feet0 = null
	var feet1 = null
	match foot_r:
		"naked":
#			feet0.visible = true 
#			feet1.visible = false
			applyEffect(self,"Rshoe1", false)
		"cloth1":
#			feet0.visible = false
#			feet1.visible = true
			applyEffect(self,"Rshoe1", true)	
#___________________________________Status effects______________________________
# Define effects and their corresponding stat changes
var effects = {
	"garment": {"stats": {"agility": -0.05, "strength": 0.1}, "applied": false},
	"effect1": {"stats": {"energy": -500000000, "mana": 10}, "applied": false},
	"effect2": {"stats": { "vitality": 2,"agility": 0.05,}, "applied": false},
	"overhydration": {"stats": { "vitality": -0.02,"agility": -0.05,}, "applied": false},
	"dehydration": {"stats": { "intelligence": -0.25,"agility": -0.25,}, "applied": false},
	"bloated": {"stats": {"intelligence": -0.02,"agility": -0.15,}, "applied": false},
	"hungry": {"stats": {"intelligence": -0.22,"agility": -0.05,}, "applied": false},
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
	"confused": {"stats": { "intelligence": -0.75}, "applied": false},
	"impaired": {"stats": { "dexterity": -0.25}, "applied": false},
	"lethargy": {"stats": {}, "applied": false},
	"redpotion": {"stats": {}, "applied": false},
	#equipment effects______________________________________________________________________________
	"helm1": {"stats": {"blunt_resistance": 3,"heat_resistance": 6,"cold_resistance": 3,"radiant_resistance": 6}, "applied": false},
	"garment1": {"stats": {"slash_resistance": 3,"pierce_resistance": 1,"heat_resistance": 12,"cold_resistance": 12}, "applied": false},
	"pants1": {"stats": {"slash_resistance": 4,"pierce_resistance": 3,"heat_resistance": 6,"cold_resistance": 8}, "applied": false},
	"Lshoe1": {"stats": {"slash_resistance": 1,"blunt_resistance": 3,"pierce_resistance": 1,"heat_resistance": 1,"cold_resistance": 6,"jolt_resistance": 15}, "applied": false},
	"Rshoe1": {"stats": {"slash_resistance": 1,"blunt_resistance": 3,"pierce_resistance": 1,"heat_resistance": 1,"cold_resistance": 6,"jolt_resistance": 15}, "applied": false},
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
		else:
			applyEffect(self,"redpotion",false)
#_____________________________Hunger system and Hydration System___________________________
onready var kilocalories_label = $UI/GUI/Portrait/Kilocalories
onready var kilocalories_bar = $UI/GUI/Portrait/KilocaloriesBar
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
		kilocalories -= 500
		water -= 125
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
				enemy.applyEffect(enemy,"effect1", true)
				if enemy.has_method("takeDamage"):
					if is_on_floor():
						#insert sound effect here
							enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)


#Stats__________________________________________________________________________
var level = 100
var energy = 100
var max_energy = 100
const base_max_energy = 100


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

var sanity  = 1
var wisdom = 1
var memory = 1
var intelligence = 1
var instinct = 1

var force = 1
var strength = 1
var impact = 1
var ferocity  = 1 
var fury = 1 

var accuracy = 1
var dexterity = 1
var poise = 1
var balance = 1
var focus = 1

var haste = 1
var agility = 1
var celerity = 1
var flexibility = 1
var deflection = 1

var endurance = 1
var stamina = 1
var vitality = 1
var resistance = 1
var tenacity = 1

const base_charisma = 1 
var charisma = 1
var charisma_multiplier = 1 
var loyalty = 1 
var diplomacy = 1
var authority = 1
var empathy = 1
var courage = 1 
var recovery = 1

const base_melee_atk_speed: int = 1 
var melee_atk_speed: float = 1 
const base_ranged_atk_speed: int = 1 
var ranged_atk_speed: float = 1 
const base_casting_speed: int  = 1 
var critical_chance: float = 0.00
var critical_strength: float = 2
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

var staggered = 0 

func regenStats():
	#regen resolve
	if resolve < max_resolve:
		resolve += recovery
		
	#breath 
	if water > max_water * 0.3:
		if kilocalories > max_kilocalories * 0.3:
			if breath < max_breath:
				breath += stamina
				
		
func limitStatsToMaximum():
	if health > max_health:
		health = max_health
	if resolve > max_resolve:
		resolve = max_resolve

func convertStats():
	max_health = base_max_health * vitality
	max_sprint_speed = base_max_sprint_speed * agility
	run_speed = base_run_speed * agility

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
	displayResourcesRound(ne_bar,ne_label,nefis,max_resolve,"NE : ")
	displayResourcesRound(ae_bar,ae_label,aefis,max_resolve,"AE : ")
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
	
	var int_lab = $UI/GUI/Equipment/Attributes/Intelligence/value
	displayStats(int_lab, intelligence)
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
	displayStats(val_cha,charisma_multiplier)
	var val_dip = $UI/GUI/Equipment/Attributes/Diplomacy/value
	displayStats(val_dip,diplomacy)
	var val_au = $UI/GUI/Equipment/Attributes/Authority/value
	displayStats(val_au,authority)	
	var val_cou = $UI/GUI/Equipment/Attributes/Courage/value
	displayStats(val_cou,courage)
	var val_loy = $UI/GUI/Equipment/Attributes/Loyalty/value
	displayStats(val_loy,loyalty)
	
	displayStats(value_ins, instinct)
	displayStats(value_wis, wisdom)
	displayStats(value_mem, memory)
	displayStats(value_san, sanity)
	displayStats(value_force, force)
	displayStats(value_strength, strength)
	displayStats(value_impact, impact)
	displayStats(value_ferocity, ferocity)
	displayStats(value_fury, fury)	
	displayStats(value_accuracy, accuracy)
	displayStats(value_dexterity, dexterity)
	displayStats(value_poise, poise)
	displayStats(value_balance, balance)
	displayStats(value_focus, focus)
	displayStats(value_haste, haste)
	displayStats(value_agility, agility)
	displayStats(value_celerity, celerity)
	displayStats(value_flexibility, flexibility)
	displayStats(value_deflection, deflection)
	displayStats(value_endurance, endurance)
	displayStats(value_stamina, stamina)
	displayStats(value_vitality, vitality)
	displayStats(value_resistance, resistance)
	displayStats(value_tenacity, tenacity)
	
	
	#resistances and damages________________________________________________
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
	var empathy_label = $UI/GUI/Equipment/Attributes/Empathy
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
#intelligence
func plusInt():
	if attribute >0:
		if spent_attribute_points_int < 5:
			spent_attribute_points_int += 1
			attribute -= 1 
			intelligence += attribute_increase_factor
		elif spent_attribute_points_int < 10:
			spent_attribute_points_int += 1
			attribute -= 1 
			intelligence += attribute_increase_factor * 0.5
		elif spent_attribute_points_int < 15:
			spent_attribute_points_int += 1
			attribute -= 1 
			intelligence += attribute_increase_factor * 0.2
		elif spent_attribute_points_int < 20:
			spent_attribute_points_int += 1
			attribute -= 1
			intelligence += attribute_increase_factor * 0.1
		elif spent_attribute_points_int < 25:
			spent_attribute_points_int += 1
			attribute -= 1 
			intelligence += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_int += 1
			attribute -= 1 
			intelligence += attribute_increase_factor * 0.01
func minusInt():
	if intelligence > 0.05:
		spent_attribute_points_int -= 1
		attribute += 1 
		if spent_attribute_points_int < 5:
			intelligence -= attribute_increase_factor
		elif spent_attribute_points_int < 10:
			intelligence -= attribute_increase_factor * 0.5
		elif spent_attribute_points_int < 15:
			intelligence -= attribute_increase_factor * 0.2
		elif spent_attribute_points_int < 20:
			intelligence -= attribute_increase_factor * 0.1
		elif spent_attribute_points_int < 25:
			intelligence -= attribute_increase_factor * 0.05
		else:
			intelligence -= attribute_increase_factor * 0.01
#Instincts
func plusIns():
	if attribute > 0:
		if spent_attribute_points_ins < 5:
			spent_attribute_points_ins += 1
			attribute -= 1
			instinct += attribute_increase_factor
		elif spent_attribute_points_ins < 10:
			spent_attribute_points_ins += 1
			attribute -= 1
			instinct += attribute_increase_factor * 0.5
		elif spent_attribute_points_ins < 15:
			spent_attribute_points_ins += 1
			attribute -= 1
			instinct += attribute_increase_factor * 0.2
		elif spent_attribute_points_ins < 20:
			spent_attribute_points_ins += 1
			attribute -= 1
			instinct += attribute_increase_factor * 0.1
		elif spent_attribute_points_ins < 25:
			spent_attribute_points_ins += 1
			attribute -= 1
			instinct += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_ins += 1
			attribute -= 1
			instinct += attribute_increase_factor * 0.01
func minusIns():
	if instinct > 0.05:
		spent_attribute_points_ins -= 1
		attribute += 1
		if spent_attribute_points_ins < 5:
			instinct -= attribute_increase_factor
		elif spent_attribute_points_ins < 10:
			instinct -= attribute_increase_factor * 0.5
		elif spent_attribute_points_ins < 15:
			instinct -= attribute_increase_factor * 0.2
		elif spent_attribute_points_ins < 20:
			instinct -= attribute_increase_factor * 0.1
		elif spent_attribute_points_ins < 25:
			instinct -= attribute_increase_factor * 0.05
		else:
			instinct -= attribute_increase_factor * 0.01
# Wisdom
func plusWis():
	if attribute > 0:
		if spent_attribute_points_wis < 5:
			spent_attribute_points_wis += 1
			attribute -= 1
			wisdom += attribute_increase_factor
		elif spent_attribute_points_wis < 10:
			spent_attribute_points_wis += 1
			attribute -= 1
			wisdom += attribute_increase_factor * 0.5
		elif spent_attribute_points_wis < 15:
			spent_attribute_points_wis += 1
			attribute -= 1
			wisdom += attribute_increase_factor * 0.2
		elif spent_attribute_points_wis < 20:
			spent_attribute_points_wis += 1
			attribute -= 1
			wisdom += attribute_increase_factor * 0.1
		elif spent_attribute_points_wis < 25:
			spent_attribute_points_wis += 1
			attribute -= 1
			wisdom += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_wis += 1
			attribute -= 1
			wisdom += attribute_increase_factor * 0.01
func minusWis():
	if wisdom > 0.05:
		spent_attribute_points_wis -= 1
		attribute += 1
		if spent_attribute_points_wis < 5:
			wisdom -= attribute_increase_factor
		elif spent_attribute_points_wis < 10:
			wisdom -= attribute_increase_factor * 0.5
		elif spent_attribute_points_wis < 15:
			wisdom -= attribute_increase_factor * 0.2
		elif spent_attribute_points_wis < 20:
			wisdom -= attribute_increase_factor * 0.1
		elif spent_attribute_points_wis < 25:
			wisdom -= attribute_increase_factor * 0.05
		else:
			wisdom -= attribute_increase_factor * 0.01
# Memory
func plusMem():
	if attribute > 0:
		if spent_attribute_points_mem < 5:
			spent_attribute_points_mem += 1
			attribute -= 1
			memory += attribute_increase_factor
		elif spent_attribute_points_mem < 10:
			spent_attribute_points_mem += 1
			attribute -= 1
			memory += attribute_increase_factor * 0.5
		elif spent_attribute_points_mem < 15:
			spent_attribute_points_mem += 1
			attribute -= 1
			memory += attribute_increase_factor * 0.2
		elif spent_attribute_points_mem < 20:
			spent_attribute_points_mem += 1
			attribute -= 1
			memory += attribute_increase_factor * 0.1
		elif spent_attribute_points_mem < 25:
			spent_attribute_points_mem += 1
			attribute -= 1
			memory += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_mem += 1
			attribute -= 1
			memory += attribute_increase_factor * 0.01
func minusMem():
	if memory > 0.05:
		spent_attribute_points_mem -= 1
		attribute += 1
		if spent_attribute_points_mem < 5:
			memory -= attribute_increase_factor
		elif spent_attribute_points_mem < 10:
			memory -= attribute_increase_factor * 0.5
		elif spent_attribute_points_mem < 15:
			memory -= attribute_increase_factor * 0.2
		elif spent_attribute_points_mem < 20:
			memory -= attribute_increase_factor * 0.1
		elif spent_attribute_points_mem < 25:
			memory -= attribute_increase_factor * 0.05
		else:
			memory -= attribute_increase_factor * 0.01
# Sanity
func plusSan():
	if attribute > 0:
		if spent_attribute_points_san < 5:
			spent_attribute_points_san += 1
			attribute -= 1
			sanity += attribute_increase_factor
		elif spent_attribute_points_san < 10:
			spent_attribute_points_san += 1
			attribute -= 1
			sanity += attribute_increase_factor * 0.5
		elif spent_attribute_points_san < 15:
			spent_attribute_points_san += 1
			attribute -= 1
			sanity += attribute_increase_factor * 0.2
		elif spent_attribute_points_san < 20:
			spent_attribute_points_san += 1
			attribute -= 1
			sanity += attribute_increase_factor * 0.1
		elif spent_attribute_points_san < 25:
			spent_attribute_points_san += 1
			attribute -= 1
			sanity += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_san += 1
			attribute -= 1
			sanity += attribute_increase_factor * 0.01
func minusSan():
	if sanity > 0.05:
		spent_attribute_points_san -= 1
		attribute += 1
		if spent_attribute_points_san < 5:
			sanity -= attribute_increase_factor
		elif spent_attribute_points_san < 10:
			sanity -= attribute_increase_factor * 0.5
		elif spent_attribute_points_san < 15:
			sanity -= attribute_increase_factor * 0.2
		elif spent_attribute_points_san < 20:
			sanity -= attribute_increase_factor * 0.1
		elif spent_attribute_points_san < 25:
			sanity -= attribute_increase_factor * 0.05
		else:
			sanity -= attribute_increase_factor * 0.01
#Strength
func plusStr():
	if attribute > 0:
		if spent_attribute_points_str < 5:
			spent_attribute_points_str += 1
			attribute -= 1
			strength += attribute_increase_factor
		elif spent_attribute_points_str < 10:
			spent_attribute_points_str += 1
			attribute -= 1
			strength += attribute_increase_factor * 0.5
		elif spent_attribute_points_str < 15:
			spent_attribute_points_str += 1
			attribute -= 1
			strength += attribute_increase_factor * 0.2
		elif spent_attribute_points_str < 20:
			spent_attribute_points_str += 1
			attribute -= 1
			strength += attribute_increase_factor * 0.1
		elif spent_attribute_points_str < 25:
			spent_attribute_points_str += 1
			attribute -= 1
			strength += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_str += 1
			attribute -= 1
			strength += attribute_increase_factor * 0.01
func minusStr():
	if strength > 0.05:
		spent_attribute_points_str -= 1
		attribute += 1
		if spent_attribute_points_str < 5:
			strength -= attribute_increase_factor
		elif spent_attribute_points_str < 10:
			strength -= attribute_increase_factor * 0.5
		elif spent_attribute_points_str < 15:
			strength -= attribute_increase_factor * 0.2
		elif spent_attribute_points_str < 20:
			strength -= attribute_increase_factor * 0.1
		elif spent_attribute_points_str < 25:
			strength -= attribute_increase_factor * 0.05
		else:
			strength -= attribute_increase_factor * 0.01
#Force
func plusFor():
	if attribute > 0:
		if spent_attribute_points_for < 5:
			spent_attribute_points_for += 1
			attribute -= 1
			force += attribute_increase_factor
		elif spent_attribute_points_for < 10:
			spent_attribute_points_for += 1
			attribute -= 1
			force += attribute_increase_factor * 0.5
		elif spent_attribute_points_for < 15:
			spent_attribute_points_for += 1
			attribute -= 1
			force += attribute_increase_factor * 0.2
		elif spent_attribute_points_for < 20:
			spent_attribute_points_for += 1
			attribute -= 1
			force += attribute_increase_factor * 0.1
		elif spent_attribute_points_for < 25:
			spent_attribute_points_for += 1
			attribute -= 1
			force += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_for += 1
			attribute -= 1
			force += attribute_increase_factor * 0.01
func minusFor():
	if force > 0.05:
		spent_attribute_points_for -= 1
		attribute += 1
		if spent_attribute_points_for < 5:
			force -= attribute_increase_factor
		elif spent_attribute_points_for < 10:
			force -= attribute_increase_factor * 0.5
		elif spent_attribute_points_for < 15:
			force -= attribute_increase_factor * 0.2
		elif spent_attribute_points_for < 20:
			force -= attribute_increase_factor * 0.1
		elif spent_attribute_points_for < 25:
			force -= attribute_increase_factor * 0.05
		else:
			force -= attribute_increase_factor * 0.01
#Impact
func plusImp():
	if attribute > 0:
		if spent_attribute_points_imp < 5:
			spent_attribute_points_imp += 1
			attribute -= 1
			impact += attribute_increase_factor
		elif spent_attribute_points_imp < 10:
			spent_attribute_points_imp += 1
			attribute -= 1
			impact += attribute_increase_factor * 0.5
		elif spent_attribute_points_imp < 15:
			spent_attribute_points_imp += 1
			attribute -= 1
			impact += attribute_increase_factor * 0.2
		elif spent_attribute_points_imp < 20:
			spent_attribute_points_imp += 1
			attribute -= 1
			impact += attribute_increase_factor * 0.1
		elif spent_attribute_points_imp < 25:
			spent_attribute_points_imp += 1
			attribute -= 1
			impact += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_imp += 1
			attribute -= 1
			impact += attribute_increase_factor * 0.01
func minusImp():
	if impact > 0.05:
		spent_attribute_points_imp -= 1
		attribute += 1
		if spent_attribute_points_imp < 5:
			impact -= attribute_increase_factor
		elif spent_attribute_points_imp < 10:
			impact -= attribute_increase_factor * 0.5
		elif spent_attribute_points_imp < 15:
			impact -= attribute_increase_factor * 0.2
		elif spent_attribute_points_imp < 20:
			impact -= attribute_increase_factor * 0.1
		elif spent_attribute_points_imp < 25:
			impact -= attribute_increase_factor * 0.05
		else:
			impact -= attribute_increase_factor * 0.01
#Ferocity
func plusFer():
	if attribute > 0:
		if spent_attribute_points_fer < 5:
			spent_attribute_points_fer += 1
			attribute -= 1
			ferocity += attribute_increase_factor
		elif spent_attribute_points_fer < 10:
			spent_attribute_points_fer += 1
			attribute -= 1
			ferocity += attribute_increase_factor * 0.5
		elif spent_attribute_points_fer < 15:
			spent_attribute_points_fer += 1
			attribute -= 1
			ferocity += attribute_increase_factor * 0.2
		elif spent_attribute_points_fer < 20:
			spent_attribute_points_fer += 1
			attribute -= 1
			ferocity += attribute_increase_factor * 0.1
		elif spent_attribute_points_fer < 25:
			spent_attribute_points_fer += 1
			attribute -= 1
			ferocity += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_fer += 1
			attribute -= 1
			ferocity += attribute_increase_factor * 0.01
func minusFer():
	if ferocity > 0.05:
		spent_attribute_points_fer -= 1
		attribute += 1
		if spent_attribute_points_fer < 5:
			ferocity -= attribute_increase_factor
		elif spent_attribute_points_fer < 10:
			ferocity -= attribute_increase_factor * 0.5
		elif spent_attribute_points_fer < 15:
			ferocity -= attribute_increase_factor * 0.2
		elif spent_attribute_points_fer < 20:
			ferocity -= attribute_increase_factor * 0.1
		elif spent_attribute_points_fer < 25:
			ferocity -= attribute_increase_factor * 0.05
		else:
			ferocity -= attribute_increase_factor * 0.01
#Fury
func plusFur():
	if attribute > 0:
		if spent_attribute_points_fur < 5:
			spent_attribute_points_fur += 1
			attribute -= 1
			fury += attribute_increase_factor
		elif spent_attribute_points_fur < 10:
			spent_attribute_points_fur += 1
			attribute -= 1
			fury += attribute_increase_factor * 0.5
		elif spent_attribute_points_fur < 15:
			spent_attribute_points_fur+= 1
			attribute -= 1
			fury += attribute_increase_factor * 0.2
		elif spent_attribute_points_fur < 20:
			spent_attribute_points_fur += 1
			attribute -= 1
			fury += attribute_increase_factor * 0.1
		elif spent_attribute_points_fur < 25:
			spent_attribute_points_fur += 1
			attribute -= 1
			fury += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_fur += 1
			attribute -= 1
			fury += attribute_increase_factor * 0.01
func minusFur():
	if fury > 0.05:
		spent_attribute_points_fur -= 1
		attribute += 1
		if spent_attribute_points_fur < 5:
			fury -= attribute_increase_factor
		elif spent_attribute_points_fur < 10:
			fury -= attribute_increase_factor * 0.5
		elif spent_attribute_points_fur < 15:
			fury -= attribute_increase_factor * 0.2
		elif spent_attribute_points_fur < 20:
			fury -= attribute_increase_factor * 0.1
		elif spent_attribute_points_fur < 25:
			fury -= attribute_increase_factor * 0.05
		else:
			fury -= attribute_increase_factor * 0.01
#Vitality, for now it only increases health 
func plusVit():
	if attribute > 0:
		if spent_attribute_points_vit < 5:
			spent_attribute_points_vit += 1
			attribute -= 1
			vitality += attribute_increase_factor
		elif spent_attribute_points_vit < 10:
			spent_attribute_points_vit += 1
			attribute -= 1
			vitality += attribute_increase_factor * 0.5
		elif spent_attribute_points_vit < 15:
			spent_attribute_points_vit += 1
			attribute -= 1
			vitality += attribute_increase_factor * 0.2
		elif spent_attribute_points_vit < 20:
			spent_attribute_points_vit += 1
			attribute -= 1
			vitality += attribute_increase_factor * 0.1
		elif spent_attribute_points_vit < 25:
			spent_attribute_points_vit += 1
			attribute -= 1
			vitality += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_vit += 1
			attribute -= 1
			vitality += attribute_increase_factor * 0.01
func minusVit():
	if vitality > 0.05:
		spent_attribute_points_vit -= 1
		attribute += 1
		if spent_attribute_points_vit < 5:
			vitality -= attribute_increase_factor
		elif spent_attribute_points_vit < 10:
			vitality -= attribute_increase_factor * 0.5
		elif spent_attribute_points_vit < 15:
			vitality -= attribute_increase_factor * 0.2
		elif spent_attribute_points_vit < 20:
			vitality -= attribute_increase_factor * 0.1
		elif spent_attribute_points_vit < 25:
			vitality -= attribute_increase_factor * 0.05
		else:
			vitality -= attribute_increase_factor * 0.01
#Stamina 
func plusSta():
	if attribute > 0:
		if spent_attribute_points_sta < 5:
			spent_attribute_points_sta += 1
			attribute -= 1
			stamina += attribute_increase_factor
		elif spent_attribute_points_sta < 10:
			spent_attribute_points_sta += 1
			attribute -= 1
			stamina += attribute_increase_factor * 0.5
		elif spent_attribute_points_sta < 15:
			spent_attribute_points_sta += 1
			attribute -= 1
			stamina += attribute_increase_factor * 0.2
		elif spent_attribute_points_sta < 20:
			spent_attribute_points_sta += 1
			attribute -= 1
			stamina += attribute_increase_factor * 0.1
		elif spent_attribute_points_sta < 25:
			spent_attribute_points_sta += 1
			attribute -= 1
			stamina += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_sta += 1
			attribute -= 1
			stamina += attribute_increase_factor * 0.01
func minusSta():
	if stamina > 0.05:
		spent_attribute_points_sta -= 1
		attribute += 1
		if spent_attribute_points_sta < 5:
			stamina -= attribute_increase_factor
		elif spent_attribute_points_sta < 10:
			stamina -= attribute_increase_factor * 0.5
		elif spent_attribute_points_sta < 15:
			stamina -= attribute_increase_factor * 0.2
		elif spent_attribute_points_sta < 20:
			stamina -= attribute_increase_factor * 0.1
		elif spent_attribute_points_sta < 25:
			stamina -= attribute_increase_factor * 0.05
		else:
			stamina -= attribute_increase_factor * 0.01
#Endurance
func plusEnd():
	if attribute > 0:
		if spent_attribute_points_end < 5:
			spent_attribute_points_end += 1
			attribute -= 1
			endurance += attribute_increase_factor
		elif spent_attribute_points_end < 10:
			spent_attribute_points_end += 1
			attribute -= 1
			endurance += attribute_increase_factor * 0.5
		elif spent_attribute_points_end < 15:
			spent_attribute_points_end += 1
			attribute -= 1
			endurance += attribute_increase_factor * 0.2
		elif spent_attribute_points_end < 20:
			spent_attribute_points_end += 1
			attribute -= 1
			endurance += attribute_increase_factor * 0.1
		elif spent_attribute_points_end < 25:
			spent_attribute_points_end += 1
			attribute -= 1
			endurance += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_end += 1
			attribute -= 1
			endurance += attribute_increase_factor * 0.01
func minusEnd():
	if endurance > 0.05:
		spent_attribute_points_end -= 1
		attribute += 1
		if spent_attribute_points_end < 5:
			endurance -= attribute_increase_factor
		elif spent_attribute_points_end < 10:
			endurance -= attribute_increase_factor * 0.5
		elif spent_attribute_points_end < 15:
			endurance -= attribute_increase_factor * 0.2
		elif spent_attribute_points_end < 20:
			endurance -= attribute_increase_factor * 0.1
		elif spent_attribute_points_end < 25:
			endurance -= attribute_increase_factor * 0.05
		else:
			endurance -= attribute_increase_factor * 0.01
#Resistance, it increases health, energy, resolve, defense at 1/3 value of other attributes
func plusRes():
	if attribute > 0:
		if spent_attribute_points_res < 5:
			spent_attribute_points_res += 1
			attribute -= 1
			resistance += attribute_increase_factor
		elif spent_attribute_points_res < 10:
			spent_attribute_points_res += 1
			attribute -= 1
			resistance += attribute_increase_factor * 0.5
		elif spent_attribute_points_res < 15:
			spent_attribute_points_res += 1
			attribute -= 1
			resistance += attribute_increase_factor * 0.2
		elif spent_attribute_points_res < 20:
			spent_attribute_points_res += 1
			attribute -= 1
			resistance += attribute_increase_factor * 0.1
		elif spent_attribute_points_res < 25:
			spent_attribute_points_res += 1
			attribute -= 1
			resistance += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_res += 1
			attribute -= 1
			resistance += attribute_increase_factor * 0.01
func minusRes():
	if resistance > 0.05:
		spent_attribute_points_res -= 1
		attribute += 1
		if spent_attribute_points_res < 5:
			resistance -= attribute_increase_factor
		elif spent_attribute_points_res < 10:
			resistance -= attribute_increase_factor * 0.5
		elif spent_attribute_points_res < 15:
			resistance -= attribute_increase_factor * 0.2
		elif spent_attribute_points_res < 20:
			resistance -= attribute_increase_factor * 0.1
		elif spent_attribute_points_res < 25:
			resistance -= attribute_increase_factor * 0.05
		else:
			resistance -= attribute_increase_factor * 0.01
#Tenacity
func plusTen():
	if attribute > 0:
		if spent_attribute_points_ten < 5:
			spent_attribute_points_ten += 1
			attribute -= 1
			tenacity += attribute_increase_factor
		elif spent_attribute_points_ten < 10:
			spent_attribute_points_ten += 1
			attribute -= 1
			tenacity += attribute_increase_factor * 0.5
		elif spent_attribute_points_ten < 15:
			spent_attribute_points_ten += 1
			attribute -= 1
			tenacity += attribute_increase_factor * 0.2
		elif spent_attribute_points_ten < 20:
			spent_attribute_points_ten += 1
			attribute -= 1
			tenacity += attribute_increase_factor * 0.1
		elif spent_attribute_points_ten < 25:
			spent_attribute_points_ten += 1
			attribute -= 1
			tenacity += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_ten += 1
			attribute -= 1
			tenacity += attribute_increase_factor * 0.0
func minusTen():
	if tenacity > 0.05:
		spent_attribute_points_ten -= 1
		attribute += 1
		if spent_attribute_points_ten < 5:
			tenacity -= attribute_increase_factor
		elif spent_attribute_points_ten < 10:
			tenacity -= attribute_increase_factor * 0.5
		elif spent_attribute_points_ten < 15:
			tenacity -= attribute_increase_factor * 0.2
		elif spent_attribute_points_ten < 20:
			tenacity -= attribute_increase_factor * 0.1
		elif spent_attribute_points_ten < 25:
			tenacity -= attribute_increase_factor * 0.05
		else:
			tenacity -= attribute_increase_factor * 0.01
#Agility 
func plusAgi():
	if attribute > 0:
		if spent_attribute_points_agi < 5:
			spent_attribute_points_agi += 1
			attribute -= 1
			agility += attribute_increase_factor
		elif spent_attribute_points_agi < 10:
			spent_attribute_points_agi += 1
			attribute -= 1
			agility += attribute_increase_factor * 0.5
		elif spent_attribute_points_agi < 15:
			spent_attribute_points_agi += 1
			attribute -= 1
			agility += attribute_increase_factor * 0.2
		elif spent_attribute_points_agi < 20:
			spent_attribute_points_agi += 1
			attribute -= 1
			agility += attribute_increase_factor * 0.1
		elif spent_attribute_points_agi < 25:
			spent_attribute_points_agi += 1
			attribute -= 1
			agility += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_agi += 1
			attribute -= 1
			agility += attribute_increase_factor * 0.01
func minusAgi():
	if agility > 0.05:
		spent_attribute_points_agi -= 1
		attribute += 1
		if spent_attribute_points_agi < 5:
			agility -= attribute_increase_factor
		elif spent_attribute_points_agi < 10:
			agility -= attribute_increase_factor * 0.5
		elif spent_attribute_points_agi < 15:
			agility -= attribute_increase_factor * 0.2
		elif spent_attribute_points_agi < 20:
			agility -= attribute_increase_factor * 0.1
		elif spent_attribute_points_agi < 25:
			agility -= attribute_increase_factor * 0.05
		else:
			agility -= attribute_increase_factor * 0.01
#Haste
func plusHas():
	if attribute > 0:
		if spent_attribute_points_has < 5:
			spent_attribute_points_has += 1
			attribute -= 1
			haste += attribute_increase_factor
		elif spent_attribute_points_has < 10:
			spent_attribute_points_has += 1
			attribute -= 1
			haste += attribute_increase_factor * 0.5
		elif spent_attribute_points_has < 15:
			spent_attribute_points_has += 1
			attribute -= 1
			haste += attribute_increase_factor * 0.2
		elif spent_attribute_points_has < 20:
			spent_attribute_points_has += 1
			attribute -= 1
			haste += attribute_increase_factor * 0.1
		elif spent_attribute_points_has < 25:
			spent_attribute_points_has += 1
			attribute -= 1
			haste += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_has += 1
			attribute -= 1
			haste += attribute_increase_factor * 0.01
func minusHas():
	if haste > 0.05:
		spent_attribute_points_has -= 1
		attribute += 1
		if spent_attribute_points_has < 5:
			haste -= attribute_increase_factor
		elif spent_attribute_points_has < 10:
			haste -= attribute_increase_factor * 0.5
		elif spent_attribute_points_has < 15:
			haste -= attribute_increase_factor * 0.2
		elif spent_attribute_points_has < 20:
			haste -= attribute_increase_factor * 0.1
		elif spent_attribute_points_has < 25:
			haste -= attribute_increase_factor * 0.05
		else:
			haste -= attribute_increase_factor * 0.01
#Celerety 
func plusCel():
	if attribute > 0:
		if spent_attribute_points_cel < 5:
			spent_attribute_points_cel += 1
			attribute -= 1
			celerity += attribute_increase_factor
		elif spent_attribute_points_cel < 10:
			spent_attribute_points_cel += 1
			attribute -= 1
			celerity += attribute_increase_factor * 0.5
		elif spent_attribute_points_cel < 15:
			spent_attribute_points_cel += 1
			attribute -= 1
			celerity += attribute_increase_factor * 0.2
		elif spent_attribute_points_cel < 20:
			spent_attribute_points_cel += 1
			attribute -= 1
			celerity += attribute_increase_factor * 0.1
		elif spent_attribute_points_cel < 25:
			spent_attribute_points_cel += 1
			attribute -= 1
			celerity += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_cel += 1
			attribute -= 1
			celerity += attribute_increase_factor * 0.01
func minusCel():
	if celerity > 0.05:
		spent_attribute_points_cel -= 1
		attribute += 1
		if spent_attribute_points_cel < 5:
			celerity -= attribute_increase_factor
		elif spent_attribute_points_cel < 10:
			celerity -= attribute_increase_factor * 0.5
		elif spent_attribute_points_cel < 15:
			celerity -= attribute_increase_factor * 0.2
		elif spent_attribute_points_cel < 20:
			celerity -= attribute_increase_factor * 0.1
		elif spent_attribute_points_cel < 25:
			celerity -= attribute_increase_factor * 0.05
		else:
			celerity -= attribute_increase_factor * 0.01
#Flexibity.... this is mostly about taking less falling damage or when being knocked down by tackles 
func plusFle():
	if attribute > 0:
		if spent_attribute_points_fle < 5:
			spent_attribute_points_fle += 1
			attribute -= 1
			flexibility += attribute_increase_factor
		elif spent_attribute_points_fle< 10:
			spent_attribute_points_fle += 1
			attribute -= 1
			flexibility += attribute_increase_factor * 0.5
		elif spent_attribute_points_fle < 15:
			spent_attribute_points_fle += 1
			attribute -= 1
			flexibility += attribute_increase_factor * 0.2
		elif spent_attribute_points_fle< 20:
			spent_attribute_points_fle += 1
			attribute -= 1
			flexibility += attribute_increase_factor * 0.1
		elif spent_attribute_points_fle < 25:
			spent_attribute_points_fle += 1
			attribute -= 1
			flexibility += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_fle += 1
			attribute -= 1
			flexibility += attribute_increase_factor * 0.01
func minusFle():
	if flexibility > 0.05:
		spent_attribute_points_fle -= 1
		attribute += 1
		if spent_attribute_points_fle < 5:
			flexibility -= attribute_increase_factor
		elif spent_attribute_points_fle < 10:
			flexibility -= attribute_increase_factor * 0.5
		elif spent_attribute_points_fle < 15:
			flexibility -= attribute_increase_factor * 0.2
		elif spent_attribute_points_fle < 20:
			flexibility -= attribute_increase_factor * 0.1
		elif spent_attribute_points_fle < 25:
			flexibility -= attribute_increase_factor * 0.05
		else:
			flexibility -= attribute_increase_factor * 0.01
#Deflection
func plusDef():
	if attribute > 0:
		if spent_attribute_points_def < 5:
			spent_attribute_points_def += 1
			attribute -= 1
			deflection += attribute_increase_factor
		elif spent_attribute_points_def < 10:
			spent_attribute_points_def += 1
			attribute -= 1
			deflection += attribute_increase_factor * 0.5
		elif spent_attribute_points_def < 15:
			spent_attribute_points_def += 1
			attribute -= 1
			deflection += attribute_increase_factor * 0.2
		elif spent_attribute_points_def < 20:
			spent_attribute_points_def += 1
			attribute -= 1
			deflection += attribute_increase_factor * 0.1
		elif spent_attribute_points_def < 25:
			spent_attribute_points_def += 1
			attribute -= 1
			deflection += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_def += 1
			attribute -= 1
			deflection += attribute_increase_factor * 0.01
func minusDef():
	if deflection > 0.05:
		spent_attribute_points_def -= 1
		attribute += 1
		if spent_attribute_points_def < 5:
			deflection -= attribute_increase_factor
		elif spent_attribute_points_def < 10:
			deflection -= attribute_increase_factor * 0.5
		elif spent_attribute_points_def < 15:
			deflection -= attribute_increase_factor * 0.2
		elif spent_attribute_points_def < 20:
			deflection -= attribute_increase_factor * 0.1
		elif spent_attribute_points_def < 25:
			deflection -= attribute_increase_factor * 0.05
		else:
			deflection -= attribute_increase_factor * 0.01
#Dexterity
func plusDex():
	if attribute > 0:
		if spent_attribute_points_dex < 5:
			spent_attribute_points_dex += 1
			attribute -= 1
			dexterity += attribute_increase_factor
		elif spent_attribute_points_dex < 10:
			spent_attribute_points_dex += 1
			attribute -= 1
			dexterity += attribute_increase_factor * 0.5
		elif spent_attribute_points_dex < 15:
			spent_attribute_points_dex += 1
			attribute -= 1
			dexterity += attribute_increase_factor * 0.2
		elif spent_attribute_points_dex < 20:
			spent_attribute_points_dex += 1
			attribute -= 1
			dexterity += attribute_increase_factor * 0.1
		elif spent_attribute_points_dex < 25:
			spent_attribute_points_dex += 1
			attribute -= 1
			dexterity += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_dex += 1
			attribute -= 1
			dexterity += attribute_increase_factor * 0.01
func minusDex():
	if dexterity > 0.05:
		spent_attribute_points_dex -= 1
		attribute += 1
		if spent_attribute_points_dex < 5:
			dexterity -= attribute_increase_factor
		elif spent_attribute_points_dex < 10:
			dexterity -= attribute_increase_factor * 0.5
		elif spent_attribute_points_dex < 15:
			dexterity -= attribute_increase_factor * 0.2
		elif spent_attribute_points_dex < 20:
			dexterity -= attribute_increase_factor * 0.1
		elif spent_attribute_points_dex < 25:
			dexterity -= attribute_increase_factor * 0.05
		else:
			dexterity -= attribute_increase_factor * 0.01
#Accuracy
func plusAcc():
	if attribute > 0:
		if spent_attribute_points_acc < 5:
			spent_attribute_points_acc += 1
			attribute -= 1
			accuracy += attribute_increase_factor
		elif spent_attribute_points_acc < 10:
			spent_attribute_points_acc += 1
			attribute -= 1
			accuracy += attribute_increase_factor * 0.5
		elif spent_attribute_points_acc < 15:
			spent_attribute_points_acc += 1
			attribute -= 1
			accuracy += attribute_increase_factor * 0.2
		elif spent_attribute_points_acc < 20:
			spent_attribute_points_acc += 1
			attribute -= 1
			accuracy += attribute_increase_factor * 0.1
		elif spent_attribute_points_acc < 25:
			spent_attribute_points_acc += 1
			attribute -= 1
			accuracy += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_acc += 1
			attribute -= 1
			accuracy += attribute_increase_factor * 0.01
func minusAcc():
	if accuracy > 0.05:
		spent_attribute_points_acc -= 1
		attribute += 1
		if spent_attribute_points_acc < 5:
			accuracy -= attribute_increase_factor
		elif spent_attribute_points_acc < 10:
			accuracy -= attribute_increase_factor * 0.5
		elif spent_attribute_points_acc < 15:
			accuracy -= attribute_increase_factor * 0.2
		elif spent_attribute_points_acc < 20:
			accuracy -= attribute_increase_factor * 0.1
		elif spent_attribute_points_acc < 25:
			accuracy -= attribute_increase_factor * 0.05
		else:
			accuracy -= attribute_increase_factor * 0.01
#Focus
func plusFoc():
	if attribute > 0:
		if spent_attribute_points_foc < 5:
			spent_attribute_points_foc += 1
			attribute -= 1
			focus += attribute_increase_factor
		elif spent_attribute_points_foc < 10:
			spent_attribute_points_foc += 1
			attribute -= 1
			focus += attribute_increase_factor * 0.5
		elif spent_attribute_points_foc < 15:
			spent_attribute_points_foc += 1
			attribute -= 1
			focus += attribute_increase_factor * 0.2
		elif spent_attribute_points_foc < 20:
			spent_attribute_points_foc += 1
			attribute -= 1
			focus += attribute_increase_factor * 0.1
		elif spent_attribute_points_foc < 25:
			spent_attribute_points_foc += 1
			attribute -= 1
			focus += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_foc += 1
			attribute -= 1
			focus += attribute_increase_factor * 0.01
func minusFoc():
	if focus > 0.05:
		spent_attribute_points_foc -= 1
		attribute += 1
		if spent_attribute_points_foc < 5:
			focus -= attribute_increase_factor
		elif spent_attribute_points_foc < 10:
			focus -= attribute_increase_factor * 0.5
		elif spent_attribute_points_foc < 15:
			focus -= attribute_increase_factor * 0.2
		elif spent_attribute_points_foc < 20:
			focus -= attribute_increase_factor * 0.1
		elif spent_attribute_points_foc < 25:
			focus -= attribute_increase_factor * 0.05
		else:
			focus -= attribute_increase_factor * 0.01
#Poise 
func plusPoi():
	if attribute > 0:
		if spent_attribute_points_poi < 5:
			spent_attribute_points_poi += 1
			attribute -= 1
			poise += attribute_increase_factor
		elif spent_attribute_points_poi < 10:
			spent_attribute_points_poi += 1
			attribute -= 1
			poise += attribute_increase_factor * 0.5
		elif spent_attribute_points_poi < 15:
			spent_attribute_points_poi += 1
			attribute -= 1
			poise += attribute_increase_factor * 0.2
		elif spent_attribute_points_poi < 20:
			spent_attribute_points_poi += 1
			attribute -= 1
			poise += attribute_increase_factor * 0.1
		elif spent_attribute_points_poi < 25:
			spent_attribute_points_poi += 1
			attribute -= 1
			poise += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_poi += 1
			attribute -= 1
			poise += attribute_increase_factor * 0.01
func minusPoi():
	if poise > 0.05:
		spent_attribute_points_poi -= 1
		attribute += 1
		if spent_attribute_points_poi < 5:
			poise -= attribute_increase_factor
		elif spent_attribute_points_poi < 10:
			poise -= attribute_increase_factor * 0.5
		elif spent_attribute_points_poi < 15:
			poise -= attribute_increase_factor * 0.2
		elif spent_attribute_points_poi < 20:
			poise -= attribute_increase_factor * 0.1
		elif spent_attribute_points_poi < 25:
			poise -= attribute_increase_factor * 0.05
		else:
			poise -= attribute_increase_factor * 0.01
#Balance
func plusBal():
	if attribute > 0:
		if spent_attribute_points_bal < 5:
			spent_attribute_points_bal += 1
			attribute -= 1
			balance += attribute_increase_factor
		elif spent_attribute_points_bal < 10:
			spent_attribute_points_bal += 1
			attribute -= 1
			balance += attribute_increase_factor * 0.5
		elif spent_attribute_points_bal < 15:
			spent_attribute_points_bal += 1
			attribute -= 1
			balance += attribute_increase_factor * 0.2
		elif spent_attribute_points_bal < 20:
			spent_attribute_points_bal += 1
			attribute -= 1
			balance += attribute_increase_factor * 0.1
		elif spent_attribute_points_bal < 25:
			spent_attribute_points_bal += 1
			attribute -= 1
			balance += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_bal += 1
			attribute -= 1
			balance += attribute_increase_factor * 0.01
func minusBal():
	if balance > 0.05:
		spent_attribute_points_bal -= 1
		attribute += 1
		if spent_attribute_points_bal < 5:
			balance -= attribute_increase_factor
		elif spent_attribute_points_bal < 10:
			balance -= attribute_increase_factor * 0.5
		elif spent_attribute_points_bal < 15:
			balance -= attribute_increase_factor * 0.2
		elif spent_attribute_points_bal < 20:
			balance -= attribute_increase_factor * 0.1
		elif spent_attribute_points_bal < 25:
			balance -= attribute_increase_factor * 0.05
		else:
			balance -= attribute_increase_factor * 0.01
#Charisma 
func plusCha():
	print("ok")
	if attribute > 0:
		if spent_attribute_points_cha < 5:
			spent_attribute_points_cha += 1
			attribute -= 1
			charisma_multiplier += attribute_increase_factor
		elif spent_attribute_points_cha < 10:
			spent_attribute_points_cha += 1
			attribute -= 1
			charisma_multiplier += attribute_increase_factor * 0.5
		elif spent_attribute_points_cha < 15:
			spent_attribute_points_cha += 1
			attribute -= 1
			charisma_multiplier += attribute_increase_factor * 0.2
		elif spent_attribute_points_cha < 20:
			spent_attribute_points_cha += 1
			attribute -= 1
			charisma_multiplier += attribute_increase_factor * 0.1
		elif spent_attribute_points_cha < 25:
			spent_attribute_points_cha += 1
			attribute -= 1
			charisma_multiplier += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_cha += 1
			attribute -= 1
			charisma_multiplier += attribute_increase_factor * 0.01
func minusCha():
	if charisma_multiplier > 0.05:
		spent_attribute_points_cha -= 1
		attribute += 1
		if spent_attribute_points_cha < 5:
			charisma_multiplier -= attribute_increase_factor
		elif spent_attribute_points_cha < 10:
			charisma_multiplier -= attribute_increase_factor * 0.5
		elif spent_attribute_points_cha < 15:
			charisma_multiplier -= attribute_increase_factor * 0.2
		elif spent_attribute_points_cha < 20:
			charisma_multiplier -= attribute_increase_factor * 0.1
		elif spent_attribute_points_cha < 25:
			charisma_multiplier -= attribute_increase_factor * 0.05
		else:
			charisma_multiplier -= attribute_increase_factor * 0.01
#Diplomancy 
func plusDip():
	if attribute > 0:
		if spent_attribute_points_dip < 5:
			spent_attribute_points_dip += 1
			attribute -= 1
			diplomacy += attribute_increase_factor
		elif spent_attribute_points_dip < 10:
			spent_attribute_points_dip += 1
			attribute -= 1
			diplomacy += attribute_increase_factor * 0.5
		elif spent_attribute_points_dip < 15:
			spent_attribute_points_dip += 1
			attribute -= 1
			diplomacy += attribute_increase_factor * 0.2
		elif spent_attribute_points_dip < 20:
			spent_attribute_points_dip += 1
			attribute -= 1
			diplomacy += attribute_increase_factor * 0.1
		elif spent_attribute_points_dip < 25:
			spent_attribute_points_dip += 1
			attribute -= 1
			diplomacy += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_dip += 1
			attribute -= 1
			diplomacy += attribute_increase_factor * 0.01
func minusDip():
	if diplomacy > 0.05:
		spent_attribute_points_dip -= 1
		attribute += 1
		if spent_attribute_points_dip < 5:
			diplomacy -= attribute_increase_factor
		elif spent_attribute_points_dip < 10:
			diplomacy -= attribute_increase_factor * 0.5
		elif spent_attribute_points_dip < 15:
			diplomacy -= attribute_increase_factor * 0.2
		elif spent_attribute_points_dip < 20:
			diplomacy -= attribute_increase_factor * 0.1
		elif spent_attribute_points_dip < 25:
			diplomacy -= attribute_increase_factor * 0.05
		else:
			diplomacy -= attribute_increase_factor * 0.01
#Authority
func plusAut():
	if attribute > 0:
		if spent_attribute_points_aut < 5:
			spent_attribute_points_aut += 1
			attribute -= 1
			authority += attribute_increase_factor
		elif spent_attribute_points_aut < 10:
			spent_attribute_points_aut += 1
			attribute -= 1
			authority += attribute_increase_factor * 0.5
		elif spent_attribute_points_aut < 15:
			spent_attribute_points_aut += 1
			attribute -= 1
			authority += attribute_increase_factor * 0.2
		elif spent_attribute_points_aut < 20:
			spent_attribute_points_aut += 1
			attribute -= 1
			authority += attribute_increase_factor * 0.1
		elif spent_attribute_points_aut < 25:
			spent_attribute_points_aut += 1
			attribute -= 1
			authority += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_aut += 1
			attribute -= 1
			authority += attribute_increase_factor * 0.01
func minusAut():
	if authority > 0.05:
		spent_attribute_points_aut -= 1
		attribute += 1
		if spent_attribute_points_aut < 5:
			authority -= attribute_increase_factor
		elif spent_attribute_points_aut < 10:
			authority -= attribute_increase_factor * 0.5
		elif spent_attribute_points_aut < 15:
			authority -= attribute_increase_factor * 0.2
		elif spent_attribute_points_aut < 20:
			authority -= attribute_increase_factor * 0.1
		elif spent_attribute_points_aut < 25:
			authority -= attribute_increase_factor * 0.05
		else:
			authority -= attribute_increase_factor * 0.01
#Courage 
func plusCou():
	if attribute > 0:
		if spent_attribute_points_cou < 5:
			spent_attribute_points_cou += 1
			attribute -= 1
			courage += attribute_increase_factor
		elif spent_attribute_points_cou < 10:
			spent_attribute_points_cou += 1
			attribute -= 1
			courage += attribute_increase_factor * 0.5
		elif spent_attribute_points_cou < 15:
			spent_attribute_points_cou += 1
			attribute -= 1
			courage += attribute_increase_factor * 0.2
		elif spent_attribute_points_cou < 20:
			spent_attribute_points_cou += 1
			attribute -= 1
			courage += attribute_increase_factor * 0.1
		elif spent_attribute_points_cou < 25:
			spent_attribute_points_cou += 1
			attribute -= 1
			courage += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_cou += 1
			attribute -= 1
			courage += attribute_increase_factor * 0.01
func minusCou():
	if courage > 0.05:
		spent_attribute_points_cou -= 1
		attribute += 1
		if spent_attribute_points_cou < 5:
			courage -= attribute_increase_factor
		elif spent_attribute_points_cou < 10:
			courage -= attribute_increase_factor * 0.5
		elif spent_attribute_points_cou < 15:
			courage -= attribute_increase_factor * 0.2
		elif spent_attribute_points_cou < 20:
			courage -= attribute_increase_factor * 0.1
		elif spent_attribute_points_cou < 25:
			courage -= attribute_increase_factor * 0.05
		else:
			courage -= attribute_increase_factor * 0.01
#Loyalty
func plusLoy():
	if attribute > 0:
		if spent_attribute_points_loy < 5:
			spent_attribute_points_loy += 1
			attribute -= 1
			loyalty += attribute_increase_factor
		elif spent_attribute_points_loy < 10:
			spent_attribute_points_loy += 1
			attribute -= 1
			loyalty += attribute_increase_factor * 0.5
		elif spent_attribute_points_loy < 15:
			spent_attribute_points_loy += 1
			attribute -= 1
			loyalty += attribute_increase_factor * 0.2
		elif spent_attribute_points_loy < 20:
			spent_attribute_points_loy += 1
			attribute -= 1
			loyalty += attribute_increase_factor * 0.1
		elif spent_attribute_points_loy < 25:
			spent_attribute_points_loy += 1
			attribute -= 1
			loyalty += attribute_increase_factor * 0.05
		else:
			spent_attribute_points_loy += 1
			attribute -= 1
			loyalty += attribute_increase_factor * 0.01
func minusLoy():
	if loyalty > 0.05:
		spent_attribute_points_loy -= 1
		attribute += 1
		if spent_attribute_points_loy < 5:
			loyalty -= attribute_increase_factor
		elif spent_attribute_points_loy < 10:
			loyalty -= attribute_increase_factor * 0.5
		elif spent_attribute_points_loy < 15:
			loyalty -= attribute_increase_factor * 0.2
		elif spent_attribute_points_loy < 20:
			loyalty -= attribute_increase_factor * 0.1
		elif spent_attribute_points_loy < 25:
			loyalty -= attribute_increase_factor * 0.05
		else:
			loyalty -= attribute_increase_factor * 0.01




onready var critical_chance_val = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/CritChanceValue
onready var critical_str_val = $UI/GUI/Equipment/EquipmentBG/CombatStats/GridContainer/CritDamageValue



func resistanceMath():
	var additional_resistance = 0
	var res_multiplier = 0.5
	if resistance > 1:
		additional_resistance = res_multiplier * (resistance - 1)
	elif resistance < 1:
		additional_resistance = -res_multiplier * (1 - resistance)
	defense = base_defense + int(resistance * 10)
	max_health = (base_max_health * (vitality + additional_resistance)) * scale_factor
	max_energy = base_max_energy * (stamina  + additional_resistance)
	max_resolve = base_max_resolve * (tenacity + additional_resistance)
	

var additional_melee_atk_speed : float = 0
var casting_speed: float = 1 
func updateAttackSpeed():
	var bonus_universal_speed = (celerity -1) * 0.15
	var atk_speed_formula = (dexterity - scale_factor ) * 0.5 
	melee_atk_speed = base_melee_atk_speed + atk_speed_formula + bonus_universal_speed + additional_melee_atk_speed
	
	var atk_speed_formula_ranged = (strength -1) * 0.5
	ranged_atk_speed = base_ranged_atk_speed + atk_speed_formula_ranged + bonus_universal_speed
	
	var atk_speed_formula_casting = (instinct -1) * 0.35 + ((memory-1) * 0.05) + bonus_universal_speed
	casting_speed = base_casting_speed + atk_speed_formula_casting



func updateCritical():
	critical_chance = max(0, (accuracy - 1.00) * 0.5) +  max(0, (impact - 1.00) * 0.005) 
	critical_strength = ((ferocity -1) * 2) 
	critical_chance_val.text = str(round(critical_chance * 100 * 1000) / 1000) + "%"
	critical_str_val.text = "x" + str(critical_strength)

func updateStaggerChance():
	stagger_chance = max(0, (impact - 1.00) * 0.45) +  max(0, (ferocity - 1.00) * 0.005) 


func updateScaleRelatedAttributes():
	charisma = base_charisma * (charisma_multiplier * 0.87 * (scale_factor * 1.15))

func updateAllStats():
	updateAttackSpeed()
	updateScaleRelatedAttributes()
	updateCritical()
	updateStaggerChance()










#___________________________________________Save data system________________________________________
var entity_name: String = "dai"
const SAVE_DIR: String = "user://saves/"
var save_path: String = SAVE_DIR + entity_name + "save.dat"
func savePlayerData():
	var data = {
		"position": translation,
		"camera.translation.y" : camera.translation.y,
		"camera.translation.z" : camera.translation.z,

		
		"health": health,
		"max_health": max_health,
		
		"breath": breath,
		"max_breath":max_breath,
		
		"resolve": resolve,
		"max_resolve": max_resolve,
		

		
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
		"recovery": recovery,
		"resistance": resistance,
		"tenacity": tenacity,
#Social attributes 
		"charisma_multiplier":charisma_multiplier,
		"loyalty": loyalty,
		"diplomacy": diplomacy,
		"authority": authority,
		"empathy": empathy,
		"courage": courage,
		
		
		
		
		
		"effects": effects,
		}
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
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
			if "recovery" in player_data:
				recovery = player_data["recovery"]
#Social attributes 
			if "charisma_multiplier" in player_data:
				charisma_multiplier = player_data["charisma_multiplier"]
			if "loyalty" in player_data:
				loyalty = player_data["loyalty"]
			if "diplomacy" in player_data:
				diplomacy = player_data["diplomacy"]
			if "authority" in player_data:
				authority = player_data["authority"]
			if "empathy" in player_data:
				empathy = player_data["empathy"]
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
