extends Node


# This script is momentary, before releasing the game, delete this node, it servers nothing inside the actual game 
onready var parent:KinematicBody = get_parent()
onready var entity_state_label =  $"../DebugLabel"

func _physics_process(delta: float) -> void:
	if parent.is_in_group("Entity"):
		if Engine.get_physics_frames() % 6 == 0:
			entity_state_debug()
			

func entity_state_debug()-> void:
	var state_enum = Icons.state_list  # Access the enum from the singleton
	var state_value = parent.state  # Get the current state value
	var state_name = state_enum.keys()[state_value]  # Convert enum to string
	if entity_state_label == null:
		pass
	else:
		entity_state_label.text = state_name
