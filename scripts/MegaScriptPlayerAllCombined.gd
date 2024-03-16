extends KinematicBody
onready var player_mesh = $Mesh
onready var animation = $Mesh/Race/AnimationPlayer

var injured = false
var blend = 0.25

# Condition States
var is_attacking = bool()
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()


func _ready(): 
	loadPlayerData()
	closeAllUI()
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)

func _physics_process(delta):
	$hp.text = str(health)
	$Debug.text = animation_state
	displayLabels()
	displayClock()
	frameRate()
	speedlabel()
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
	rayAttack()
	showEnemyStats()
	matchAnimationStates()
	animations()
	attack()
	doubleAttack(delta)
	fallDamage()
	skillUserInterfaceInputs()
	addItemToInventory()
	positionCoordinates()
	
	MainWeapon()
	
#_______________________________________________Basic Movement______________________________________
var h_rot 
var blocking = false
var is_in_combat = false
var enabled_climbing = false
var is_crouching = false
var is_sprinting = false
var sprint_speed = 10
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
				sprint_speed += 0.005
				if sprint_animation_speed < max_sprint_animation_speed:
					sprint_animation_speed +=0.0005
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
		elif Input.is_action_pressed("crouch"):
			sprint_speed = 10
			is_crouching = true 
			is_running = false
			is_sprinting = false
			is_aiming = false
			movement_speed = walk_speed * 0.5
		elif Input.is_action_pressed("attack"):
			sprint_speed = 10
			is_crouching = false
			is_running = false
			is_sprinting = false
			is_aiming = false
			is_attacking = true 
			movement_speed = 3
		elif health < (max_health * 0.1):
			movement_speed = walk_speed * 0.5
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
var direction = Vector3()
var horizontal_velocity = Vector3()
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
var dodge_animation_duration = 0
var dodge_animation_max_duration = 3
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
var is_aiming = false
var camrot_h = 0
var camrot_v = 0
onready var parent = $".."
export var cam_v_max = 200 # -75 recommended
export var cam_v_min = -125 # -55 recommended
onready var camera_v =$Camroot/h/v
onready var camera_h =$Camroot/h
onready var camera = $Camroot/h/v/Camera
onready var minimap_camera = $UI/GUI/Minimap/Viewport/Camera
var minimap_rotate = false
var h_sensitivity = 0.1
var v_sensitivity = 0.1
var rot_speed_multiplier = .15 #reduce this to make the rotation radius larger
var h_acceleration = 10
var v_acceleration = 10
var touch_start_position = Vector2.ZERO
var zoom_speed = 0.1
var mouse_sense = 0.1

func shake_camera(duration: float, intensity: float, rand_x, rand_y):
	pass

func Zoom(zoom_direction):
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
func stiffCamera(delta):
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

onready var minimap = $UI/GUI/Minimap
func miniMapVisibility():
	if Input.is_action_just_pressed("minimap"):
		minimap.visible = !minimap.visible
	
	
	
	
func lifesteal(damage):
	pass



#___________________________________________Save data system________________________________________
var entity_name = "dai"
const SAVE_DIR = "user://saves/"
var save_path = SAVE_DIR + entity_name + "save.dat"
func savePlayerData():
	var data = {
		"position": translation,
		"camera.translation.y" : camera.translation.y,
		"camera.translation.z" : camera.translation.z,
		"main_weapon": main_weapon,
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
			if "main_weapon"  in player_data:
				main_weapon = player_data["main_weapon"]

func _on_Timer_timeout():
	savePlayerData()

var is_fullscreen = false
func fullscreen():
	if Input.is_action_just_pressed("fullscreen"):
		is_fullscreen = !is_fullscreen
		OS.set_window_fullscreen(is_fullscreen)

onready var ray = $Camroot/h/v/Camera/Aim
func rayAttack():#used for testing 
	if ray.is_colliding():
		var body = ray.get_collider()
		if body.is_in_group("Entity") and body != self:
			if Input.is_action_just_pressed("attack"):
				body.takeDamage(5, 5, self, 0.1, "heat")
				body.energy -= 1
		if body.is_in_group("Spawner"):
			if Input.is_action_just_pressed("attack"):
				body.start()
				#body.quantity += 20


func _on_Detector_body_entered(body):
	if body.is_in_group("Spawner"):
			body.start()
			#body.quantity += 20


#__________________________________Entitygraphical interface________________________________________
onready var entity_graphic_interface = $UI/GUI/EnemyUI
onready var entity_inspector 
onready var enemy_ui_tween =$UI/GUI/EnemyUI/Tween
onready var enemy_health_bar = $UI/GUI/EnemyUI/HP
onready var enemy_health_label = $UI/GUI/EnemyUI/HP/HPlab
onready var enemy_energy_bar = $UI/GUI/EnemyUI/EN
onready var enemy_energy_label =$UI/GUI/EnemyUI/EN/ENlab
var fade_duration = 0.3
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
var weapon_type = "fist"

var animation_state = "idle"
func matchAnimationStates():
	match animation_state:
#_______________________________attacking states________________________________
		"slide":
			var slide_blend = 0.333
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
			animation.play("run cycle", 0, sprint_animation_speed)
		"run":
			animation.play("run cycle")
		"jump":
			animation.play("jump",0.2, 1)
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
			var slot1 = $UI/GUI/SkillBar/GridContainer/SlotUP1/Icon
			if slot1.texture != null:
				if slot1.texture.resource_path == "res://UI/graphics/SkillIcons/rush.png":
					animation.play("combo attack 2hander cycle", 0.35)
				elif slot1.texture.resource_path == "res://UI/graphics/SkillIcons/selfheal.png":
					animation.play("crawl cycle", 0.35)
				else:
					pass





var sprint_animation_speed = 1
func animations():
#on water
	if is_swimming:
		if is_walking:
			animation_state = "swim"
		else:
			animation_state = "idle water"
			
#on land
	elif dodge_animation_duration > 0:
		animation_state = "slide"


	elif not is_on_floor() and not is_climbing and not is_swimming:
		animation_state = "fall"
	elif double_atk_animation_duration > 0 and !cursor_visible: 
		animation_state = "double attack"
	elif Input.is_action_pressed("rclick") and Input.is_action_pressed("attack") and !cursor_visible:
		animation_state = "guard attack"
	elif Input.is_action_pressed("rclick") and !cursor_visible:
		if !is_walking:
			animation_state = "guard"
		else:
			animation_state = "guard walk"
#attacks________________________________________________________________________
	elif Input.is_action_pressed("attack") and Input.is_action_pressed("run") and !cursor_visible: 
		animation_state = "run attack"
	elif Input.is_action_pressed("attack") and Input.is_action_pressed("sprint") and !cursor_visible: 
		animation_state = "sprint attack"
	elif Input.is_action_pressed("attack") and !cursor_visible:
			animation_state = "base attack"
#_______________________________________________________________________________
	elif is_sprinting:
			animation_state = "sprint"
	elif is_running:
			animation_state = "run"
	elif Input.is_action_pressed("crouch"):
		if is_walking:
			animation_state = "crouch walk"
		else:
			animation_state = "crouch"
	elif is_walking:
			animation_state = "walk"
	elif jump_animation_duration != 0:
		animation_state = "jump"
#skills 
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
var double_atk_animation_duration = 0
var double_atk_animation_max_duration = 1.125
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
			if enemy.has_method("takeDamage"):
				if is_on_floor():
					#insert sound effect here
					if randf() <= critical_chance *2:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,damage_type)
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
var critical_chance = 0.3
var critical_strength = 2
var stagger_chance = 0.3
func slideDealDamage():
	var damage_type = "blunt"
	var damage = 2.5
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
var jump_force = 10
func jumpUp():#called on animation
	vertical_velocity = Vector3.UP * jump_force 
func jumpDown():#called on animation
	vertical_velocity = Vector3.UP * -jump_force

func speedlabel():
	$kmh.text = "km/h " + str(movement_speed)


var can_move = false
func stopMovement():
	can_move = false
func startMovement():
	can_move = true 



#Stats__________________________________________________________________________
var level = 1
var health = 1000
const base_health = 1000
var max_health = 1000
const base_max_health = 1000
var energy = 100
var max_energy = 100
const base_max_energy = 100
var resolve = 100
var max_resolve = 100
const base_max_resolve = 100

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
var skill_points = 1000
var defense =  10


#attributes 
var coordination = 1
var creativity = 1
var wisdom = 1
var memory = 1
var intelligence = 1
var willpower = 1

var power = 1
var strength = 1
var impact = 1
var resistance = 1
var tenacity = 1

var accuracy = 1
var dexterity = 1

var balance = 1
var focus = 1

var acrobatics = 1
var agility = 1
var athletics = 1
var flexibility = 1
var placeholder_ = 1

var endurance = 1
var stamina = 1
var vitality = 1
var vigor = 1
var recovery = 1

var charisma = 1
var loyalty = 1 
var diplomacy = 1
var leadership = 1
var empathy = 1

#__________________________________________Defenses and stuff_______________________________________
#resistances
var slash_resistance = 25
var pierce_resistance = 25
var blunt_resistance = 25
var sonic_resistance = 25
var heat_resistance = 25
var cold_resistance = 25
var jolt_resistance = 25
var toxic_resistance = 25
var acid_resistance = 25
var bleed_resistance = 25
var neuro_resistance = 25
var radiant_resistance = 25

var stagger_resistance = 0.5
var deflection_chance = 0.33

var staggered = 0 
var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_view  = $Mesh/TakeDamageView/Viewport
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type):
	var random = randf()
	var damage_to_take = damage
	var text = floatingtext_damage.instance()
	if damage_type == "slash":
		var mitigation = slash_resistance / (slash_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		#instigator.lifesteal(damage_to_take)
	elif damage_type == "pierce":
		var mitigation = pierce_resistance / (pierce_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		#instigator.lifesteal(damage_to_take)
	elif damage_type == "blunt":
		var mitigation = blunt_resistance / (blunt_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "sonic":
		var mitigation = sonic_resistance / (sonic_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "heat":
		var mitigation = heat_resistance / (heat_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		if instigator.has_method("lifesteal"):
			instigator.lifesteal(damage_to_take)
	elif damage_type == "cold":
		var mitigation = cold_resistance / (cold_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "jolt":
		var mitigation = jolt_resistance / (jolt_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "toxic":
		var mitigation = toxic_resistance / (toxic_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "acid":
		var mitigation = acid_resistance / (acid_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "bleed":
		var mitigation = bleed_resistance / (bleed_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "neuro":
		var mitigation = neuro_resistance / (neuro_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "radiant":
		var mitigation = radiant_resistance / (radiant_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
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

var cursor_visible = false
onready var keybinds = $UI/GUI/Keybinds
onready var inventory = $UI/GUI/Inventory
onready var crafting = $UI/GUI/Crafting
onready var skill_trees = $UI/GUI/SkillTrees
onready var character = $UI/GUI/Character
onready var menu = $UI/GUI/Menu
func skillUserInterfaceInputs():
	if Input.is_action_just_pressed("skills"):
		closeSwitchOpen(skill_trees)
		saveSkillBarData()
	if Input.is_action_just_pressed("tab"):
		is_in_combat = !is_in_combat
		saveSkillBarData()
	if Input.is_action_just_pressed("mousemode") or Input.is_action_just_pressed("ui_cancel"):	# Toggle mouse mode
		saveInventoryData()
		saveSkillBarData()
		cursor_visible =!cursor_visible
	if !cursor_visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("Inventory"):
		closeSwitchOpen(inventory)
		saveInventoryData()
		saveSkillBarData()
	elif Input.is_action_just_pressed("Crafting"):
		closeSwitchOpen(crafting)
		saveInventoryData()
		saveSkillBarData()
	elif Input.is_action_just_pressed("Character"):
		closeSwitchOpen(character)
	elif Input.is_action_just_pressed("UI"):
		closeSwitchOpen(character)
		closeSwitchOpen(crafting)
		closeSwitchOpen(inventory)
		closeSwitchOpen(skill_trees)
	elif Input.is_action_just_pressed("Menu"):
		closeSwitchOpen(menu)
#skillbar buttons
func _on_Inventory_pressed():
	closeSwitchOpen(inventory)
func _on_Character_pressed():
	closeSwitchOpen(character)
func _on_Skills_pressed():
	closeSwitchOpen(skill_trees)
func _on_Menu_pressed():
	closeSwitchOpen(menu)
func _on_OpenAllUI_pressed():
	closeSwitchOpen(character)
	closeSwitchOpen(crafting)
	closeSwitchOpen(inventory)
	closeSwitchOpen(skill_trees)


func closeAllUI():
		character.visible = false 
		crafting.visible  = false
		inventory.visible = false
		skill_trees.visible = false
		keybinds.visible = false
		menu.visible = false
func closeSwitchOpen(ui):
	ui.visible = !ui.visible
func _on_CloseSkillsTrees_pressed():
	skill_trees.visible = false
func _on_CraftingCloseButton_pressed():
	crafting.visible = false
func _on_InventoryCloseButton_pressed():
	inventory.visible = false
func _on_InventoryOpenCraftingSystemButton_pressed():
	crafting.visible = !$UI/GUI/Crafting.visible
	saveSkillBarData()
func _on_SkillTreeCloseButton_pressed():
	skill_trees.visible = false
func _on_CharacterCloseButton_pressed():
	character.visible = false
func _on_CloseMenu_pressed():
	menu.visible = false
func _on_Keybinds_pressed():
	closeSwitchOpen(keybinds)
func _on_Quit_pressed():
	saveInventoryData()
	savePlayerData()
	saveSkillBarData()
	get_tree().quit()
func _on_InventorySaveButton_pressed():
	saveInventoryData()
	saveSkillBarData()
onready var skills_list1 = $UI/GUI/SkillTrees/Background/SylvanSkills
func _on_SkillTree1_pressed():
	skills_list1.visible = !skills_list1.visible
	saveSkillBarData()
	
func saveInventoryData():
	var inventory_grid = $UI/GUI/Inventory/ScrollContainer/InventoryGrid
	# Call savedata() function on each child of inventory_grid that belongs to the group "Inventory"
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
			if child.get_node("Icon").has_method("savedata"):
				child.get_node("Icon").savedata()
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
	$UI/GUI/SkillBar/GridContainer/SlotUP1/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP2/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP3/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP4/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP5/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP6/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP7/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP8/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP9/Icon.savedata()
	$UI/GUI/SkillBar/GridContainer/SlotUP0/Icon.savedata()

#__________________________________Inventory____________________________________
onready var inventory_grid = $UI/GUI/Inventory/ScrollContainer/InventoryGrid
# Function to combine slots when pressed
func _on_CombineSlots_pressed():
	var combined_items = {}  # Dictionary to store combined items
	for child in inventory_grid.get_children():
		if child.is_in_group("Inventory"):
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

#________________________________Add items to inventory_________________________
func addItemToInventory():
	var items = $Mesh/Detector.get_overlapping_bodies()
	for item in items:
		if item.is_in_group("Mushroom1"):
			for child in inventory_grid.get_children():
				if child.is_in_group("Inventory"):
					var icon = child.get_node("Icon")
					if icon.texture == null:
						icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/1.png")
						child.quantity += 1
						break
					elif icon.texture.get_path() == "res://UI/graphics/mushrooms/PNG/background/1.png":
						child.quantity += 1
						break
		if item.is_in_group("Mushroom2"):
			for child in inventory_grid.get_children():
				if child.is_in_group("Inventory"):
					var icon = child.get_node("Icon")
					if icon.texture == null:
						icon.texture = preload("res://UI/graphics/mushrooms/PNG/background/2.png")
						child.quantity += 1
						break
					elif icon.texture.get_path() == "res://UI/graphics/mushrooms/PNG/background/2.png":
						child.quantity += 1
						break
		if item.is_in_group("sword0"):
			for child in inventory_grid.get_children():
				if child.is_in_group("Inventory"):
					var icon = child.get_node("Icon")
					if icon.texture == null:
						icon.texture = preload("res://0.png")
						child.quantity = 1
						child.item = "sword 0"
						break
					elif icon.texture.get_path() == "res://0.png" and child.quantity == 1 and child.item == "sword 0":
						continue  # Move to the next slot if this one already has a sword
					elif icon.texture == null:
						icon.texture = preload("res://0.png")
						child.quantity = 1
						child.item = "sword 0"
						break

#_____________________________________more GUI stuff________________________________________________
onready var fps_label = $UI/GUI/Minimap/FPSLabel
func frameRate():
	fps_label.text = "%d" % Engine.get_frames_per_second()
func _on_FPS_pressed():
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
onready var time_label = $UI/GUI/Minimap/Time
func displayClock():
	# Get the current date and time
	var datetime = OS.get_datetime()
	# Display hour and minute in the label
	time_label.text = "Time: %02d:%02d" % [datetime.hour, datetime.minute]	
onready var coordinates = $UI/GUI/Minimap/Coordinates
func positionCoordinates():
	var rounded_position = Vector3(
		round(global_transform.origin.x * 10) / 10,
		round(global_transform.origin.y * 10) / 10,
		round(global_transform.origin.z * 10) / 10
	)
	# Use %d to format integers without decimals
	coordinates.text = "%d, %d, %d" % [rounded_position.x, rounded_position.y, rounded_position.z]






#__________________________________Weapon Management____________________________
#Main Weapon____________________________________________________________________
onready var attachment_r = $Mesh/Race/Armature/Skeleton/HoldL
onready var detector = $Mesh/Detector
var sword0: PackedScene = preload("res://itemTest.tscn")
var sword1: PackedScene = preload("res://itemTest.tscn")
var sword2: PackedScene = preload("res://itemTest.tscn")
var currentInstance: Node = null  
var main_weapon = "sword 0"
var got_weapon = false


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
	var slot = $UI/GUI/Character/Weapon
	var icon = $UI/GUI/Character/Weapon/Icon
	match main_weapon:
		"sword 0":
			if currentInstance == null:
				currentInstance = sword0.instance()
				fixInstance()
				
				var sword_texture = preload("res://0.png")
				addItemToCharacterSheet(icon,slot,sword_texture,"sword 0")
		"sword 1":    
			if currentInstance == null:
				currentInstance = sword1.instance()
				fixInstance()
		"sword 2":    
			if currentInstance == null:
				currentInstance = sword2.instance()
				fixInstance()
		"null":
			currentInstance = null
			got_weapon = false
func removeWeapon():
	if got_weapon:
		attachment_r.remove_child(currentInstance)
		got_weapon = false
func drop():
	if currentInstance != null and Input.is_action_just_pressed("drop") and got_weapon:
		removeWeapon()
		# Set the drop position
		var drop_position = global_transform.origin + direction.normalized() * 1.0
		currentInstance.global_transform.origin = Vector3(drop_position.x - rand_range(-0.3, 1), global_transform.origin.y + 0.2, drop_position.z + rand_range(-0.5, 0.88))
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
		$UI/GUI/Character/Weapon.item = "null"
		$UI/GUI/Character/Weapon/Icon.texture = null

func pickItemsMainHand():
	var bodies = $Mesh/Detector.get_overlapping_bodies()
	for body in bodies:
		if Input.is_action_pressed("attack"):
			#print(currentInstance)
			if currentInstance == null:
				if body.is_in_group("sword0") and not got_weapon:
					main_weapon = "sword 0"
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword1") and not got_weapon:


					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword3") and not got_weapon:


					body.queue_free()  # Remove the picked-up item from the floor
			elif currentInstance != null and sec_currentInstance == null:
				if body.is_in_group("sword0") and not got_sec_weapon:


					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword1") and not got_sec_weapon:
				
				
					body.queue_free()  # Remove the picked-up item from the floor
				elif body.is_in_group("sword3") and not got_sec_weapon:


					body.queue_free()  # Remove the picked-up item from the floor

func MainWeapon():
	pickItemsMainHand()
	switch()
	if Input.is_action_just_pressed("drop"):
		drop()
		main_weapon = "null"
#Secondary__________________________________________________________________________________________
onready var attachment_l = $Mesh/Armature020/Skeleton/HoldL
var sec_currentInstance: Node = null  
var has_sec_sword0 = false
var has_sec_sword1 = false
var has_sec_sword2 = false
var has_sec_sword3 = false
var got_sec_weapon = false

func fixSecInstance():
	attachment_l.add_child(sec_currentInstance)
	sec_currentInstance.get_node("CollisionShape").disabled = true
	sec_currentInstance.scale = Vector3(100, 100, 100)
	got_sec_weapon = true
func switchSec():
	if has_sec_sword0:
		if sec_currentInstance == null:
			sec_currentInstance = sword0.instance()
			fixSecInstance()
	elif has_sec_sword1:    
		if sec_currentInstance == null:
			sec_currentInstance = sword1.instance()
			fixSecInstance()
	elif has_sec_sword2:    
		if sec_currentInstance == null:
			sec_currentInstance = sword2.instance()
			fixSecInstance()
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
		# Set the drop position
		var drop_position = global_transform.origin + direction.normalized() * 1.0
		sec_currentInstance.global_transform.origin = Vector3(drop_position.x - rand_range(-0.3, 1), global_transform.origin.y + 0.2, drop_position.z + rand_range(-0.5, 0.88))
		# Set the scale of the dropped instance
		sec_currentInstance.scale = Vector3(1, 1, 1)
		var collision_shape = sec_currentInstance.get_node("CollisionShape")
		if collision_shape != null:
			collision_shape.disabled = false
		get_tree().root.add_child(sec_currentInstance)
		# Reset variables
		has_sec_sword0 = false
		has_sec_sword1 = false
		has_sec_sword2 = false
		got_sec_weapon = false
		sec_currentInstance = null
func SecWeapon():
	switchSec()
	if Input.is_action_just_pressed("drop"):
		dropSec()
		has_sec_sword0 = false
		has_sec_sword1 = false
		has_sec_sword2 = false
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


func displayLabels():
	var agility_label = $UI/GUI/Character/Stats/AgiLabel
	var int_label = $UI/GUI/Character/Stats/AgiLabel2
	displayStats(agility_label,agility)
	displayStats(int_label,intelligence)

func displayStats(label,value):
	label.text = str(value)
	

# Define effects and their corresponding stat changes
var effects = {
	"effect0": {"stats": {"agility": -0.05, "strength": 0.1}, "applied": false},
	"effect1": {"stats": {"health": -5, "mana": 10}, "applied": false},
	"effect2": {"stats": {"health": -5, "mana": 10, "intelligence": 2,"agility": 0.05,}, "applied": false},
	# Add more effects as needed
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



