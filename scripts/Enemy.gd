extends KinematicBody

onready var threat_system: Node = $Threat
onready var animation =  $Mesh/human/AnimationPlayer
onready var anim_tree = $AnimationTree
var vertical_velocity : Vector3 = Vector3()
var movement: Vector3 = Vector3()
var horizontal_velocity : Vector3 = Vector3()
var is_climbing:bool = false
var movement_speed = int()
var angular_acceleration = int()
var acceleration = int()
var random_atk:float


func _ready()->void:
	var process:Timer = $Process #This is a timer node called "Process"
	process.connect("timeout", self, "process") #remember to set this timer to process mode = Physics
	#you can put any value in here, tick rate is inverse to FPS, smaller ticks = higher FPS for your enemies
	#like Your_FakeProcess_Timer.start(0.05) means that your enemy will run at 20FPS which is more than enough
	#and remember to put your time into physics mode and not idle mode otherwise it won't save you from lag
	process.start(autoload.entity_tick_rate + rand_range(-0.03, 0.03)) 

func process()->void:
	#if you need to use detal then this function "get_physics_process_delta_time()" works the same 
	#you can multiply things by this function like speed *get_physics_process_delta_time() 
	#your_functions_here()
	
	
	if health <=0:
		if has_died == false:
			death_time = 3.958
	moveAside()
	matchState()
	autoload.entityGravity(self)
	autoload.movement(self)
	threat_system.loseThreat()


func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)


	
	
var state = autoload.state_list.wander
var stagger_time:float  = 0
var death_time:float  = 0
var has_died:bool = false
func matchState()->void:
	match state:
		autoload.state_list.idle:
			animation.play("idle",0.3)
		autoload.state_list.wander:
			if health >0:
				$Wandering.wander()# animations are inside 
				forceDirectionChange()
		autoload.state_list.curious:
			lookTarget()
		autoload.state_list.engage:
			if health >0:
				lookTarget()
				var  distance_to_target = findDistanceTarget()
				if distance_to_target != null:
					if distance_to_target > 1.4:
						followTarget(false)
						animation.play("walk combat",0.3)
					else:
						if random_atk < 0.25:  # 25% chance
							animation.play("triple slash", 0.25)
						elif random_atk < 0.50:  # 25% chance
							animation.play("chop sword", 0.3)
						elif random_atk < 0.75:  # 25% chance
							animation.play("heavy swing", 0.3)
						else:  # 25% chance
							animation.play("spin", 0.3)
		autoload.state_list.orbit:
			if orbit_time > 0:
				orbit_time -= 3 * get_physics_process_delta_time()
				orbitTarget()
				lookTarget()
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

onready var wall_check_ray:RayCast = $RayStraightLonger
onready var check_floor_ray: RayCast = $RayCheckFloor
onready var tween = $Tween
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
					
onready var eyes = $Eyes
var turn_speed = 9
func lookTarget()->void:
	var target = threat_system.findHighestThreat()
	if target: 
		eyes.look_at(target.player.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turn_speed))
var direction: Vector3
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

var target_point: Vector3






var staggered = 0 
onready var take_damage_audio = $TakeHit
onready var take_damage_view  = $TakeDamageView/Viewport
func takeThreat(aggro_power,instigator)->void:
	var target = threat_system.createFindThreat(instigator)
	state = autoload.state_list.engage
	target.threat += aggro_power
var parry: bool =  false
var absorbing: bool = false
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type)->void:
	var text = autoload.floatingtext_damage.instance()
	if parry == false:
		take_damage_audio.play()
		var random = randf()
		var damage_to_take = damage
		var instigatorAggro = threat_system.createFindThreat(instigator)
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
		else:
			if random < stagger_chance - stagger_resistance:
				state = autoload.state_list.staggered
				text.status = "Staggered"

		health -= damage_to_take	
		instigatorAggro.threat += damage_to_take + aggro_power
		text.amount =round(damage_to_take * 100)/ 100
		text.state = damage_type
		take_damage_view.add_child(text)
		if health <= 0:
			state =autoload.state_list.dead
	else:
		text.status = "Parried"
		text.state = damage_type
		take_damage_view.add_child(text)
		
#stats______________________________________________________________________________________________
var entity_name = "Demon"
var level: int = 100


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
var critical_chance: float = 0
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


var guard_dmg_absorbition: float = 2 #total damage taken will be divided by this when guarding


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



func changeAttackType()->void:
	random_atk = rand_range(0,1)
func die():
	death_time = 0
	has_died = true 
	state = autoload.state_list.dead
func staggeredOver():
	state = autoload.state_list.wander





func baseMeleeAtk()->void:
	var damage_type:String = "slash"
	var damage = 10 + slash_dmg
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
#				if victim.state != autoload.state_list.dead:
##					pushEnemyAway(0.3, victim,0.25)

						if randf() <= critical_chance:#critical hit
							if victim.absorbing == true or victim.parry == true: #victim is guarding
								if isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,self,stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guarding, flank damage + punishment damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
							else:#player is guarding
								if isFacingSelf(victim,0.30): #check if the victim is looking at me 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,self,stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks, extra damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
##______________________________________________________________normal hit_______________________________________________________________________________________________
						else: 
							if victim.absorbing == true or victim.parry == true: #victim is guarding
								if isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(damage/victim.guard_dmg_absorbition,aggro_power,self,stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(damage_flank + punishment_damage,aggro_power,self,stagger_chance,punishment_damage_type)
							#victim is not guarding
							else:
								if isFacingSelf(victim,0.30):#the victim is looking face to face at self 
									victim.takeDamage(damage,aggro_power,self,stagger_chance,damage_type)
								else: #appareantly the victim is showing his back or flanks, extra damage
									victim.takeDamage(damage_flank,aggro_power,self,stagger_chance,damage_type)
