extends Spatial

onready var parent:KinematicBody = get_parent()
onready var viewport:Viewport = $Viewport
var instigatorAggro

func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type)->void:
	var health = parent.health
	var max_health = parent.max_health
	var slash_resistance = parent.slash_resistance
	var pierce_resistance = parent.pierce_resistance
	var blunt_resistance = parent.blunt_resistance
	var sonic_resistance = parent.sonic_resistance
	var heat_resistance = parent.heat_resistance
	var cold_resistance = parent.cold_resistance
	var jolt_resistance = parent.jolt_resistance
	var toxic_resistance = parent.toxic_resistance
	var acid_resistance = parent.acid_resistance
	var bleed_resistance = parent.bleed_resistance
	var neuro_resistance = parent.neuro_resistance
	var radiant_resistance = parent.radiant_resistance
	
	
	
	var random_range = rand_range(0,1)
	var text = autoload.floatingtext_damage.instance()
	if parent.has_method("lookTarget"):
		parent.lookTarget(parent.turn_speed*3)	
	parent.stored_instigator = instigator
	if parent.parry == false:
		var damage_to_take = damage
		if parent.threat_system != null:
			instigatorAggro = parent.threat_system.createFindThreat(instigator)
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
	
	
		if randf() < stagger_chance- parent.stagger_resistance:
				parent.state = autoload.state_list.staggered
				parent.staggered_duration = true
				text.status = "Staggered"
		parent.health -= damage_to_take	
		instigatorAggro.threat += damage_to_take + aggro_power
		text.amount =round(damage_to_take * 100)/ 100
		text.state = damage_type
		viewport.add_child(text)
		if health <= 0:
			parent.state = autoload.state_list.dead
			if instigator.has_method("takeExperience"):
				instigator.takeExperience(round((max_health * 0.01)+ parent.experience_worth))
	else:
		text.status = "Parried"
		text.state = damage_type
		viewport.add_child(text)
		

var has_died:bool = false
func getKilled(instigator)->void:
	var health = parent.health
	var max_health = parent.max_health
	
	if has_died == false:
		if health <= 0:
			parent.state = autoload.state_list.dead
			if instigator.has_method("takeExperience"):
				instigator.takeExperience(round((max_health * 0.01)+ parent.experience_worth))
	
