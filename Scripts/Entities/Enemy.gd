extends KinematicBody

export var entity_name: String = "Bandit"
export var species: String = "Goblin"
export var is_boss:bool = false
export var stationary:bool = false
export var can_respawn:bool = true
export var can_be_looted:bool = false 
export var is_randomized:bool = false
export var can_wear_armor:bool = true


export var save_data_password:String = "Mei is quite Cute"
export var spawn_point:Vector3 = Vector3(0,10,0)


export var weight:float = 50

onready var world = get_parent()
var experience_worth:int = 15
onready var threat_system: Node = $Threat
onready var animation = $Mesh/EntityHolder/AnimationPlayer
onready var entity_holder = $Mesh/EntityHolder
onready var stats = $Stats
onready var effects = $Effects

var vertical_velocity : Vector3 = Vector3()
var movement: Vector3 = Vector3()
var horizontal_velocity : Vector3 = Vector3()
var is_climbing:bool = false
var movement_speed = int()
var angular_acceleration = int()
var acceleration = int()
var random_atk:float

var dropped_loot:bool = false
var garroted:bool = false
var thrown: bool = false
var is_being_held:bool = false
var thrower:Node = null

var deadly_bleeding_duration:float = 0
var frame_limiter:int = 100000
var frame_limiter2:int = 100000
func _ready() -> void:
	frame_limiter = Autoload.rng.randi_range(2,4)
	frame_limiter2 = Autoload.rng.randi_range(6,12)
	loadData()

func _physics_process(delta: float) -> void:
	$Label3D2.text = str(stats.health)
	$DebugLabel2.text = active_action
	if is_being_held == false:
		if Engine.get_physics_frames() % frame_limiter == 0:  
				behaviourTree()
				if stats.health >0:
					threat_system.loseThreat()
				if stats.health <0 or stats.health ==0:
					can_be_looted = true
		
		if Engine.get_physics_frames() % frame_limiter2 == 0:
			Autoload.entityGravity(self)
			

					
		if Engine.get_physics_frames() % 5 == 0:  # Every 5 physics frames 
				rotateShadow()
				moveShadow()
		if Engine.get_physics_frames() % 24 == 0:
			effects.effectManager()
			letMeDie()
			lostAndFound()

	else:
		getThrown(delta)
		gravity()



var gravity_active: bool = true
var gravity_force: float = 9.0

func gravity():#only for when the enemy is being thrown
	if not is_on_floor():
		vertical_velocity += Vector3.DOWN * gravity_force * get_physics_process_delta_time()
		
	else:
		vertical_velocity = Vector3.ZERO

func getThrown(delta: float) -> void:
	if thrown == true:
		horizontal_velocity = (direction * (thrower.stats.strength * 15)) / (weight/10)
		set_collision_layer(1) 
		set_collision_mask(1) 
		if is_on_floor():
			thrower = null
			is_being_held = false
			thrown = false
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)

	var collision = move_and_collide(movement)
	if collision:
		if collision.collider.is_in_group("Entity"):
			if is_instance_valid(collision.collider.stats):
				if collision.collider != thrower:
					if thrown == true:
						collision.collider.stats.getHit(thrower, 15, Autoload.damage_type.blunt,0)
						vertical_velocity = Vector3.DOWN * 3
						

		direction = Vector3.ZERO
		horizontal_velocity = Vector3.ZERO

func saveData():
	var save_directory: String = "user://Worlds/" + world.world_name + "/" + species + "/" + entity_name + "/" +str(name)+ "/" 
	var save_path: String = save_directory  + "/save.dat"
	var data = {
		"position": translation,
		"health": stats.health,
		"max_health": stats.max_health,
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
	var save_directory: String = "user://Worlds/" + world.world_name + "/" + species + "/" + entity_name + "/" +str(name)+ "/" 
	var save_path: String = save_directory  + "/save.dat"
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


func respawn()->void:
	print("not at spawn point")
	translation =  spawn_point
	print("respawned at spawn point")
	how_long_have_i_been_dead = 0 
	stats.health = stats.max_health
	threat_system.resetThreats()
	can_be_looted = false
	state = Autoload.state_list.wander
	dying = false
	dead = false

	if is_randomized == true:
		if can_wear_armor == true:
			entity_holder.selectRandomEquipment()
func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)



var state = Autoload.state_list.wander
var dying:bool = false
var dead:bool = false
var staggered_duration: bool = false
var knockeddown:bool = false
var knockeddown_first_part:bool = false

func behaviourTree()->void:
	var target = threat_system.findHighestThreat()
	if stats.health <0:
		if dying == true:
			if dead == false:
				if animation:
					animation.play("death",0.6)
			else:
				if animation:
					animation.play("dead",0.6)
		else:
			if animation:
				animation.play("dead",0.6)
	elif garroted == true:
		animation.play("garroted",0.2)
	elif stunned_duration > 0:
		animationCancel()
		animation.play("stunned",0.2)

	elif knockeddown == true:
		animReset()
		animationCancel()
		if stats.health > 1:
			animation.play("knocked down",0.3)
			if knockeddown_first_part == false:
				lookTarget(5)
				
	elif staggered_duration == true:
		animationCancel()
		animation.play("staggered",0.2)
		
	else:
		if garroted == false:
			matchState()

onready var wander:Node = $Wandering
func matchState()->void:
	if animation:
		match state:
			Autoload.state_list.idle:
				animation.play("idle",0.3)
			Autoload.state_list.wander:
				if stationary == false:
					wander.wander()
					if wander.is_walking == true:
						animation.play("walk")
					else:
						animation.play("idle")
				forceDirectionChange()
			Autoload.state_list.curious:
				lookTarget(turn_speed)
			Autoload.state_list.engage:
				combat()
			Autoload.state_list.orbit:
				if staggered_duration == false:
					if orbit_time > 0:
						orbit_time -= 3 * get_physics_process_delta_time()
						orbitTarget()
						lookTarget(turn_speed)
					else:
						state = Autoload.state_list.engage

onready var wall_check_ray:RayCast = $RayStraightLonger
onready var check_floor_ray: RayCast = $RayCheckFloor
func forceDirectionChange() -> void:
	var collider = wall_check_ray.get_collider()
	var collider_floor = check_floor_ray.get_collider()

	if collider and not collider.is_in_group("Player"):
		tween.interpolate_property(self, "rotation_degrees:y", self.rotation_degrees.y, self.rotation_degrees.y - 90, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
	if not collider_floor:
		tween.interpolate_property(self, "rotation_degrees:y", self.rotation_degrees.y, self.rotation_degrees.y + 90, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()
var orbit_time:float = 5
onready var ray_straight: RayCast = $RayStraight

func slideLeft():
	var distance = 2.0
	
	var direction_to_target = -global_transform.basis.x  # Move sideways to the left
	
	var movement = direction_to_target * distance * stats.speed * get_process_delta_time()
	
	move_and_slide(movement)





var direction: Vector3
onready var tween = $Tween

func slideForward() -> void:
	if stored_attacker != null:
		var  distance_to_target = findDistanceTarget()
		if distance_to_target > 1.4:
			var distance: float = 2.0
			var direction: Vector3 = (stored_attacker.global_transform.origin - global_transform.origin).normalized()
			var target_position: Vector3 = global_transform.origin + (direction * distance)

			tween.stop_all()
			tween.interpolate_property(self, "translation", global_transform.origin, target_position, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
			tween.start()
		else:
			tween.stop_all()
func stopSlidingForward()-> void:
	tween.stop_all()
var turn_speed = 9



func rotateAwayFromDirection(target_direction: Vector3) -> void:
	if target_direction.length_squared() > 0.0001:
		var look_at_rotation = Basis()
		look_at_rotation = look_at_rotation.rotated(Vector3(0, 1, 0), atan2(-target_direction.x, -target_direction.z))
		self.global_transform.basis = look_at_rotation

func rotateTowardsDirection(target_direction: Vector3) -> void:
	if target_direction.length_squared() > 0.0001:
		var look_at_rotation = Basis()
		look_at_rotation = look_at_rotation.rotated(Vector3(0, 1, 0), atan2(target_direction.x, target_direction.z))
		self.global_transform.basis = look_at_rotation

func lookTarget(speed: float) -> void:
	var target = threat_system.findHighestThreat()
	if not target:
		return
	
	var direction = (target.player.global_transform.origin - global_transform.origin).normalized()
	direction.y = 0  # Set the Y component to 0 to prevent flying
	
	if direction.length_squared() > 0.0001:
		var current_direction = -global_transform.basis.z.normalized()
		var target_rotation = current_direction.linear_interpolate(direction, speed)
		
		var look_at_rotation = Basis()
		look_at_rotation = look_at_rotation.rotated(Vector3(0, 1, 0), atan2(target_rotation.x, target_rotation.z))
		self.global_transform.basis = look_at_rotation



func followTarget(angry:bool)->void:
	if angry == false:
		var target =threat_system.findHighestThreat()
		if target:
			
			direction = (target.player.global_transform.origin - global_transform.origin).normalized()
			direction.y = 0  # Set the Y component to 0 to prevent flying
			rotateTowardsDirection(direction)
			move_and_slide(direction * stats.speed)
	else:
		var target =threat_system.findLowestThreat()
		if target:
			rotateTowardsDirection(direction)
			direction = (target.player.global_transform.origin - global_transform.origin).normalized()
			direction.y = 0  # Set the Y component to 0 to prevent flying
			move_and_slide(direction * stats.speed)
			
			
var orbit_angle = 0.0  # Declare orbit_angle as a member variable
func orbitTarget()->void:
	if stats.health > 0: 
		var  distance_to_target = findDistanceTarget()
		if distance_to_target:
			var target = threat_system.findHighestThreat()
			if target != null:
				var center = target.player.global_transform.origin
				var radius = 4  # Set your desired radius here
				var min_distance_to_start_orbit = 5  # Adjust the minimum distance to start orbiting
				var max_orbit_speed = stats.speed * 0.7  # Adjust the maximum orbit speed (30% of walk_speed)
				var min_orbit_speed = stats.speed * 0.08  # Adjust the minimum orbit speed (10% of walk_speed)
				var orbit_speed = clamp((max_orbit_speed - min_orbit_speed) * (1 - distance_to_target / min_distance_to_start_orbit) + min_orbit_speed, min_orbit_speed, max_orbit_speed)
				if distance_to_target > min_distance_to_start_orbit:
					var direction_to_target = (center - global_transform.origin).normalized()# Move towards the target until the minimum distance is reached
					global_transform.origin += direction_to_target * stats.speed * get_process_delta_time()
				else:
					var relative_position = global_transform.origin - center# Calculate the relative position of the object from the target
					#relative_position.y = 0  # Make sure the rotation is in the XZ plane
					var rotation_angle = orbit_speed * get_process_delta_time()# Calculate the rotation angle
					var rotated_position = relative_position.rotated(Vector3.UP, rotation_angle)# Calculate the new position by rotating around the target
					global_transform.origin = center + rotated_position# Set the new position relative to the target
func findDistanceTarget():
	var target = threat_system.findHighestThreat()
	if target != null:
		var center = target.player.global_transform.origin
		var distance_to_target = global_transform.origin.distance_to(center)
		return distance_to_target
#________________This Section is dedicated to moving towards random directions______________________
var rotation_speed: float = 2.0

onready var take_damage_audio = $TakeHit

func takeThreat(aggro_power,instigator)->void:
	stored_attacker = instigator
	var target = threat_system.createFindThreat(instigator)
	state = Autoload.state_list.engage
	target.threat += aggro_power
	
	

var parry: bool =  false
var absorbing: bool = false



func getKnockedDown(instigator)-> void:#call this for skills that have a different knock down chance
	var text = Autoload.floatingtext_damage.instance()
	text.status = "Knocked Down!"
	add_child(text)
	animReset()
	
func animReset():
	active_action = "none"
	staggered_duration = false

	

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


var stored_attacker:KinematicBody 
var bleeding_duration:float = 0
var stunned_duration:float = 0
var berserk_duration:float = 0 




func staggeredOver():
	state = Autoload.state_list.wander
	staggered_duration = false
	
var active_action:String = "none"

func combat()->void:
	if staggered_duration == false:
		var  distance_to_target = findDistanceTarget()
		attackAnimations()
		if distance_to_target != null:
			if distance_to_target <= 2:
				randomizeAttacks()
			else:
				if random_atk > 0.8:
					animation.play("ultimate",0.1)
					animationCancel()
				else:
					chase()



func chase()->void:
	if active_action == "none":
		lookTarget(turn_speed)
		followTarget(false)
		animation.play("walk",0.1)
func attackAnimations()->void:
	match active_action:
		"atk1":
			animation.play("atk1", 0.25,1)
		"atk2":
			animation.play("atk2", 0.3,1)
		"atk3":
			animation.play("atk3", 0.3,1)
		"atk4":
			animation.play("atk4", 0.3)
		"atk5":
			animation.play("atk5", 0.3)

func animationCancel()->void:
	active_action = "none"
	
func changeAttackType()->void:
	random_atk = rand_range(0,1)
	match active_action:
		"atk1":
			active_action = "atk2"
		"atk2":
			active_action = "atk3"
		"atk3":
			active_action = "atk4"
		"atk4":
			active_action = "atk5"
		"atk5":
			active_action = "atk1"

var atk2_cost: float = 60

var can_switch_atk:bool = true
func randomizeAttacks() -> void:
	if random_atk < 0.2:  # 20%
		active_action = "atk1"
	elif random_atk < 0.4:  # 20%
#		if resolve > atk2_cost:
			active_action = "atk2"
#		else:
#			if random_atk <0.5:
#				atk3_duration = true
#			else:
#				atk5_duration = true
	elif random_atk < 0.6:  # 20%
		active_action = "atk3"
	elif random_atk < 0.8:  # 20%
		active_action = "atk4"
	else:  # 20%
		active_action = "atk5"


func die()->void:
	dying = false
	dead = true
func getUp()->void:
	knockeddown = false
	state = Autoload.state_list.wander
func startGettingUp()->void:
	knockeddown_first_part = false

onready var collision_shape:CollisionShape = $CollisionShape
var how_long_have_i_been_dead:float = 0
func letMeDie()->void:
	if stats.health <= -98.9:
		how_long_have_i_been_dead += 1
		if how_long_have_i_been_dead >= 10:
			respawn()




func goBeserk()->void:
	berserk_duration += 20
	if stats.health < stats.max_health:
		stats.health += 15






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

var time_fallin:int = 0
var time_stuck_on_wall:int = 0 
onready var ray_down:RayCast =$RayDownBehind
func lostAndFound():
	if not ray_down.is_colliding():
		time_fallin += 1
		#print(str(name)+ "fallen for: " + str(time_fallin))
		if time_fallin > 5:
			translation = spawn_point
			time_fallin = 0
	else:
		time_fallin = 0
#	if is_on_wall():
#		time_stuck_on_wall += 1
#		if time_stuck_on_wall > 5:
#			translation = spawn_point
#			time_stuck_on_wall = 0
#	else:
#		time_stuck_on_wall = 0
