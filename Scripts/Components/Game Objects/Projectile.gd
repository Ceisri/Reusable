extends KinematicBody

var direction: Vector3 = Vector3.ZERO # Direction of the bullet
onready var area: Area = $Area
var summoner: KinematicBody
var damage: float 
var life_time: int = 15
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
							if damage_type == null:
								pass
							else:
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


func isFacingSelf(body:Node, threshold: float) -> bool:
	# Get the global position of the calling object (self)
	var self_global_transform = get_global_transform()
	var self_position = self_global_transform.origin
	# Get the global position of the body
	var body_position = body.global_transform.origin
	# Calculate the direction vector from the calling object (self) to the body
	var direction_to_body = (body_position - self_position).normalized()
	# Get the facing direction of the body from its Mesh node
	var facing_direction = Vector3.ZERO
	var direction_node = body.get_node("DirectionControl")
	
	if direction_node:
		facing_direction = direction_node.global_transform.basis.z.normalized()
	else:# If DirectionControl node is not found, use the default facing direction of the body
		facing_direction = body.global_transform.basis.z.normalized()
	# Calculate the dot product between the body's facing direction and the direction to the calling object (self)
	var dot_product = facing_direction.dot(direction_to_body)

	var angle_between = rad2deg(acos(dot_product))

	# If the dot product is greater than a certain threshold, consider the body is facing the calling object (self)
	return dot_product >= threshold
