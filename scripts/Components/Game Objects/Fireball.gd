extends KinematicBody

var direction: Vector3 = Vector3.ZERO # Direction of the bullet
onready var area: Area = $Area
var summoner: KinematicBody
var damage: float 
var life_time: int = 5
var velocity: Vector3 = Vector3.ZERO # Initial velocity
var speed:float = 30
var time_to_rotate:float = 5



func _physics_process(delta: float) -> void:
	move_and_collide(direction.normalized() * speed * get_physics_process_delta_time())
	

#Rotate away from summoner
#	if time_to_rotate > 0:
#		time_to_rotate -= 1
#		var opposite_direction = -summoner.direction.normalized()
#		look_at(global_transform.origin + opposite_direction, Vector3.UP)
		
	for body in area.get_overlapping_bodies():
		if body.is_in_group("Entity"):
			if body != self:
				if body != summoner:
					if body.has_node("Stats"):
						body.get_node("Stats").getHit(summoner,damage,Autoload.damage_type.heat,0,0)
						queue_free()
					else:
						print("ring of fire cast by :" + str(summoner.name) + "  cant deal damage to: " + str(body.name))
		else:
			if body != self:
				if body != summoner:
					queue_free()
	
	if Engine.get_physics_frames() % 24 == 0:
		life_time -= 1
		if life_time <=0:
			queue_free()

