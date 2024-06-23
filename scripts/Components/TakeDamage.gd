extends Spatial

onready var parent:KinematicBody = get_parent()
var instigatorAggro

func resetEffects()->void:#For cleanses or respawns
	parent.stunned_duration = 0
	parent.bleeding_duration = 0
	parent.berserk_duration = 0
	
	
func effectDurations()->void:
	if parent.bleeding_duration > 0:
		if parent.stored_instigator == null:
			pass
		else:
			var damage: float = autoload.bleed_dmg 
			if parent.is_player == true:
				takeDOTPlayer(damage,parent.stored_instigator,"bleed")
			else:
				takeDOT(damage,damage, parent.stored_instigator, "bleed")
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
		
		
func stutterNow(damage, damage_type)->void:
	var text = autoload.floatingtext_damage.instance()
	text.status = "Lag NOW"
	text.state = damage_type
	text.amount = damage
	add_child(text)

		
onready var fall_sound =$GetKnockedDown



func takeDOT(damage, aggro_power, instigator, damage_type)->void:
	if parent.health > -100:
		var entity_holder = parent.entity_holder
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

			parent.health -= damage_to_take
			instigatorAggro.threat += damage_to_take + aggro_power
			text.amount =round(damage_to_take * 100)/ 100
			text.state = damage_type
			add_child(text)




func takeDOTPlayer(damage,instigator, damage_type)->void:
	if parent.health > -100:
		var random_range = rand_range(0,100)
		var text = autoload.floatingtext_damage.instance()
		if parent.has_method("lookTarget"):
			if parent.health >0:
				parent.lookTarget(parent.turn_speed*3)	
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

			parent.health -= damage_to_take
			text.amount =round(damage_to_take * 100)/ 100
			text.state = damage_type
			viewport.add_child(text)




func takeDamage(damage, aggro_power, instigator, damage_type)->void:
	if parent.health > -100:
		var entity_holder = parent.entity_holder
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

			if parent.health <=0:
				if parent.health >= -100:
					entity_holder.gather(instigator,round(damage_to_take))

			if random_range < instigator.stagger_chance - parent.stagger_resistance:
				if parent.health >0:
						parent.staggered_duration = true
						parent.changeAttackType()
						text.status = "Staggered!"
						
			if random_range < instigator.knockdown_chance:
				if instigator.impact > parent.balance:
					if parent.health > damage_to_take * 3:#This is important to avoid enemies getting up while they are dead just to then die instantly soon after
						parent.staggered_duration = false
						text.status = "Knocked Down!"
						parent.changeAttackType()
						getKnockedDown(instigator)
				else:
					parent.staggered_duration = false
					text.status = "Knock Down Resisted!"
#______________________________________DMG SECTION__________________________________________________
			if instigator.isFacingSelf(parent,0.30):
				if parent.absorbing == true:
					var total_dmg_to_take = damage_to_take / parent.guard_dmg_absorbition
					var absorbed_damage = damage_to_take - total_dmg_to_take
					var absorbed_percentage = (absorbed_damage / damage_to_take) * 100
					text.status = "Absorbed: " + str(round(absorbed_percentage*100)/100) + "%"
					text.state = damage_type
					parent.health -= total_dmg_to_take
					add_child(text)

				else:
					if random_range < instigator.critical_chance:
						var total_dmg_to_take = damage_to_take * instigator.critical_dmg 
						parent.health -= total_dmg_to_take
						text.amount =round(total_dmg_to_take * 100)/ 100
						instigatorAggro.threat += total_dmg_to_take
						text.status = "Critical Hit!"
						text.state = damage_type
						add_child(text)

					else:
						parent.health -= damage_to_take
						instigatorAggro.threat += damage_to_take + aggro_power
						text.amount =round(damage_to_take * 100)/ 100
						text.state = damage_type
						add_child(text)

			
		
			else:
				if  random_range< instigator.critical_chance:
					var total_dmg_to_take = (damage_to_take * instigator.critical_dmg) + instigator.flank_dmg
					parent.health -= total_dmg_to_take
					text.amount =round(total_dmg_to_take * 100)/ 100
					instigatorAggro.threat += total_dmg_to_take
					text.status = "Critical + Flank!"
					text.state = damage_type
					add_child(text)
	
				else:
					var total_dmg_to_take = damage_to_take  + instigator.flank_dmg
					parent.health -= total_dmg_to_take
					text.amount =round(total_dmg_to_take * 100)/ 100
					instigatorAggro.threat += total_dmg_to_take
					text.state = damage_type
					text.status = "Flanked!"
					add_child(text)

		else:
			text.status = "Parried!"
			text.state = damage_type
			add_child(text)

		
		
		
func getKnockedDown(instigator)->void:
	if parent.health > 20:
		instigatorAggro = parent.threat_system.createFindThreat(instigator)
		parent.animReset()
		parent.knockeddown_duration = true
		parent.knockeddown_first_part = true
		parent.staggered_duration = false
		parent.stored_instigator = instigator
		instigatorAggro.threat += 50
		fall_sound.play()
		parent.changeAttackType()
	
func getKnockedDownPlayer(instigator)->void:
		parent.knockeddown_duration = true
		parent.staggered_duration = false
		parent.stored_instigator = instigator


onready var viewport:Viewport = $Viewport
func takeDamagePlayer(damage, aggro_power, instigator, stagger_chance, damage_type)->void:
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
				
		if random_range < instigator.knockdown_chance / parent.balance:
			if parent.absorbing == false:
				if parent.parry == false:
					if parent.health < damage_to_take * 3:#This is important to avoid enemies getting up while they are dead just to then die instantly soon after
						parent.knockeddown_duration = false
						
					else:
						parent.staggered_duration = false
						text.status = "Knocked Down!"
						getKnockedDownPlayer(instigator)
						viewport.add_child(text)
						
		elif random_range < instigator.stagger_chance - parent.stagger_resistance:
			if parent.absorbing == false:
				if parent.parry == false:
					if parent.health >0:
						parent.staggered_duration = true
						text.status = "Staggered!"
						if viewport == null:
							add_child(text)
						else:
							viewport.add_child(text)
					else:
						parent.staggered_duration = false
						parent.knockeddown_duration = false
						
		if parent.health <0:
			parent.staggered_duration = false
			parent.knockeddown_duration = false
			parent.state = autoload.state_list.downed
						
		if instigator.isFacingSelf(parent,0.30): #Frontal attacks
			if parent.absorbing == true:
				var total_dmg_to_take = damage_to_take / parent.guard_dmg_absorbition
				var absorbed_damage = damage_to_take - total_dmg_to_take
				var absorbed_percentage = (absorbed_damage / damage_to_take) * 100
				text.status = "Absorbed: " + str(round(absorbed_percentage*100)/100) + "%"
				text.state = damage_type
				parent.health -= total_dmg_to_take
				viewport.add_child(text)
			else:
				if random_range < instigator.critical_chance:
					var total_dmg_to_take = damage_to_take * instigator.critical_dmg 
					parent.health -= total_dmg_to_take
					text.amount =round(total_dmg_to_take * 100)/ 100
					text.status = "Critical Hit!"
					text.state = damage_type
					viewport.add_child(text)
				else:
					parent.health -= damage_to_take	
					text.amount =round(damage_to_take * 100)/ 100
					text.state = damage_type
					if viewport == null:
						add_child(text)
					else:
						viewport.add_child(text)

		else: #Backstabs or Flank Attacks
				if  random_range< instigator.critical_chance:
					var total_dmg_to_take = (damage_to_take * instigator.critical_dmg) + instigator.flank_dmg
					parent.health -= total_dmg_to_take
					text.amount =round(total_dmg_to_take * 100)/ 100
					text.status = "Critical + Flank!"
					text.state = damage_type
					if viewport == null:
						add_child(text)
					else:
						viewport.add_child(text)
				else:
					var total_dmg_to_take = damage_to_take + instigator.flank_dmg
					parent.health -= total_dmg_to_take
					text.amount =round(total_dmg_to_take * 100)/ 100
					text.state = damage_type
					text.status = "Flanked!"
					if viewport == null:
						add_child(text)
					else:
						viewport.add_child(text)

		if random_range < stagger_chance - parent.stagger_resistance:
			if parent.health >0:
				parent.staggered_duration = true
				text.status = "Staggered"
	else:
		text.status = "Parried"
		text.state = damage_type
		if viewport == null:
			add_child(text)
		else:
			viewport.add_child(text)
		

func takeStagger(stagger_chance: float) -> void:
	var random_range = rand_range(0,100)
	if random_range <= stagger_chance:
		if parent.health >0:
			var text = autoload.floatingtext_damage.instance()
			parent.staggered_duration = true
			text.status = "Staggered"
			parent.changeAttackType()
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

var has_got_killed_already:bool = false
func getKilled(instigator)->void:
	if parent.health <= 0:
		if parent.death_duration == false:
			if has_got_killed_already == false:
				parent.death_duration = true
				print(str(instigator.entity_name) +" has killed " +str(parent.entity_name))
				if instigator.auto_loot == true:
						parent.entity_holder.dropItems(instigator)
						if instigator.has_method("takeExperience"):
							instigator.takeExperience(round((parent.max_health * 0.01)+ parent.experience_worth))
							has_got_killed_already = true
				else:
						parent.entity_holder.dropItemsLootTable(instigator)
						has_got_killed_already = true
						if instigator.has_method("takeExperience"):
							instigator.takeExperience(round((parent.max_health * 0.01)+ parent.experience_worth))


func regenerate()->void:
	if parent.health >0:
		if parent.health < parent.max_health:
			parent.health += 0.01
		if parent.aefis < parent.max_aefis:
			parent.aefis += 1
		if parent.nefis < 	parent.max_nefis:
			parent.nefis += 1
		if parent.resolve < parent.resolve:
			parent.resolve += 0.25
		
