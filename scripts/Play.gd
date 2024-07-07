extends CanvasLayer

onready var create_new_world_button:Button = $Control/CreateNewWorld
onready var world_name_line_edit:LineEdit = $Control/EnterWorldName
onready var world_list_grid:GridContainer = $Control/WorldList
var enter_saved_world_button = load("res://Game/Interface/Scenes/WorldButton.tscn")

onready var create_new_character_button:Button = $Control/CreateCharacter
onready var character_name_line_edit:LineEdit = $Control/EnterCharName
onready var character_list_grid:GridContainer = $Control/CharList
var enter_saved_character_button = load("res://Game/Interface/Scenes/WorldButton.tscn")

var selected_player

# List to keep track of loaded characters
var loaded_characters := []

func _ready():
	loadWorlds()
	loadCharacters()
	create_new_world_button.connect("pressed", self, "_on_create_new_world_button_pressed")
	create_new_character_button.connect("pressed", self, "_on_create_new_character_button_pressed")

#func _physics_process(delta: float) -> void:
#	if Engine.get_physics_frames() % 66 == 0:
#		saveWorlds()
#		saveCharacters()

func _on_create_new_world_button_pressed():
	var world_name = world_name_line_edit.text
	if world_name != "":
		createWorld(world_name)
		addWorldToList(world_name)
		world_name_line_edit.clear()

func createWorld(world_name: String):
	var world_directory = "user://WorldList/" + world_name
	var dir = Directory.new()
	if dir.dir_exists(world_directory):
		print("World already exists")
	else:
		dir.make_dir_recursive(world_directory)
		var save_file = File.new()
		save_file.open(world_directory + "/save.dat", File.WRITE)
		save_file.store_line("World name: " + world_name)
		save_file.close()
		print("World created: " + world_name)

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
	var world_button = enter_saved_world_button.instance()
	world_button.text = world_name
	world_button.connect("pressed", self, "_on_world_button_pressed", [world_name])
	world_list_grid.add_child(world_button)

var world:PackedScene = load("res://Game/World/Map/World.tscn")
var player:PackedScene = load("res://Game/World/Player/Scenes/Player.tscn")
func _on_world_button_pressed(world_name: String):
	if selected_player == null:
		print("Please select a player")
	else:
		var world_instance = world.instance()
		world_instance.world_name = world_name
		Root.add_child(world_instance)
		var player_instance = player.instance()
		player_instance.entity_name = selected_player
		world_instance.add_child(player_instance)
		print("Entered world: " + world_name)
		queue_free()

func _on_create_new_character_button_pressed():
	var character_name = character_name_line_edit.text
	if character_name != "":
		createCharacter(character_name)
		addCharacterToList(character_name)
		character_name_line_edit.clear()

func createCharacter(character_name: String):
	var character_directory = "user://Characters/" + character_name
	var dir = Directory.new()

	dir.make_dir_recursive(character_directory)
	var save_file = File.new()
	save_file.open(character_directory + "/save.dat", File.WRITE)
	save_file.store_line("Character name: " + character_name)
	save_file.close()
	print("Character created: " + character_name)

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



func addCharacterToList(character_name: String):
	var character_directory = "user://Characters/" + character_name
	var save_file_path = character_directory + "/save.dat"
	
	var file = File.new()
	if file.file_exists(save_file_path):
		var error = file.open(save_file_path, File.READ)
		if error == OK:
			var character_data = file.get_as_text()
			file.close()
			
			var character_button = enter_saved_character_button.instance()
			character_button.text = character_name
			character_button.connect("pressed", self, "_on_character_button_pressed", [character_name])
			
			var delete_button = Button.new()
			delete_button.text = "Delete"
			delete_button.connect("pressed", self, "_on_DeleteChar_pressed", [character_name, character_button])
			
			var hbox = HBoxContainer.new()
			hbox.add_child(character_button)
			hbox.add_child(delete_button)
			
			character_list_grid.add_child(hbox)
		else:
			print("Failed to open file: " + save_file_path + ", Error: " + str(error))
	else:
		print("Save file not found: " + save_file_path)


func _on_character_button_pressed(character_name: String):
	selected_player = character_name
	print("Selected character: " + character_name)
	# Implement logic to select the character, such as setting up the game state for the character

func _on_DeleteChar_pressed(character_name: String, character_button: Button):
	character_list_grid.remove_child(character_button.get_parent())  # Remove UI element
	character_button.get_parent().queue_free()  # Free UI element from memory
	resetCharacterData(character_name)  # Reset character data (remove from file system)

func resetCharacterData(character_name: String):
	var path = "user://Characters/" + character_name + "/save.dat"
	var dir = Directory.new()
	if dir.file_exists(path):
		dir.remove(path)
		print("Saved data reset")
	loaded_characters.erase(character_name)  # Remove from loaded characters list

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
