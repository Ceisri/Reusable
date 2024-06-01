extends Control

onready var player_scene: PackedScene = preload("res://player/Player.tscn")
onready var slot1: Button = $Slot1
onready var slot2: Button = $Slot2
onready var slot3: Button = $Slot3
onready var slot4: Button = $Slot4

onready var delete1: Button = $Delete1
onready var delete2: Button = $Delete2
onready var delete3: Button = $Delete3
onready var delete4: Button = $Delete4

func _ready():
	slot1.connect("pressed", self, "createOrPlay1")
	slot2.connect("pressed", self, "createOrPlay2")
	slot3.connect("pressed", self, "createOrPlay3")
	slot4.connect("pressed", self, "createOrPlay4")
	delete1.connect("pressed", self, "delete1")
	delete2.connect("pressed", self, "delete2")
	delete3.connect("pressed", self, "delete3")
	delete4.connect("pressed", self, "delete4")
func createOrPlay1():
	var player_instance = player_scene.instance()
	player_instance.save_directory = "user://player1"
	player_instance.save_path = player_instance.save_directory + "/SavedVariables.dat"
	get_parent().add_child(player_instance)
	queue_free()
func createOrPlay2():
	var player_instance = player_scene.instance()
	player_instance.save_directory = "user://player2"
	player_instance.save_path = player_instance.save_directory + "/SavedVariables.dat"
	get_parent().add_child(player_instance)
	queue_free()
func createOrPlay3():
	var player_instance = player_scene.instance()
	player_instance.save_directory = "user://player3"
	player_instance.save_path = player_instance.save_directory + "/SavedVariables.dat"
	get_parent().add_child(player_instance)
	queue_free()
func createOrPlay4():
	var player_instance = player_scene.instance()
	player_instance.save_directory = "user://player4"
	player_instance.save_path = player_instance.save_directory + "/SavedVariables.dat"
	get_parent().add_child(player_instance)
	queue_free()

func findDestroyFile(path):
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				dir.remove(file_name) # Corrected line to remove the file 
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")

func delete1():
	findDestroyFile("user://player1")
func delete2():
	findDestroyFile("user://player2")
func delete3():
	findDestroyFile("user://player3")
func delete4():
	findDestroyFile("user://player4")
