extends Node
onready var parent = get_parent()
export var speed = 3

func  _ready() -> void:
	level = Autoload.rng.randi_range(1,1000)
	slash_resistance = rand_range(-10, 300)
	heat_resistance = rand_range(-10, 300)
	convertStats()

#func _physics_process(delta: float) -> void:#only here for testing
#	if parent.is_in_group("Player"):
#		addFloatingText(33,Autoload.damage_type.cold,true)


func getHit(attacker: Node, damage: float, damage_type: int, extra_penetrate_chance: float,extra_threat) -> void:
	var damage_to_take: float = damage
	var mitigation: float = 0.0  # Initialize mitigation to 0.0
	var deflected:bool = false
	var penetrating_blow: bool = false
	var flank_attack: bool = false
	var backstab: bool = false
	var backstab_mitigation:float = back_defense / (back_defense + 100.0)
	var flank_mitigation:float = flank_defense / (flank_defense + 100.0)
	var front_mitigation:float = front_defense / (front_defense + 100.0)
	var damage_after_backstab:float = 0.0
	var damage_after_flank:float = 0.0
	var damage_after_front:float = 0.0
	var attacker_threat
	parent.stored_attacker = attacker
	if parent.has_node("Threat"):
			attacker_threat = parent.get_node("Threat").createFindThreat(attacker)
	else:
		print("enemy doesn't have threat node, fix that")

	if not parent.is_in_group("Boss"):
		if parent.has_method("lookTarget"):
			if parent.stats.health >0:
				parent.lookTarget(parent.turn_speed * 0.5)	


	var final_damage:float = 0.0
	match damage_type:
		Autoload.damage_type.slash:
			mitigation = slash_resistance / (slash_resistance + 100.0)
		Autoload.damage_type.pierce:
			mitigation = pierce_resistance / (pierce_resistance + 100.0)
		Autoload.damage_type.blunt:
			mitigation = blunt_resistance / (blunt_resistance + 100.0)
		Autoload.damage_type.sonic:
			mitigation = sonic_resistance / (sonic_resistance + 100.0)
		Autoload.damage_type.heat:
			mitigation = heat_resistance / (heat_resistance + 100.0)
		Autoload.damage_type.cold:
			mitigation = cold_resistance / (cold_resistance + 100.0)
		Autoload.damage_type.jolt:
			mitigation = jolt_resistance / (jolt_resistance + 100.0)
		Autoload.damage_type.toxic:
			mitigation = toxic_resistance / (toxic_resistance + 100.0)
		Autoload.damage_type.acid:
			mitigation = acid_resistance / (acid_resistance + 100.0)
		Autoload.damage_type.bleed:
			mitigation = bleed_resistance / (bleed_resistance + 100.0)
		Autoload.damage_type.arcane:
			mitigation = arcane_resistance / (arcane_resistance + 100.0)
		Autoload.damage_type.radiant:
			mitigation = radiant_resistance / (radiant_resistance + 100.0)
	
	# Check if attacker is flanking
	if attacker.has_method("isFacingSelf"):
		if attacker.isFacingSelf(parent, 0.5):
			backstab = true
		if attacker.isFacingSelf(parent, 0):  # Flank attack
			flank_attack = true
			
	if attacker.is_in_group("Player"):
		attacker.stored_victim = parent
		attacker.time_to_show_stored_victim = 10
		attacker.popUIHit(attacker.entity_health_label)
		
		
	parent.stored_attacker = attacker
	var random_range: float = rand_range(0, 100)
	
	if random_range <= deflect_chance:  # Deflected hit
		var damage_after_deflection = damage_to_take * deflection_strength
		deflected = true
		damage_to_take *= (1.0 - mitigation)
		if backstab:
			damage_after_backstab = (damage_after_deflection * (1.0 - backstab_mitigation))* attacker.stats.backstab_strength
			final_damage = damage_after_backstab 
		elif flank_attack:
			damage_after_flank = (damage_after_deflection * (1.0 - flank_mitigation)) * attacker.stats.flank_strength
			final_damage = damage_after_flank 
		else:
			damage_after_front = damage_to_take * (1.0 - front_mitigation)
			final_damage = damage_after_front 

	else:
		if random_range <= extra_penetrate_chance + attacker.stats.penetration_chance:  # Penetrating hit
			penetrating_blow = true
			damage_to_take *= (1.0 - mitigation / attacker.stats.penetration_strength)
			if backstab:
				damage_after_backstab = (damage_to_take * (1.0 - backstab_mitigation))* attacker.stats.backstab_strength
				final_damage = damage_after_backstab 
			elif flank_attack:
				damage_after_flank = (damage_to_take * (1.0 - flank_mitigation)) * attacker.stats.flank_strength
				final_damage = damage_after_flank 
			else:
				damage_after_front = damage_to_take * (1.0 - front_mitigation)
				final_damage = damage_after_front 

		else:  # Normal hit
			damage_to_take *= (1.0 - mitigation)
			if backstab:
				damage_after_backstab = (damage_to_take * (1.0 - backstab_mitigation))* attacker.stats.backstab_strength
				final_damage = damage_after_backstab 
			elif flank_attack:
				damage_after_flank = (damage_to_take * (1.0 - flank_mitigation)) * attacker.stats.flank_strength
				final_damage = damage_after_flank 
			else:
				damage_after_front = damage_to_take * (1.0 - front_mitigation)
				final_damage = damage_after_front 
	
	if attacker.is_in_group("Player"):
		debugHit(attacker, damage,final_damage, damage_type,deflected, penetrating_blow,flank_attack,backstab)
	addFloatingText(attacker,final_damage, damage_type, penetrating_blow)
	health -= round(final_damage* 100) / 100
	if health <=0:
		if parent.is_in_group("BodyPart"):
			pass
		else:
			if parent.dead == false:
				parent.dying = true
	if parent.has_node("Threat"):
		attacker_threat.threat += damage_to_take + extra_threat
		
		
		
func convertStats():
	deflect_chance = base_deflect_chance + extr_deflect_chance 
	penetration_chance = base_penetration_chance + extr_deflect_chance 

	flank_strength = base_flank_strength + extr_flank_strength
	backstab_strength = base_backstab_strength + extr_backstab_strength
	
	front_defense = base_front_defense + extr_front_defense
	flank_defense = base_flank_defense + extr_flank_defense
	back_defense = base_back_defense + extr_back_defense
	
export var level = 1
#resistances
export var stagger_resistance: float = 0.0 #0 to 100 in percentage, this is directly detracted to instigator.stagger_chance 
export var slash_resistance: int = 15 #50 equals 33.333% damage reduction 100 equals 50% damage reduction, 200 equals 66.666% damage reduction
export var pierce_resistance: int = 0
export var blunt_resistance: int = 15
export var sonic_resistance: int = 0
export var heat_resistance: int = 0
export var cold_resistance: int = 0
export var jolt_resistance: int = 0
export var toxic_resistance: int = 0
export var acid_resistance: int = 0
export var arcane_resistance: int = 0
export var bleed_resistance: int = 0
export var radiant_resistance: int = 0

export var health:float = 1600
export var max_health:float = 1600

const base_max_resolve = 100
var max_resolve = 100
var resolve = 100
const base_max_breath = 100
var max_breath = 100
var breath = 100

#Chance to take less damage and avoid critical hits or penetrating hits
export var base_deflect_chance:float = 25
export var extr_deflect_chance:float = 0.0
export var deflect_chance:float = 0.0
export var deflection_strength:float = 0.3
#Chance to ignore damage mitigation
export var base_penetration_chance:float = 25
export var extr_penetration_chance:float = 0.0
export var penetration_chance:float = 0.0
export var penetration_strength:float = 2 #divide the mitigation body who takes damage by this value 

export var base_backstab_strength:float = 2
export var extr_backstab_strength:float =0
export var backstab_strength:float =0 

export var base_flank_strength:float = 1.5
export var extr_flank_strength:float = 0
export var flank_strength:float = 0

export var base_front_defense:float = 0
export var extr_front_defense:float = 0
export var front_defense:float = 0

export var base_back_defense:float = 0
export var extr_back_defense:float = 0
export var back_defense:float = 0

export var base_flank_defense:float = 0
export var extr_flank_defense:float = 0
export var flank_defense:float = 0



#attributes 
export var sanity: float  = 1
export var wisdom: float = 1
export var memory: float = 1
export var intelligence: float = 1
export var instinct: float = 1

export var force: float = 1
export var strength: float = 1
export var impact: float = 1
export var ferocity: float  = 1 
export var fury: float = 1 

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


var charisma: float = 1
var loyalty: float = 1 
var diplomacy: float = 1
var authority: float = 1
var courage: float = 1 



var on_hit_resolve_regen:float = 1
var extra_on_hit_resolve_regen:float = 0
var total_on_hit_resolve_regen:float = 1

const base_melee_atk_speed: int = 1 
var melee_atk_speed: float = 1 
const base_range_atk_speed: int = 1 
var range_atk_speed: float = 1 
const base_casting_speed: int  = 1 
var casting_speed: float = 1 


var extra_melee_atk_speed : float = 0
var extra_range_atk_speed : float = 0
var extra_cast_atk_speed : float = 0



func addFloatingText(attacker:Node,damage:float, damage_type:int,penetrating:bool)->void:
		var floating_text = Autoload.floating_text.instance()
		floating_text.damage_type = damage_type
		floating_text.amount = round(damage * 100) / 100
		if penetrating == true :
			floating_text.penetrating_hit = true
		if not parent.is_in_group("Player"):
			if attacker.is_in_group("Entity"):
				attacker.canvas.add_child(floating_text)
		else:
			if parent.popup_viewport:
				floating_text.player = parent
				parent.popup_viewport.add_child(floating_text)

# Use this function to debug combat in-game without having to look at the print outputs of the engine.
# It also helps with playtesting across multiple platforms or with multiplayer.
func debugHit(attacker: KinematicBody, damage: float, damage_post_mitigation: float, damage_type: int, deflected: bool, penetrate: bool,flank_attack:bool,backstab:bool)->void:
	attacker.debug.time_passed_since_last_hit = 0 
	var damage_type_enum = Autoload.damage_type
	var damage_type_value = damage_type
	var damage_type_name = damage_type_enum.keys()[damage_type_value]
	if attacker.debug != null:
		var successful_hit: String = " got hit"
		var parent_id = str(parent.get_instance_id())# Get the parent's ID
		attacker.debug.flanked = flank_attack
		attacker.debug.backstab = backstab
		attacker.debug.error_message = parent.entity_name + " " + parent_id + " " + successful_hit + "\npremitigation dmg: " + str(damage)
		if deflected:
			attacker.debug.damage_post_mitigation = str(round(damage_post_mitigation * 100) / 100) + " " + damage_type_name + " deflected"
		elif penetrate:
			attacker.debug.damage_post_mitigation = str(round(damage_post_mitigation * 100) / 100) + " " + damage_type_name + " penetrated"
		else:
			attacker.debug.damage_post_mitigation = str(round(damage_post_mitigation * 100) / 100) + " " + damage_type_name
