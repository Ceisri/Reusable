extends Control

onready var species_button: TextureButton = $SpeciesButtonHolder/button
onready var sex_button: TextureButton = $SexButtonHolder/button
onready var gender_button: TextureButton = $GenderButtonHolder/button

onready var randomize_name_button: TextureButton = $RandomizeName/button
onready var species_label: Label = $SpeciesButtonHolder/label
onready var sex_label: Label = $SexButtonHolder/label
onready var sex_label_2: Label = $SexLabel
onready var gender_label: Label = $GenderLabel
onready var character_name_line_edit: LineEdit = $LineEdit
onready var avatar_icon: TextureRect = $Portrait/Avatar

var sex_list: Array = Autoload.sexes
var gender_list: Array = ["Male", "Female", "Other"] 
var species_list: Array = Autoload.species  # List of species from Autoload
var current_sex_index: int = 0
var current_species_index: int = 0
var selected_sex: String  # Will store both gender and chromosome info
var selected_species: String  
var selected_gender: String = "Female"  # Default gender

func _ready() -> void:
	sex_button.connect("pressed", self, "onSexButtonPressed")
	gender_button.connect("pressed", self, "onGenderButtonPressed")
	species_button.connect("pressed", self, "onSpeciesButtonPressed")
	randomize_name_button.connect("pressed", self, "changeNameBasedOnSex")
	# Set default genes to "XX" Female and species to the first in the list or "Unknown"
	selected_sex = "XX Female"
	selected_gender = "Female"
	if species_list.size() > 0:
		selected_species = species_list[0]
	else:
		selected_species = "Unknown"
	updateLabels()
	updatePortrait()
	switchMeshBasedOnSex()

onready var mesh_container: Node = $"../MeshContainer"
var human_male:PackedScene = load("res://Game/World/Player/Models/Sex_Species_Meshes/MaleHuman.tscn")
var human_female:PackedScene = load("res://Game/World/Player/Models/Sex_Species_Meshes/FemaleHuman.tscn")


func switchMeshBasedOnSex() -> void:
	var scene_to_instance: PackedScene = null
	
	if selected_sex.find("Female") != -1:
		scene_to_instance = human_female
	elif selected_sex.find("Male") != -1:
		scene_to_instance = human_male
	else:
		print("Selected sex not recognized. No mesh will be instantiated.")
		return

	# Remove any existing mesh
	for child in mesh_container.get_children():
		child.queue_free()
	
	# Instance the correct mesh
	if scene_to_instance:
		var instance = scene_to_instance.instance()
		mesh_container.add_child(instance)
		
		
		
func onSexButtonPressed() -> void:
	
	switchSex()
	switchMeshBasedOnSex()
	changeNameBasedOnSex()
	updatePortrait()



func onGenderButtonPressed() -> void:
	switchGender()
	changeNameBasedOnSex()

func onSpeciesButtonPressed() -> void:
	switchSpecies()
	updatePortrait()

func changeNameBasedOnSex() -> void:
	var names_list: Array = []

	# Determine which names list to use based on the relationship between selected_gender and selected_sex
	var gender_part = sex_label_2.text.split(": ")[1]
	if selected_gender == gender_part:  # Match based on visible part
		# Match genders to sex-based names
		if selected_sex.find("Female") != -1:
			names_list = Autoload.names_X
		elif selected_sex.find("Male") != -1:
			names_list = Autoload.names_Y
		elif selected_sex.find("Mosaic") != -1:
			names_list = Autoload.names_X + Autoload.names_Y
		else:
			names_list = []
	else:
		# Mismatch, use gender-based names
		if selected_gender == "Female":
			names_list = Autoload.names_X
		elif selected_gender == "Male":
			names_list = Autoload.names_Y
		elif selected_gender == "Other":
			names_list = Autoload.names_X + Autoload.names_Y
		else:
			names_list = []

	# Select a random name from the appropriate list
	if names_list.size() > 0:
		var random_index = randi() % names_list.size()
		var random_name = names_list[random_index]
		character_name_line_edit.text = random_name
	else:
		character_name_line_edit.text = ""

func switchSex() -> void:
	if sex_list.size() > 0:
		current_sex_index = (current_sex_index + 1) % sex_list.size()
		updateLabels()

func switchGender() -> void:
	if gender_list.size() > 0:
		var current_index = gender_list.find(selected_gender)
		var next_index = (current_index + 1) % gender_list.size()
		selected_gender = gender_list[next_index]
		updateLabels()

func switchSpecies() -> void:
	if species_list.size() > 0:
		current_species_index = (current_species_index + 1) % species_list.size()
		selected_species = species_list[current_species_index]
		updateLabels()



func updateLabels() -> void:
	if sex_list.size() > 0:
		var sex_entry = sex_list[current_sex_index]
		if sex_entry:
			var parts = sex_entry.split(" - ")
			if parts.size() > 1:
				var chromosome_part = parts[0].strip_edges()
				var gender_part = parts[1].strip_edges().to_lower().capitalize()
				selected_sex = chromosome_part + " " + gender_part  # Store both chromosome and gender
				sex_label.text = "Genes: " + chromosome_part  # Show chromosome part
				sex_label_2.text = "Sex: " + gender_part  # Show only gender
			else:
				sex_label.text = "Genes: Unknown"
				sex_label_2.text = "Sex: Unknown"
				selected_sex = ""
		else:
			sex_label.text = "Genes: Unknown"
			sex_label_2.text = "Sex: Unknown"
			selected_sex = ""
	
	updateSpeciesLabel()
	updateGenderLabel()

func updateSpeciesLabel() -> void:
	species_label.text =  selected_species

func updateGenderLabel() -> void:
	gender_label.text = "Gender: " + selected_gender

func updatePortrait() -> void:
	match selected_species:
		"Homo Sapiens":
			match selected_sex.split(" ")[1]:  # Extract the gender part
				"Male":
					avatar_icon.texture = load("res://Game/Interface/Assets/Species_Portraits/human male.jpg")
				"Female":
					avatar_icon.texture = load("res://Game/Interface/Assets/Species_Portraits/human female.jpg")
				"Mosaic":
					avatar_icon.texture = load("res://Game/Interface/Assets/Species_Portraits/human mosaic.jpg")
