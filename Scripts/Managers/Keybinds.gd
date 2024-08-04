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

onready var esc_button: TextureButton = $Keybind5/button
onready var esc_label: Label = $Keybind5/label
var capturing_input_esc = false

onready var front_button: TextureButton = $Keybind6/button
onready var front_label: Label = $Keybind6/label
var capturing_input_front = false

onready var back_button: TextureButton = $Keybind7/button
onready var back_label: Label = $Keybind7/label
var capturing_input_back = false

onready var left_button: TextureButton = $Keybind8/button
onready var left_label: Label = $Keybind8/label
var capturing_input_left = false

onready var right_button: TextureButton = $Keybind9/button
onready var right_label: Label = $Keybind9/label
var capturing_input_right = false

onready var jump_button: TextureButton = $Keybind10/button
onready var jump_label: Label = $Keybind10/label
var capturing_input_jump = false


onready var sprint_button: TextureButton = $Keybind11/button
onready var sprint_label: Label = $Keybind11/label
var capturing_input_sprint = false

onready var run_button: TextureButton = $Keybind12/button
onready var run_label: Label = $Keybind12/label
var capturing_input_run = false

onready var crouch_button: TextureButton = $Keybind13/button
onready var crouch_label: Label = $Keybind13/label
var capturing_input_crouch = false

onready var crawl_button: TextureButton = $Keybind14/button
onready var crawl_label: Label = $Keybind14/label
var capturing_input_crawl = false

const CONFIG_FILE_PATH = "user://general_keybinds.cfg" # Path to the configuration file

func _ready() -> void:
	load_keybinds()
	connect_buttons()

func connect_buttons() -> void:
	menu_button.connect("pressed", self, "menuPressed")
	inventory_button.connect("pressed", self, "inventoryPressed")
	loot_button.connect("pressed", self, "lootPressed")
	skills_button.connect("pressed", self, "skillsPressed")
	esc_button.connect("pressed", self, "escPressed")
	front_button.connect("pressed", self, "frontPressed")
	back_button.connect("pressed", self, "backPressed")
	left_button.connect("pressed", self, "leftPressed")
	right_button.connect("pressed", self, "rightPressed")
	jump_button.connect("pressed", self, "jumpPressed")
	sprint_button.connect("pressed", self, "sprintPressed")
	run_button.connect("pressed", self, "runPressed")
	crouch_button.connect("pressed", self, "crouchPressed")
	crawl_button.connect("pressed", self, "crawlPressed")



func menuPressed() -> void:
	capturing_input_menu = true
	menu_label.text = "Open menu:\n..."

func inventoryPressed() -> void:
	capturing_input_inventory = true
	inventory_label.text = "Open inventory:\n..."

func lootPressed() -> void:
	capturing_input_loot = true
	loot_label.text = "Open loot:\n..."

func skillsPressed() -> void:
	capturing_input_skills = true
	skills_label.text = "Open skills:\n..."

func escPressed() -> void:
	capturing_input_esc = true
	esc_label.text = "Show Mouse:\n..."

func frontPressed() -> void:
	capturing_input_front = true
	front_label.text = "Show Mouse:\n..."

func backPressed() -> void:
	capturing_input_back = true
	back_label.text = "Move back:\n..."

func leftPressed() -> void:
	capturing_input_left = true
	left_label.text = "Move left:\n..."

func rightPressed() -> void:
	capturing_input_right = true
	right_label.text = "Move right:\n..."

func jumpPressed() -> void:
	capturing_input_jump = true
	jump_label.text = "Jump:\n..."
	
func sprintPressed() -> void:
	capturing_input_sprint = true
	sprint_label.text = "Sprint:\n..."

func runPressed() -> void:
	capturing_input_run = true
	run_label.text = "Run:\n..."

func crouchPressed() -> void:
	capturing_input_crouch = true
	crouch_label.text = "Crouch:\n..."

func crawlPressed() -> void:
	capturing_input_crawl = true
	crawl_label.text = "Crawl:\n..."


func _input(event: InputEvent) -> void:
	if capturing_input_menu:
		handleInputEvent(event, "Menu", menu_label)
	elif capturing_input_inventory:
		handleInputEvent(event, "Inventory", inventory_label)
	elif capturing_input_loot:
		handleInputEvent(event, "Loot", loot_label)
	elif capturing_input_skills:
		handleInputEvent(event, "Skills", skills_label)
	elif capturing_input_esc:
		handleInputEvent(event, "ESC", esc_label)
	elif capturing_input_front:
		handleInputEvent(event, "Front", front_label)
	elif capturing_input_back:
		handleInputEvent(event, "Back", back_label)
	elif capturing_input_left:
		handleInputEvent(event, "Left", left_label)
	elif capturing_input_right:
		handleInputEvent(event, "Right", right_label)
	elif capturing_input_jump:
		handleInputEvent(event, "Jump", jump_label)
	elif capturing_input_sprint:
		handleInputEvent(event, "Sprint", sprint_label)
	elif capturing_input_run:
		handleInputEvent(event, "Run", run_label)
	elif capturing_input_crouch:
		handleInputEvent(event, "Crouch", crouch_label)
	elif capturing_input_crawl:
		handleInputEvent(event, "Crawl", crawl_label)

func handleInputEvent(event: InputEvent, action_name: String, label: Label) -> void:
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
		elif action_name == "ESC":
			label.text = "Show Mouse:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Front":
			label.text = "Move front:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Back":
			label.text = "Move back:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Left":
			label.text = "Move left:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Right":
			label.text = "Move right:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Jump":
			label.text = "Jump:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Sprint":
			label.text = "Sprint:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Run":
			label.text = "Run:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Crouch":
			label.text = "Crouch:\n" + OS.get_scancode_string(new_key)
		elif action_name == "Crawl":
			label.text = "Crawl:\n" + OS.get_scancode_string(new_key)

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
		elif action_name == "ESC":
			capturing_input_esc = false
		elif action_name == "Front":
			capturing_input_front = false
		elif action_name == "Back":
			capturing_input_back = false
		elif action_name == "Left":
			capturing_input_left = false
		elif action_name == "Right":
			capturing_input_right = false
		elif action_name == "Jump":
			capturing_input_jump = false
		elif action_name == "Sprint":
			capturing_input_sprint = false
		elif action_name == "Run":
			capturing_input_run = false
		elif action_name == "Crouch":
			capturing_input_crouch = false
		elif action_name == "Crawl":
			capturing_input_crawl = false

		save_keybinds()

func save_keybinds() -> void:
	var config = ConfigFile.new()
	config.set_value("Keybinds", "Menu", InputMap.get_action_list("Menu"))
	config.set_value("Keybinds", "Inventory", InputMap.get_action_list("Inventory"))
	config.set_value("Keybinds", "Loot", InputMap.get_action_list("Loot"))
	config.set_value("Keybinds", "Skills", InputMap.get_action_list("Skills"))
	config.set_value("Keybinds", "ESC", InputMap.get_action_list("ESC"))
	config.set_value("Keybinds", "Front", InputMap.get_action_list("Front"))
	config.set_value("Keybinds", "Back", InputMap.get_action_list("Back"))
	config.set_value("Keybinds", "Left", InputMap.get_action_list("Left"))
	config.set_value("Keybinds", "Right", InputMap.get_action_list("Right"))
	config.set_value("Keybinds", "Jump", InputMap.get_action_list("Jump"))
	config.set_value("Keybinds", "Sprint", InputMap.get_action_list("Sprint"))
	config.set_value("Keybinds", "Run", InputMap.get_action_list("Run"))
	config.set_value("Keybinds", "Crouch", InputMap.get_action_list("Crouch"))
	config.set_value("Keybinds", "Crawl", InputMap.get_action_list("Crawl"))

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
		InputMap.action_erase_events("Front")
		InputMap.action_erase_events("Back")
		InputMap.action_erase_events("Left")
		InputMap.action_erase_events("Right")
		InputMap.action_erase_events("Jump")
		InputMap.action_erase_events("Sprint")
		InputMap.action_erase_events("Run")
		InputMap.action_erase_events("Crouch")
		InputMap.action_erase_events("Crawl")

		load_keybind("Menu", config)
		load_keybind("Inventory", config)
		load_keybind("Loot", config)
		load_keybind("Skills", config)
		load_keybind("ESC", config)
		load_keybind("Front", config)
		load_keybind("Back", config)
		load_keybind("Left", config)
		load_keybind("Right", config)
		load_keybind("Jump", config)
		load_keybind("Sprint", config)
		load_keybind("Run", config)
		load_keybind("Crouch", config)
		load_keybind("Crawl", config)

		# Set the label text to the currently assigned key for the actions
		var menu_key = InputMap.get_action_list("Menu")[0].scancode if InputMap.has_action("Menu") else 0
		var inventory_key = InputMap.get_action_list("Inventory")[0].scancode if InputMap.has_action("Inventory") else 0
		var loot_key = InputMap.get_action_list("Loot")[0].scancode if InputMap.has_action("Loot") else 0
		var skills_key = InputMap.get_action_list("Skills")[0].scancode if InputMap.has_action("Skills") else 0
		var escape_key = InputMap.get_action_list("ESC")[0].scancode if InputMap.has_action("ESC") else 0
		var front_key = InputMap.get_action_list("Front")[0].scancode if InputMap.has_action("Front") else 0
		var back_key = InputMap.get_action_list("Back")[0].scancode if InputMap.has_action("Back") else 0
		var left_key = InputMap.get_action_list("Left")[0].scancode if InputMap.has_action("Left") else 0
		var right_key = InputMap.get_action_list("Right")[0].scancode if InputMap.has_action("Right") else 0
		var jump_key = InputMap.get_action_list("Jump")[0].scancode if InputMap.has_action("Jump") else 0
		var sprint_key = InputMap.get_action_list("Sprint")[0].scancode if InputMap.has_action("Sprint") else 0
		var run_key = InputMap.get_action_list("Run")[0].scancode if InputMap.has_action("Run") else 0
		var crouch_key = InputMap.get_action_list("Crouch")[0].scancode if InputMap.has_action("Crouch") else 0
		var crawl_key = InputMap.get_action_list("Crawl")[0].scancode if InputMap.has_action("Crawl") else 0

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
		if escape_key == 0:
			escape_key = KEY_ESCAPE
			var escape_event = InputEventKey.new()
			escape_event.scancode = escape_key
			InputMap.action_add_event("ESC", escape_event)
		if front_key == 0:
			front_key = KEY_W
			var front_event = InputEventKey.new()
			front_event.scancode = front_key
			InputMap.action_add_event("Front", front_event)
		if back_key == 0:
			back_key = KEY_S
			var back_event = InputEventKey.new()
			back_event.scancode = back_key
			InputMap.action_add_event("Back", back_event)
		if left_key == 0:
			left_key = KEY_A
			var left_event = InputEventKey.new()
			left_event.scancode = left_key
			InputMap.action_add_event("Left", left_event)
		if right_key == 0:
			right_key = KEY_D
			var right_event = InputEventKey.new()
			right_event.scancode = right_key
			InputMap.action_add_event("Right", right_event)
		if jump_key == 0:
			jump_key = KEY_SPACE
			var jump_event = InputEventKey.new()
			jump_event.scancode = jump_key
			InputMap.action_add_event("Jump", jump_event)
		if sprint_key == 0:
			sprint_key = KEY_ALT
			var sprint_event = InputEventKey.new()
			sprint_event.scancode = sprint_key
			InputMap.action_add_event("Sprint", sprint_event)

		if run_key == 0:
			run_key = KEY_SHIFT
			var run_event = InputEventKey.new()
			run_event.scancode = run_key
			InputMap.action_add_event("Run", run_event)

		if crouch_key == 0:
			crouch_key = KEY_CONTROL
			var crouch_event = InputEventKey.new()
			crouch_event.scancode = crouch_key
			InputMap.action_add_event("Crouch", crouch_event)

		if crawl_key == 0:
			crawl_key = KEY_LESS
			var crawl_event = InputEventKey.new()
			crawl_event.scancode = crawl_key
			InputMap.action_add_event("Crawl", crawl_event)


		menu_label.text = "Open menu:\n" + OS.get_scancode_string(menu_key)
		inventory_label.text = "Open inventory:\n" + OS.get_scancode_string(inventory_key)
		loot_label.text = "Open loot:\n" + OS.get_scancode_string(loot_key)
		skills_label.text = "Open skills:\n" + OS.get_scancode_string(skills_key)
		esc_label.text = "Show Mouse:\n" + OS.get_scancode_string(escape_key)
		front_label.text = "Move front:\n" + OS.get_scancode_string(front_key)
		back_label.text = "Move back:\n" + OS.get_scancode_string(back_key)
		left_label.text = "Move left:\n" + OS.get_scancode_string(left_key)
		right_label.text = "Move right:\n" + OS.get_scancode_string(right_key)
		jump_label.text = "Jump:\n" + OS.get_scancode_string(jump_key)
		sprint_label.text = "Sprint:\n" + OS.get_scancode_string(sprint_key)
		run_label.text = "Run:\n" + OS.get_scancode_string(run_key)
		crouch_label.text = "Crouch:\n" + OS.get_scancode_string(crouch_key)
		crawl_label.text = "Crawl:\n" + OS.get_scancode_string(crawl_key)

	else:
		print("Error loading keybinds:", error)

func load_keybind(action_name: String, config: ConfigFile) -> void:
	var keybinds = config.get_value("Keybinds", action_name, [])
	for keybind in keybinds:
		InputMap.action_add_event(action_name, keybind)
	var key_name = OS.get_scancode_string(keybinds[0].scancode) if keybinds else "Unknown"
