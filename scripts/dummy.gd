extends KinematicBody


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

var max_distance = 30.1

func _physics_process(delta):
	var aggro_info = gatherAggroInformation()
	var target = findTargetWithHighestAggro()
	updateStats()


func _on_AggroTimer_timeout():
	for playerAggro in targets:
		var distance = eyes.global_transform.origin.distance_to(playerAggro.player.global_transform.origin)
		var aggro_change = calculateAggroChange(distance, playerAggro.aggro)

		if distance <= aggro_gain_radius:
			playerAggro.aggro += aggro_change
		else:
			playerAggro.aggro = max(0, playerAggro.aggro - 5)
func gatherAggroInformation() -> Array:
	var aggro_info = []  # Array to store player aggro information
	for player in players:
		var distance = eyes.global_transform.origin.distance_to(player.global_transform.origin)
		var playerAggro = getOrCreatePlayerAggro(player)
		# Aggro change logic moved to _on_AggroTimer_timeout
		aggro_info.append("ID: " + str(player.get_instance_id()) + " Aggro: " + str(playerAggro.aggro))
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
	take_damage_audio.play()
	var random = randf()
	var damage_to_take = damage
	var instigatorAggro = getOrCreatePlayerAggro(instigator)
	var text = floatingtext_damage.instance()
	if damage_type == "slash":
		var mitigation = slash_resistance / (slash_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		instigator.lifesteal(damage_to_take)
	elif damage_type == "pierce":
		var mitigation = pierce_resistance / (pierce_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
		instigator.lifesteal(damage_to_take)
	elif damage_type == "blunt":
		var mitigation = blunt_resistance / (blunt_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "sonic":
		var mitigation = sonic_resistance / (sonic_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
	elif damage_type == "heat":
		var mitigation = heat_resistance / (heat_resistance + 100.0)
		damage_to_take *= (1.0 - mitigation)
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

	health -= damage_to_take	
	instigatorAggro.aggro += damage_to_take + aggro_power
	text.amount =round(damage_to_take * 100)/ 100
	text.state = damage_type
	take_damage_view.add_child(text)
	if health < 0:
		health += 500

var staggered = 0 #1 equals 0.1seconds
func _on_Duration_timeout():
	if staggered >=0:
		staggered = max(0, staggered - 0.1)
func getKilled(instigator):
	var instigatorAggro = getOrCreatePlayerAggro(instigator)
	instigator.receiveExperience(150)

func roundToTwoDecimals(number):
	return round(number * 100.0) / 100.0



var blend = 0.3

var gravity_force = Vector3(0, -9.8, 0)
onready var health_bar = $Viewport/HPbar
func updateStats():
	health_bar.value = health
	health_bar.max_value = max_health
	
#stats______________________________________________________________________________________________
var entity_name = "Demon"
var level = 1
var health = 500
const base_health = 500
var max_health = 500
const base_max_health = 500
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
