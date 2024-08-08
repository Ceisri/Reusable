extends Control

var player
onready var close_button:TextureButton = $Close/button
onready var smile_slider: Slider = $FrontView/Smile
onready var camera_front:Camera = $FrontView/Portrait/ViewportContainer/Viewport/Camera
onready var camera_side:Camera = $SideView/Portrait/ViewportContainer/Viewport/Camera
onready var camera_body:Camera = $Fullbody/Portrait/ViewportContainer/Viewport/Camera

onready var face_button = $SwitchFace
onready var skin_melanin_slider: Slider = $Fullbody/SkinMelanin
onready var hair_melanin_slider: Slider = $Fullbody/HairMelanin
onready var hair_melanin_slider2: Slider = $Fullbody/HairMelanin2
onready var stretch_marks_opacity: Slider = $Fullbody/StretchOpacitySlider
onready var stretch_marks_intesity: Slider = $Fullbody/StretchIntensitySlider



onready var switch_color_picked: TextureButton =  $SwitchColorPicked/button

func _ready() -> void:
	face_button.connect("pressed", self, "faceChanged")
	smile_slider.connect("value_changed", self, "smileValueChanged")
	stretch_marks_opacity.connect("value_changed", self, "stretchMarkOpacityValueChanged")
	stretch_marks_intesity.connect("value_changed", self, "stretchMarkIntensityValueChanged")
	
	
	skin_melanin_slider.connect("value_changed", self, "skinMelaninChanged")
	hair_melanin_slider.connect("value_changed", self, "hairMelaninChanged")
	hair_melanin_slider2.connect("value_changed", self, "hairMelaninChanged2")
	close_button.connect("pressed", self, "close")
	switch_color_picked.connect("pressed", self, "switchColorPicked")

	
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

var selected_face: int = 0
func faceChanged() -> void:
	selected_face = (selected_face + 1) % Autoload.humman_fem_heads.size()
	player.character.switchFace(selected_face)



func stretchMarkIntensityValueChanged(value):
	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Eye") == -1 and child.name.find("Hair") == -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 0:
				var material = mesh.surface_get_material(0)  # First material surface
				if material:
					material.set("shader_param/stretch_marks_threshold", value * 0.01)
				else:
					print("Material not found on body mesh.")
				return  # Assuming you want to set the material on the first match

func stretchMarkOpacityValueChanged(value):
	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Eye") == -1 and child.name.find("Hair") == -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 0:
				var material = mesh.surface_get_material(0)  # First material surface
				if material:
					material.set("shader_param/stretch_marks_opacity", value * 0.01)
				else:
					print("Material not found on body mesh.")
				return  # Assuming you want to set the material on the first match



func smileValueChanged(value) -> void:
	player.character.smile  = value / 100
	player.character.applyBlendShapes()

var human_fem_skin = load("res://Game/World/Player/Materials/skin.material")
var skin_melanin_value: float = 0.0

func skinMelaninChanged(value: float) -> void:
	skin_melanin_value = value
	var base_color = Color(1.0, 1.0, 1.0) # white as base color
	var darkening_color = Color(77 / 255.0, 65 / 255.0, 48 / 255.0) # red 77, green 65, blue 48
	var factor = value / 100.0

	for child in player.skeleton.get_children():
		if child is MeshInstance and not child.name.find("Eye") != -1 and not child.name.find("Hair") != -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 0:
				var material = mesh.surface_get_material(0) # First material surface
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					var final_color = base_color.linear_interpolate(darkening_color, factor)
					spatial_material.albedo_color = final_color
					mesh.surface_set_material(0, spatial_material)


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
	load("res://Game/World/Player/Textures/Hair/hairDark3.png"),
	load("res://Game/World/Player/Textures/Hair/hairRed.png"),
]

# External indices for saving and loading
var hair_melanin_index_1: int = 0
var hair_melanin_index_2: int = 0

func hairMelaninChanged(value: float) -> void:
	hair_melanin_index_1 = int(value) # Convert the slider value to an integer index
	hair_melanin_index_1 = clamp(hair_melanin_index_1, 0, hair_melanin_levels.size() - 1) # Ensure the index is within the valid range

	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Hair") != -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 0:
				var material = mesh.surface_get_material(0) # First surface material
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					spatial_material.albedo_texture = hair_melanin_levels[hair_melanin_index_1]
					mesh.surface_set_material(0, spatial_material)

func hairMelaninChanged2(value: float) -> void:
	hair_melanin_index_2 = int(value) # Convert the slider value to an integer index
	hair_melanin_index_2 = clamp(hair_melanin_index_2, 0, hair_melanin_levels.size() - 1) # Ensure the index is within the valid range

	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Hair") != -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 1:
				var material = mesh.surface_get_material(1) # Second surface material
				if material and material is SpatialMaterial:
					var spatial_material := material as SpatialMaterial
					spatial_material.albedo_texture = hair_melanin_levels[hair_melanin_index_2]
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
					

var picking_color_for: String = "hair1"

func switchColorPicked() -> void:
	match picking_color_for:
		"hair1":
			picking_color_for = "hair2"
		"hair2":
			picking_color_for = "eye1"
		"eye1":
			picking_color_for = "eye2"
		"eye2":
			picking_color_for = "both eyes"
		"both eyes":
			picking_color_for = "both hair colors"
		"both hair colors":
			picking_color_for = "hair1"
	$SwitchColorPicked/label.text = "Choosing color for:" + "\n" + picking_color_for

func _on_ColorPicker_color_changed(color)-> void:
	match picking_color_for:
		"hair1":
			colorHair(color)
		"hair2":
			colorHair2(color)
		"both hair colors":
			colorHair2(color)
			colorHair(color)
			
		
		

func _on_BodyPositivity_value_changed(value):
	$Fullbody/label2.text = "Body Positivity: " + str(player.character.body_positivity * 100)
	player.character.body_positivity = value / 100
	player.character.applyBlendShapes()



