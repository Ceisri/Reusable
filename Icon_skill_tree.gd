extends TextureRect


onready var player = $"../../../../../.."


var points: int = 0

func savedata():
	var parentName = get_parent().get_name()  # Get the name of the parent node
	var skill_tree_name = get_parent().get_parent().get_name()
	var savePath = player.save_directory + "/" + skill_tree_name + parentName + "_saved_points_data.txt"  # Construct the save path based on parent name
	var file = File.new()
	file.open(savePath, File.WRITE)
	file.store_line(str(points))  # Store the points as a string
	file.close()

func loaddata():
	var parentName = get_parent().get_name()
	var skill_tree_name = get_parent().get_parent().get_name()
	var savePath =  player.save_directory + "/" + skill_tree_name + parentName + "_saved_points_data.txt"
	var file = File.new()
	if file.file_exists(savePath):
		file.open(savePath, File.READ)
		var points_str = file.get_line()
		file.close()
		if points_str != "":
			points = int(points_str)
