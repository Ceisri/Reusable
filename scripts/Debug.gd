extends Control

onready var parent:KinematicBody = get_parent().get_parent()

func _physics_process(delta: float) -> void:
	if parent.is_in_group("Player"):
		if visible == true:
			if Engine.get_physics_frames() % 2 == 0:
				checkTrue()
			if Engine.get_physics_frames() % 6 == 0:
				debugPerformance()
				bugFinderAction()
			if Engine.get_physics_frames() % 24 == 0:
				debugCombat()

func _input(event:InputEvent) -> void:
	if Input:
		if Engine.get_physics_frames() % 2 == 0:
			inventoryDebug()



onready var combat_info =  $CombatLabel
var error_message:String = ""
var who_got_hit:String = ""
var damage_post_mitigation:String  = ""
var time_passed_since_last_hit:float = 0
var backstab_treshold:float 
var flanked:bool = false
var backstab:bool = false
func debugCombat()-> void:
	var error:String = "\n" +error_message
	var hit:String = "\n" + who_got_hit
	var dmg_to_take:String = "\npost-mitigation: " + str(damage_post_mitigation)
	var bck_tresh:String = "\nangle between me and victim: " + str(backstab_treshold)
	var flank_string:String = "\nflanked: " + str(flanked) 
	var backstab_string:String = "\nbackstabbed: " + str(backstab) 
	if damage_post_mitigation == "":
		dmg_to_take = ""
	else:
		time_passed_since_last_hit +=  1
	combat_info.text = error+\
					   hit  +\
					   dmg_to_take+\
					   bck_tresh+\
					   flank_string+\
					   backstab_string+\
					   "\n" + str(time_passed_since_last_hit) + " seconds ago"
					   

onready var engine_label:Label =  $EngineLabel
var debug_mode:bool = true

func _on_Debug_pressed()->void:
	debug_mode = !debug_mode
	visible = !visible
	
func debugPerformance() -> void:
#	var weapon_enum = Icons.weapon_type_list
#	var weapon_value = parent.weapon_type
#	var weapon_name = weapon_enum.keys()[weapon_value]
#
#	var main_weapon_enum = Icons.main_weap_list
#	var main_weapon_value = parent.main_weapon
#	var main_weapon_name = main_weapon_enum.keys()[main_weapon_value]
#
#	var sec_weapon_enum = Icons.sec_weap_list
#	var sec_weapon_value = parent.sec_weapon
#	var sec_weapon_name = sec_weapon_enum.keys()[sec_weapon_value]
#	# Prepare each line of the debug text separately
#	var state_line = "\nState: " + state_name
#	var weapon_line = "\nWeapon Stance: " + weapon_name
#	var main_weapon_line = "\nRight Hand: " + main_weapon_name
#	var sec_weapon_line = "\nLeft Hand: " + sec_weapon_name
#	var stunned_line = "\nStunned: " + str(stunned_duration)
#	var knockeddown_line = "\nKnocked Down: " + str(knockeddown_duration)
#	var staggered_line = "\nStaggered: " + str(staggered_duration)
#	var dir_assist = "\nDirection Assist: " + str(direction_assist)
#	var long_base_atk_line = "\nLong Base Attack: " + str(long_base_atk) +"\n"+"\n"+"\n"
	# Add maximum engine physics frames and process frames
	var engine_frames_passed = "\nEngine ticks passed: " + str(Engine.get_physics_frames())
	var max_process_frames_line = "\nMax Process Frames: " + str(Engine.get_target_fps())
	var max_physics_frames_line = "\nPhysics ticks" + str(Engine.get_physics_interpolation_fraction())
	var num_nodes_line = "\nNumber of Nodes: " + str(get_tree().get_node_count())
	# Get dynamic memory usage using OS.get_dynamic_memory_usage()
	var dynamic_memory_bytes = OS.get_dynamic_memory_usage()
	# Convert bytes to megabytes (MB) and format to show values after the decimal point
	var dynamic_memory_mb = dynamic_memory_bytes / 1024.0 / 1024.0
	# Convert to string with two decimal places
	var dynamic_memory = "\nDynamic Memory: " + str(round(dynamic_memory_mb * 100) / 100) + " MB"
	# Get static memory usage using GDNative or external libraries
	var battery_line = "\nBattery left: " +str(OS.get_power_percent_left()) + "%"
	#Returns the number of logical CPU cores available on the host machine. 
	#On CPUs with HyperThreading enabled, this number will be greater than the number of physical CPU cores.
	var processor_count = "\nCPU cores free: " +str(OS.get_processor_count())
	var processor_name = "\nProcessor Name: " +str(OS.get_processor_name())
	#Returns the total number of available audio drivers.
	var audio_proc_count = "\nAudio drivers free: " +str(OS.get_audio_driver_count())
	var audio_name = "\nAudio drivers name: " +str(OS.get_audio_driver_name(1))
	var device_id = "\nDevice ID: " +str(OS.get_unique_id())
	var time_zone = "\nTimeZone: " + str(OS.get_time_zone_info())
	
	# Concatenate all lines into debug_text
	var debug_text =max_process_frames_line+\
					num_nodes_line+\
					max_physics_frames_line+\
					engine_frames_passed+\
					dynamic_memory+\
					battery_line+\
					processor_count+\
					processor_name+\
					audio_proc_count+\
					audio_name+\
					device_id+\
					time_zone
	
	# Assign the constructed debug text to the Debug node's text property
	engine_label.text = debug_text



var active_action:String = ""
var last_skills:String = ""
onready var action_label:Label = $ActionLabel
func bugFinderAction() -> void:
	var last_skill_used = "\nLast Skill Used: " + last_skills
	var skill_bar_key_pressed = "Skillbar Key Pressed: " + parent.skill_bar_input
	var animation = "\nAnimation: " + str(parent.animation.current_animation)
	var action = "\nAction: " + active_action
	var movement = "\nmovement" + parent.movement_mode + " speed: " + str(parent.movement_speed)
	
	var debug_text =skill_bar_key_pressed +\
					animation+\
					action+\
					last_skill_used+\
					movement
	action_label.text = debug_text


onready var bools_label:Label = $BoolLabel
func checkTrue()-> void:
	var bools_text = ""

	if parent.garrote_active:
		bools_text += "garrote_active: True\n"

	if parent.staggered:
		bools_text += "staggered: True\n"

	if parent.knockeddown:
		bools_text += "knockeddown: True\n"

	# If none of the booleans are true, bools_text will remain ""
	bools_label.text = bools_text


onready var inv_label:Label = $InventoryDebug
var selected_slot = null
var last_pressed_button = null
func inventoryDebug() -> void:
	var inv_text = ""

	if selected_slot != null:
		inv_text += "selected slot: " + str(selected_slot) + "\n"
	else:
		inv_text += "selected slot: \n"

	if last_pressed_button != null:
		inv_text += "last pressed slot: " + str(last_pressed_button) + "\n"
	else:
		inv_text += "last pressed slot: \n"

	inv_label.text = inv_text

onready var harvest_label:Label = $HarvestLabel
var harvested_item_size:float 
var harvested_item:Node = null
func debugHarvesting() -> void:
	var harvest_text = ""

	if harvested_item != null:
		harvest_text += "harvested: " + harvested_item.name + "\n"
	else:
		harvest_text += "harvested: \n"

	harvest_text += "size: " + str(harvested_item_size) + "\n"

	harvest_label.text = harvest_text
	
