extends Control

onready var forward_button = $GridContainer/ForwardKeybind
onready var back_button = $GridContainer/BackKeybind
onready var left_button = $GridContainer/LeftKeybind
onready var right_button = $GridContainer/RightKeybind
onready var run_button = $GridContainer/RunKeybind
onready var sprint_button = $GridContainer/SprintKeybind
onready var jump_button = $GridContainer/JumpKeybind
onready var crouch_button = $GridContainer/CrouchKeybind
onready var tab_button = $GridContainer/TabKeybind
onready var skills_button = $GridContainer/SkillsKeybind

var capturing_input_forward = false
var capturing_input_back = false
var capturing_input_left = false
var capturing_input_right = false
var capturing_input_run = false
var capturing_input_sprint = false
var capturing_input_jump = false
var capturing_input_crouch = false
var capturing_input_tab = false
var capturing_input_skills = false

const CONFIG_FILE_PATH = "user://keybinds.cfg" # Path to the configuration file

func _ready():
	load_keybinds()

func _input(event):
	if capturing_input_forward:
		handle_input_event(event, "forward", forward_button)
	if capturing_input_back:
		handle_input_event(event, "backward", back_button)
	if capturing_input_left:
		handle_input_event(event, "left", left_button)
	if capturing_input_right:
		handle_input_event(event, "right", right_button)
	if capturing_input_run:
		handle_input_event(event, "run", run_button)
	if capturing_input_sprint:
		handle_input_event(event, "sprint", sprint_button)
	if capturing_input_jump:
		handle_input_event(event, "jump", jump_button)
	if capturing_input_crouch:
		handle_input_event(event, "crouch", crouch_button)
	if capturing_input_tab:
		handle_input_event(event, "tab", tab_button)
	if capturing_input_skills:
		handle_input_event(event, "skills", skills_button)

func handle_input_event(event, action_name, button):
	if event is InputEventKey:
		var new_key = event.scancode
		var input_event = InputEventKey.new()
		input_event.scancode = new_key
		
		# Remove all existing bindings for the action
		InputMap.action_erase_events(action_name)
		
		# Add the new key binding
		InputMap.action_add_event(action_name, input_event)
		
		var key_name = OS.get_scancode_string(new_key)
		button.text = key_name
		if action_name == "forward":
			capturing_input_forward = false
		elif action_name == "backward":
			capturing_input_back = false
		elif action_name == "left":
			capturing_input_left = false
		elif action_name == "right":
			capturing_input_right = false
		elif action_name == "run":
			capturing_input_run = false
		elif action_name == "sprint":
			capturing_input_sprint = false
		elif action_name == "jump":
			capturing_input_jump = false
		elif action_name == "crouch":
			capturing_input_crouch = false
		elif action_name == "tab":
			capturing_input_tab = false
		elif action_name == "skills":
			capturing_input_skills = false
		save_keybinds()

func _on_ForwardKeybind_pressed():
	capturing_input_forward = true
	forward_button.text = "..."

func _on_BackKeybind_pressed():
	capturing_input_back = true 
	back_button.text = "..."

func _on_LeftKeybind_pressed():
	capturing_input_left = true 
	left_button.text = "..."

func _on_RightKeybind_pressed():
	capturing_input_right = true 
	right_button.text = "..."

func _on_RunKeybind_pressed():
	capturing_input_run = true
	run_button.text = "..."

func _on_SprintKeybind_pressed():
	capturing_input_sprint = true
	sprint_button.text = "..."

func _on_JumpKeybind_pressed():
	capturing_input_jump = true
	jump_button.text = "..."

func _on_CrouchKeybind_pressed():
	capturing_input_crouch = true
	crouch_button.text = "..."

func _on_TabKeybind_pressed():
	capturing_input_tab = true
	tab_button.text = "..."

func _on_SkillsKeybind_pressed():
	capturing_input_skills = true
	skills_button.text = "..."

func save_keybinds():
	var config = ConfigFile.new()
	config.set_value("Keybinds", "Forward", InputMap.get_action_list("forward"))
	config.set_value("Keybinds", "Backward", InputMap.get_action_list("backward"))
	config.set_value("Keybinds", "Left", InputMap.get_action_list("left"))
	config.set_value("Keybinds", "Right", InputMap.get_action_list("right"))
	config.set_value("Keybinds", "Run", InputMap.get_action_list("run"))
	config.set_value("Keybinds", "Sprint", InputMap.get_action_list("sprint"))
	config.set_value("Keybinds", "Jump", InputMap.get_action_list("jump"))
	config.set_value("Keybinds", "Crouch", InputMap.get_action_list("crouch"))
	config.set_value("Keybinds", "Tab", InputMap.get_action_list("tab"))
	config.set_value("Keybinds", "Skills", InputMap.get_action_list("skills"))
	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		print("Error saving keybinds:", error)

func load_keybinds():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_FILE_PATH)
	if error == OK:
		# Clear all existing bindings before adding loaded keybinds
		InputMap.action_erase_events("forward")
		InputMap.action_erase_events("backward")
		InputMap.action_erase_events("left")
		InputMap.action_erase_events("right")
		InputMap.action_erase_events("run")
		InputMap.action_erase_events("sprint")
		InputMap.action_erase_events("jump")
		InputMap.action_erase_events("crouch")
		InputMap.action_erase_events("tab")
		InputMap.action_erase_events("skills")
		
		load_keybind("Forward", forward_button, "forward", config)
		load_keybind("Backward", back_button, "backward", config)
		load_keybind("Left", left_button, "left", config)
		load_keybind("Right", right_button, "right", config)
		load_keybind("Run", run_button, "run", config)
		load_keybind("Sprint", sprint_button, "sprint", config)
		load_keybind("Jump", jump_button, "jump", config)
		load_keybind("Crouch", crouch_button, "crouch", config)
		load_keybind("Tab", tab_button, "tab", config)
		load_keybind("Skills", skills_button, "skills", config)
	else:
		print("Error loading keybinds:", error)

func load_keybind(action_name, button, input_action, config):
	var keybinds = config.get_value("Keybinds", action_name, [])
	for keybind in keybinds:
		InputMap.action_add_event(input_action, keybind)
	var key_name = OS.get_scancode_string(keybinds[0].scancode) if keybinds else "Unknown"
	button.text = key_name


