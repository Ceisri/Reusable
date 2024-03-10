extends TextureRect


var savedTexture : Texture
var savedQuantity : int

func _ready():
	loaddata()



func savedata():
	savedTexture = texture
	savedQuantity = get_parent().quantity  # Save the quantity of the parent
	var parentName = get_parent().get_name()  # Get the name of the parent node
	var savePath = "user://" + parentName + "_saved_texture_data.txt"  # Construct the save path based on parent name
	var file = File.new()
	file.open(savePath, File.WRITE)
	if savedTexture != null:
		file.store_line(savedTexture.get_path())  # Store the texture path
		file.store_line(str(savedQuantity))  # Store the quantity as a string
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
				savedQuantity = int(quantity_str)
			else:
				print("Failed to load texture from path:", path)
		else:
			print("Saved texture path is empty.")
	else:
		print("File '", savePath, "' does not exist.")
	
	if savedTexture != null:
		texture = savedTexture
		get_parent().quantity = savedQuantity
	else:
		print("No texture found for icon.")


#this script won't work unless savadata() for every specific icon is called somewhere
#now I'm using this in a timer on the player script 
#	# Call savedata() function on each child of inventory_grid that belongs to the group "Inventory"
#	for child in inventory_grid.get_children():
#		if child.is_in_group("Inventory"):
#			if child.get_node("Icon").has_method("savedata"):
#				child.get_node("Icon").savedata()
#

