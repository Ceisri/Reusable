extends TextureRect

var savedTexture : Texture

func _ready():
	loaddata()


func savedata():
	savedTexture = texture
	var parentName = get_parent().get_name()  # Get the name of the parent node
	var savePath = "user://" + parentName + "_saved_texture_data.txt"  # Construct the save path based on parent name
	var file = File.new()
	file.open(savePath, File.WRITE)
	if savedTexture != null:  
		file.store_line(savedTexture.get_path())  
	file.close()

func loaddata():
	var parentName = get_parent().get_name()
	var savePath = "user://" + parentName + "_saved_texture_data.txt"
	var file = File.new()
	if file.file_exists(savePath):
		file.open(savePath, File.READ)
		var path = file.get_line()
		var quantity_str = file.get_line()
		file.close()
		if path != "":
			var loadedTexture = load(path)
			if loadedTexture != null:
				savedTexture = loadedTexture
			else:
				pass
#				print("Failed to load texture from path:", path)
		else:
			pass
#			print("Saved texture path is empty.")
	else:
		pass
#		print("File '", savePath, "' does not exist.")
	
	if savedTexture != null:
		texture = savedTexture

	else:
		pass
#		print("No texture found for icon.")
