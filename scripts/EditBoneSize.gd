extends Node
#
#onready var skeleton =$"../Mesh/Race/Armature/Skeleton"
#var head_default_transform = Transform()
#var scale = 1
#onready var head_index = skeleton.find_bone("mixamorig_left_arm")# Get the index of the "head" bone
#func _ready():
#	head_default_transform = skeleton.get_bone_rest(head_index)#Get the default rest transform of the "head" bone
#func _on_bighead_pressed():
#	scale += 0.01
#	var new_scale = Vector3(scale,scale,scale)
#							#depth, 
#	# Scale the rest transform accordingly
#	var new_rest_transform = Transform(head_default_transform.basis.scaled(new_scale),head_default_transform.origin)
#	skeleton.set_bone_rest(head_index, new_rest_transform)
#func _on_smallhead_pressed():
#	scale -= 0.01
#	print(scale)
#	var new_scale = Vector3(scale,scale,scale)
#	# Scale the rest transform accordingly
#	var new_rest_transform = Transform(head_default_transform.basis.scaled(new_scale),head_default_transform.origin)
#	skeleton.set_bone_rest(head_index, new_rest_transform)# Set the new rest transform for the "head" bone
#func _on_resethead_pressed():
#	scale = 1
#	skeleton.set_bone_rest(head_index, head_default_transform)#reset bone scale to default
