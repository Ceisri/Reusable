extends KinematicBody


onready var area: Area = $Area
var summoner: KinematicBody
var damage: float 
var life_time:int = 3

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 24 == 0:
		life_time -= 1
		if life_time <=0:
			queue_free()
	if Engine.get_physics_frames() % 12 == 0:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("Entity"):
				if body != self:
					if body != summoner:
						if body.has_node("Stats"):
							body.get_node("Stats").getHit(summoner,damage,Autoload.damage_type.heat,0,0)
						else:
							print("ring of fire cast by :" + str(summoner.name) + "  cant deal damage to: " + str(body.name))
