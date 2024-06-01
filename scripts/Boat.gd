extends KinematicBody

var speed = 100  # Adjust this value to control the speed of the movement
onready var mesh = $Mesh



var is_steering = true
var stored_body 
func _physics_process(delta):
	checkSteeringDirection(delta)
	physicsSauce()
	directionTimer(delta)
	#print(speed)

func moveForward(delta):
	horizontal_velocity = direction * speed * delta
	
func checkSteeringDirection(delta):
	var bodies = $Mesh/Area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			stored_body = body
			direction = body.direction 
			stored_direction = direction
			direction_timer += 5 * delta
			speed = 100
			angular_acceleration = 0.03
			moveForward(delta)
			horizontal_velocity = horizontal_velocity.linear_interpolate(direction.normalized() * speed, acceleration * delta)
			rotateShip(delta)
			body.player_mesh.rotation.y = mesh.rotation.y
	if  direction_timer >0: 
		horizontal_velocity = stored_direction * speed * delta
		horizontal_velocity = horizontal_velocity.linear_interpolate(stored_direction.normalized() * speed, acceleration * delta)
		rotateShip(delta)
		if speed >0:
			speed -= 10
		elif speed < 0:
			speed = 0 
		if angular_acceleration >0: 
			angular_acceleration -= 0.0003
		elif angular_acceleration < 0:
			angular_acceleration = 0 

var angular_acceleration = 0.03
var acceleration = 0.05
var horizontal_velocity = Vector3()
var movement = Vector3()
var vertical_velocity = Vector3()
var direction 

func rotateShip(delta):
	mesh.rotation.y = lerp_angle(mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
	
func physicsSauce():
	# The Physics Sauce. Movement, gravity and velocity in a perfect dance.
	movement.z = horizontal_velocity.z + vertical_velocity.z
	movement.x = horizontal_velocity.x + vertical_velocity.x
	move_and_slide(movement, Vector3.UP)
	
var stored_direction = Vector3.ZERO  # Variable to store the direction
var direction_timer = 0
func directionTimer(delta):
	# Update direction_timer
	if direction_timer > 0:
		direction_timer -= delta
	else:
		stored_direction = Vector3.ZERO 
