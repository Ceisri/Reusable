extends KinematicBody

onready var eyes: Spatial = $Eyes
var summoner: KinematicBody
var state: String
var turn_speed: float = 8
var maximum_enemy_range: float = 20
var summoner_distance_limit : float = 5
var enemy_distance_limit : float = 1
var command: String 
var speed: float = 4
var closestEnemy: KinematicBody = null


func _ready() -> void:
	add_to_group("Servant")
	add_to_group("Entity")
	


func _physics_process(delta: float) -> void:
	updateClosestEnemy()
	rotateTowardsSummoner(delta)
	listen(delta)
	die()

func listen(delta: float) -> void:
	match command:
		"follow":
			moveTowardsSummoner(delta)
		"attack":
			moveTowardsEnemy(delta)
			
func moveTowardsSummoner(delta: float) -> void:
	var direction = (summoner.global_transform.origin - global_transform.origin).normalized()
	var distance_to_summoner = global_transform.origin.distance_to(summoner.global_transform.origin)
	
	if distance_to_summoner > summoner_distance_limit:
		move_and_slide(direction * speed)
		rotateTowards(summoner)
		updateClosestEnemy()

func moveTowardsEnemy(delta: float) -> void:
	if not closestEnemy:
		return

	var direction = (closestEnemy.global_transform.origin - global_transform.origin).normalized()
	var distance_to_enemy = global_transform.origin.distance_to(closestEnemy.global_transform.origin)
	
	if distance_to_enemy > enemy_distance_limit:
		move_and_slide(direction * speed)
		eyes.look_at(closestEnemy.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turn_speed))

func rotateTowardsSummoner(delta: float) -> void:
	if not checkEnemies(): # check if there are enemies in the area
		rotateTowards(summoner)
	else:
		if command != "follow":
			# rotate to look towards enemies
			rotateTowardsEnemies()

func updateClosestEnemy() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	closestEnemy = null
	var minDistance = maximum_enemy_range
	for enemy in enemies:
		var distance = enemy.global_transform.origin.distance_to(global_transform.origin)
		if distance < minDistance:
			minDistance = distance
			closestEnemy = enemy

func checkEnemies() -> bool:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		var distance = enemy.global_transform.origin.distance_to(global_transform.origin)
		if distance <= maximum_enemy_range:
			return true
	return false

func rotateTowardsEnemies() -> void:
	if closestEnemy:
		rotateTowards(closestEnemy)

func rotateTowards(node: Node) -> void:
	eyes.look_at(node.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad(eyes.rotation.y * turn_speed))







func die():
	if health <=0:
		queue_free()


#Stats__________________________________________________________________________
var level = 100


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
var toxic_resistance: int = 750
var acid_resistance: int = 25
var bleed_resistance: int = 0
var neuro_resistance: int = 0
var radiant_resistance: int = 0
var deflection_chance : float = 0.33
var stagger_resistance: float = 0.5
var staggered = 0 
var  guard_dmg_absorbition: float = 2

var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_view  = $TakeDamageView/Viewport
func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type):
	toxic_resistance += 10
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
	if state == "guard":
		health -= (damage_to_take / guard_dmg_absorbition)
		text.amount = ((damage_to_take / guard_dmg_absorbition) * 100)/ 100
		text.status = "Guarded"
		text.state = damage_type
	else:
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
	
func scaleUP():
	if scale_factor <= 2.2:
		max_health = base_max_health * scale_factor
		scale_factor += 0.1
		scale = Vector3(scale_factor,scale_factor,scale_factor)
