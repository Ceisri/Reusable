extends Area


var summoner
var damage
var duration: int = 15

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
							else:
								print("ring of fire cast by :" + str(summoner.name) + "  cant deal damage to: " + str(body.name))
