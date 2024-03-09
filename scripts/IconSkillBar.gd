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
	var parentName = get_parent().get_name()  # Get the name of the parent node
	var savePath = "user://" + parentName + "_saved_texture_data.txt"  # Construct the save path based on parent name
	
	var file = File.new()
	if file.file_exists(savePath):
		file.open(savePath, File.READ)
		var path = file.get_line()
		file.close()
		if path != "":
			var loadedTexture = load(path)
			if loadedTexture != null:  
				savedTexture = loadedTexture
			else:
				print("Failed to load texture from path:", path)
		else:
			print("Saved texture path is empty.")
	else:
		print("File '", savePath, "' does not exist.")
	
	savedTexture = savedTexture if savedTexture != null else Texture.new()
	texture = savedTexture
