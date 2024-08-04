extends MeshInstance



"""
@Ceisri
Documentation String: 
The following two functions 'rotateShadow()' and  'moveShadow()' check the x and z rotation
of the floor and the distance between it and the player then it corects the rotation and height of 
shadow_mesh so it matches the floor, which avoids jarring situations where the shadow phases thru the floor.
shadow_mesh is basically a plane with a transparent black spot texture to mimic a shadow.
The reason of this fake shadow system is to simply avoid performance costs that come with real shadows
"""
onready var floor_ray_cast:RayCast = get_parent().get_node("CheckFloor")

func rotateShadow() -> void:
	# Check if the object is currently on the floor
	if get_parent().is_on_floor():
		# Force update the RayCast to ensure it's up-to-date with collisions
		floor_ray_cast.force_raycast_update()
		# Check if the RayCast is currently colliding with an object
		if floor_ray_cast.is_colliding():
			# Get the normal vector of the collision surface
			var floor_normal: Vector3 = floor_ray_cast.get_collision_normal()
			# Calculate the rotation axis to align with the floor normal
			var up_dir: Vector3 = Vector3.UP
			var rotation_axis: Vector3 = up_dir.cross(floor_normal).normalized()
			# Calculate the rotation angle to match the floor's inclination
			var rotation_angle: float = acos(up_dir.dot(floor_normal))
			# Create a quaternion for rotation based on axis and angle
			var rotation_quat: Quat = Quat(rotation_axis, rotation_angle)
			# Convert the quaternion rotation to Euler angles and apply it to the shadow_mesh
			rotation = rotation_quat.get_euler()
func moveShadow() -> void:
	if floor_ray_cast.is_colliding():
		# Get the collision point and set the shadow's position just above the ground
		var collision_point = floor_ray_cast.get_collision_point()
		if !get_parent().is_on_floor():
			global_transform.origin = Vector3(collision_point.x, collision_point.y + 0.1, collision_point.z)
		else:
			global_transform.origin = Vector3(collision_point.x, collision_point.y + 0.055, collision_point.z)  
