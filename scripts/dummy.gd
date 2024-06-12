extends KinematicBody

onready var threat_system: Node = $Threat
onready var animation =  $Mesh/human/AnimationPlayer

func _ready()->void:
	var process = $Process
	process.connect("timeout", self, "process") #remember to set this timer to process mode = Physics
	process.start(autoload.entity_tick_rate)

func process()->void:
	if health < -10:
		health += 100
	threat_system.loseThreat()


func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)


	
var staggered_duration: bool = false
var state = autoload.state_list.wander
var stagger_time:float  = 0
var death_time:float  = 0
var has_died:bool = false
func matchState()->void:
	match state:
		autoload.state_list.idle:
			animation.play("idle",0.3)
			animation.play("triple slash", 0.25)
		autoload.state_list.wander:
			animation.play("triple slash", 0.25)
			pass
		autoload.state_list.curious:
			animation.play("triple slash", 0.25)
			pass
		autoload.state_list.engage:
			pass
		autoload.state_list.orbit:
			pass
		autoload.state_list.staggered:
			animation.play("staggered",0.2)
		autoload.state_list.dead:
			pass



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





#________________This Section is dedicated to moving towards random directions______________________

# Declare class variables
var speed: float = 3.0
var rotation_speed: float = 2.0

var target_point: Vector3



var staggered = 0 
onready var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_audio = $TakeHit
onready var take_damage_view  = $TakeDamageView/Viewport
func takeThreat(aggro_power,instigator)->void:
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
var slash_resistance: int = 50 #50 equals 33.333% damage reduction 100 equals 50% damage reduction, 200 equals 66.666% damage reduction
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


func staggeredOver():
	state = autoload.state_list.wander




