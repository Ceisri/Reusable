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



	health -= damage_to_take
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
var slash_resistance = 12
var pierce_resistance = 12
var blunt_resistance = 12
var sonic_resistance = 12
var heat_resistance = 12
var cold_resistance = 12
var jolt_resistance = 12
var toxic_resistance = 12
var acid_resistance = 15
var bleed_resistance = 15
var neuro_resistance = 5
var radiant_resistance = 15

var stagger_resistance = 0.5
var deflection_chance = 0

#___________________________________Status effects______________________________
# Define effects and their corresponding stat changes
var effects = {
	"effect0": {"stats": {"agility": -0.05, "strength": 0.1}, "applied": false},
	"effect1": {"stats": {"energy": -500000000, "mana": 10}, "applied": false},
	"effect2": {"stats": {"health": -5, "mana": 10, "intelligence": 2,"agility": 0.05,}, "applied": false},
	"overhydration": {"stats": {"max_health": -5,  "intelligence": -0.02,"agility": -0.05,}, "applied": false},
	"dehydration": {"stats": {"max_health": -25, "intelligence": -0.25,"agility": -0.25,}, "applied": false},
	"bloated": {"stats": {"max_health": -5,"intelligence": -0.02,"agility": -0.15,}, "applied": false},
	"hungry": {"stats": {"max_health": -5,"intelligence": -0.22,"agility": -0.05,}, "applied": false},
	"bleeding": {"stats": {}, "applied": false},
	"stunned": {"stats": {}, "applied": false},
	"frozen": {"stats": {}, "applied": false},
	"blinded": {"stats": {}, "applied": false},
	"terrorized": {"stats": {}, "applied": false},
	"scared": {"stats": {}, "applied": false},
	"intimidated": {"stats": {}, "applied": false},
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
