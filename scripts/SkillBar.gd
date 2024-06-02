 extends Control

func _ready():
	load_keybinds()
	connectSkillSlots()
func connectSkillSlots():
	skill_slot1.connect("pressed", self, "slot1Pressed")
	skill_slot2.connect("pressed", self, "slot2Pressed")
	skill_slot3.connect("pressed", self, "slot3Pressed")
	skill_slot4.connect("pressed", self, "slot4Pressed")
	skill_slot5.connect("pressed", self, "slot5Pressed")
	skill_slot6.connect("pressed", self, "slot6Pressed")
	skill_slot7.connect("pressed", self, "slot7Pressed")
	skill_slot8.connect("pressed", self, "slot8Pressed")
	skill_slot9.connect("pressed", self, "slot9Pressed")
	skill_slot10.connect("pressed", self, "slot10Pressed")
	skill_slot11.connect("pressed", self, "slot11Pressed")
	skill_slot12.connect("pressed", self, "slot12Pressed")
	skill_slot13.connect("pressed", self, "slot13Pressed")
	skill_slot14.connect("pressed", self, "slot14Pressed")
	skill_slot15.connect("pressed", self, "slot15Pressed")
	skill_slot16.connect("pressed", self, "slot16Pressed")
	skill_slot17.connect("pressed", self, "slot17Pressed")
	skill_slot18.connect("pressed", self, "slot18Pressed")
	skill_slot19.connect("pressed", self, "slot19Pressed")
	skill_slot20.connect("pressed", self, "slot20Pressed")


var edit = false 
func _on_Edit_pressed():
	edit = !edit 


#lower row of shortcut keybinds 
onready var skilltree = $"../SkillTrees/Background/SylvanSkills"
onready var skill_slot1 = $GridContainer/Slot1
onready var skill_slot2 = $GridContainer/Slot2
onready var skill_slot3 = $GridContainer/Slot3
onready var skill_slot4 = $GridContainer/Slot4
onready var skill_slot5 = $GridContainer/Slot5
onready var skill_slot6 = $GridContainer/Slot6
onready var skill_slot7 = $GridContainer/Slot7
onready var skill_slot8 = $GridContainer/Slot8
onready var skill_slot9 = $GridContainer/Slot9
onready var skill_slot10 = $GridContainer/Slot10
onready var skill_slot11 = $GridContainer/Slot11
onready var skill_slot12 = $GridContainer/Slot12
onready var skill_slot13 = $GridContainer/Slot13
onready var skill_slot14 = $GridContainer/Slot14
onready var skill_slot15 = $GridContainer/Slot15
onready var skill_slot16 = $GridContainer/Slot16
onready var skill_slot17 = $GridContainer/Slot17
onready var skill_slot18 = $GridContainer/Slot18
onready var skill_slot19 = $GridContainer/Slot19
onready var skill_slot20 = $GridContainer/Slot20




onready var skill_slot_label_1 = $GridContainer/Slot1/Label
onready var skill_slot_label_2 = $GridContainer/Slot2/Label 
onready var skill_slot_label_3 = $GridContainer/Slot3/Label 
onready var skill_slot_label_4 = $GridContainer/Slot4/Label
onready var skill_slot_label_5 = $GridContainer/Slot5/Label 
onready var skill_slot_label_6 = $GridContainer/Slot6/Label
onready var skill_slot_label_7 = $GridContainer/Slot7/Label 
onready var skill_slot_label_8 = $GridContainer/Slot8/Label
onready var skill_slot_label_9 = $GridContainer/Slot9/Label 
onready var skill_slot_label_10 = $GridContainer/Slot10/Label




var capturing_input1 = false
var capturing_input2 = false
var capturing_input3 = false
var capturing_input4 = false
var capturing_input5 = false
var capturing_input6 = false
var capturing_input7 = false
var capturing_input8 = false
var capturing_input9 = false
var capturing_input10 = false
func slot1Pressed():
	if edit:
		capturing_input1 = true
		skill_slot_label_1.text = "..."

func slot2Pressed():
	if edit:
		capturing_input2 = true
		skill_slot_label_2.text = "..."

func slot3Pressed():
	if edit:
		capturing_input3 = true
		skill_slot_label_3.text = "..."

func slot4Pressed():
	if edit:
		capturing_input4 = true
		skill_slot_label_4.text = "..."
func slot5Pressed():
	if edit:
		capturing_input5 = true
		skill_slot_label_5.text = "..."

func slot6Pressed():
	if edit:
		capturing_input6 = true
		skill_slot_label_6.text = "..."

func slot7Pressed():
	if edit:
		capturing_input7 = true
		skill_slot_label_7.text = "..."

func slot8Pressed():
	if edit:
		capturing_input8 = true
		skill_slot_label_8.text = "..."

func slot9Pressed():
	if edit:
		capturing_input9 = true
		skill_slot_label_9.text = "..."

func slot10Pressed():
	if edit:
		capturing_input10 = true
		skill_slot_label_10.text = "..."


#upper row of shortcut keybinds ____________________________________________________________________

onready var skill_slot_label_11 = $GridContainer/Slot11/Label
onready var skill_slot_label_12 = $GridContainer/Slot12/Label
onready var skill_slot_label_13 = $GridContainer/Slot13/Label
onready var skill_slot_label_14 = $GridContainer/Slot14/Label
onready var skill_slot_label_15 = $GridContainer/Slot15/Label
onready var skill_slot_label_16 = $GridContainer/Slot16/Label
onready var skill_slot_label_17 = $GridContainer/Slot17/Label
onready var skill_slot_label_18 = $GridContainer/Slot18/Label
onready var skill_slot_label_19 = $GridContainer/Slot19/Label
onready var skill_slot_label_20 = $GridContainer/Slot20/Label


var capturing_input1UP = false
var capturing_input2UP = false
var capturing_input3UP = false
var capturing_input4UP = false
var capturing_input5UP = false
var capturing_input6UP = false
var capturing_input7UP = false
var capturing_input8UP = false
var capturing_input9UP = false
var capturing_input10UP = false

func slot11Pressed():
	if edit:
		capturing_input1UP = true
		skill_slot_label_11.text = "..."
func slot12Pressed():
	if edit:
		capturing_input2UP = true
		skill_slot_label_12.text = "..."
		
func slot13Pressed():
	if edit:
		capturing_input3UP = true
		skill_slot_label_13.text = "..."
		
func slot14Pressed():
	if edit:
		capturing_input4UP = true
		skill_slot_label_14.text = "..."
		
func slot15Pressed():
	if edit:
		capturing_input5UP = true
		skill_slot_label_15.text = "..."
		
func slot16Pressed():
	if edit:
		capturing_input6UP = true
		skill_slot_label_16.text = "..."
		
func slot17Pressed():
	if edit:
		capturing_input7UP = true
		skill_slot_label_17.text = "..."
		
func slot18Pressed():
	if edit:
		capturing_input8UP = true
		skill_slot_label_18.text = "..."
		
func slot19Pressed():
	if edit:
		capturing_input9UP = true
		skill_slot_label_19.text = "..."
		
func slot20Pressed():
	if edit:
		capturing_input10UP = true
		skill_slot_label_20.text = "..."



const CONFIG_FILE_PATH = "user://skillbar_keybinds.cfg" # Path to the configuration file



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
	if capturing_input7:
		handle_input_event(event, "7", skill_slot_label_7)
	if capturing_input8:
		handle_input_event(event, "8", skill_slot_label_8)
	if capturing_input9:
		handle_input_event(event, "9", skill_slot_label_9)
	if capturing_input10:
		handle_input_event(event, "0", skill_slot_label_10)
#___________________________________________________________________________________________________
	if capturing_input1UP:
		handle_input_event(event, "Q", skill_slot_label_11)
	if capturing_input2UP:
		handle_input_event(event, "E", skill_slot_label_12)
	if capturing_input3UP:
		handle_input_event(event, "R", skill_slot_label_13)
	if capturing_input4UP:
		handle_input_event(event, "T", skill_slot_label_14)
	if capturing_input5UP:
		handle_input_event(event, "F", skill_slot_label_15)
	if capturing_input6UP:
		handle_input_event(event, "G", skill_slot_label_16)
	if capturing_input7UP:
		handle_input_event(event, "Y", skill_slot_label_17)
	if capturing_input8UP:
		handle_input_event(event, "H", skill_slot_label_18)
	if capturing_input9UP:
		handle_input_event(event, "V", skill_slot_label_19)
	if capturing_input10UP:
		handle_input_event(event, "B", skill_slot_label_20)




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
		elif action_name == "7":
			capturing_input7 = false
		elif action_name == "8":
			capturing_input8 = false
		elif action_name == "9":
			capturing_input9 = false
		elif action_name == "0":
			capturing_input10 = false
#___________________________________________________________________________________________________
		elif action_name == "Q":
			capturing_input1UP = false
		elif action_name == "E":
			capturing_input2UP = false
		elif action_name == "R":
			capturing_input3UP = false
		elif action_name == "T":
			capturing_input4UP = false
		elif action_name == "F":
			capturing_input5UP = false
		elif action_name == "G":
			capturing_input6UP = false
		elif action_name == "Y":
			capturing_input7UP = false
		elif action_name == "H":
			capturing_input8UP = false
		elif action_name == "V":
			capturing_input9UP = false
		elif action_name == "B":
			capturing_input10UP = false

		save_keybinds()


func save_keybinds():
	var config = ConfigFile.new()
	config.set_value("Keybinds", "Skill1", skill_slot_label_1.text)
	config.set_value("Keybinds", "1", InputMap.get_action_list("1"))

	config.set_value("Keybinds", "Skill2", skill_slot_label_2.text)
	config.set_value("Keybinds", "2", InputMap.get_action_list("2"))
	
	config.set_value("Keybinds", "Skill3", skill_slot_label_3.text)
	config.set_value("Keybinds", "3", InputMap.get_action_list("3"))
	
	config.set_value("Keybinds", "Skill4", skill_slot_label_4.text)
	config.set_value("Keybinds", "4", InputMap.get_action_list("4"))
	
	config.set_value("Keybinds", "Skill5", skill_slot_label_5.text)
	config.set_value("Keybinds", "5", InputMap.get_action_list("5"))
	
	config.set_value("Keybinds", "Skill6", skill_slot_label_6.text)
	config.set_value("Keybinds", "6", InputMap.get_action_list("6"))
	
	config.set_value("Keybinds", "Skill7", skill_slot_label_7.text)
	config.set_value("Keybinds", "7", InputMap.get_action_list("7"))

	config.set_value("Keybinds", "Skill8", skill_slot_label_8.text)
	config.set_value("Keybinds", "8", InputMap.get_action_list("8"))

	config.set_value("Keybinds", "Skill9", skill_slot_label_9.text)
	config.set_value("Keybinds", "9", InputMap.get_action_list("9"))

	config.set_value("Keybinds", "Skill10", skill_slot_label_10.text)
	config.set_value("Keybinds", "0", InputMap.get_action_list("0"))
#___________________________________________________________________________________________________
	config.set_value("Keybinds", "SkillQ", skill_slot_label_11.text)
	config.set_value("Keybinds", "Q", InputMap.get_action_list("Q"))
	
	config.set_value("Keybinds", "SkillE", skill_slot_label_12.text)
	config.set_value("Keybinds", "E", InputMap.get_action_list("E"))

	config.set_value("Keybinds", "SkillR", skill_slot_label_13.text)
	config.set_value("Keybinds", "R", InputMap.get_action_list("R"))

	config.set_value("Keybinds", "SkillT", skill_slot_label_14.text)
	config.set_value("Keybinds", "T", InputMap.get_action_list("T"))

	config.set_value("Keybinds", "SkillF", skill_slot_label_15.text)
	config.set_value("Keybinds", "F", InputMap.get_action_list("F"))

	config.set_value("Keybinds", "SkillG", skill_slot_label_16.text)
	config.set_value("Keybinds", "G", InputMap.get_action_list("G"))

	config.set_value("Keybinds", "SkillY", skill_slot_label_17.text)
	config.set_value("Keybinds", "Y", InputMap.get_action_list("Y"))

	config.set_value("Keybinds", "SkillH", skill_slot_label_18.text)
	config.set_value("Keybinds", "H", InputMap.get_action_list("H"))

	config.set_value("Keybinds", "SkillV", skill_slot_label_19.text)
	config.set_value("Keybinds", "V", InputMap.get_action_list("V"))

	config.set_value("Keybinds", "SkillB", skill_slot_label_20.text)
	config.set_value("Keybinds", "B", InputMap.get_action_list("B"))
	
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
		InputMap.action_erase_events("3")
		InputMap.action_erase_events("4")
		InputMap.action_erase_events("5")
		InputMap.action_erase_events("6")
		InputMap.action_erase_events("7")
		InputMap.action_erase_events("8")
		InputMap.action_erase_events("9")
		InputMap.action_erase_events("0")

		
		load_keybind("1", skill_slot1, "1", config)
		load_keybind("2", skill_slot2, "2", config)
		load_keybind("3", skill_slot3, "3", config)
		load_keybind("4", skill_slot4, "4", config)
		load_keybind("5", skill_slot5, "5", config)
		load_keybind("6", skill_slot6, "6", config)
		load_keybind("7", skill_slot7, "7", config)
		load_keybind("8", skill_slot8, "8", config)
		load_keybind("9", skill_slot9, "9", config)
		load_keybind("10", skill_slot10, "0", config)

		skill_slot_label_1.text = config.get_value("Keybinds", "Skill1", "")  # Corrected line
		skill_slot_label_2.text = config.get_value("Keybinds", "Skill2", "")
		skill_slot_label_1.text = config.get_value("Keybinds", "Skill1", "")
		skill_slot_label_2.text = config.get_value("Keybinds", "Skill2", "")
		skill_slot_label_3.text = config.get_value("Keybinds", "Skill3", "")
		skill_slot_label_4.text = config.get_value("Keybinds", "Skill4", "")
		skill_slot_label_5.text = config.get_value("Keybinds", "Skill5", "")
		skill_slot_label_6.text = config.get_value("Keybinds", "Skill6", "")
		skill_slot_label_7.text = config.get_value("Keybinds", "Skill7", "")
		skill_slot_label_8.text = config.get_value("Keybinds", "Skill8", "")
		skill_slot_label_9.text = config.get_value("Keybinds", "Skill9", "")
		skill_slot_label_10.text = config.get_value("Keybinds", "Skill10", "")
#___________________________________________________________________________________________________
		InputMap.action_erase_events("Q")
		InputMap.action_erase_events("E")
		InputMap.action_erase_events("R")
		InputMap.action_erase_events("T")
		InputMap.action_erase_events("F")
		InputMap.action_erase_events("G")
		InputMap.action_erase_events("Y")
		InputMap.action_erase_events("H")
		InputMap.action_erase_events("V")
		InputMap.action_erase_events("B")
		
		load_keybind("Q", skill_slot11, "Q", config)
		load_keybind("E", skill_slot12, "E", config)
		load_keybind("R", skill_slot13, "R", config)
		load_keybind("T", skill_slot14, "T", config)
		load_keybind("F", skill_slot15, "F", config)
		load_keybind("G", skill_slot16, "G", config)
		load_keybind("Y", skill_slot17, "Y", config)
		load_keybind("H", skill_slot18, "H", config)
		load_keybind("V", skill_slot19, "V", config)
		load_keybind("B", skill_slot20, "B", config)
		
		skill_slot_label_11.text = config.get_value("Keybinds", "SkillQ", "")
		skill_slot_label_12.text = config.get_value("Keybinds", "SkillE", "")
		skill_slot_label_13.text = config.get_value("Keybinds", "SkillR", "")
		skill_slot_label_14.text = config.get_value("Keybinds", "SkillT", "")
		skill_slot_label_15.text = config.get_value("Keybinds", "SkillF", "")
		skill_slot_label_16.text = config.get_value("Keybinds", "SkillG", "")
		skill_slot_label_17.text = config.get_value("Keybinds", "SkillY", "")
		skill_slot_label_18.text = config.get_value("Keybinds", "SkillH", "")
		skill_slot_label_19.text = config.get_value("Keybinds", "SkillV", "")
		skill_slot_label_20.text = config.get_value("Keybinds", "SkillB", "")

	else:
		print("Error loading keybinds:", error)

func load_keybind(action_name, button, input_action, config):
	var keybinds = config.get_value("Keybinds", action_name, [])
	for keybind in keybinds:
		InputMap.action_add_event(input_action, keybind)
	var key_name = OS.get_scancode_string(keybinds[0].scancode) if keybinds else "Unknown"
