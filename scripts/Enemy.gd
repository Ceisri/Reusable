extends KinematicBody

var experience_worth:int = 15
onready var threat_system: Node = $Threat
onready var animation = $Mesh/EntityHolder/AnimationPlayer
onready var entity_holder = $Mesh/EntityHolder
var vertical_velocity : Vector3 = Vector3()
var movement: Vector3 = Vector3()
var horizontal_velocity : Vector3 = Vector3()
var is_climbing:bool = false
var movement_speed = int()
var angular_acceleration = int()
var acceleration = int()
var random_atk:float



export var spawn_point:Vector3 
export var can_be_looted:bool = false ##loot system in entity_holder = $Mesh/EntityHolder
export var is_made_of= autoload.gathering_type.furless
export var is_randomized:bool = true
export var can_wear_armor:bool = true
export var can_respawn:bool = true

onready var process:Timer = $Process #This is a timer node called "Process"
func _ready()->void:
	spawn_point = translation
	if is_randomized == true:
		if can_wear_armor == true:
			entity_holder.selectRandomEquipment()
	var one_sec:Timer = $"1secTimer"
	
	process.connect("timeout", self, "process") #remember to set this timer to process mode = Physics
	one_sec.connect("timeout", self, "oneSecondTimer")
	#you can put any value in here, tick rate is inverse to FPS, smaller ticks = higher FPS for your enemies
	#like Your_FakeProcess_Timer.start(0.05) means that your enemy will run at 20FPS which is more than enough
	#and remember to put your time into physics mode and not idle mode otherwise it won't save you from lag
	process.start(autoload.entity_tick_rate + rand_range(0, 0.015)) 

func process()->void:
	if health >0:
		autoload.entityGravity(self)
	moveAside()
	matchState()	
	if health >0:
		threat_system.loseThreat()
		if staggered_duration == true:
			state = autoload.state_list.staggered
	if health <0 or health ==0:
		can_be_looted = true
		if has_died == false:
			death_time = 3.958
			if has_died == true:
				state = autoload.state_list.dead
				
				
				
				
				
func respawn()->void:
	health = max_health
	threat_system.resetThreats()
	death_time = 0
	has_died = false
	can_be_looted = false
	state = autoload.state_list.wander
	translation = spawn_point
	damage_effect_manager.resetEffects()
	health = max_health
	health = max_health
	health = max_health
	if is_randomized == true:
		if can_wear_armor == true:
			entity_holder.selectRandomEquipment()
		
			
	
func oneSecondTimer()->void:
	damage_effect_manager.effectDurations()

func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)


	
	
var state = autoload.state_list.wander
var stagger_time:float  = 0
var death_time:float  = 0
var staggered_duration: bool = false
var has_died:bool = false

var atk_1_duration:bool = false
var atk1_spam:int = 0

var atk_2_duration:bool = false
var atk2_spam:int = 0

var atk_3_duration:bool = false
var atk3_spam:int = 0

var atk_4_duration:bool = false
var atk4_spam:int = 0
func matchState()->void:
	match state:
		autoload.state_list.idle:
			animation.play("idle",0.3)
		autoload.state_list.wander:
			if health >0:
				$Wandering.wander()# animations are inside 
				forceDirectionChange()
		autoload.state_list.curious:
			lookTarget(turn_speed)
		autoload.state_list.engage:
			var target = threat_system.findHighestThreat()
			if health >0:#not dead
#_______________________Entity is Stunned, Stop all attacks_______________________________________
				if stunned_duration > 0:# not stunned 
					animationCancel()
					state = autoload.state_list.stunned
					animation.play("staggered",0.2)
#_______________________Entity is staggered, Stop all attacks_______________________________________
				elif staggered_duration == true:
					animationCancel()
					state = autoload.state_list.staggered
					animation.play("staggered",0.2)	
#_______________________Entity is free to move and attack_______________________________________
				else:
					attackAnimations()
					var  distance_to_target = findDistanceTarget()
					if distance_to_target != null:
#________________________Target in range start choosing an attack and lock it in____________________
						if distance_to_target < 1.3:
							var random_value = randf()

							if random_atk < 0.25:  # 25% 
									atk_1_duration = true
									#Entity is stuck in animation, check how many times it attacked to see if it can turn around 
									if atk1_spam > 2:
										lookTarget(turn_speed)
							elif random_atk < 0.50:  # 25% 
									atk_2_duration = true
									#Entity is stuck in animation, check how many times it attacked to see if it can turn around 
									if atk2_spam > 1:
										lookTarget(turn_speed)
							elif random_atk < 0.75:  # 25%
									atk_3_duration = true
									if atk3_spam > 1:
										lookTarget(turn_speed)
							else:  # 25% of the remaining 70% 
									atk_4_duration = true
									#Entity is stuck in animation, check how many times it attacked to see if it can turn around 
									if atk4_spam > 1:
										lookTarget(turn_speed)

#__________________Target too far away, if not stuck in attack animation, follow it_________________
						else:
							if  atk_1_duration == false and atk_2_duration == false and atk_3_duration == false and atk_4_duration == false:
								changeAttackType()
								lookTarget(turn_speed)
								followTarget(false)
								animation.play("walk combat",0.3)
								
		autoload.state_list.orbit:
			if staggered_duration == false:
				if orbit_time > 0:
					orbit_time -= 3 * get_physics_process_delta_time()
					orbitTarget()
					lookTarget(turn_speed)
				else:
					state = autoload.state_list.engage
		autoload.state_list.stunned:
			if stunned_duration > 0:
				animation.play("staggered",0.2)
			else:
				state = autoload.state_list.engage
		autoload.state_list.staggered:
			animation.play("staggered",0.2)
		autoload.state_list.dead:
			if death_time >0:
				death_time -= 1 * get_physics_process_delta_time()
				animation.play("death",0.2)
				if death_time <= 0:
					has_died = true
			else:	
				animation.play("dead",0.6)


func attackAnimations()->void:
	if atk_1_duration == true:
		animation.play("atk1", 0.25)
	elif atk_2_duration == true:
		animation.play("atk2", 0.3)
	elif atk_3_duration == true:
		animation.play("atk3", 0.3)
	elif atk_4_duration == true:
		animation.play("atk4", 0.3)


func animationCancel()->void:
	atk_1_duration = false
	atk_2_duration = false
	atk_3_duration = false
	atk_4_duration = false
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
func moveAside()->void: #move to the side to leave space for other enemies
	if health > 0:
		if state != autoload.state_list.wander:
			if ray_straight.is_colliding():
				var body = ray_straight.get_collider()
				if body != self:
					if body.is_in_group("Enemy"):
						state = autoload.state_list.orbit
						orbit_time = 1.5
					elif body.is_in_group("Player"):
							state = autoload.state_list.engage
var direction: Vector3
onready var tween = $Tween
func slideForward() -> void:
	var  distance_to_target = findDistanceTarget()
	if distance_to_target != null:
		if distance_to_target > 1.4:
			var distance: float = 2.0  # Define a shorter distance of movement
			var speed: float = 2.0  # Define a faster speed
			var target_position: Vector3 = global_transform.origin + (direction.normalized() * distance)  # Calculate the target position

			# Stop any ongoing tweens
			tween.stop_all()

			# Tween the position smoothly with an ease-out effect
			tween.interpolate_property(self, "translation", global_transform.origin, target_position, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
			tween.start()
		else:
			tween.stop_all()
func slideForward2() -> void:
	var  distance_to_target = findDistanceTarget()
	if distance_to_target != null:
		if distance_to_target > 1.4:
			var distance: float = 0.5  # Define a shorter distance of movement
			var speed: float = 1.0  # Define a faster speed
			var target_position: Vector3 = global_transform.origin + (direction.normalized() * distance)  # Calculate the target position

			# Stop any ongoing tweens
			tween.stop_all()

			# Tween the position smoothly with an ease-out effect
			tween.interpolate_property(self, "translation", global_transform.origin, target_position, 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
			tween.start()
		else:
			tween.stop_all()
func stopSlidingForward()-> void:
	tween.stop_all()
onready var eyes = $Eyes
var turn_speed = 9
func lookTarget(turning_speed)->void:
	var target = threat_system.findHighestThreat()
	if target: 
		eyes.look_at(target.player.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turning_speed))
		
		
func lookTargetTween(turning_speed: float) -> void:
	var target = threat_system.findHighestThreat()
	if target:
		var target_position = target.player.global_transform.origin
		var look_at_target_transform = eyes.global_transform.looking_at(target_position, Vector3.UP)
		var target_rotation_y = look_at_target_transform.basis.get_euler().y

		# Stop any existing tweening
		tween.stop_all()

		# Tween the rotation.y to target_rotation_y over a duration based on turning_speed
		tween.interpolate_property(eyes, "rotation:y", eyes.rotation.y, target_rotation_y, turning_speed, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()

		
		
		
var walk_speed: float = 3
func followTarget(angry:bool)->void:
	if angry == false:
		var target =threat_system.findHighestThreat()
		if target:
			direction = (target.player.global_transform.origin - global_transform.origin).normalized()
			direction.y = 0  # Set the Y component to 0 to prevent flying
			move_and_slide(direction * walk_speed)
	else:
		var target =threat_system.findLowestThreat()
		if target:
			direction = (target.player.global_transform.origin - global_transform.origin).normalized()
			direction.y = 0  # Set the Y component to 0 to prevent flying
			move_and_slide(direction * walk_speed)
var orbit_angle = 0.0  # Declare orbit_angle as a member variable
func orbitTarget()->void:
	if health > 0: 
		var  distance_to_target = findDistanceTarget()
		if distance_to_target:
			var target = threat_system.findHighestThreat()
			if target != null:
				var center = target.player.global_transform.origin
				var radius = 4  # Set your desired radius here
				var min_distance_to_start_orbit = 5  # Adjust the minimum distance to start orbiting
				var max_orbit_speed = walk_speed * 0.7  # Adjust the maximum orbit speed (30% of walk_speed)
				var min_orbit_speed = walk_speed * 0.08  # Adjust the minimum orbit speed (10% of walk_speed)
				var orbit_speed = clamp((max_orbit_speed - min_orbit_speed) * (1 - distance_to_target / min_distance_to_start_orbit) + min_orbit_speed, min_orbit_speed, max_orbit_speed)
				if distance_to_target > min_distance_to_start_orbit:
					var direction_to_target = (center - global_transform.origin).normalized()# Move towards the target until the minimum distance is reached
					global_transform.origin += direction_to_target * walk_speed * get_process_delta_time()
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

# Declare class variables
var speed: float = 3.0
var rotation_speed: float = 2.0

onready var take_damage_audio = $TakeHit
onready var take_damage_view  = $"Damage&Effects/Viewport"
func takeThreat(aggro_power,instigator)->void:
	stored_instigator = instigator
	var target = threat_system.createFindThreat(instigator)
	state = autoload.state_list.engage
	target.threat += aggro_power
	
	
func takeStagger(stagger_chance: float) -> void:
	damage_effect_manager.takeStagger(stagger_chance)
	
var parry: bool =  false
var absorbing: bool = false
onready var damage_effect_manager = $"Damage&Effects"
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type)->void:
	stored_instigator = instigator
	damage_effect_manager.takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type)
	damage_effect_manager.getKilled(instigator)

#stats______________________________________________________________________________________________
var entity_name = "Demon"
var level: int = 1

const base_weight = 60
var weight = 60
const base_walk_speed = 6
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
const base_max_health = 60
var max_health = 60
var health = 60
#________________________


#additional combat energy systems
const base_max_resolve = 100
var max_resolve = 100
var resolve = 100



var scale_factor = 1


var critical_chance: float = 0
var critical_strength: float = 2.0
var stagger_chance: float = 8 #0 to 100 in percentage
var life_steal: float = 0
#resistances
var stagger_resistance: float = 0.0 #0 to 100 in percentage, this is directly detracted to instigator.stagger_chance 
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




var base_flank_dmg : float = 5.0
var flank_dmg: float = 5.0 #extra damage to add to backstabs 
var extra_melee_atk_speed : float = 0
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


var stored_instigator:KinematicBody 
var bleeding_duration:float = 0
var stunned_duration:float = 0
var berserk_duration:float = 0 
func effectDurations():
	if bleeding_duration > 0:
		if stored_instigator == null:
			pass
		else:
			var damage: float = autoload.bleed_dmg 
			takeDamage(damage,damage,stored_instigator,0,"bleed")
		applyEffect("bleeding",true)
		bleeding_duration -= 1
	else:
		applyEffect("bleeding",false)
	if stunned_duration > 0:
		state = autoload.state_list.stunned
		applyEffect("stunned",true)
		stunned_duration -= 1
	else:
		state = autoload.state_list.engage
		applyEffect("stunned",false)
	


#___________________________________________________________________________________________________
func showStatusIcon(
	icon1: TextureRect, icon2: TextureRect, icon3: TextureRect, icon4: TextureRect, 
	icon5: TextureRect, icon6: TextureRect, icon7: TextureRect, icon8: TextureRect, 
	icon9: TextureRect, icon10: TextureRect, icon11: TextureRect, icon12: TextureRect, 
	icon13: TextureRect, icon14: TextureRect, icon15: TextureRect, icon16: TextureRect, 
	icon17: TextureRect, icon18: TextureRect, icon19: TextureRect, icon20: TextureRect, 
	icon21: TextureRect, icon22: TextureRect, icon23: TextureRect, icon24: TextureRect
):
	# Reset all icons
	var all_icons = [icon1, icon2, icon3, icon4, icon5, icon6, icon7, icon8, icon9, icon10, icon11, icon12, icon13, icon14, icon15, icon16, icon17, icon18, icon19, icon20, icon21, icon22, icon23, icon24]
	for icon in all_icons:
		icon.texture = null
		icon.modulate = Color(1, 1, 1)
	# Apply status icons based on applied effects
	var applied_effects = [
		{"name": "dehydration", "texture": autoload.dehydration_texture, "modulation_color": Color(1, 0, 0)},
		{"name": "overhydration", "texture": autoload.overhydration_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bloated", "texture": autoload.bloated_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "hungry", "texture": autoload.hungry_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bleeding", "texture": autoload.bleeding_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "frozen", "texture": autoload.frozen_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "stunned", "texture": autoload.stunned_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blinded", "texture": autoload.blinded_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "terrorized", "texture": autoload.terrorized_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "scared", "texture": autoload.scared_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "intimidated", "texture": autoload.intimidated_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "rooted", "texture": autoload.rooted_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockbuffs", "texture": autoload.blockbuffs_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockactive", "texture": autoload.block_active_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "blockpassive", "texture": autoload.block_passive_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "brokendefense", "texture": autoload.broken_defense_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "healreduction", "texture": autoload.heal_reduction_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "bomb", "texture": autoload.bomb_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "slow", "texture": autoload.slow_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "burn", "texture": autoload.burn_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "sleep", "texture": autoload.sleep_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "weakness", "texture": autoload.weakness_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "poisoned", "texture": autoload.poisoned_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "confused", "texture": autoload.confusion_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "impaired", "texture": autoload.impaired_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "lethargy", "texture": autoload.lethargy_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "redpotion", "texture": autoload.red_potion_texture, "modulation_color": Color(1, 1, 1)},
		{"name": "berserk", "texture": autoload.berserk_texture, "modulation_color": Color(1, 1, 1)},
	]

	for effect in applied_effects:
		if effects.has(effect["name"]) and effects[effect["name"]]["applied"]:
			for icon in all_icons:
				if icon.texture == null:
					icon.texture = effect["texture"]
					icon.modulate = effect["modulation_color"]
					break  # Exit loop after applying status to the first available icon

#___________________________________________Status effects__________________________________________
# Define effects and their corresponding stat changes
var effects = {
	"effect2": {"stats": { "extra_vitality": 2,"extra_agility": 0.05,}, "applied": false},
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
	"berserk": {"stats": {"extra_intelligence": -0.5,"extra_balance": -0.5,"extra_agility": 0.5,"extra_melee_atk_speed": 1,"extra_ranged_atk_speed": 0.5,"extra_casting_atk_speed": 0.3,"extra_ferocity": 0.3,"extra_fury": 0.3,}, "applied": false},
	
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




func changeAttackType()->void:
	random_atk = rand_range(0,1)
func die():
	death_time = 0
	has_died = true 
	state = autoload.state_list.dead
func staggeredOver():
	state = autoload.state_list.wander
	staggered_duration = false
#___________________________________________________________________________________________________
func baseMeleeAtk()->void:
	var damage_type:String = "slash"
	var damage = 3 * level 
	var damage_flank = damage + flank_dmg 
	var critical_damage : float  = damage * critical_strength
	var critical_flank_damage : float  = damage_flank * critical_strength
	var punishment_damage : float = 7 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "cold"
	var aggro_power = 0
	var enemies = $Area.get_overlapping_bodies()
	dealDMG(enemies,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank)
func dealDMG(enemy_detector1,critical_damage,aggro_power,damage_type,critical_flank_damage,punishment_damage,punishment_damage_type,damage,damage_flank):
	for victim in enemy_detector1:
		if victim.is_in_group("Player"):
			if victim != self:
				victim.stored_instigator = self 
				var rand = rand_range(0,1)
				if victim.state != autoload.state_list.dead:
						if randf() <= critical_chance:#critical hit
							if victim.absorbing == true: #victim is guarding
								if isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,self,stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guarding, flank damage + punishment damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
							elif victim.parry == true: 
								if isFacingSelf(victim,0.30): #the victim is looking face to face at self
									victim.takeDamage(0,aggro_power,self,0,damage_type)
								else: #apparently the victim is showing his back or flanks while guarding, flank damage + punishment damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
							else:#player is guarding
								if isFacingSelf(victim,0.30): #check if the victim is looking at me 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,self,stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks, extra damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
##______________________________________________________________normal hit_______________________________________________________________________________________________
						else: 
							if victim.absorbing == true:#victim is guarding
								if isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(damage/victim.guard_dmg_absorbition,aggro_power,self,stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(damage_flank + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
							elif victim.parry == true:
								if isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(0,aggro_power,self,0,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(damage_flank + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
							else:
								if isFacingSelf(victim,0.30):#the victim is looking face to face at self 
									victim.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
								else: #appareantly the victim is showing his back or flanks, extra damage
									victim.takeDamage(damage_flank,aggro_power,self,stagger_chance,damage_type)



func atk1Spam()->void:
	atk1_spam += 1
	if atk1_spam == 4:
		atk1_spam = 0
func atk2Spam()->void:
	atk2_spam += 1
	if atk2_spam == 4:
		atk2_spam = 0
func atk3Spam()->void:
	atk3_spam += 1
	if atk3_spam == 4:
		atk3_spam = 0
func atk4Spam()->void:
	atk4_spam += 1
	if atk4_spam == 4:
		atk4_spam = 0
