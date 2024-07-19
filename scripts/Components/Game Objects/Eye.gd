extends MeshInstance

onready var parent = get_parent()
onready var initial_rotation = rotation_degrees

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 24 == 0:
		lookTarget(15 * delta)

func lookTarget(turning_speed: float) -> void:
	var target = parent.get_node("Threat").findHighestThreat()
	if target:
		var target_pos = target.player.global_transform.origin

		# Get the direction to the target
		var direction = (target_pos - global_transform.origin).normalized()

		# Use look_at to set the rotation towards the target
		look_at(target_pos, Vector3.UP)

		# Get the current rotation in degrees
		var current_rotation = rotation_degrees

		# Calculate the relative rotation to the initial rotation
		var relative_rotation = current_rotation - initial_rotation

		# Clamp the rotation angles to ±75 degrees
		var max_angle = 60
		relative_rotation.x = clamp(relative_rotation.x, -max_angle, max_angle)
		relative_rotation.y = clamp(relative_rotation.y, -max_angle, max_angle)
		relative_rotation.z = 0  # Optionally clamp roll to 0

		# Apply the clamped rotation
		rotation_degrees = initial_rotation + relative_rotation
