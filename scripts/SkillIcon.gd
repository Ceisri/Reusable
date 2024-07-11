extends TextureRect

onready var player:KinematicBody =   $"../../../../.."
var savedTexture : Texture
var savedQuantity : int

func _ready():
	loadData()



func saveData():
	savedTexture = texture
	savedQuantity = get_parent().quantity  # Save the quantity of the parent
	var parentName = get_parent().get_name()  # Get the name of the parent node
	var savePath = player.save_directory +"/"+ parentName + "saved_player_skill.txt"  # Construct the save path based on parent name
	var file = File.new()
	file.open(savePath, File.WRITE)
	if savedTexture != null:
		file.store_line(savedTexture.get_path())  # Store the texture path
		file.store_line(str(savedQuantity))  # Store the quantity as a string
	file.close()

func loadData():
	var parentName = get_parent().get_name()
	var savePath = player.save_directory +"/"+ parentName + "saved_player_skill.txt"
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
				savedQuantity = int(quantity_str)
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
		get_parent().quantity = savedQuantity
	else:
		pass


