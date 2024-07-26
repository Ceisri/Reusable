extends Timer

onready var parent:KinematicBody = get_parent()
onready var collision_shape:CollisionShape = get_parent().get_node("CollisionShape")

func _ready() -> void:
	connect("timeout", self, "respawn")

func begin() -> void: # Don't auto start this, I'll call it from another script
	# Set the parent invisible and disable the collision shape
	parent.visible = false
	collision_shape.disabled = true
	
	# Start the timer with 10 seconds
	start(10)


func respawn() -> void:
	# Teleport the parent to (0, -10, 0)
	parent.translation = Vector3(0, -10, 0)
	
	# Make the parent visible and enable the collision shape
	parent.visible = true
	collision_shape.disabled = false
