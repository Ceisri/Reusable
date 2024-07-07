extends KinematicBody


onready var debug:Control =  $UI/Debug
onready var name_label:Label3D = $Label3D
onready var canvas:CanvasLayer = $Canvas
onready var stats:Node = $Stats
onready var data:Node = $SaveData
onready var popup_viewport:Viewport =  $Sprite3D/Viewport

var username: String
var entity_name:String = "Human"
var is_player:bool = true 
var online_mode:bool = true

puppet var puppet_username: String
var is_in_combat:bool = false


func _ready() -> void:
	add_to_group("Entity")
	add_to_group("Player")
	setEngineTicks(max_engine_FPS)
	setProcessFPS(max_processs_FPS)
	loadUniversalData()
	
	
	
var max_engine_FPS:int = 24
var max_processs_FPS:int = 24
func setEngineTicks(ticks_per_second: int) -> void:
	Engine.iterations_per_second = ticks_per_second
func setProcessFPS(fps: int) -> void:
	Engine.target_fps = fps




func _physics_process(delta: float) -> void:
	fastRefreshFunctions(delta)
func fastRefreshFunctions(delta:float)-> void:
	gravity()
	climbStairs()
	climb()
	mouseMode()
	rotateMesh()
	movement(delta)
	camera_rotation()
	animationTest()
	clickInputs()
	fullscreen()
	pickupObject()
	carryObject()


var gravity_force: float = 20
func gravity():#for seamless climbing first check if is_climbing
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
				

var blend: float = 0.22

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
var state = Autoload.state_list.idle
onready var animation:AnimationPlayer =  $DirectionControl/Character/AnimationPlayer
var attacking:bool = false
func animationTest()-> void:#Momentary Delete Later
	if is_instance_valid(animation):
		if !is_on_floor():
			if flip_duration == true:
				animation.play("flip")
			else:
				if !is_on_wall():
					if movement_mode != "climb":
						animation.play("fall")
		elif attacking == true:
			animation.play("punch",blend)
			moveTowardsDirection(6)
		elif moving == true:
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
	
		else:
			if sneaking == true:
				animation.play("sneak", 0.3)
			else:
				animation.play("idle", 0.3)
		


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

	if input_direction.length() > 0:
		direction = input_direction.rotated(Vector3.UP, h_rot).normalized()
		moving = true
		movement_speed = walk_speed
	elif joystick_active:
		direction = -joystick_direction.rotated(Vector3.UP, h_rot).normalized()
		moving = true
		movement_speed = walk_speed
	
	if moving == true:
		if Input.is_action_pressed("sprint"):
			is_in_combat = false
			movement_speed = sprint_speed
			movement_mode = "sprint"
			if sprint_speed < max_sprint_speed:
				sprint_speed += 0.005 * stats.agility
			elif sprint_speed > max_sprint_speed:
				sprint_speed = max_sprint_speed
		elif Input.is_action_pressed("run"):
			sprint_speed = default_sprint_speed
			movement_mode = "run"
			movement_speed = run_speed

		elif sneaking == true:
			sprint_speed = default_sprint_speed
			movement_mode = "sneak"
			movement_speed = walk_speed * 0.5
		else: # Walk State and speed
			if stats.health >0:
				sprint_speed = default_sprint_speed
				movement_speed = walk_speed 
				movement_mode = "walk"
			else:
				sprint_speed = default_sprint_speed
				movement_speed = walk_speed * 0.3
				movement_mode = "crawl"
	if sneak_toggle == true:
		if Input.is_action_just_pressed("sneak"):
			sneaking = !sneaking
	if sneak_toggle == false:
		if Input.is_action_pressed("sneak"):
			sneaking = true
		else:
			sneaking = false
	if jump_count < 1:
		if carried_body == null:
			if is_on_floor():
				if Input.is_action_just_pressed("jump"):
					jump_count += 1
					vertical_velocity = Vector3.UP * jump_strength
			else:
				if Input.is_action_just_pressed("jump"):
					jump_count += 1
					vertical_velocity = Vector3.UP * jump_strength
					flip_duration = true
	if is_on_floor():
		jump_count = 0
		
	print(jump_count)



	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)

func _on_SneakToggle_pressed():
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
func dodgeIframe():
	if state == Autoload.state_list.slide or backstep_duration == true or frontstep_duration == true or leftstep_duration == true or rightstep_duration == true or dash_duration == true:
		set_collision_layer(6) 
		set_collision_mask(6) 
	else:
		set_collision_layer(1) 
		set_collision_mask(1)   
		
func doublePressToDash()-> void:
	pass
#	if stats.resolve >= all_skills.dash_cost:
#		if dash_countback > 0:
#			dash_timerback += get_physics_process_delta_time()
#		if dash_timerback >= double_press_time:
#			dash_countback = 0
#			dash_timerback = 0.0
#		if Input.is_action_just_pressed("backward"):
#			dash_countback += 1
#		if dash_countback == 2 and dash_timerback < double_press_time:
#			dash_duration = true
#			resolve -= all_skills.dash_cost
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
#			resolve -= all_skills.dash_cost
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
#			resolve -= all_skills.dash_cost
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
#			resolve -= all_skills.dash_cost


func climbStairs()-> void:
	if moving:
		if climb_ray.is_colliding():
			if is_on_wall():
				if is_on_floor():
					vertical_velocity = Vector3.UP * (stats.strength * 3)
					horizontal_velocity = direction * walk_speed * 2


var is_swimming:bool = false
var wall_incline
var is_wall_in_range:bool = false
var gravity_active:bool = true
onready var head_ray =  $DirectionControl/HeadRay
onready var climb_ray =  $DirectionControl/ClimbRay
func climb()-> void:
	if carried_body == null:
		if climb_ray.is_colliding() and is_on_wall():
			if moving == true and not Input.is_action_pressed("sprint") and not Input.is_action_pressed("run") and not Input.is_action_pressed("sneak"):
				gravity_active = false
				checkWallInclination()
				if not head_ray.is_colliding() and not is_wall_in_range:#vaulting
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

func mouseMode()-> void:
	if Input.is_action_just_pressed("ui_cancel"):	# Toggle mouse mode
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

#Input section______________________________________________________________________________________
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
func fullscreen()-> void:
	if Input.is_action_just_pressed("fullscreen"):
		is_fullscreen = !is_fullscreen
		OS.set_window_fullscreen(is_fullscreen)
		saveGame()
		
		
		
#SaveGame___________________________________________________________________________________________

func saveGame()->void:
	for entity in get_tree().get_nodes_in_group("Entity"):
		entity.saveUniversalData()
		




var slot: String = "1"
var save_directory: String = "user://saves/"
var save_path: String = save_directory +  "save.dat" 
func saveUniversalData():
	var data = {
		"position": translation,
		"health": stats.health,
		"max_health": stats.max_health,
		}
	var dir = Directory.new()
	if !dir.dir_exists(save_directory):
		dir.make_dir_recursive(save_directory)
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, "P@paB3ar6969")
	if error == OK:
		file.store_var(data)
		file.close()
		
func loadUniversalData():
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
				#print(str(fade_duration))


func showEntityIntel(body)-> void:#show this if the playe has enough perception or other stats, players will be able to see these enemy info just by looking at them 
	entity_frontdef_label.text ="front defense: "+ str(body.stats.front_defense)
	entity_flankdef_label.text ="flank defense: "+ str(body.stats.flank_defense)
	entity_backdef_label.text ="back defense: "+ str(body.stats.back_defense)
	
var carried_body: KinematicBody = null
var hold_offset: Vector3 = Vector3(0, 2, 0)
var throw_force: float = 25.0 # Adjust the throw force as needed
var max_pickup_distance: float = 2.0 # Maximum distance to allow picking up objects

func pickupObject() -> void:
	if Input.is_action_just_pressed("pickup"):
		if carried_body:
			var throw_direction = (carried_body.global_transform.origin - camera.global_transform.origin).normalized()
			carried_body.move_and_slide(throw_direction * throw_force)
			carried_body.direction = throw_direction
			carried_body.thrown = true
			carried_body = null
		elif ray.is_colliding():
			var body = ray.get_collider()
			if body and body != self and body.is_in_group("Liftable"):
				var distance_to_body = body.global_transform.origin.distance_to(global_transform.origin)
				if distance_to_body <= max_pickup_distance:
					carried_body = body

func carryObject():
	if carried_body:
		carried_body.translation = translation + hold_offset

