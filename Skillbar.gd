extends Control

var can_drag:bool = false
var dragging: bool = false
var offset: Vector2


func _on_DragUI_pressed():
	can_drag = !can_drag

func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 2 == 0:
		if can_drag ==true:
			dragUI()

func dragUI() -> void:
	if dragging:
		rect_position = get_global_mouse_position() + offset




onready var skill_slot1 = $GridContainer/Slot1
onready var skill_slot2 = $GridContainer/Slot2
onready var skill_slot3 = $GridContainer/Slot3
onready var skill_slot4 = $GridContainer/Slot4
onready var skill_slot5 = $GridContainer/Slot5
onready var skill_slot6 = $GridContainer/Slot6
onready var skill_slot7 = $GridContainer/Slot7
onready var skill_slot8 = $GridContainer/Slot8
onready var skill_slot9 = $GridContainer/Slot9
onready var skill_slot0 = $GridContainer/Slot0

onready var skill_slotQ = $GridContainer/SlotQ
onready var skill_slotE = $GridContainer/SlotE
onready var skill_slotZ = $GridContainer/SlotZ
onready var skill_slotX = $GridContainer/SlotX
onready var skill_slotC = $GridContainer/SlotC
onready var skill_slotR = $GridContainer/SlotR
onready var skill_slotF = $GridContainer/SlotF
onready var skill_slotT = $GridContainer/SlotT
onready var skill_slotV = $GridContainer/SlotV
onready var skill_slotG = $GridContainer/SlotG
onready var skill_slotB = $GridContainer/SlotB
onready var skill_slotY = $GridContainer/SlotY
onready var skill_slotH = $GridContainer/SlotH
onready var skill_slotN = $GridContainer/SlotN
onready var skill_slotF1 = $GridContainer/SlotF1
onready var skill_slotF2 = $GridContainer/SlotF2
onready var skill_slotF3 = $GridContainer/SlotF3
onready var skill_slotF4 = $GridContainer/SlotF4





onready var skill_slot_label_1 = $GridContainer/Slot1/Label
onready var skill_slot_label_2 = $GridContainer/Slot2/Label
onready var skill_slot_label_3 = $GridContainer/Slot3/Label
onready var skill_slot_label_4 = $GridContainer/Slot4/Label
onready var skill_slot_label_5 = $GridContainer/Slot5/Label
onready var skill_slot_label_6 = $GridContainer/Slot6/Label
onready var skill_slot_label_7 = $GridContainer/Slot7/Label
onready var skill_slot_label_8 = $GridContainer/Slot8/Label
onready var skill_slot_label_9 = $GridContainer/Slot9/Label
onready var skill_slot_label_0 = $GridContainer/Slot0/Label
onready var skill_slot_label_Q = $GridContainer/SlotQ/Label
onready var skill_slot_label_E = $GridContainer/SlotE/Label
onready var skill_slot_label_Z = $GridContainer/SlotZ/Label
onready var skill_slot_label_X = $GridContainer/SlotX/Label
onready var skill_slot_label_C = $GridContainer/SlotC/Label
onready var skill_slot_label_R = $GridContainer/SlotR/Label
onready var skill_slot_label_F = $GridContainer/SlotF/Label
onready var skill_slot_label_T = $GridContainer/SlotT/Label
onready var skill_slot_label_V = $GridContainer/SlotV/Label
onready var skill_slot_label_G = $GridContainer/SlotG/Label
onready var skill_slot_label_B = $GridContainer/SlotB/Label
onready var skill_slot_label_Y = $GridContainer/SlotY/Label
onready var skill_slot_label_H = $GridContainer/SlotH/Label
onready var skill_slot_label_N = $GridContainer/SlotN/Label
onready var skill_slot_label_F1 = $GridContainer/SlotF1/Label
onready var skill_slot_label_F2 = $GridContainer/SlotF2/Label
onready var skill_slot_label_F3 = $GridContainer/SlotF3/Label
onready var skill_slot_label_F4 = $GridContainer/SlotF4/Label


var capturing_input1 = false
var capturing_input2 = false
var capturing_input3 = false
var capturing_input4 = false
var capturing_input5 = false
var capturing_input6 = false
var capturing_input7 = false
var capturing_input8 = false
var capturing_input9 = false
var capturing_input0 = false
var capturing_inputQ = false
var capturing_inputE = false
var capturing_inputZ = false
var capturing_inputX = false
var capturing_inputC = false
var capturing_inputR = false
var capturing_inputF = false
var capturing_inputT = false
var capturing_inputV = false
var capturing_inputG = false
var capturing_inputB = false
var capturing_inputY = false
var capturing_inputH = false
var capturing_inputN = false
var capturing_inputF1 = false
var capturing_inputF2 = false
var capturing_inputF3 = false
var capturing_inputF4 = false




func _ready()->void:
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
	skill_slot0.connect("pressed", self, "slot0Pressed")

	skill_slotQ.connect("pressed", self, "slotQPressed")
	skill_slotE.connect("pressed", self, "slotEPressed")
	skill_slotZ.connect("pressed", self, "slotZPressed")
	skill_slotX.connect("pressed", self, "slotXPressed")
	skill_slotC.connect("pressed", self, "slotCPressed")
	skill_slotR.connect("pressed", self, "slotRPressed")
	skill_slotF.connect("pressed", self, "slotFPressed")
	skill_slotT.connect("pressed", self, "slotTPressed")
	skill_slotV.connect("pressed", self, "slotVPressed")
	skill_slotG.connect("pressed", self, "slotGPressed")
	skill_slotB.connect("pressed", self, "slotBPressed")
	skill_slotY.connect("pressed", self, "slotYPressed")
	skill_slotH.connect("pressed", self, "slotHPressed")
	skill_slotN.connect("pressed", self, "slotNPressed")

	skill_slotF1.connect("pressed", self, "slotF1Pressed")
	skill_slotF2.connect("pressed", self, "slotF2Pressed")
	skill_slotF3.connect("pressed", self, "slotF3Pressed")
	skill_slotF4.connect("pressed", self, "slotF4Pressed")


var edit = false 
func _on_EditSkillbarKeybinds_pressed()->void:
	edit = !edit 





func slot1Pressed()->void:
	if edit:
		capturing_input1 = true
		skill_slot_label_1.text = "..."
func slot2Pressed()->void:
	if edit:
		capturing_input2 = true
		skill_slot_label_2.text = "..."
func slot3Pressed()->void:
	if edit:
		capturing_input3 = true
		skill_slot_label_3.text = "..."
func slot4Pressed()->void:
	if edit:
		capturing_input4 = true
		skill_slot_label_4.text = "..."
func slot5Pressed()->void:
	if edit:
		capturing_input5 = true
		skill_slot_label_5.text = "..."
func slot6Pressed()->void:
	if edit:
		capturing_input6 = true
		skill_slot_label_6.text = "..."
func slot7Pressed()->void:
	if edit:
		capturing_input7 = true
		skill_slot_label_7.text = "..."
func slot8Pressed()->void:
	if edit:
		capturing_input8 = true
		skill_slot_label_8.text = "..."
func slot9Pressed()->void:
	if edit:
		capturing_input9 = true
		skill_slot_label_9.text = "..."
func slot0Pressed()->void:
	if edit:
		capturing_input0 = true
		skill_slot_label_0.text = "..."

func slotQPressed()->void:
	if edit:
		capturing_inputQ = true
		skill_slot_label_Q.text = "..."

func slotEPressed()->void:
	if edit:
		capturing_inputE = true
		skill_slot_label_E.text = "..."

func slotZPressed()->void:
	if edit:
		capturing_inputZ = true
		skill_slot_label_Z.text = "..."

func slotXPressed()->void:
	if edit:
		capturing_inputX = true
		skill_slot_label_X.text = "..."

func slotCPressed()->void:
	if edit:
		capturing_inputC = true
		skill_slot_label_C.text = "..."

func slotRPressed()->void:
	if edit:
		capturing_inputR = true
		skill_slot_label_R.text = "..."

func slotFPressed()->void:
	if edit:
		capturing_inputF = true
		skill_slot_label_F.text = "..."

func slotTPressed()->void:
	if edit:
		capturing_inputT = true
		skill_slot_label_T.text = "..."

func slotVPressed()->void:
	if edit:
		capturing_inputV = true
		skill_slot_label_V.text = "..."

func slotGPressed()->void:
	if edit:
		capturing_inputG = true
		skill_slot_label_G.text = "..."

func slotBPressed()->void:
	if edit:
		capturing_inputB = true
		skill_slot_label_B.text = "..."

func slotYPressed()->void:
	if edit:
		capturing_inputY = true
		skill_slot_label_Y.text = "..."

func slotHPressed()->void:
	if edit:
		capturing_inputH = true
		skill_slot_label_H.text = "..."

func slotNPressed()->void:
	if edit:
		capturing_inputN = true
		skill_slot_label_N.text = "..."


func slotF1Pressed()->void:
	if edit:
		capturing_inputF1 = true
		skill_slot_label_F1.text = "..."

func slotF2Pressed()->void:
	if edit:
		capturing_inputF2 = true
		skill_slot_label_F2.text = "..."

func slotF3Pressed()->void:
	if edit:
		capturing_inputF3 = true
		skill_slot_label_F3.text = "..."

func slotF4Pressed()->void:
	if edit:
		capturing_inputF4 = true
		skill_slot_label_F4.text = "..."




const CONFIG_FILE_PATH = "user://skillbar_keybinds.cfg" # Path to the configuration file



func _input(event)->void:
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# Check if the mouse is over the Control node
				if get_global_rect().has_point(event.position):
					dragging = true
					offset = rect_position - event.position
			else:
				dragging = false
				
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
	if capturing_input0:
		handle_input_event(event, "0", skill_slot_label_0)
	if capturing_inputQ:
		handle_input_event(event, "Q", skill_slot_label_Q)
	if capturing_inputE:
		handle_input_event(event, "E", skill_slot_label_E)
	if capturing_inputZ:
		handle_input_event(event, "Z", skill_slot_label_Z)
	if capturing_inputX:
		handle_input_event(event, "X", skill_slot_label_X)
	if capturing_inputC:
		handle_input_event(event, "C", skill_slot_label_C)
	if capturing_inputR:
		handle_input_event(event, "R", skill_slot_label_R)
	if capturing_inputF:
		handle_input_event(event, "F", skill_slot_label_F)
	if capturing_inputT:
		handle_input_event(event, "T", skill_slot_label_T)
	if capturing_inputV:
		handle_input_event(event, "V", skill_slot_label_V)
	if capturing_inputG:
		handle_input_event(event, "G", skill_slot_label_G)
	if capturing_inputB:
		handle_input_event(event, "B", skill_slot_label_B)
	if capturing_inputY:
		handle_input_event(event, "Y", skill_slot_label_Y)
	if capturing_inputH:
		handle_input_event(event, "H", skill_slot_label_H)
	if capturing_inputN:
		handle_input_event(event, "N", skill_slot_label_N)
	if capturing_inputF1:
		handle_input_event(event, "F1", skill_slot_label_F1)
	if capturing_inputF2:
		handle_input_event(event, "F2", skill_slot_label_F2)
	if capturing_inputF3:
		handle_input_event(event, "F3", skill_slot_label_F3)
	if capturing_inputF4:
		handle_input_event(event, "F4", skill_slot_label_F4)


func handle_input_event(event, action_name, label)->void:
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
			capturing_input0 = false
		elif action_name == "Q":
			capturing_inputQ = false
		elif action_name == "E":
			capturing_inputE = false
		elif action_name == "Z":
			capturing_inputZ = false
		elif action_name == "X":
			capturing_inputX = false
		elif action_name == "C":
			capturing_inputC = false
		elif action_name == "R":
			capturing_inputR = false
		elif action_name == "F":
			capturing_inputF = false
		elif action_name == "T":
			capturing_inputT = false
		elif action_name == "V":
			capturing_inputV = false
		elif action_name == "G":
			capturing_inputG = false
		elif action_name == "B":
			capturing_inputB = false
		elif action_name == "Y":
			capturing_inputY = false
		elif action_name == "H":
			capturing_inputH = false
		elif action_name == "N":
			capturing_inputN = false
		elif action_name == "F1":
			capturing_inputF1 = false
		elif action_name == "F2":
			capturing_inputF2 = false
		elif action_name == "F3":
			capturing_inputF3 = false
		elif action_name == "F4":
			capturing_inputF4 = false




		save_keybinds()


func save_keybinds()->void:
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

	config.set_value("Keybinds", "Skill0", skill_slot_label_0.text)
	config.set_value("Keybinds", "0", InputMap.get_action_list("0"))

	config.set_value("Keybinds", "SkillQ", skill_slot_label_Q.text)
	config.set_value("Keybinds", "Q", InputMap.get_action_list("Q"))

	config.set_value("Keybinds", "SkillE", skill_slot_label_E.text)
	config.set_value("Keybinds", "E", InputMap.get_action_list("E"))

	config.set_value("Keybinds", "SkillZ", skill_slot_label_Z.text)
	config.set_value("Keybinds", "Z", InputMap.get_action_list("Z"))

	config.set_value("Keybinds", "SkillX", skill_slot_label_X.text)
	config.set_value("Keybinds", "X", InputMap.get_action_list("X"))

	config.set_value("Keybinds", "SkillC", skill_slot_label_C.text)
	config.set_value("Keybinds", "C", InputMap.get_action_list("C"))

	config.set_value("Keybinds", "SkillR", skill_slot_label_R.text)
	config.set_value("Keybinds", "R", InputMap.get_action_list("R"))

	config.set_value("Keybinds", "SkillF", skill_slot_label_F.text)
	config.set_value("Keybinds", "F", InputMap.get_action_list("F"))

	config.set_value("Keybinds", "SkillT", skill_slot_label_T.text)
	config.set_value("Keybinds", "T", InputMap.get_action_list("T"))

	config.set_value("Keybinds", "SkillV", skill_slot_label_V.text)
	config.set_value("Keybinds", "V", InputMap.get_action_list("V"))

	config.set_value("Keybinds", "SkillG", skill_slot_label_G.text)
	config.set_value("Keybinds", "G", InputMap.get_action_list("G"))

	config.set_value("Keybinds", "SkillB", skill_slot_label_B.text)
	config.set_value("Keybinds", "B", InputMap.get_action_list("B"))

	config.set_value("Keybinds", "SkillY", skill_slot_label_Y.text)
	config.set_value("Keybinds", "Y", InputMap.get_action_list("Y"))

	config.set_value("Keybinds", "SkillH", skill_slot_label_H.text)
	config.set_value("Keybinds", "H", InputMap.get_action_list("H"))

	config.set_value("Keybinds", "SkillN", skill_slot_label_N.text)
	config.set_value("Keybinds", "N", InputMap.get_action_list("N"))


	config.set_value("Keybinds", "SkillF1", skill_slot_label_F1.text)
	config.set_value("Keybinds", "F1", InputMap.get_action_list("F1"))

	config.set_value("Keybinds", "SkillF2", skill_slot_label_F2.text)
	config.set_value("Keybinds", "F2", InputMap.get_action_list("F2"))

	config.set_value("Keybinds", "SkillF3", skill_slot_label_F3.text)
	config.set_value("Keybinds", "F3", InputMap.get_action_list("F3"))

	config.set_value("Keybinds", "SkillF4", skill_slot_label_F4.text)
	config.set_value("Keybinds", "F4", InputMap.get_action_list("F4"))


	
	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		print("Error saving keybinds:", error)

func load_keybinds()->void:
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

		InputMap.action_erase_events("Q")
		InputMap.action_erase_events("E")
		InputMap.action_erase_events("Z")
		InputMap.action_erase_events("X")
		InputMap.action_erase_events("C")
		InputMap.action_erase_events("R")
		InputMap.action_erase_events("F")
		InputMap.action_erase_events("T")
		InputMap.action_erase_events("V")
		InputMap.action_erase_events("G")
		InputMap.action_erase_events("B")
		InputMap.action_erase_events("Y")
		InputMap.action_erase_events("H")
		InputMap.action_erase_events("N")

		InputMap.action_erase_events("F1")
		InputMap.action_erase_events("F2")
		InputMap.action_erase_events("F3")
		InputMap.action_erase_events("F4")


		
		load_keybind("1", skill_slot1, "1", config)
		load_keybind("2", skill_slot2, "2", config)
		load_keybind("3", skill_slot3, "3", config)
		load_keybind("4", skill_slot4, "4", config)
		load_keybind("5", skill_slot5, "5", config)
		load_keybind("6", skill_slot6, "6", config)
		load_keybind("7", skill_slot7, "7", config)
		load_keybind("8", skill_slot8, "8", config)
		load_keybind("9", skill_slot9, "9", config)
		load_keybind("0", skill_slot0, "0", config)
		load_keybind("Q", skill_slotQ, "Q", config)
		load_keybind("E", skill_slotE, "E", config)
		load_keybind("Z", skill_slotZ, "Z", config)
		load_keybind("X", skill_slotX, "X", config)
		load_keybind("C", skill_slotC, "C", config)
		load_keybind("R", skill_slotR, "R", config)
		load_keybind("F", skill_slotF, "F", config)
		load_keybind("T", skill_slotT, "T", config)
		load_keybind("V", skill_slotV, "V", config)
		load_keybind("G", skill_slotG, "G", config)
		load_keybind("B", skill_slotB, "B", config)
		load_keybind("Y", skill_slotY, "Y", config)
		load_keybind("H", skill_slotH, "H", config)
		load_keybind("N", skill_slotN, "N", config)
		load_keybind("F1", skill_slotF1, "F1", config)
		load_keybind("F2", skill_slotF2, "F2", config)
		load_keybind("F3", skill_slotF3, "F3", config)
		load_keybind("F4", skill_slotF4, "F4", config)


		skill_slot_label_1.text = config.get_value("Keybinds", "Skill1", "")
		skill_slot_label_2.text = config.get_value("Keybinds", "Skill2", "")
		skill_slot_label_3.text = config.get_value("Keybinds", "Skill3", "")
		skill_slot_label_4.text = config.get_value("Keybinds", "Skill4", "")
		skill_slot_label_5.text = config.get_value("Keybinds", "Skill5", "")
		skill_slot_label_6.text = config.get_value("Keybinds", "Skill6", "")
		skill_slot_label_7.text = config.get_value("Keybinds", "Skill7", "")
		skill_slot_label_8.text = config.get_value("Keybinds", "Skill8", "")
		skill_slot_label_9.text = config.get_value("Keybinds", "Skill9", "")
		skill_slot_label_0.text = config.get_value("Keybinds", "Skill0", "")
		skill_slot_label_Q.text = config.get_value("Keybinds", "SkillQ", "")
		skill_slot_label_E.text = config.get_value("Keybinds", "SkillE", "")
		skill_slot_label_Z.text = config.get_value("Keybinds", "SkillZ", "")
		skill_slot_label_X.text = config.get_value("Keybinds", "SkillX", "")
		skill_slot_label_C.text = config.get_value("Keybinds", "SkillC", "")
		skill_slot_label_R.text = config.get_value("Keybinds", "SkillR", "")
		skill_slot_label_F.text = config.get_value("Keybinds", "SkillF", "")
		skill_slot_label_T.text = config.get_value("Keybinds", "SkillT", "")
		skill_slot_label_V.text = config.get_value("Keybinds", "SkillV", "")
		skill_slot_label_G.text = config.get_value("Keybinds", "SkillG", "")
		skill_slot_label_B.text = config.get_value("Keybinds", "SkillB", "")
		skill_slot_label_Y.text = config.get_value("Keybinds", "SkillY", "")
		skill_slot_label_H.text = config.get_value("Keybinds", "SkillH", "")
		skill_slot_label_N.text = config.get_value("Keybinds", "SkillN", "")

		skill_slot_label_F1.text = config.get_value("Keybinds", "SkillF1", "")
		skill_slot_label_F2.text = config.get_value("Keybinds", "SkillF2", "")
		skill_slot_label_F3.text = config.get_value("Keybinds", "SkillF3", "")
		skill_slot_label_F4.text = config.get_value("Keybinds", "SkillF4", "")


	else:
		print("Error loading keybinds:", error)

func load_keybind(action_name, button, input_action, config)->void:
	var keybinds = config.get_value("Keybinds", action_name, [])
	for keybind in keybinds:
		InputMap.action_add_event(input_action, keybind)
	var key_name = OS.get_scancode_string(keybinds[0].scancode) if keybinds else "Unknown"


