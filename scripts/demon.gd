extends KinematicBody

onready var tridi_label = $Label3D
onready var eyes = $Eyes
onready var players = get_tree().get_nodes_in_group("Player")
const aggro_gain_radius = 20
const turn_speed = 3
const aggro_timer_interval = 1  # Set the interval according to your needs
var is_target_at_melee_range : bool = false
var is_chasing : bool = false
var is_target_at_dash_range : bool = false
var is_sprinting : bool = false
class PlayerAggro:
	var player : Node
	var aggro : int
var targets : Array = []
var coward : PlayerAggro
var speed = 4
var velocity = Vector3()
var max_distance = 30.1
var aggro_info


func _physics_process(delta):
	aggro_info = gatherAggroInformation()
	var target = findTargetWithHighestAggro()
	is_moving()
	gravity()
	updateStats()
	rotateTowardsTarget(target)
	forceDirectionChange(target)
	animations(target)	
	# Display the list of player aggro information on the label
	#displayAggroInfo(aggro_info)
	# Rotate towards the target with the highest aggro
	directionChangeTimer += delta
	if target:
		var distance_to_target = global_transform.origin.distance_to(target.player.global_transform.origin) 
		is_target_at_melee_range = distance_to_target <= 2.0
		is_target_at_dash_range = distance_to_target > 0 and distance_to_target <= 8.0
		is_chasing = distance_to_target > 8.0
		if distance_to_target > 12 and distance_to_target <= 25:
			is_sprinting = true
		else:
			is_sprinting = false
func _on_AggroTimer_timeout():
	$Health.text = str(health)
	for playerAggro in targets:
		var distance = eyes.global_transform.origin.distance_to(playerAggro.player.global_transform.origin)
		var aggro_change = calculateAggroChange(distance, playerAggro.aggro)

		if distance <= aggro_gain_radius:
			playerAggro.aggro += aggro_change
		else:
			playerAggro.aggro = max(0, playerAggro.aggro - 5)
func gatherAggroInformation() -> Array:
	var aggro_info = []  # Array to store player aggro information
	for playerAggro in targets:
		var player = playerAggro.player
		var distance = eyes.global_transform.origin.distance_to(player.global_transform.origin)
		# Aggro change logic moved to _on_AggroTimer_timeout
		aggro_info.append(player.entity_name + " ID: " + str(player.get_instance_id()) + " Aggro: " + str(playerAggro.aggro))
	return aggro_info


func getOrCreatePlayerAggro(player: Node) -> PlayerAggro:
	for existingTarget in targets:
		if existingTarget.player == player:
			return existingTarget
	var playerAggro = PlayerAggro.new()
	playerAggro.player = player
	targets.append(playerAggro)
	return playerAggro

func findTargetWithHighestAggro() -> PlayerAggro:
	var highest_aggro = -1
	var target : PlayerAggro = null
	for playerAggro in targets:
		if playerAggro.aggro > highest_aggro:
			target = playerAggro
			highest_aggro = playerAggro.aggro
	return target
func displayAggroInfo(aggro_info: Array):
	tridi_label.text = "\n".join(aggro_info)
func rotateTowardsTarget(target: PlayerAggro):
	if target and target.player.is_in_group("Player"):
		# Move towards "Base" regardless of distance 
		eyes.look_at(target.player.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turn_speed))
		moveTowardsPlayerWithHighestAggro()
	elif target and target.player.global_transform.origin.distance_to(global_transform.origin) < max_distance:
		# Move towards players only if nearby
		eyes.look_at(target.player.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turn_speed))
		moveTowardsPlayerWithHighestAggro()
	else:
		if not is_idle:
			move_and_slide(getSlideVelocity(walk_speed))

var direction

func moveTowardsPlayerWithHighestAggro():
	var target = findTargetWithHighestAggro()
	if target and not is_target_at_melee_range:
		# Assuming the enemy has a KinematicBody and a speed variable
		direction = (target.player.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0  # Set the Y component to 0 to prevent flying
		move_and_slide(direction * speed)
#________________This Section is dedicated to moving towards random directions______________________
var directionChangeTimer = 0.0
var directionChangeInterval = 0.0
var targetRotation : Quat
var rotationSpeed : float = 2.0
func moveRandomDirection():
	if directionChangeTimer >= directionChangeInterval:
		directionChangeTimer = 0.0
		var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
		targetRotation = Quat(Vector3.UP, randomDirection)
func changeRandomDirection():
	var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
	var lookRotation = randomDirection.angle_to(Vector3.FORWARD)
	rotate_y(lookRotation)
func getSlideVelocity(speed: float) -> Vector3:
	var forwardVector = -transform.basis.z
	return forwardVector * speed
onready var change_direction_timer = $ChangeDirection
var minChangeInterval = 3
var maxChangeInterval = 12
var idle_chance = 0.25 
var idle_min_duration = 1
var idle_max_duration = 21
var is_idle = false
var is_walking = false
func _on_ChangeDirection_timeout():
	if randf() < idle_chance:
		# Enemy goes idle
		var idle_duration = rand_range(idle_min_duration, idle_max_duration)
		set_process(true)  # Enable _process so we can track idle duration
		yield(get_tree().create_timer(idle_duration), "timeout")
		is_walking = false
		is_idle = true
		#print("Idle for:", idle_duration, "seconds")
	else:
		changeRandomDirection()
		# Set a new random interval for the timer
		change_direction_timer.wait_time = rand_range(minChangeInterval, maxChangeInterval)
		change_direction_timer.start()
		#print("Moving, next change in:", change_direction_timer.wait_time)
		is_walking = true 
		is_idle = false
onready var wall_check_ray = $RayCheckWalls
onready var check_floor_ray = $RayCheckFloor
func forceDirectionChange(target):
	if !target:
		# Ray hit something, get the collider
		var collider = wall_check_ray.get_collider()
		var collider_floor = check_floor_ray.get_collider()
		# Check if the collider is not in the "Player" group
		if collider and not collider.is_in_group("Player"):
			# Collider is not in the "Player" group, change direction
			changeRandomDirection()
			#print("wall")
		if not collider_floor:
			changeRandomDirection()
			#print("avoid falling down")
func calculateAggroChange(distance, aggro):
	if distance <= 1:
		return 6
	elif distance <= 5:
		return 5
	elif distance <= 7:
		return 4
	elif distance <= 9:
		return 3
	elif distance <= 10:
		return 2
	elif distance <= 15:
		return 1
	elif distance <= 20:
		return 0
	elif distance <= 25:
		return -1
	elif distance <= 30:
		return max(-2, -aggro)
	else:
		return max(-50000, -aggro)
var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_audio = $TakeHit
onready var take_damage_view  = $TakeDamageView/Viewport
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type):
	$Health.text = str(health)
	take_damage_audio.play()
	var random = randf()
	var damage_to_take = damage
	var instigatorAggro = getOrCreatePlayerAggro(instigator)
	var text = floatingtext_damage.instance()
	if damage_type == "slash":
		var mitigation = slash_resistance / (slash_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
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

	health -= damage_to_take	
	instigatorAggro.aggro += damage_to_take + aggro_power
	text.amount =round(damage_to_take * 100)/ 100
	text.state = damage_type
	take_damage_view.add_child(text)
	if health < 0:
		getKilled(instigator)
		queue_free()	
	
	
	
func takeAggro(aggro_power,instigator):
	var instigatorAggro = getOrCreatePlayerAggro(instigator)
	instigatorAggro.aggro += aggro_power

	
var staggered = 0 #1 equals 0.1seconds	
func _on_Duration_timeout():
	if staggered >=0:
		staggered = max(0, staggered - 0.1)
func getKilled(instigator):
	var instigatorAggro = getOrCreatePlayerAggro(instigator)
	if instigator.has_method("receiveExperience"):
		instigator.receiveExperience(150)

func roundToTwoDecimals(number):
	return round(number * 100.0) / 100.0
func is_moving() -> bool:
	# Check if the enemy has a non-zero velocity	
	return get_slide_count() > 0
var is_dashing = false
func dashSpeed():
	print(speed)
	is_dashing = !is_dashing
	if is_dashing:
		speed += 6
	else:
		speed -= 6
func normalSpeed():
	pass
var blend = 0.3
func animations(target: PlayerAggro):
	var animation = $AnimationPlayer
	if staggered == 0:
		if target:
			if target.player.global_transform.origin.distance_to(global_transform.origin) < max_distance:
				if is_target_at_melee_range:
					animation.play("slash", blend)
					speed = 4
				elif is_target_at_dash_range:
					speed = 10
					animation.play("dash", blend)
				elif is_sprinting:
					speed = 20
					animation.play("run", blend)
				elif is_chasing:
					speed = 4
					animation.play("walk", blend)
			else:
				if is_walking:
					animation.play("walk", blend)
				else:
					animation.play("idle", blend)
		else:
			if is_walking:
				animation.play("walk", blend)
				speed = 0
			else:
				animation.play("idle", blend)
	else:
		animation.play("tpose",0.4)
var gravity_force = Vector3(0, -9.8, 0)
func gravity():	# Apply gravity
	velocity += gravity_force
	# Move the character
	var movement = velocity 
	move_and_collide(movement)
func teleportBehindPlayer():
	# 25% chance to teleport behind target with highest aggro
	var target = findTargetWithHighestAggro()
	if target and randf() < 0.3:
		var mesh = target.player.find_node("Mesh")  # Assuming "Mesh" is a direct child of the target
		if mesh:
			var mesh_basis = mesh.global_transform.basis
			var teleport_position = target.player.global_transform.origin - mesh_basis.z * 5.0
			global_transform.origin = teleport_position
func pushPlayerBackNULL():
	var target = findTargetWithHighestAggro()
	#var player_mesh = target.player.find_node("Mesh")  # Assuming "Mesh" is a direct child of the player
	var player_camera = target.player.find_node("Camera")  # Assuming "Camera" is a direct child of the player
	if player_camera:
		var camera_transform = player_camera.global_transform
		var camera_forward = -camera_transform.basis.z.normalized()
		# Move the player backward (adjust the distance as needed)
		var push_distance = 35
		var movement = camera_forward * push_distance
		target.player.move_and_slide(movement)
		
		
		
		
onready var health_bar = $Viewport/HPbar
func updateStats():
	health_bar.value = health
	health_bar.max_value = max_health
	
#stats______________________________________________________________________________________________
var entity_name = "Demon"
var level = 1
var health = 100
const base_health = 100
var max_health = 100
const base_max_health = 100
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
var strength = 1.5
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


var critical_chance = 0.3
var critical_strength = 2
var stagger_chance = 0.3
func slash():
	var rand_num = randi() % 12  # Generate a random number between 0 and 11
	var damage_type: String = ""

	if rand_num == 0:
		damage_type = "slash"
	elif rand_num == 1:
		damage_type = "blunt"
	elif rand_num == 2:
		damage_type = "pierce"
	elif rand_num == 3:
		damage_type = "sonic"
	elif rand_num == 4:
		damage_type = "heat"
	elif rand_num == 5:
		damage_type = "cold"
	elif rand_num == 6:
		damage_type = "jolt"
	elif rand_num == 7:
		damage_type = "toxic"
	elif rand_num == 8:
		damage_type = "acid"
	elif rand_num == 9:
		damage_type = "bleed"
	elif rand_num == 10:
		damage_type = "neuro"
	else:
		damage_type = "radiant"

	var damage = 15
	var aggro_power = damage + 20
	var enemies = $Area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("Player"):
			if enemy.has_method("takeDamage"):
					pushEnemyAway(0.05, enemy,0.15)
					#insert sound effect here
					if randf() <= critical_chance:
						var critical_damage = damage * critical_strength
						enemy.takeDamage(critical_damage,aggro_power,self,stagger_chance,"slash")
					else:
						enemy.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
onready var tween = $Tween
func pushEnemyAway(push_distance, enemy, push_speed):
	if enemy.animation_state != null:
		if enemy.animation_state != "guard":
			if not isFacingSelf(enemy,0.45):
				print("player is not facing the enemy")
				if enemy.animation_state != "guard attack":
					if enemy.animation_state != "guard walk":
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
							var bounce_motion = -2 * normal * normal.dot(motion) + motion
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
	else:
		# If Mesh node is not found, use the default facing direction of the enemy
		enemy_facing_direction = enemy_global_transform.basis.z.normalized()
	# Calculate the dot product between the enemy's facing direction and the direction to the calling object (self)
	var dot_product = -enemy_facing_direction.dot(direction_to_enemy)
	# If the dot product is greater than a certain threshold, consider the enemy is facing the calling object (self)
	return dot_product >= threshold








var lifesteal_pop = preload("res://UI/lifestealandhealing.tscn")
var life_steal: float = 0
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

func showStatusIcon(icon1, icon2, icon3, icon4, icon5, icon6, icon7, icon8, icon9, icon10, icon11, icon12, icon13, icon14, icon15, icon16, icon17, icon18, icon19, icon20, icon21, icon22, icon23, icon24):
	
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
