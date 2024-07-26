extends Node

onready var world = get_parent().get_parent()
onready var parent = get_parent()
export var size: float = 1
export var save_data_password: String = "123123123123"
export var max_size: float = 3
var time_invisible: int = 0
var max_time_invisible: int = 5
var start_coming_back: bool = false
var growth_rate: float = 0.01  # Slow down the growth rate
var grow_delay: float = 0  # Initialize grow_delay to a default value
var first_encounter: bool = true  # Track if the player has encountered the plant before

func _ready() -> void:
	parent.add_to_group("Resource")
	parent.add_to_group("BlueTip")
	parent.add_to_group("Plant")
	loadData()
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 12 == 0:
		if time_invisible > 0:
			time_invisible -= 1 
		else:
			parent.show()
			parent.get_node("CollisionShape").disabled = false
			if size < max_size:
				size += growth_rate
				parent.scale = Vector3(size, size, size)
			elif size >= max_size:
				set_physics_process(false)


# Call this function when the player goes too far away
func playerLeft()-> void:
	set_physics_process(false)

# Call this function when the player comes back
func playerBack()-> void:
	if not first_encounter:
		start_coming_back = true
	else:
		first_encounter = false  # Mark that the player has encountered the plant
	set_physics_process(true)

export var entity_name: String = "Blue Tip Grass"
export var species: String = "Grass"

func saveData() -> void:
	var save_directory: String = "user://Worlds/" + world.world_name + "/" + species + "/" + entity_name + "/" + str(name) + "/" 
	var save_path: String = save_directory + "/save.dat"
	var data = {
		"size": size,
		"first_encounter": first_encounter,
	}
	var dir = Directory.new()
	if not dir.dir_exists(save_directory):
		dir.make_dir_recursive(save_directory)
	var file = File.new()
	var error = file.open_encrypted_with_pass(save_path, File.WRITE, save_data_password)
	if error == OK:
		file.store_var(data)
		file.close()

func loadData() -> void:
	var save_directory: String = "user://Worlds/" + world.world_name + "/" + species + "/" + entity_name + "/" + str(name) + "/" 
	var save_path: String = save_directory + "/save.dat"
	
	var file = File.new()
	if file.file_exists(save_path):
		var error = file.open_encrypted_with_pass(save_path, File.READ, save_data_password)
		if error == OK:
			var data_file = file.get_var()
			file.close()
			if "size" in data_file:
				size = data_file["size"]
			if "first_encounter" in data_file:
				first_encounter = data_file["first_encounter"]
			# Correct scale application after loading
			parent.scale = Vector3(abs(size), abs(size), abs(size))
