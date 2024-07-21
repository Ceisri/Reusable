extends Control

onready var menu_button: TextureButton = $Keybind1/button
onready var menu_label: Label = $Keybind1/label
var capturing_input_menu = false

onready var inventory_button: TextureButton = $Keybind2/button
onready var inventory_label: Label = $Keybind2/label
var capturing_input_inventory = false

onready var loot_button: TextureButton = $Keybind3/button
onready var loot_label: Label = $Keybind3/label
var capturing_input_loot = false

onready var skills_button: TextureButton = $Keybind4/button
onready var skills_label: Label = $Keybind4/label
var capturing_input_skills = false

const CONFIG_FILE_PATH = "user://general_keybinds.cfg" # Path to the configuration file

func _ready() -> void:
	load_keybinds()
	connect_buttons()

func connect_buttons() -> void:
	menu_button.connect("pressed", self, "menu_pressed")
	inventory_button.connect("pressed", self, "inventory_pressed")
	loot_button.connect("pressed", self, "loot_pressed")
	skills_button.connect("pressed", self, "skills_pressed")

func menu_pressed() -> void:
	capturing_input_menu = true
	menu_label.text = "Open menu:\n..."

func inventory_pressed() -> void:
	capturing_input_inventory = true
	inventory_label.text = "Open inventory:\n..."

func loot_pressed() -> void:
	capturing_input_loot = true
	loot_label.text = "Open loot:\n..."

func skills_pressed() -> void:
	capturing_input_skills = true
	skills_label.text = "Open skills:\n..."

func _input(event: InputEvent) -> void:
	if capturing_input_menu:
		handle_input_event(event, "Menu", menu_label)
	elif capturing_input_inventory:
		handle_input_event(event, "Inventory", inventory_label)
	elif capturing_input_loot:
		handle_input_event(event, "Loot", loot_label)
	elif capturing_input_skills:
		handle_input_event(event, "Skills", skills_label)

func handle_input_event(event: InputEvent, action_name: String, label: Label) -> void:
	if event is InputEventKey:
		var new_key = event.scancode
		var input_event = InputEventKey.new()
		input_event.scancode = new_key
		
		# Update the key binding
		if action_name == "Menu":
			label.text = "Open menu:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Inventory":
			label.text = "Open inventory:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Loot":
			label.text = "Open loot:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Skills":
			label.text = "Open skills:\n" + OS.get_scancode_string(new_key)

		# Remove all existing bindings for the action
		InputMap.action_erase_events(action_name)
		
		# Add the new key binding
		InputMap.action_add_event(action_name, input_event)
		
		if action_name == "Menu":
			capturing_input_menu = false
		elif action_name == "Inventory":
			capturing_input_inventory = false
		elif action_name == "Loot":
			capturing_input_loot = false
		elif action_name == "Skills":
			capturing_input_skills = false

		save_keybinds()

func save_keybinds() -> void:
	var config = ConfigFile.new()
	config.set_value("Keybinds", "Menu", InputMap.get_action_list("Menu"))
	config.set_value("Keybinds", "Inventory", InputMap.get_action_list("Inventory"))
	config.set_value("Keybinds", "Loot", InputMap.get_action_list("Loot"))
	config.set_value("Keybinds", "Skills", InputMap.get_action_list("Skills"))
	
	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		print("Error saving keybinds:", error)

func load_keybinds() -> void:
	var config = ConfigFile.new()
	var error = config.load(CONFIG_FILE_PATH)
	if error == OK:
		# Clear all existing bindings before adding loaded keybinds
		InputMap.action_erase_events("Menu")
		InputMap.action_erase_events("Inventory")
		InputMap.action_erase_events("Loot")
		InputMap.action_erase_events("Skills")

		load_keybind("Menu", config)
		load_keybind("Inventory", config)
		load_keybind("Loot", config)
		load_keybind("Skills", config)

		# Set the label text to the currently assigned key for the actions
		var menu_key = InputMap.get_action_list("Menu")[0].scancode if InputMap.has_action("Menu") else 0
		var inventory_key = InputMap.get_action_list("Inventory")[0].scancode if InputMap.has_action("Inventory") else 0
		var loot_key = InputMap.get_action_list("Loot")[0].scancode if InputMap.has_action("Loot") else 0
		var skills_key = InputMap.get_action_list("Skills")[0].scancode if InputMap.has_action("Skills") else 0

		# Set default keybinds if no saved keybinds are found
		if menu_key == 0:
			menu_key = KEY_O
			var menu_event = InputEventKey.new()
			menu_event.scancode = menu_key
			InputMap.action_add_event("Menu", menu_event)
		if inventory_key == 0:
			inventory_key = KEY_I
			var inventory_event = InputEventKey.new()
			inventory_event.scancode = inventory_key
			InputMap.action_add_event("Inventory", inventory_event)
		if loot_key == 0:
			loot_key = KEY_L
			var loot_event = InputEventKey.new()
			loot_event.scancode = loot_key
			InputMap.action_add_event("Loot", loot_event)
		if skills_key == 0:
			skills_key = KEY_K
			var skills_event = InputEventKey.new()
			skills_event.scancode = skills_key
			InputMap.action_add_event("Skills", skills_event)

		menu_label.text = "Open menu:\n" + OS.get_scancode_string(menu_key)
		inventory_label.text = "Open inventory:\n" + OS.get_scancode_string(inventory_key)
		loot_label.text = "Open loot:\n" + OS.get_scancode_string(loot_key)
		skills_label.text = "Open skills:\n" + OS.get_scancode_string(skills_key)

	else:
		print("Error loading keybinds:", error)

func load_keybind(action_name: String, config: ConfigFile) -> void:
	var keybinds = config.get_value("Keybinds", action_name, [])
	for keybind in keybinds:
		InputMap.action_add_event(action_name, keybind)
	var key_name = OS.get_scancode_string(keybinds[0].scancode) if keybinds else "Unknown"
