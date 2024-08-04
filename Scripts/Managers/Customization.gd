extends Control

var player

onready var smile_slider: Slider = $FrontView/Smile
onready var camera_front:Camera = $FrontView/Portrait/ViewportContainer/Viewport/Camera
onready var camera_side:Camera = $SideView/Portrait/ViewportContainer/Viewport/Camera
onready var camera_body:Camera = $Fullbody/Portrait/ViewportContainer/Viewport/Camera


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ESC"):
		visible = false

	if visible:
		var forward_vector = player.direction_control.global_transform.basis.z
		var right_vector = player.direction_control.global_transform.basis.x
		var base_position = player.direction_control.global_transform.origin

		# Desired distances for camera positioning
		var face_distance = 0.305
		var side_distance = 0.118
		var body_distance = 0.305
		var body_height = 1.044

		# Move and rotate camera_front to look at the player's face
		camera_front.translation = base_position + forward_vector * face_distance + Vector3(0, 1.32, 0)
		camera_front.look_at(base_position, Vector3.UP)  # Point at the player's position
		camera_front.rotation.x = 0  # Reset pitch to avoid downward looking

		# Move and rotate camera_side to look at the side of the player
		camera_side.translation = base_position + right_vector * -0.2 + forward_vector * side_distance + Vector3(-0.15,1.4,0.1)
		camera_side.look_at(base_position, Vector3.UP)  # Point at the player's position
		camera_side.rotation.x = 0  # Reset pitch to avoid downward looking

		# Move and rotate camera_body to capture the entire body of the player
		camera_body.translation = base_position + forward_vector * body_distance + Vector3(0, 1.32, body_height)
		camera_body.look_at(base_position, Vector3.UP)  # Point at the player's position
		camera_body.rotation.x = 0  # Reset pitch to avoid downward looking



func _ready() -> void:
	smile_slider.connect("value_changed", self, "smileValueChanged")
	
func smileValueChanged(value) -> void:
	EditSmile(value)

func EditSmile(value) -> void:
	# Your code for editing smile goes here
	pass

