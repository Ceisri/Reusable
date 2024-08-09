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

onready var breast_slider: Slider = $Fullbody/Breasts
onready var breast_roundness_slider: Slider = $Fullbody/BreastRoundness
onready var buttocks_slider: Slider = $Fullbody/Buttocks
onready var fat_slider: Slider = $Fullbody/Fat
onready var muscle_slider: Slider = $Fullbody/Muscle
onready var height_slider: Slider = $Fullbody/Heigth



onready var switch_color_picked: TextureButton =  $SwitchColorPicked/button

func _ready() -> void:
	face_button.connect("pressed", self, "faceChanged")
	smile_slider.connect("value_changed", self, "smileValueChanged")
	stretch_marks_opacity.connect("value_changed", self, "stretchMarkOpacityValueChanged")
	stretch_marks_intesity.connect("value_changed", self, "stretchMarkIntensityValueChanged")
	height_slider.connect("value_changed", self, "heightValueChanged")
	
	
	
	breast_slider.connect("value_changed", self, "breastValueChanged")
	breast_roundness_slider.connect("value_changed", self, "breastRoundnessValueChanged")
	buttocks_slider.connect("value_changed", self, "buttocksValueChanged")
	fat_slider.connect("value_changed", self, "fatValueChanged")
	muscle_slider.connect("value_changed", self, "muscleValueChanged")
	
	skin_melanin_slider.connect("value_changed", self, "skinMelaninChanged")
	hair_melanin_slider.connect("value_changed", self, "hairMelaninChanged")
	hair_melanin_slider2.connect("value_changed", self, "hairMelaninChanged2")
	close_button.connect("pressed", self, "close")
	switch_color_picked.connect("pressed", self, "switchColorPicked")


var face_distance:float = 0.305
var side_distance:float = 0.118
var front_height:float = 1.32
var side_height:float = 1.4
var body_distance:float = 1.55
var body_z:float = 1.044
var body_y:float = 1.32
var side_x:float = -0.15
var side_z:float = 0.1
func _physics_process(delta: float) -> void:
	if visible:
		if Input.is_action_just_pressed("ESC"):
			visible = false
		var forward_vector = player.direction_control.global_transform.basis.z
		var right_vector = player.direction_control.global_transform.basis.x
		var base_position = player.direction_control.global_transform.origin

		# Desired distances for camera positioning


		# Move and rotate camera_front to look at the player's face
		camera_front.translation = base_position + forward_vector * face_distance + Vector3(0,front_height, 0)
		camera_front.look_at(base_position, Vector3.UP)  # Point at the player's position
		camera_front.rotation.x = 0  # Reset pitch to avoid downward looking

		# Move and rotate camera_side to look at the side of the player
		camera_side.translation = base_position + right_vector * -0.2 + forward_vector * side_distance + Vector3(side_x,side_height,0.1)
		camera_side.look_at(base_position, Vector3.UP)  # Point at the player's position
		camera_side.rotation.x = 0  # Reset pitch to avoid downward looking

		# Move and rotate camera_body to capture the entire body of the player
		camera_body.translation = base_position + forward_vector * body_distance + Vector3(0,body_y, body_z)
		camera_body.look_at(base_position, Vector3.UP)  # Point at the player's position
		camera_body.rotation.x = 0  # Reset pitch to avoid downward looking


		$Fullbody/BreastRoundnessLabel.text = "Breast Roundness: " +  str(player.breast_roundness * 100)
		$Fullbody/BreastSize.text = "Breast Size: " +  str(-player.breast_size * 100)
		$Fullbody/ButtLabel.text =  "Buttocks Size: " +  str(player.buttocks * 100)
		$Fullbody/FatLabel.text =  "Fat: " +  str(player.fat * 100)
		$Fullbody/MuscleLabel.text =  "Muscle: " +  str(player.muscle * 100)
		updateHeightlabel()

func updateSliderValues():
	smile_slider.value = player.smile 
	breast_slider.value = -player.breast_size * 100
	breast_roundness_slider.value = player.breast_roundness * 100
	buttocks_slider.value = player.buttocks * 100
	fat_slider.value = player.fat * 100
	muscle_slider.value = player.muscle * 100
	skin_melanin_slider.value = skin_melanin_value
	hair_melanin_slider.value = hair_melanin_index_1
	hair_melanin_slider2.value = hair_melanin_index_2
	


func updateHeightlabel() -> void:
	var height_in_feet = Autoload.convertToFeet(player.height)
	var height_in_inches = (height_in_feet - int(height_in_feet)) * 12 # Convert the remainder to inches
	$Fullbody/HeightLabel.text = "Height: " + str(player.height) + "cm   " + str(int(height_in_feet)) + "′" + str(round(height_in_inches)) + "″"


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

func _on_BodyPositivity_value_changed(value):
	$Fullbody/label2.text = "Body Positivity: " + str(player.body_positivity * 100)
	player.body_positivity = value / 100
	player.applyBlendShapes()



func breastValueChanged(value) -> void:
	player.breast_size  = -value / 100
	player.applyBlendShapes()
func breastRoundnessValueChanged(value) -> void:
	player.breast_roundness  = value / 100
	player.applyBlendShapes()
func buttocksValueChanged(value) -> void:
	player.buttocks  = value / 100
	player.applyBlendShapes()
func fatValueChanged(value) -> void:
	player.fat  = value / 100
	player.applyBlendShapes()
func muscleValueChanged(value) -> void:
	player.muscle  = value / 100
	player.applyBlendShapes()
	
	

func heightValueChanged(value) -> void:
	player.height = value  
	player.editHeight()



func smileValueChanged(value) -> void:
	player.smile  = value / 100
	player.applyBlendShapes()


var skin_melanin_value: float = 0.0

func skinMelaninChanged(value: float) -> void:
	skin_melanin_value = value
	var base_color = Color(1.0, 1.0, 1.0) # White as base color
	var darkening_color = Color(77 / 255.0, 65 / 255.0, 48 / 255.0) # Red 77, Green 65, Blue 48
	var factor = value / 100.0

	for child in player.skeleton.get_children():
		if child is MeshInstance and child.name.find("Eye") == -1 and child.name.find("Hair") == -1:
			var mesh = child.mesh
			if mesh and mesh.get_surface_count() > 0:
				var material = mesh.surface_get_material(0) # First material surface
				if material and material is ShaderMaterial:
					var final_color = base_color.linear_interpolate(darkening_color, factor)
					material.set_shader_param("albedo", final_color)


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

