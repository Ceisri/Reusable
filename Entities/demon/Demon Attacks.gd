extends Node

onready var parent =  $".."


func stab()->void:
	var damage_type = "pierce"
	var player = parent
	var damage = 22 + player.pierce_dmg 
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var aggro_power = damage + 20
	var enemies = $"../Area2".get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("player"):
			if enemy.has_method("takeDamage"):
				if enemy.has_method("applyEffect"):
					enemy.applyEffect(enemy,"bleeding", true)	
				if player.is_on_floor():
					#insert sound effect here
					if randf() <= player.critical_chance:
						if player.isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(critical_damage,aggro_power,player,player.stagger_chance,damage_type)
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(critical_flank_damage,aggro_power,player,player.stagger_chance,damage_type)
					else:
						if player.isFacingSelf(enemy,0.30): #check if the enemy is looking at me 
							enemy.takeDamage(damage,aggro_power,player,player.stagger_chance,"heat")
						else: #apparently the enemy is showing his back or flanks, extra damagec
							enemy.takeDamage(damage_flank,aggro_power,player,player.stagger_chance,"heat")
