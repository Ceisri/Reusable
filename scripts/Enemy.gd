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

var is_player:bool = false 

export var spawn_point:Vector3 
export var can_be_looted:bool = false ##loot system in entity_holder = $Mesh/EntityHolder
var is_made_of= autoload.gathering_type.furless
export var is_randomized:bool = false
export var can_wear_armor:bool = true
export var can_respawn:bool = true

onready var process:Timer = $Process #This is a timer node called "Process"
func _ready()->void:
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
	stutterPrevention()
	
	
func stutterPrevention()->void:#This prevents lag happening when first hitting an enemy,
	#It probably happens because the prealoed scene is harder to instance the first time 
	var text = autoload.floatingtext_damage.instance()
	text.status = "STUTTER PREVENTION"
	add_child(text)
	damage_effect_manager.stutterNow(99999999999, "heat")
	threat_system.resetThreats()
	health = max_health
	
	
	
var dropped_loot:bool = false
func process()->void:
	if health >0:
		autoload.entityGravity(self)
	behaviourTree()
	if health >0:
		threat_system.loseThreat()
	if health <0 or health ==0:
		can_be_looted = true


				
func respawn()->void:
	health = max_health
	threat_system.resetThreats()
	can_be_looted = false
	state = autoload.state_list.wander
	translation =  Vector3(0,5, 0)
	damage_effect_manager.resetEffects()
	health = max_health
	health = max_health
	health = max_health
	death_duration = false
	damage_effect_manager.has_got_killed_already = false
	if is_randomized == true:
		if can_wear_armor == true:
			entity_holder.selectRandomEquipment()
		
			
	
func oneSecondTimer()->void:
	damage_effect_manager.regenerate()
	attackSpeedMath()
	var state_enum = autoload.state_list  # Access the enum from the singleton
	var state_value = state  # Get the current state value
	var state_name = state_enum.keys()[state_value]  # Convert enum to string
	$Label3D.text = state_name
	if staggered_duration == true:
		staggered_duration = false
	damage_effect_manager.effectDurations()


func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)



var state = autoload.state_list.wander
var death_duration:bool = false


var staggered_duration: bool = false
var knockeddown_duration:bool = false
var knockeddown_first_part:bool = false

func behaviourTree()->void:
	var target = threat_system.findHighestThreat()
	
	if health <0:
		if death_duration == true:
			animation.play("death",0.6)
		else:
			animation.play("dead",0.6)

	elif stunned_duration > 0:
		animationCancel()
		animation.play("stunned",0.2)

	elif knockeddown_duration == true:
		animReset()
		animationCancel()
		if health > 1:
			animation.play("knocked down",0.3)
			if knockeddown_first_part == false:
				lookTarget(5)
				
	elif staggered_duration == true:
		animationCancel()
		animation.play("staggered",0.2)
		
	else:
		matchState()
		
func matchState()->void:
		match state:
			autoload.state_list.idle:
				animation.play("idle",0.3)
			autoload.state_list.wander:
				$Wandering.wander()# animations are inside 
				forceDirectionChange()
			autoload.state_list.curious:
				lookTarget(turn_speed)
			autoload.state_list.engage:
				combat()
			autoload.state_list.orbit:
				if staggered_duration == false:
					if orbit_time > 0:
						orbit_time -= 3 * get_physics_process_delta_time()
						orbitTarget()
						lookTarget(turn_speed)
					else:
						state = autoload.state_list.engage








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
	var speed = 2.0
	
	var direction_to_target = -global_transform.basis.x  # Move sideways to the left
	
	var movement = direction_to_target * distance * speed * get_process_delta_time()
	
	move_and_slide(movement)





var direction: Vector3
onready var tween = $Tween

func slideForward() -> void:
	if stored_instigator != null:
		var  distance_to_target = findDistanceTarget()
		if distance_to_target > 1.4:
			var distance: float = 2.0
			var speed: float = 2.0
			var direction: Vector3 = (stored_instigator.global_transform.origin - global_transform.origin).normalized()
			var target_position: Vector3 = global_transform.origin + (direction * distance)

			tween.stop_all()
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
	damage_effect_manager.takeDamage(damage, aggro_power, instigator, damage_type)
	damage_effect_manager.getKilled(instigator)

	if health >0: 
		lookTarget(turn_speed)
		lookTarget(turn_speed)
		lookTarget(turn_speed)
		lookTarget(turn_speed)

func getKnockedDown(instigator)-> void:#call this for skills that have a different knock down chance
	var text = autoload.floatingtext_damage.instance()
	damage_effect_manager.getKnockedDown(instigator)
	text.status = "Knocked Down!"
	add_child(text)
	animReset()
	
func animReset():
	atk1_duration = false
	atk2_duration = false
	atk3_duration = false
	atk4_duration = false
	staggered_duration = false

#stats______________________________________________________________________________________________
export var entity_name = "Goblin"
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
const base_max_health = 160
var max_health = 160
var health = 160
#________________________




#additional combat energy systems
const base_max_resolve = 100
var max_resolve = 100
var resolve = 100



var critical_chance: float = 33
var critical_dmg: float = 2.05
var knockdown_chance: float = 6
var stagger_chance: float = 13 #0 to 100 in percentage


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
var celerity: float = 2
var flexibility: float = 1
var deflection: float = 1

var endurance: float = 1
var stamina: float = 1
var vitality: float = 1
var resistance: float = 1
var tenacity: float = 1


var charisma: float = 1
var loyalty: float = 1 
var diplomacy: float = 1
var authority: float = 1
var courage: float = 1 
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
var guard_dmg_absorbition: float = 2.5


var base_flank_dmg : float = 5.0
var flank_dmg: float = 5.0 #extra damage to add to backstabs 

const base_melee_atk_speed: int = 1 
var melee_atk_speed: float = 1 
const base_range_atk_speed: int = 1 
var range_atk_speed: float = 1 
const base_cast_speed: int  = 1 
var cast_speed: float = 1 


var extra_melee_atk_speed : float = 0
var extra_range_atk_speed : float = 0
var extra_cast_atk_speed : float = 0


func attackSpeedMath()->void:
	print(melee_atk_speed)
	var bonus_universal_speed = (total_celerity -1) * 0.15
	
	total_dexterity = extra_dexterity + dexterity
	melee_atk_speed = base_melee_atk_speed + (total_dexterity -1) + extra_melee_atk_speed
	
	var atk_speed_formula_range = (total_strength -1) * 0.5
	range_atk_speed = base_range_atk_speed + atk_speed_formula_range + bonus_universal_speed+ extra_range_atk_speed
	
	var atk_speed_formula_cast = (total_instinct -1) * 0.35 + ((total_memory-1) * 0.05) + bonus_universal_speed
	cast_speed = base_cast_speed + atk_speed_formula_cast	+ extra_cast_atk_speed

	

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
	"berserk": {"stats": {"extra_intelligence": -0.5,"extra_balance": -0.5,"extra_agility": 0.5,"extra_melee_atk_speed": 1,"extra_range_atk_speed": 0.5,"extra_cast_atk_speed": 0.3,"extra_ferocity": 0.3,"extra_fury": 0.3,}, "applied": false},
	
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




func staggeredOver():
	state = autoload.state_list.wander
	staggered_duration = false
	
	
var atk1_duration:bool = false
var atk1_spam:int = 0

var atk2_duration:bool = false
var atk2_spam:int = 0

var atk3_duration:bool = false
var atk3_spam:int = 0

var atk4_duration:bool = false
var atk4_spam:int = 0


var atk5_duration:bool = false
var atk5_spam:int = 0

func combat()->void:
	if staggered_duration == false:
		var  distance_to_target = findDistanceTarget()
		attackAnimations()
		if distance_to_target != null:
			if distance_to_target <= 2:
				randomizeAttacks()
				print("This unit is attacking" + str(distance_to_target))
			else:
				if aefis == max_aefis:
					print(random_atk)
					if random_atk > 0.8:
						animation.play("ultimate",0.1)
						animationCancel()
					else:
						chase()
					
				else:
					chase()


func chase()->void:
	if atk1_duration == false and atk2_duration == false and atk3_duration == false and atk4_duration == false and atk5_duration == false:
		lookTarget(turn_speed)
		followTarget(false)
		animation.play("walk combat",0.1)
func attackAnimations()->void:
	if atk1_duration == true:
		animation.play("atk1", 0.25,melee_atk_speed)
	elif atk2_duration == true:
		animation.play("atk2", 0.3,melee_atk_speed)
	elif atk3_duration == true:
		animation.play("atk3", 0.3,melee_atk_speed)
	elif atk4_duration == true:
		animation.play("atk4", 0.3,melee_atk_speed)
	elif atk5_duration == true:
		animation.play("atk5", 0.3,melee_atk_speed)

func animationCancel()->void:
	atk1_duration = false
	atk2_duration = false
	atk3_duration = false
	atk4_duration = false
	atk5_duration = false
	
func changeAttackType()->void:
	random_atk = rand_range(0,1)
	if atk1_duration  == true:
		 atk1_duration = false
	if atk2_duration == true:
		 atk2_duration = false
	if atk3_duration == true:
		 atk3_duration = false
	if atk4_duration == true:
		 atk4_duration = false
	if atk5_duration == true:
		 atk5_duration = false

var atk2_cost: float = 60

var can_switch_atk:bool = true
func randomizeAttacks() -> void:
	if random_atk < 0.2:  # 20%
		atk1_duration = true
	elif random_atk < 0.4:  # 20%
		if resolve > atk2_cost:
			atk2_duration = true
		else:
			if random_atk <0.5:
				atk3_duration = true
			else:
				atk5_duration = true
	elif random_atk < 0.6:  # 20%
		atk3_duration = true
	elif random_atk < 0.8:  # 20%
		atk4_duration = true
	else:  # 20%
		atk5_duration = true



func die()->void:
	death_duration = false
func getUp()->void:
	knockeddown_duration = false
	state = autoload.state_list.wander
func startGettingUp()->void:
	knockeddown_first_part = false




func consumeResolve(value)->void:
	resolve -= value
	


func goBeserk()->void:
	aefis -= 100
	berserk_duration += 20
	if health < max_health:
		health += 15

#________________________________________ATTACKS GO HERE____________________________________________
func baseMeleeAtk()->void:
	var damage_type:String = "slash"
	var damage = 5 * level 
	var aggro_power = 0
	var enemies = $Area.get_overlapping_bodies()
	for victim in enemies:
		dealDMG(victim,aggro_power,damage_type,damage)
		
func strongMeleeAtk()->void:
	var damage_type:String = "slash"
	var damage = 12 * level 
	var aggro_power = 0
	var enemies = $Area.get_overlapping_bodies()
	for victim in enemies:
		dealDMG(victim,aggro_power,damage_type,damage)
func knockdownMeleeAtk()->void:
	var damage_type:String = "slash"
	var damage = 12 * level 
	var aggro_power = 0
	var enemies = $Area2.get_overlapping_bodies()
	for victim in enemies:
		if victim != self:
			if victim.is_in_group("Entity"):
				if victim.is_in_group("Player"):
					if victim.parry == false:
						if victim.absorbing == false:
							victim.getKnockedDown(self)
						else:
							if victim.resolve > 0:
								victim.resolve -= damage
		dealDMG(victim,aggro_power,damage_type,damage)
func dealDMG(victim,aggro_power,damage_type,damage)-> void:
		var random = rand_range(0,1)
		if victim  != self:
			if victim.is_in_group("Entity"):
				if victim.is_in_group("Player"):
					if victim.has_method("takeDamage"):
						victim.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
						resolve += 10
						if resolve > max_resolve:
							resolve = max_resolve



