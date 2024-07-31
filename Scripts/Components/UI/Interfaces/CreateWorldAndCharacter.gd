extends CanvasLayer

# Buttons and Inputs for creating worlds and characters
onready var switch_section:TextureButton =  $ChoosePlayerWorld/button
onready var switch_world_name_button:TextureButton = $WorldPart/RandomizeName/button

onready var char_part:Control = $PlayerPart
onready var create_new_world_button:TextureButton =  $WorldPart/CreateWorld/button
onready var world_name_line_edit:LineEdit =  $WorldPart/LineEdit
onready var world_list_grid:GridContainer =   $WorldPart/Scroll/Grid
var button = load("res://Game/Interface/Scenes/Button.tscn")


onready var info_label =  $Control/info
onready var world_part:Control =  $WorldPart
onready var create_new_character_button:TextureButton = $PlayerPart/CreateChar/button
onready var character_name_line_edit:LineEdit =  $PlayerPart/LineEdit
onready var character_list_grid:GridContainer = $PlayerPart/Scroll/Grid

onready var sex_button:TextureButton = $PlayerPart/SexButtonHolder/button
onready var sex_label:Label = $PlayerPart/SexButtonHolder/label
onready var sex_label2:Label = $PlayerPart/SexLabel
var sex_list:Array = Autoload.sexes
var current_sex_index:int = 0

var selected_player

# List to keep track of loaded characters
var loaded_characters := []

func _ready():
	char_part.visible = true
	world_part.visible = false
	loadWorlds()
	loadCharacters()
	switch_section.connect("pressed", self, "switchSection")
	create_new_world_button.connect("pressed", self, "_on_create_new_world_button_pressed")
	create_new_character_button.connect("pressed", self, "_on_create_new_character_button_pressed")
	sex_button.connect("pressed", self, "switchSex")
	switch_world_name_button.connect("pressed",self, "switchWorldName")
	

onready var random_info_label:Label = $Control/RandomInfo
func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 80 == 0:
		Autoload.randomizeInfo(random_info_label)


func switchSection()-> void:
	char_part.visible = !char_part.visible
	world_part.visible = !world_part.visible
	if char_part.visible:
		 $ChoosePlayerWorld/label.text = "Choose World"
	else:
		 $ChoosePlayerWorld/label.text = "Choose Character"
	

func _on_create_new_world_button_pressed():
	var world_name = world_name_line_edit.text
	if world_name != "":
		createWorld(world_name)
		addWorldToList(world_name)
		world_name_line_edit.clear()
		
func switchWorldName()-> void:
		Autoload.changeWorldName(world_name_line_edit)

func createWorld(world_name: String):
	var world_directory = "user://WorldList/" + world_name
	var dir = Directory.new()
	if dir.dir_exists(world_directory):
		info_label.text = "World already exists"
	else:
		dir.make_dir_recursive(world_directory)
		var save_file = File.new()
		save_file.open(world_directory + "/save.dat", File.WRITE)
		save_file.store_line("World name: " + world_name)
		save_file.close()
		info_label.text = "World created:" + world_name

func loadWorlds():
	var world_directory = "user://WorldList/"
	var dir = Directory.new()
	if dir.dir_exists(world_directory):
		dir.open(world_directory)
		dir.list_dir_begin()
		var world_name = dir.get_next()
		while world_name != "":
			if dir.current_is_dir() and world_name != "." and world_name != "..":
				addWorldToList(world_name)
			world_name = dir.get_next()
		dir.list_dir_end()

func addWorldToList(world_name: String):
	var button_scene = load("res://Game/Interface/Scenes/Button.tscn")
	
	# World Button
	var world_button = button_scene.instance()
	world_button.get_node("label").text = world_name
	world_button.get_node("button").connect("pressed", self, "_on_world_button_pressed", [world_name])
	
	# Delete Button
	var delete_button = button_scene.instance()
	delete_button.get_node("label").text = "Delete"
	delete_button.get_node("button").connect("pressed", self, "deleteWorld", [world_name, delete_button])

	var hbox = HBoxContainer.new()
	hbox.add_child(world_button)
	hbox.add_child(delete_button)
	
	world_list_grid.add_child(hbox)



func deleteWorld(world_name: String, delete_button: Control):
	if delete_press_count.has(world_name):
		delete_press_count[world_name] += 1
	else:
		delete_press_count[world_name] = 1

	if delete_press_count[world_name] >= 6:  # Replace '3' with the desired number of presses
		var hbox = delete_button.get_parent()
		world_list_grid.remove_child(hbox)
		hbox.queue_free()
		resetWorldData(world_name)  # Reset world data (remove from file system)
		delete_press_count.erase(world_name)
	else:
		# Optionally, provide feedback to the user about remaining presses
		info_label.text = "Press " + str(6 - delete_press_count[world_name]) + " more times to delete."


var world:PackedScene = load("res://Game/World/Map/World.tscn")
var player:PackedScene = load("res://Game/World/Player/Scenes/Player.tscn")
func _on_world_button_pressed(world_name: String):
	if selected_player == null:
		info_label.text = "Please select a player"
	else:
		info_label.text ="Entered world: " + world_name
		var world_instance = world.instance()
		world_instance.world_name = world_name
		Root.add_child(world_instance)
		var player_instance = player.instance()
		player_instance.entity_name = selected_player
		player_instance.species =  char_part.selected_species
		player_instance.sex =  char_part.selected_sex
		player_instance.gender =  char_part.selected_gender


		world_instance.add_child(player_instance)
		queue_free()

func _on_create_new_character_button_pressed():
	var character_name = character_name_line_edit.text
	if character_name != "":
		createCharacter(character_name)
		addCharacterToList(character_name)
		char_part.changeNameBasedOnSex()




		
func createCharacter(character_name: String):
	var character_directory = "user://Characters/" + character_name
	var dir = Directory.new()

	dir.make_dir_recursive(character_directory)
	var save_file = File.new()
	save_file.open(character_directory + "/save.dat", File.WRITE)
	save_file.store_line("Character name: " + character_name)
	save_file.close()
	info_label.text = "Character created: " + character_name 

func loadCharacters():
	for child in character_list_grid.get_children():
		child.queue_free()
	loaded_characters.clear()
	var character_directory = "user://Characters/"
	var dir = Directory.new()
	if dir.dir_exists(character_directory):
		dir.open(character_directory)
		dir.list_dir_begin()
		var character_name = dir.get_next()
		while character_name != "":
			if dir.current_is_dir() and character_name != "." and character_name != "..":
				addCharacterToList(character_name)
			character_name = dir.get_next()
		dir.list_dir_end()
		
		
# Keep track of the presses for deletion
var delete_press_count = {}
func addCharacterToList(character_name: String):
	var character_directory = "user://Characters/" + character_name
	var save_file_path = character_directory + "/save.dat"
	
	var file = File.new()
	if file.file_exists(save_file_path):
		var error = file.open(save_file_path, File.READ)
		if error == OK:
			var character_data = file.get_as_text()
			file.close()
			
			var button_scene = load("res://Game/Interface/Scenes/Button.tscn")
			
			# Character Button
			var character_button = button_scene.instance()
			character_button.get_node("label").text = character_name
			character_button.get_node("button").connect("pressed", self, "selectCharacter", [character_name])
			
			# Delete Button
			var delete_button = button_scene.instance()
			delete_button.get_node("label").text = "Delete"
			delete_button.get_node("button").connect("pressed", self, "deleteCharacter", [character_name, delete_button])
			
			var hbox = HBoxContainer.new()
			hbox.add_child(character_button)
			hbox.add_child(delete_button)
			
			character_list_grid.add_child(hbox)
			
			# Initialize press count for this character
			delete_press_count[character_name] = 0
		else:
			info_label.text = "Failed to open file: " + save_file_path + ", Error: " + str(error)
	else:
		info_label.text = "Save file not found: " + save_file_path

func deleteCharacter(character_name: String, delete_button: Control):
	if not delete_press_count.has(character_name):
		return
	# Increment press count
	delete_press_count[character_name] += 1
	
	if delete_press_count[character_name] >= 3:
		# Proceed with deletion
		var hbox = delete_button.get_parent()
		character_list_grid.remove_child(hbox)
		hbox.queue_free()
		resetCharacterData(character_name)  # Reset character data (remove from file system)
		delete_press_count.erase(character_name)  # Remove press count for the deleted character
	else:
		# Optionally, provide feedback to the user about remaining presses
		info_label.text = "Press " + str(3 - delete_press_count[character_name]) + " more times to delete."

	
	
func selectCharacter(character_name: String):
	selected_player = character_name
	info_label.text = "Selected character: " + character_name



func resetCharacterData(character_name: String):
	var path = "user://Characters/" + character_name
	remove_recursive_absolute(path)
	OS.move_to_trash(path)
	info_label.text ="Character data reset for: " + character_name


func resetWorldData(world_name: String):
	var path = "user://WorldList/" + world_name
	var path2 = "user://Worlds/" + world_name
	remove_recursive_absolute(path)
	remove_recursive_absolute(path2)
	OS.move_to_trash(path)
	OS.move_to_trash(path2)
	info_label.text = "World data reset for: " + world_name

func remove_recursive_absolute(path: String) -> void:
	var dir = Directory.new()
	if dir.dir_exists(path):
		dir.open(path)
		dir.list_dir_begin()
		var name = dir.get_next()
		while name != "":
			if dir.current_is_dir() and name != "." and name != "..":
				remove_recursive_absolute(path.plus_file(name))
			elif dir.file_exists(path.plus_file(name)):
				dir.remove(path.plus_file(name))
			name = dir.get_next()
		dir.list_dir_end()
		dir.remove(path)
	else:
		info_label.text = "Directory does not exist: " + path

func saveWorlds():
	var world_directory = "user://WorldList/"
	var dir = Directory.new()
	if dir.dir_exists(world_directory):
		dir.open(world_directory)
		dir.list_dir_begin()
		var world_name = dir.get_next()
		while world_name != "":
			if dir.current_is_dir() and world_name != "." and world_name != "..":
				var save_file = File.new()
				save_file.open(world_directory + "/" + world_name + "/save.dat", File.WRITE)
				save_file.store_line("World name: " + world_name)
				save_file.close()
			world_name = dir.get_next()
		dir.list_dir_end()

func saveCharacters():
	var character_directory = "user://Characters/"
	var dir = Directory.new()
	if dir.dir_exists(character_directory):
		dir.open(character_directory)
		dir.list_dir_begin()
		var character_name = dir.get_next()
		while character_name != "":
			if dir.current_is_dir() and character_name != "." and character_name != "..":
				var save_file = File.new()
				save_file.open(character_directory + "/" + character_name + "/save.dat", File.WRITE)
				save_file.store_line("Character name: " + character_name)
				save_file.close()
			character_name = dir.get_next()
		dir.list_dir_end()
