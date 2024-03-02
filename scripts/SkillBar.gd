 extends Control

onready var skilltree = $"../GUI/SkillTrees/Background/SylvanSkills"
onready var skill_slot1 = $GridContainer/Slot1
onready var skill_slot2 = $GridContainer/Slot2
onready var skill_slot3 = $GridContainer/Slot3
onready var skill_slot4 = $GridContainer/Slot4
onready var skill_slot5 = $GridContainer/Slot5
onready var skill_slot6 = $GridContainer/Slot6

onready var skill_slot_label_1 = $GridContainer/Slot1/Label
onready var skill_slot_label_2 = $GridContainer/Slot2/Label 
onready var skill_slot_label_3 = $GridContainer/Slot3/Label 
onready var skill_slot_label_4 = $GridContainer/Slot4/Label
onready var skill_slot_label_5 = $GridContainer/Slot5/Label 
onready var skill_slot_label_6 = $GridContainer/Slot6/Label

var capturing_input1 = false
var capturing_input2 = false
var capturing_input3 = false
var capturing_input4 = false
var capturing_input5 = false
var capturing_input6 = false


const CONFIG_FILE_PATH = "user://skillbar_keybinds.cfg" # Path to the configuration file

func _ready():
	load_keybinds()

func _input(event):
	if capturing_input1:
		handle_input_event(event, "1", skill_slot_label_1)
	if capturing_input2:
		handle_input_event(event, "2", skill_slot_label_2)
	if capturing_input3:
		handle_input_event(event, "3", skill_slot_label_3)
	if capturing_input4:
		handle_input_event(event, "4", skill_slot_label_4)
	if capturing_input5:
		handle_input_event(event, "5", skill_slot_label_5)
	if capturing_input6:
		handle_input_event(event, "6", skill_slot_label_6)


func handle_input_event(event, action_name, label):
	if event is InputEventKey:
		var new_key = event.scancode
		var input_event = InputEventKey.new()
		input_event.scancode = new_key
		
		# Update the key binding
		label.text = OS.get_scancode_string(new_key)  # Set the text on the Label

		# Remove all existing bindings for the action
		InputMap.action_erase_events(action_name)
		
		# Add the new key binding
		InputMap.action_add_event(action_name, input_event)
		
		if action_name == "1":
			capturing_input1 = false
		elif action_name == "2":
			capturing_input2 = false
		elif action_name == "3":
			capturing_input3 = false
		elif action_name == "4":
			capturing_input4 = false
		elif action_name == "5":
			capturing_input5 = false
		elif action_name == "6":
			capturing_input6 = false

		save_keybinds()




func _on_Slot1_pressed():
	#if !skilltree.dragging:
		capturing_input1 = true
		skill_slot_label_1.text = "..."
	
func _on_Slot2_pressed():
	#if !skilltree.dragging:
		capturing_input2 = true
		skill_slot_label_2.text = "..."

func _on_Slot3_pressed():
#	if !skilltree.dragging:
		capturing_input3 = true
		skill_slot_label_3.text = "..."

func _on_Slot4_pressed():
#	if !skilltree.dragging:
		capturing_input4 = true
		skill_slot_label_4.text = "..."

func _on_Slot5_pressed():
#	if !skilltree.dragging:
		capturing_input5 = true
		skill_slot_label_5.text = "..."

func _on_Slot6_pressed():
#	if !skilltree.dragging:
		capturing_input6 = true
		skill_slot_label_6.text = "..."

func save_keybinds():
	var config = ConfigFile.new()
	config.set_value("Keybinds", "Skill1", skill_slot_label_1.text)
	config.set_value("Keybinds", "1", InputMap.get_action_list("1"))

	config.set_value("Keybinds", "Skill2", skill_slot_label_2.text)
	config.set_value("Keybinds", "2", InputMap.get_action_list("2"))
	

	config.set_value("Keybinds", "Skill3", skill_slot_label_3.text)
	config.set_value("Keybinds", "Skill4", skill_slot_label_4.text)
	config.set_value("Keybinds", "Skill5", skill_slot_label_5.text)
	config.set_value("Keybinds", "Skill6", skill_slot_label_6.text)
	
	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		print("Error saving keybinds:", error)

func load_keybinds():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_FILE_PATH)
	if error == OK:
		# Clear all existing bindings before adding loaded keybinds
		InputMap.action_erase_events("1")
		InputMap.action_erase_events("2")

		
		load_keybind("1", skill_slot1, "1", config)
		load_keybind("2", skill_slot2, "2", config)


		skill_slot_label_1.text = config.get_value("Keybinds", "Skill1", "")  # Corrected line
		skill_slot_label_2.text = config.get_value("Keybinds", "Skill2", "")
		skill_slot_label_1.text = config.get_value("Keybinds", "Skill1", "")
		skill_slot_label_2.text = config.get_value("Keybinds", "Skill2", "")
		skill_slot_label_3.text = config.get_value("Keybinds", "Skill3", "")
		skill_slot_label_4.text = config.get_value("Keybinds", "Skill4", "")
		skill_slot_label_5.text = config.get_value("Keybinds", "Skill5", "")
		skill_slot_label_6.text = config.get_value("Keybinds", "Skill6", "")

	else:
		print("Error loading keybinds:", error)

func load_keybind(action_name, button, input_action, config):
	var keybinds = config.get_value("Keybinds", action_name, [])
	for keybind in keybinds:
		InputMap.action_add_event(input_action, keybind)
	var key_name = OS.get_scancode_string(keybinds[0].scancode) if keybinds else "Unknown"












