extends Node


func pullPlayer(pull_distance, pull_speed):
	var direction = -camera.global_transform.basis.z.normalized() # Get the forward direction of the camera
	var motion = direction * pull_speed

	# Decrease the vertical speed
	motion.y *= 0.5

	var acceleration_time = pull_speed / 2.0
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = move_and_collide(motion)
	
	hook_mesh.visible = true
	
	if collision: # this checks if the player hits a wall after being pulled
		# Calculate bounce-back direction
		var normal = collision.normal

		# Adjust motion based on the collision normal to prevent sinking below the ground
		if normal.y > 0.5: # Assume that ground has a normal y component greater than 0.5
			motion.y = max(motion.y, 0)

		var bounce_motion = -4 * normal * normal.dot(motion) + motion
		# Move the player slightly away from the wall to avoid sticking
		translation += normal * 0.1 * collision.travel # afterwards they are pushed back
		# Tween the bounce-back motion
		tween.interpolate_property(self, "translation", translation, translation + bounce_motion * pull_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		# Tween the movement over time with initial acceleration followed by instant stop
		tween.interpolate_property(self, "translation", translation, translation + motion * pull_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(self, "translation", translation + motion * pull_distance, translation + motion * (pull_distance - deceleration_distance), acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, acceleration_time)
		tween.start()
