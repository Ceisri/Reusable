extends KinematicBody


export var weight:float = 30
var thrown: bool = false
var thrower:Node = null
func _physics_process(delta):
	movement(delta)
var gravity_active: bool = true
var gravity_force: float = 9.0

func gravity():
	if not is_on_floor():
		vertical_velocity += Vector3.DOWN * gravity_force * get_physics_process_delta_time()
		
	else:
		vertical_velocity = Vector3.ZERO

var direction: Vector3 = Vector3()
var horizontal_velocity: Vector3 = Vector3()
var vertical_velocity: Vector3 = Vector3()
var movement: Vector3 = Vector3()
var angular_acceleration: float = 3.25
var acceleration: float = 15.0
var movement_speed: float = 0.0

func movement(delta: float) -> void:
	if thrown:
		set_collision_mask(1) 
		set_collision_layer(1) 
		horizontal_velocity = (direction * (thrower.stats.strength + 5)) / (weight/10)
		if Engine.get_physics_frames() % 5 == 0:
			gravity()
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)

	var collision = move_and_collide(movement)
	
	if collision:
		#print("Collided with: ", collision.collider.name)
		if collision.collider.is_in_group("Entity"):
			if is_instance_valid(collision.collider.stats):
				if collision.collider != thrower:
					if thrown == true:
						collision.collider.stats.getHit(thrower, 15, Autoload.damage_type.blunt,0,1)
						vertical_velocity = Vector3.DOWN * 3
		thrown = false
		direction = Vector3.ZERO
		horizontal_velocity = Vector3.ZERO
	if Engine.get_physics_frames() % 24 == 0:
		gravity()
