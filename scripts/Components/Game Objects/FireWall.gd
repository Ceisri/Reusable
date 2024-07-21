extends Area


var summoner
var damage
var duration: int = 7

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 24 == 0:
		duration -= 1
		if duration <= 0: 
			queue_free()
		for area in get_overlapping_areas():
			if area.is_in_group("Fire") or area.is_in_group("Water") or area.is_in_group("Ice") or area.is_in_group("Smoke"):
				duration -= 5
			
	if Engine.get_physics_frames() % 12 == 0:
		for body in get_overlapping_bodies():
			if body.is_in_group("Entity"):
				if body != summoner:
					if summoner == null:
						print("summoner is null so ring of fire can't do damage")
					else:
						if damage == null:
							print("ring of fire damage is null")
						else:
							if body.has_node("Stats"):
								body.get_node("Stats").getHit(summoner,damage,Autoload.damage_type.heat,0,0)
								pushEnemyAway(0.1,body,0.25)
							else:
								print("wall of fire cast by :" + str(summoner.name) + "  cant deal damage to: " + str(body.name))


onready var tween:Tween = $Tween
func pushEnemyAway(push_distance:float, enemy:Node, push_speed:float)->void:
	var direction_to_enemy = enemy.global_transform.origin - global_transform.origin
	direction_to_enemy.y = 0  # No vertical push
	direction_to_enemy = direction_to_enemy.normalized()
	var motion = direction_to_enemy * push_speed
	var acceleration_time = push_speed / 2.0
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = enemy.move_and_collide(motion)
	if collision: #this checks the enemy hits a wall after you punch him 
		enemy.get_node("Stats").getHit(summoner,damage,Autoload.damage_type.blunt,100,0)
		# Calculate bounce-back direction
		var normal = collision.normal
		var bounce_motion = -4 * normal * normal.dot(motion) + motion
		# Move the enemy slightly away from the wall to avoid sticking
		enemy.translation += normal * 0.1 * collision.travel#afterwards he is pushed back
		# Tween the bounce-back motion
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + bounce_motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		# Tween the movement over time with initial acceleration followed by instant stop
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(enemy, "translation", enemy.translation + motion * push_distance, enemy.translation + motion * (push_distance - deceleration_distance), acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, acceleration_time)
		tween.start()
