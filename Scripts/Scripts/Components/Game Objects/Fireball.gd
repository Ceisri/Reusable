extends KinematicBody

var direction: Vector3 = Vector3.ZERO # Direction of the bullet
onready var area: Area = $Area
var summoner: KinematicBody
var damage: float 
var life_time: int
var velocity: Vector3 = Vector3.ZERO # Initial velocity
var speed:float = 10
var damage_type
var can_pentrate_wall:bool 
var does_slow_down:bool 
var is_lingering:bool 


func _physics_process(delta: float) -> void:
	move_and_collide(direction.normalized() * speed * get_physics_process_delta_time())

	for body in area.get_overlapping_bodies():
		if body.is_in_group("Entity"):
			if body != self:
				if body != summoner:
					if body.has_node("Stats"):
						if Engine.get_physics_frames() % 6 == 0:
							body.get_node("Stats").getHit(summoner,damage,damage_type,0,0)
							if is_lingering:
								life_time -= 3
							else:
								deactivate()
						
						if does_slow_down:
							if speed > 3:
								speed -= 3
						
					else:
						print("bullet shot by :" + str(summoner.name) + "  cant deal damage to: " + str(body.name))
		else:
			if body != self:
				if body != summoner:
					if !body.is_in_group("Projectile"):
						if not can_pentrate_wall:
							deactivate()
	
	if Engine.get_physics_frames() % 24 == 0:
		life_time -= 1
		if life_time <=0:
			deactivate()

var active = false
func deactivate():
	active = false
	visible = false
	set_physics_process(false)
	global_transform.origin = Vector3()  # Reset position
	direction = Vector3()  # Reset direction
