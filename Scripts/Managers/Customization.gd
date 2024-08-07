extends Control

var player
onready var close_button:TextureButton = $Close/button
onready var smile_slider: Slider = $FrontView/Smile
onready var camera_front:Camera = $FrontView/Portrait/ViewportContainer/Viewport/Camera
onready var camera_side:Camera = $SideView/Portrait/ViewportContainer/Viewport/Camera
onready var camera_body:Camera = $Fullbody/Portrait/ViewportContainer/Viewport/Camera


onready var skin_melanin_slider: Slider = $Fullbody/SkinMelanin
onready var hair_melanin_slider: Slider = $Fullbody/HairMelanin
onready var hair_melanin_slider2: Slider = $Fullbody/HairMelanin2
func _ready() -> void:
	smile_slider.connect("value_changed", self, "smileValueChanged")
	skin_melanin_slider.connect("value_changed", self, "skinMelaninChanged")
	hair_melanin_slider.connect("value_changed", self, "hairMelaninChanged")
	hair_melanin_slider2.connect("value_changed", self, "hairMelaninChanged2")
	close_button.connect("pressed", self, "close")

	
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
		var body_distance = 1.55
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

func close() -> void:
	visible = false


func smileValueChanged(value) -> void:
	player.character.smile  = value / 100
	player.character.applyBlendShapes()

var human_fem_skin = load("res://Game/World/Player/Models/Humans/Female/skin.material")

func skinMelaninChanged(value: float) -> void:
	var base_color = Color(1.0, 1.0, 1.0) # white as base color
	var darkening_color = Color(77 / 255.0, 65 / 255.0, 48 / 255.0) # red 77, green 65, blue 48
	var factor = value / 100.0

	for child in player.skeleton.get_children():
		if child is MeshInstance and not child.name.find("Eye") != -1 and not child.name.find("Hair") != -1:
			var mesh = child.mesh
			var index:int = 0
			if mesh and mesh.get_surface_count() > index:
				var material = mesh.surface_get_material(index) # Second material surface
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					var final_color = base_color.linear_interpolate(darkening_color, factor)
					spatial_material.albedo_color = final_color
					mesh.surface_set_material(index, spatial_material)
var hair_melanin_levels = [
	load("res://Game/World/Player/Textures/Hair/hairLight8.png"),
	load("res://Game/World/Player/Textures/Hair/hairLight7.png"),
	load("res://Game/World/Player/Textures/Hair/hairLight6.png"),
	load("res://Game/World/Player/Textures/Hair/hairLight5.png"),
	load("res://Game/World/Player/Textures/Hair/hairLight4.png"),
	load("res://Game/World/Player/Textures/Hair/hairLight3.png"),
	load("res://Game/World/Player/Textures/Hair/hairLight2.png"),
	load("res://Game/World/Player/Textures/Hair/hairDark.png"),
	load("res://Game/World/Player/Textures/Hair/hairDark2.png"),
	load("res://Game/World/Player/Textures/Hair/hairDark3.png")
]

var hair_material = load("res://Game/World/Player/Models/Humans/Female/Hair/hair_color_1.material")

func hairMelaninChanged(value: float) -> void:
	var index = int(value) # Convert the slider value to an integer index
	index = clamp(index, 0, hair_melanin_levels.size() - 1) # Ensure the index is within the valid range

	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Hair") != -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 0:
				var material = mesh.surface_get_material(0) # First surface material
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					spatial_material.albedo_texture = hair_melanin_levels[index]
					mesh.surface_set_material(0, spatial_material)

func hairMelaninChanged2(value: float) -> void:
	var index = int(value) # Convert the slider value to an integer index
	index = clamp(index, 0, hair_melanin_levels.size() - 1) # Ensure the index is within the valid range

	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Hair") != -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 1:
				var material = mesh.surface_get_material(1) # Second surface material
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					spatial_material.albedo_texture = hair_melanin_levels[index]
					mesh.surface_set_material(1, spatial_material)


var hair_color = Color(1, 1, 1, 1) # Default to white
# Function to update UI colors based on color
func colorHair(color: Color)-> void:
	changeHairMaterialColor(color,0)
	hair_color = color
	
var hair_color2 = Color(1, 1, 1, 1) # Default to white
func colorHair2(color: Color)-> void:
	changeHairMaterialColor(color,1)
	hair_color2 = color

func changeHairMaterialColor(color: Color, surface_index: int) -> void:
	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Hair") != -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > surface_index:
				var material = mesh.surface_get_material(surface_index)
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					spatial_material.albedo_color = color
					mesh.surface_set_material(surface_index, spatial_material)
					
					
func _on_ColorPicker_color_changed(color)-> void:
	colorHair(color)
func _on_ColorPicker2_color_changed(color):
	colorHair2(color)
		

func _on_BodyPositivity_value_changed(value):
	$Fullbody/label2.text = "Body Positivity: " + str(player.character.body_positivity * 100)
	player.character.body_positivity = value / 100
	player.character.applyBlendShapes()



