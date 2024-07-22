extends Area


var direction: Vector3 = Vector3.ZERO # Direction of the bullet
var summoner: KinematicBody
var damage: float 
var life_time: int = 5
var velocity: Vector3 = Vector3.ZERO # Initial velocity
var speed:float = 30
var time_to_rotate:float = 5

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("Entity"):
			if body != self:
				if body != summoner:
					if body.has_node("Stats"):
						if Engine.get_physics_frames() % 4 == 0:
							body.get_node("Stats").getHit(summoner,damage,Autoload.damage_type.jolt,0,0)
					else:
						print("ring of fire cast by :" + str(summoner.name) + "  cant deal damage to: " + str(body.name))

	
	if Engine.get_physics_frames() % 4 == 0:
		life_time -= 1
		if life_time <=0:
			queue_free()
