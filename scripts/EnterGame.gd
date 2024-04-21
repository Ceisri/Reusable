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
	player_instance.save_path = SAVE_DIR + "1save.dat"
	get_parent().add_child(player_instance)
	queue_free()
func createOrPlay2():
	var player_instance = player_scene.instance()
	player_instance.save_path = SAVE_DIR + "2save.dat"
	get_parent().add_child(player_instance)
	queue_free()
func createOrPlay3():
	var player_instance = player_scene.instance()
	player_instance.save_path = SAVE_DIR + "3save.dat"
	get_parent().add_child(player_instance)
	queue_free()
func createOrPlay4():
	var player_instance = player_scene.instance()
	player_instance.save_path = player_instance.SAVE_DIR + "4save.dat"
	get_parent().add_child(player_instance)
	queue_free()
	
	
const SAVE_DIR: String = "user://saves/"

func delete1():
	var player_instance = player_scene.instance()
	var dir = Directory.new()
	var save_path = SAVE_DIR + "1save.dat"
	if dir.file_exists(save_path):
		var error = dir.remove(save_path)
		if error == OK:
			print("Saved data reset")
		else:
			print("Error resetting saved data:", error)
	else:
		print("Saved data does not exist")
func delete2():
	var player_instance = player_scene.instance()
	var dir = Directory.new()
	var save_path = SAVE_DIR + "2save.dat"
	if dir.file_exists(save_path):
		var error = dir.remove(save_path)
		if error == OK:
			print("Saved data reset")
		else:
			print("Error resetting saved data:", error)
	else:
		print("Saved data does not exist")
func delete3():
	var player_instance = player_scene.instance()
	var dir = Directory.new()
	var save_path = SAVE_DIR + "3save.dat"
	if dir.file_exists(save_path):
		var error = dir.remove(save_path)
		if error == OK:
			print("Saved data reset")
		else:
			print("Error resetting saved data:", error)
	else:
		print("Saved data does not exist")
func delete4():
	var player_instance = player_scene.instance()
	var dir = Directory.new()
	var save_path = SAVE_DIR + "4save.dat"
	if dir.file_exists(save_path):
		var error = dir.remove(save_path)
		if error == OK:
			print("Saved data reset")
		else:
			print("Error resetting saved data:", error)
	else:
		print("Saved data does not exist")
