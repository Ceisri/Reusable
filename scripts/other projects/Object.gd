extends KinematicBody

var thrown: bool = false

func _physics_process(delta):
	gravity()
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
		horizontal_velocity = direction * 3.0
		
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	movement.y = vertical_velocity.y
	move_and_slide(movement, Vector3.UP)
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * movement_speed, acceleration * delta)

	var collision = move_and_collide(movement)
	
	if collision:
		print("Collided with: ", collision.collider.name)
		thrown = false
		direction = Vector3.ZERO
		horizontal_velocity = Vector3.ZERO
