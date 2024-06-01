extends TextureRect

var player 
var savedTexture : Texture
var points: int = 0

func savedata():
	savedTexture = texture
	var parentName = get_parent().get_name()  # Get the name of the parent node
	var savePath = player.save_directory + "/" + parentName + "_saved_texture_data.txt"  # Construct the save path based on parent name
	var file = File.new()
	file.open(savePath, File.WRITE)
	if savedTexture != null:
		file.store_line(savedTexture.get_path())  # Store the texture path
	file.store_line(str(points))  # Store the points as a string
	file.close()

func loaddata():
	var parentName = get_parent().get_name()
	var savePath = player.save_directory + "/" + parentName + "_saved_texture_data.txt"
	var file = File.new()
	if file.file_exists(savePath):
		file.open(savePath, File.READ)
		var path = file.get_line()
		var points_str = file.get_line()
		file.close()
		if path != "":
			var loadedTexture = load(path)
			if loadedTexture != null:
				savedTexture = loadedTexture
		if points_str != "":
			points = int(points_str)
	
	if savedTexture != null:
		texture = savedTexture
	# Ensure points is loaded properly (this line is technically redundant since points is already set above)


