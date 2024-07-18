extends Control

onready var player = get_parent()
onready var skeleton =  $"../../DirectionControl/Character/Armature/Skeleton"
var head_default_transform = Transform()
var leg_default_transform = Transform()
var scale = 1

func _physics_process(delta:float)->void:
	if Engine.get_physics_frames() % 28 == 0:
		applyDefaultSize()

var default_applied:bool = false
func applyDefaultSize()->void:
	if default_applied == false:
		if skeleton != null:
			var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
			var leg_index = skeleton.find_bone("mixamorig_right_leg")# Get the index of the "head" bone

			head_default_transform = skeleton.get_bone_rest(head_index)#Get the default rest transform of the "head" bone
			leg_default_transform = skeleton.get_bone_rest(leg_index)#Get the default rest transform of the "head" bone
			default_applied = true
			print("skeletonfound")

func _on_bighead_pressed():
	var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
	var leg_index = skeleton.find_bone("mixamorig_right_leg")# Get the index of the "head" bone

	scale += 0.01
	var new_scale = Vector3(scale,scale,scale)
							#depth, 
	# Scale the rest transform accordingly
	var new_rest_transform = Transform(head_default_transform.basis.scaled(new_scale),head_default_transform.origin)
	skeleton.set_bone_rest(head_index, new_rest_transform)
func _on_smallhead_pressed():
	var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
	var leg_index = skeleton.find_bone("mixamorig_right_leg")# Get the index of the "head" bone

	scale -= 0.01
	print(scale)
	var new_scale = Vector3(scale,scale,scale)
	# Scale the rest transform accordingly
	var new_rest_transform = Transform(head_default_transform.basis.scaled(new_scale),head_default_transform.origin)
	skeleton.set_bone_rest(head_index, new_rest_transform)# Set the new rest transform for the "head" bone
func _on_resethead_pressed():
	var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
	var leg_index = skeleton.find_bone("mixamorig_right_leg")# Get the index of the "head" bone

	scale = 1
	skeleton.set_bone_rest(head_index, head_default_transform)#reset bone scale to default


func _on_LegThickness_pressed():
	var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
	var leg_index = skeleton.find_bone("mixamorig_right_leg")# Get the index of the "head" bone

	scale += 0.1
	var new_scale = Vector3(scale,1,scale)

	var new_rest_transform = Transform(leg_default_transform.basis.scaled(new_scale),leg_default_transform.origin)
	skeleton.set_bone_rest(leg_index, new_rest_transform)

func _on_LegThicknessMinus_pressed():
	var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
	var leg_index = skeleton.find_bone("mixamorig_right_leg")# Get the index of the "head" bone

	scale -= 0.1
	var new_scale = Vector3(scale,1,scale)

	var new_rest_transform = Transform(leg_default_transform.basis.scaled(new_scale),leg_default_transform.origin)
	skeleton.set_bone_rest(leg_index, new_rest_transform)


func _on_ThighThickness_pressed():
	var leg_index = skeleton.find_bone("mixamorig_right_up_leg")# Get the index of the "head" bone

	scale -= 0.1
	var new_scale = Vector3(scale,1,scale)

	var new_rest_transform = Transform(leg_default_transform.basis.scaled(new_scale),leg_default_transform.origin)
	skeleton.set_bone_rest(leg_index, new_rest_transform)
