extends KinematicBody
onready var player_mesh = $Mesh
onready var animation = $Mesh/Race/AnimationPlayer

var injured = false
var blend = 0.25
var agility = 1 

# Condition States
var is_attacking = bool()
var is_rolling = bool()
var is_walking = bool()
var is_running = bool()


func _ready(): 
	loadPlayerData()
	direction = Vector3.BACK.rotated(Vector3.UP, $Camroot/h.global_transform.basis.get_euler().y)

func _physics_process(delta):
	if Input.is_action_just_pressed("ui_focus_next"):
		is_in_combat = !is_in_combat
	$Debug.text = animation_state
	speedlabel()
	cameraRotation(delta)
	mouseMode()
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
	animations()
	animationsAll(delta)
	attack()
	doubleAttack(delta)
	fallDamage()
#_______________________________________________Basic Movement______________________________________
var jump_force = 9
var walk_speed = 5
var run_speed = 9.5
var h_rot 
var blocking = false
var is_in_combat = false
var enabled_climbing = false
var is_crouching = false
var crouch_speed = 3
var sprint_speed = 10
var is_sprinting = false
var energy = 300

var max_sprint_speed = 25
var max_sprint_animation_speed = 2.5
func walk(delta):
	h_rot = $Camroot/h.global_transform.basis.get_euler().y
	movement_speed = 0
	angular_acceleration = 3.25
	acceleration = 15
	# Movement input, state and mechanics.
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
var strength = 1 
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
						#animation_player_top.play("climb top",blend, strength * 0.4)#vaulting animation placeholder
						vertical_velocity = Vector3.UP * 3
						horizontal_velocity = direction * 15
					elif not is_wall_in_range:#normal climb
						#animation_player_top.play("climb cycle",blend, strength)
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
	if animation_state == "fall":
		#print("fall damage " + str(fall_damage))
		#print("fall distance " + str(fall_distance))
		fall_distance += 0.015
		if fall_distance > minimum_fall_distance: 
			fall_damage += 2.5 +(0.01 * max_health)
	else:
		health -= fall_damage
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
var dash_power = 15 # Controls roll and big attack speed boosts
var dodge_animation_duration = 0
var dodge_animation_max_duration = 6
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
var is_cursor = false
var is_aiming = false
var camrot_h = 0
var camrot_v = 0
onready var parent = $".."
export var cam_v_max = 200 # -75 recommended
export var cam_v_min = -125 # -55 recommended
onready var camera_v =$Camroot/h/v
onready var camera_h =$Camroot/h
onready var camera = $Camroot/h/v/Camera
onready var minimap_camera = $Minimap/Viewport/Camera
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
	var original_pos = camera_v.global_transform.origin
	
	var shake_timer = 0.0
	
	while shake_timer < duration:
		var noise_x = rand_range(-rand_x, rand_x) * intensity
		var noise_y = rand_range(-rand_y, rand_y) * intensity
		
		camera_v.global_translate(Vector3(noise_x, noise_y, 0))
		
		shake_timer += get_process_delta_time()
		yield(get_tree(), "idle_frame")
	
	camera_v.global_transform.origin = original_pos

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
	if not is_cursor:
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
	#Scrollwheel zoom in and out 		
	if event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_UP:
		# Zoom in when scrolling up
		Zoom(-1)
	elif event is InputEventMouseButton and event.button_index == BUTTON_WHEEL_DOWN:
		# Zoom out when scrolling down
		Zoom(1)
var mouse = false
func mouseMode():
#	if Input.is_action_pressed("rclick") and !is_sprinting and !is_crouching and !is_running and !is_swimming and !is_climbing:
#		is_aiming = true
#	else:
#		is_aiming = false	
	if Input.is_action_just_pressed("mousemode") or Input.is_action_just_pressed("ui_cancel"):	# Toggle mouse mode
		is_cursor =!is_cursor
		mouse =!mouse
	if !mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
func stiffCamera(delta):
	if is_aiming:
		player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)

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

onready var minimap = $Minimap
func miniMapVisibility():
	if Input.is_action_just_pressed("minimap"):
		minimap.visible = !minimap.visible
	
	
	
	
func lifesteal(damage):
	pass



#___________________________________________Save data system________________________________________
var entity_name = "esdai"
const SAVE_DIR = "user://saves/"
var save_path = SAVE_DIR + entity_name + "save.dat"
func savePlayerData():
	var data = {
		"position": translation,
		"camera.translation.y" : camera.translation.y,
		"camera.translation.z" : camera.translation.z,
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



var level = 1 
func _on_Detector_body_entered(body):
	if body.is_in_group("Spawner"):
			body.start()
			#body.quantity += 20


#__________________________________Entitygraphical interface________________________________________
onready var entity_graphic_interface = $EnemyUI
onready var entity_inspector 
onready var enemy_ui_tween = $EnemyUI/Tween
onready var enemy_health_bar = $EnemyUI/HP
onready var enemy_health_label = $EnemyUI/HP/HPlab
onready var enemy_energy_bar = $EnemyUI/EN
onready var enemy_energy_label = $EnemyUI/EN/ENlab
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
var animation_state = "idle"
func animations():
	match animation_state:
#combat 
		"slide":
			animation.play("slide",0.1)
			horizontal_velocity = direction * 12
			movement_speed = 12
		"guarding barehand":
			animation.play("guard",0.3)
		"guarding barehand walking":
			animation.play("walk guard barehand cycle")
			
		"punching":
			animation.play("full combo cycle",0.3,1)
			if can_move == true:
				horizontal_velocity = direction * 3
				movement_speed = 3
			elif can_move == false:
				horizontal_velocity = direction * 0
				movement_speed = 0
		"stomp":
			animation.play("stomp cycle",0.55,1)
			if can_move and !is_on_wall():
				horizontal_velocity = direction * 2
				movement_speed = 2
			else:
				horizontal_velocity = direction * 0.01
				movement_speed = 0
		"heavy attack":
			if barehanded_mode:
				animation.play("high kick",0.3,1)
			if can_move and !is_on_wall():
				horizontal_velocity = direction * 7
				movement_speed = 7
			else:
				horizontal_velocity = direction * 0.3
				movement_speed = 0
		"walk combat":
			if barehanded_mode:
				animation.play("walk cycle",0,1)
		"idle combat":
			if barehanded_mode:
				animation.play("barehanded idle",0.2,1) # to replace
#movement 
		"sprint":
			animation.play("run cycle", 0, sprint_animation_speed)
		"run":
			animation.play("run cycle")
		"walk":
			animation.play("walk cycle")
		"walk combat":
			animation.play("walk combat barehand cycle")
		"crouch":
			animation.play("crouch idle",0.4)
		"crouch walking":
			animation.play("walk crouch cycle")
		"jump":
			animation.play("jump standing",0.2, 1)
		"fall":
			animation.play("fall cycle",0.3)
		"crawl":
			animation.play("crawl dying begin cycle")
		"crawl limit":
			animation.play("crawl dying limit cycle")
		"idle downed":
			animation.play("idle downed", 0.35)
		"idle":
			animation.play("idle cycle")

			
var health = 100
var max_health = 100
var sprint_animation_speed = 1
func animationOutOfCombat(): #normal
	#dodge section is prioritized
	if  dodge_animation_duration > 0:
		animation_state = "slide"
	elif !is_on_floor() and !is_climbing and !is_swimming and !is_climbing:
		animation_state = "fall"
	elif jump_animation_duration != 0:
		animation_state = "jump"
	elif is_attacking:
		if !is_sprinting and !is_running and !is_swimming and !is_climbing and !is_walking:
			pass
		elif is_walking:
			pass
	elif  !is_swimming and is_on_floor():
		if is_sprinting:
			animation_state = "sprint"
		elif is_running:
			animation_state = "run"
		elif is_walking and is_crouching:
			animation_state = "crouch walking"
		elif is_running and Input.is_action_pressed("crouch"):
			animation_state = "crouch running"
		elif is_walking:
			if health < (max_health * 0.1):
				animation_state = "crawl"
			elif health < (max_health * 0.05):
				animation_state = "crawl limit"
			else:
				animation_state = "walk"
		elif Input.is_action_pressed("crouch"):
			animation_state = "crouch"
		#elif has_axe2 and  Input.is_action_pressed("attack"):
		#		animation_state = "chopping trees"
		else:
			if health < (max_health * 0.1):
				animation_state = "idle downed"
			else:
				animation_state = "idle"
var has_axe = false
func animationsBarehanded():
	if  dodge_animation_duration > 0:
		animation_state = "slide"
	elif double_atk_animation_duration > 0: 
		animation_state = "heavy attack"
	elif Input.is_action_pressed("rclick") and Input.is_action_pressed("attack"):
			animation_state = "stomp"
	elif Input.is_action_pressed("rclick"):
		if !is_walking:
			animation_state = "guarding barehand"
		else:
			animation_state = "guarding barehand walking"
	elif Input.is_action_pressed("attack"):
		if has_axe:
			animation_state = "choping wood"
		else:
			animation_state = "punching"
	elif is_sprinting:
			animation_state = "sprint"
	elif is_running:
			animation_state = "run"
	elif is_walking and is_crouching:
			animation_state = "crouch walking"
	elif is_walking:
			animation_state = "walk combat"
	elif jump_animation_duration != 0:
		animation_state = "jump"
	else:
		animation_state = "idle combat"
		
		
func animationStrafe():
	pass
	
var barehanded_mode = true 
func animationsAll(delta):
	if is_in_combat:
		if barehanded_mode:
			animationsBarehanded()	
	else:
		if not is_swimming:
			if is_aiming:
				animationStrafe()
			else:
				animationOutOfCombat()	
	if is_swimming:
		if is_walking:
			animation_state = "swim"
		else:
			animation_state = "idle water"
	if not is_on_floor() and not is_climbing and not is_swimming:
		animation_state = "fall"


#_______________________________________________Combat______________________________________________

func attack():
	if Input.is_action_pressed("attack"):
		is_attacking = true
	else:
		is_attacking = false
		
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
	var damage_type = "toxic"
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
