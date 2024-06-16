extends Spatial

onready var parent:KinematicBody = get_parent()
var instigatorAggro


func effectDurations():
	if parent.bleeding_duration > 0:
		if parent.stored_instigator == null:
			pass
		else:
			var damage: float = autoload.bleed_dmg 
			parent.takeDamage(damage,damage,parent.stored_instigator,0,"bleed")
		parent.applyEffect("bleeding",true)
		parent.bleeding_duration -= 1
	else:
		parent.applyEffect("bleeding",false)
	if parent.stunned_duration > 0:
		parent.applyEffect("stunned",true)
		parent.stunned_duration -= 1
	else:
		parent.applyEffect("stunned",false)
		
		
	if parent.berserk_duration > 0:
		parent.berserk_duration -= 1
		parent.applyEffect("berserk",true)
	else:
		parent.applyEffect("berserk",false)
		
		
		
		
		

func takeDamage(damage, aggro_power, instigator, stagger_chance, damage_type)->void:
	instigatorAggro = parent.threat_system.createFindThreat(instigator)
	var random_range = rand_range(0,100)
	var text = autoload.floatingtext_damage.instance()
	if parent.has_method("lookTarget"):
		if parent.health >0:
			parent.lookTarget(parent.turn_speed*3)	
	parent.stored_instigator = instigator
	if parent.parry == false:
		var damage_to_take = damage
		if damage_type == "slash":
			var mitigation = parent.slash_resistance / (parent.slash_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "pierce":
			var mitigation = parent.pierce_resistance / (parent.pierce_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "blunt":
			var mitigation = parent.blunt_resistance / (parent.blunt_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "sonic":
			var mitigation = parent.sonic_resistance / (parent.sonic_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "heat":
			var mitigation = parent.heat_resistance / (parent.heat_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "cold":
			var mitigation = parent.cold_resistance / (parent.cold_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "jolt":
			var mitigation = parent.jolt_resistance / (parent.jolt_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "toxic":
			var mitigation = parent.toxic_resistance / (parent.toxic_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "acid":
			var mitigation = parent.acid_resistance / (parent.acid_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "bleed":
			var mitigation = parent.bleed_resistance / (parent.bleed_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "neuro":
			var mitigation = parent.neuro_resistance / (parent.neuro_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "radiant":
			var mitigation = parent.radiant_resistance / (parent.radiant_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
	
	
		if random_range < stagger_chance - parent.stagger_resistance:
			if parent.health >0:
					parent.state = autoload.state_list.staggered
					parent.staggered_duration = true
					text.status = "Staggered"
		parent.health -= damage_to_take	
		instigatorAggro.threat += damage_to_take + aggro_power
		text.amount =round(damage_to_take * 100)/ 100
		text.state = damage_type
		add_child(text)
	else:
		text.status = "Parried"
		text.state = damage_type
		add_child(text)


func takeDamagePlayer(damage, aggro_power, instigator, stagger_chance, damage_type)->void:
	var viewport:Viewport = $Viewport
	var random_range = rand_range(0,100)
	var text = autoload.floatingtext_damage.instance()
	if parent.has_method("lookTarget"):
		parent.lookTarget(parent.turn_speed*3)	
	parent.stored_instigator = instigator
	if parent.parry == false:
		var damage_to_take = damage
		if damage_type == "slash":
			var mitigation = parent.slash_resistance / (parent.slash_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "pierce":
			var mitigation = parent.pierce_resistance / (parent.pierce_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "blunt":
			var mitigation = parent.blunt_resistance / (parent.blunt_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "sonic":
			var mitigation = parent.sonic_resistance / (parent.sonic_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "heat":
			var mitigation = parent.heat_resistance / (parent.heat_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "cold":
			var mitigation = parent.cold_resistance / (parent.cold_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "jolt":
			var mitigation = parent.jolt_resistance / (parent.jolt_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "toxic":
			var mitigation = parent.toxic_resistance / (parent.toxic_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "acid":
			var mitigation = parent.acid_resistance / (parent.acid_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "bleed":
			var mitigation = parent.bleed_resistance / (parent.bleed_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "neuro":
			var mitigation = parent.neuro_resistance / (parent.neuro_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		elif damage_type == "radiant":
			var mitigation = parent.radiant_resistance / (parent.radiant_resistance + 100.0)
			damage_to_take *= (1.0 - mitigation)
			if instigator.has_method("lifesteal"):
				instigator.lifesteal(damage_to_take)
		if random_range < stagger_chance - parent.stagger_resistance:
			if parent.health >0:
				parent.state = autoload.state_list.staggered
				parent.staggered_duration = true
				text.status = "Staggered"
		parent.health -= damage_to_take	
		text.amount =round(damage_to_take * 100)/ 100
		text.state = damage_type
		viewport.add_child(text)

	else:
		text.status = "Parried"
		text.state = damage_type
		viewport.add_child(text)


func takeStagger(stagger_chance: float) -> void:
	var random_range = rand_range(0,100)
	if random_range <= stagger_chance:
		if parent.health >0:
			var text = autoload.floatingtext_damage.instance()
			parent.state = autoload.state_list.staggered
			parent.staggered_duration = true
			text.status = "Staggered"
			add_child(text)


func takeHealing(healing,healer):
	parent.health += healing
	var text = autoload.floatingtext_damage.instance()
	text.amount =round(healing * 100)/ 100
	text.state = autoload.state_list.healing
	add_child(text)
	
var lifesteal_pop = preload("res://UI/lifestealandhealing.tscn")	
func lifesteal(damage_to_take)-> void:#This is called by the enemy's script when they take damage
	var viewport:Viewport = $Viewport
	if parent.life_steal > 0:
		var life_steal_ratio = damage_to_take * parent.life_steal
		if parent.health < parent.max_health:
			parent.health += life_steal_ratio
			if parent.is_in_group("Player") or parent.is_in_group("player"):
				var text = lifesteal_pop.instance()
				text.amount = round(life_steal_ratio * 100)/ 100
				if viewport == null:
					add_child(text)
				else:
					viewport.add_child(text)
		elif parent.health > parent.max_health:
			parent.health = parent.max_health
	

var has_died:bool = false
func getKilled(instigator)->void:
	var entity_holder = parent.entity_holder
	var health = parent.health
	var max_health = parent.max_health
	if has_died == false:
		if health <= 0:
			parent.state = autoload.state_list.dead
			print(str(instigator.entity_name) +" has killed " +str(parent.entity_name))
			if instigator.has_method("takeExperience"):
				instigator.takeExperience(round((max_health * 0.01)+ parent.experience_worth))
				if instigator.auto_loot == true:
					entity_holder.dropItems(instigator)
				has_died = true
	
