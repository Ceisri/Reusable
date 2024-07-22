extends Node

onready var player:KinematicBody = get_parent()
onready var grid: GridContainer =  $"../Canvas/Skillbar/GridContainer"
var demon_distance: float = 10.0 
var summon_cooldown: float = 0.15 
var last_summon_time: float = 0.0 

var queue_skills:bool = true #this is only for people with disabilities or if the game ever goes online to help with high ping, as of now it can't be used by itself until I revamp the skill cancel system  
func _ready()->void:
	pass
	#connect("pressed", self , "pressed")

func pressed()->void:
	queue_skills = !queue_skills
	player.switchButtonTextures()
	
	
func comboSystem():
	pass

func updateCD(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		label.text = str(round(remaining_cooldown* 10) / 10)
	else:
		label.text = ""

func modulateIcon(icon, cooldown, current_time, last_time) -> void:
	# Interpolate the texture albedo from red to white based on the cooldown
	var cooldown_ratio = (current_time - last_time) / cooldown
	cooldown_ratio = clamp(cooldown_ratio, 0.0, 1.0)
	
	var red_color = Color(1, 0, 0)
	var white_color = Color(1, 1, 1)
	var interpolated_color = Color(
		lerp(red_color.r, white_color.r, cooldown_ratio),
		lerp(red_color.g, white_color.g, cooldown_ratio),
		lerp(red_color.b, white_color.b, cooldown_ratio),
		lerp(red_color.a, white_color.a, cooldown_ratio)
	)
	# Assuming the icon is a Sprite or similar with a modulate property
	icon.modulate = interpolated_color
	
	if icon.get_parent().get_node("CD").text == "":
		icon.modulate = white_color

func updateCooldownLabel() -> void:
	var current_time = OS.get_ticks_msec() / 1000.0
	for child in grid.get_children():
		var icon = child.get_node("Icon")

		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.garrote.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,garrote_cooldown,current_time,last_garrote_time)
				modulateIcon(icon,garrote_cooldown,current_time,last_garrote_time)
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.silent_stab.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,silent_stab_cooldown,current_time,last_silent_stab_time)
				modulateIcon(icon,silent_stab_cooldown,current_time,last_silent_stab_time)
		
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.switch_element.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,switch_element_cooldown,current_time,last_switch_element_time)
				modulateIcon(icon,switch_element_cooldown,current_time,last_switch_element_time)
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.triple_fireball.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,triple_fireball_cooldown,current_time,last_triple_fireball_time)
				modulateIcon(icon,triple_fireball_cooldown,current_time,last_triple_fireball_time)
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.triple_fireball.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,triple_fireball_cooldown,current_time,last_triple_fireball_time)
				modulateIcon(icon,triple_fireball_cooldown,current_time,last_triple_fireball_time)
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.immolate.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,immolate_cooldown,current_time,last_immolate_time)
				modulateIcon(icon,immolate_cooldown,current_time,last_immolate_time)
				
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.ring_of_fire.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,ring_of_fire_cooldown,current_time,last_ring_of_fire_time)
				modulateIcon(icon,ring_of_fire_cooldown,current_time,last_ring_of_fire_time)
		if icon != null and icon.texture != null and icon.texture.resource_path == Icons.wall_of_fire.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateCD(label,wall_of_fire_cooldown,current_time,last_wall_of_fire_time)
				modulateIcon(icon,wall_of_fire_cooldown,current_time,last_wall_of_fire_time)
				
				
				
				
# List of skill cooldowns and last times for easier access and reset
enum Skills {
	garrote,
	silent_stab,
	fireball,
	triple_fireball,
	immolate,
	ring_of_fire,
	wall_of_fire
}


var skill_cooldowns = {
	Skills.garrote: {"cooldown": garrote_cooldown, "last_time": last_garrote_time},
	Skills.silent_stab: {"cooldown": silent_stab_cooldown, "last_time": last_silent_stab_time},
	Skills.fireball: {"cooldown": fireball_cooldown, "last_time": last_fireball_time},
	Skills.triple_fireball: {"cooldown": triple_fireball_cooldown, "last_time": last_triple_fireball_time},
	Skills.immolate: {"cooldown": immolate_cooldown, "last_time": last_immolate_time},
	Skills.ring_of_fire: {"cooldown": ring_of_fire_cooldown, "last_time": last_ring_of_fire_time},
	Skills.wall_of_fire: {"cooldown": wall_of_fire_cooldown, "last_time": last_wall_of_fire_time}
}
func resetCD(skill_to_reset: int) -> void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if skill_to_reset in skill_cooldowns:
		var skill_data = skill_cooldowns[skill_to_reset]
		if skill_data.has("cooldown"):
			# Directly set last_time to 0.0
			skill_data["last_time"] = 0.0
		else:
			print("Cooldown value for skill ", skill_to_reset, " is not set.")
	else:
		print("Skill ", skill_to_reset, " is not found in skill_cooldowns.")

func updateLastTimes(skill_to_update: int) -> void:
	if skill_cooldowns.has(skill_to_update):
		match skill_to_update:
			Skills.garrote:
				last_garrote_time = skill_cooldowns[Skills.garrote]["last_time"]
			Skills.silent_stab:
				last_silent_stab_time = skill_cooldowns[Skills.silent_stab]["last_time"]
			Skills.fireball:
				last_fireball_time = skill_cooldowns[Skills.fireball]["last_time"]
			Skills.triple_fireball:
				last_triple_fireball_time = skill_cooldowns[Skills.triple_fireball]["last_time"]
			Skills.immolate:
				last_immolate_time = skill_cooldowns[Skills.immolate]["last_time"]
			Skills.ring_of_fire:
				last_ring_of_fire_time = skill_cooldowns[Skills.ring_of_fire]["last_time"]
			Skills.wall_of_fire:
				last_wall_of_fire_time = skill_cooldowns[Skills.wall_of_fire]["last_time"]
	else:
		print("Last time for skill ", skill_to_update, " is not set or skill is not found.")

# Example of resetting fireball cooldown
func fireballCD() -> void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_fireball_time >= fireball_cooldown:
		last_fireball_time = current_time
		resetCD(Skills.ring_of_fire)
		updateLastTimes(Skills.ring_of_fire)





var fireball_cooldown: float = 0
var last_fireball_time: float = 0.0 
var fireball_cost: float = 10

var triple_fireball_cooldown: float = 3
var last_triple_fireball_time: float = 0.0 
var triple_fireball_blast_cost: float = 7


var wall_of_fire_cooldown: float = 12
var last_wall_of_fire_time: float = 0.0 
var wall_of_fire_cost: float = 10

var ring_of_fire_cooldown: float = 20
var last_ring_of_fire_time: float = 0.0 
var ring_of_fire_cost: float = 10


var garrote_cooldown: float = 7
var last_garrote_time: float = 0.0 
var garrote_cost: float = 10

var silent_stab_cooldown: float = 2
var last_silent_stab_time: float = 0.0 
var silent_stab_cost: float = 10




var switch_element_cooldown: float = 1
var last_switch_element_time: float = 0.0 
var switch_element_cost: float = 10
var selected_element:String = "fire"

# List of elements to cycle through
var elements: Array = ["lightning", "fire", "ice", "shadow", "wind", "none"]


func SwitchElementCD() -> void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_switch_element_time >= switch_element_cooldown:
		last_switch_element_time = current_time

		# Find the index of the current element
		var current_index: int = elements.find(selected_element)
		
		# Check if the element is in the list
		if current_index != -1:
			# Calculate the index of the next element, ensuring it wraps around
			var next_index: int = (current_index + 1) % elements.size()
			selected_element = elements[next_index]
		else:
			# If the current element is not in the list, default to the first element
			selected_element = elements[0]

		# Output the new selected element (for debugging or confirmation)
		print("Selected element:", selected_element)


var combo_distance: float = 4# the move distance of base of base attacks when long_base_atk is true 
var cleave_distance: float = 5 # the move distance of base of base attacks  when long_base_atk is false
var combo_extr_speed: float = 0.15 # when long_base_atk is true the player does a 4 hit base attack, compensate by making it faster
var combo_switch_description: String = "switch between short and long combo mode, in short mode your base attack combo ends at with second attack, activating all related combos, on long combo it will end with the forth attack"
var combo_switch_cooldown: float =  1
var last_combo_switch_time: float = 0.0 
var can_combo_switch:bool = true
func comboSwitchCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_combo_switch_time >= combo_switch_cooldown:
		last_combo_switch_time = current_time
		player.long_base_atk = !player.long_base_atk

#___________________________________________________________________________________________________
var dash_cooldown: float = 2
var last_dash_time: float = 0.0 
var dash_cost: float = 10
func dashCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_dash_time >= dash_cooldown:
			last_dash_time = current_time

#___________________________________________________________________________________________________
var slide_cooldown: float = 5
var last_slide_time: float = 0.0 
var slide_cost: float = 10
func slideCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_slide_time >= slide_cooldown:
		last_slide_time = current_time


#___________________________________________________________________________________________________
var backstep_distance: float = 9
var backstep_cooldown: float = 6
var last_backstep_time: float = 0.0 
func backstepCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_backstep_time >= backstep_cooldown:
		last_backstep_time = current_time

#___________________________________________________________________________________________________

func silentStabCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_silent_stab_time >= silent_stab_cooldown:
		last_silent_stab_time = current_time
		player.active_action == "none"


func garroteCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_garrote_time >= garrote_cooldown:
		last_garrote_time = current_time


#func activateComboCyclone():
#	player.cyclone_combo = true
#	cyclone_combo_start_time = OS.get_ticks_msec() / 1000.0



#var fireball_cooldown: float = 0.5
#var last_fireball_time: float = 0.0 
#var fireball_cost: float = 10
#func fireballCD()->void:
#	var current_time: float = OS.get_ticks_msec() / 1000.0
#	if current_time - last_fireball_time >= fireball_cooldown:
#		last_fireball_time = current_time
#
#func resetCooldown(skill to reset)->void:


var lighting: PackedScene = preload("res://Game/World/Player/Skill_Scenes/lighting.tscn")
func placeLighting(damage):
	var player_transform: Transform = player.global_transform
	var camera_transform: Transform = player.camera.global_transform
	var camera_forward: Vector3 = -camera_transform.basis.z.normalized()
	var shoot_position: Vector3 = player_transform.origin + camera_forward * 1.1
	shoot_position.y =   player_transform.origin.y + vertical_spawn_offset
	var lighting_instance = lighting.instance()
	lighting_instance.summoner = player
	lighting_instance.damage = damage
	Root.add_child(lighting_instance)
	lighting_instance.global_transform.origin = shoot_position
	lighting_instance.look_at_from_position(shoot_position, shoot_position - player.direction, Vector3.UP)




		
var fireball: PackedScene = preload("res://Game/World/Player/Skill_Scenes/Fireball.tscn")
var vertical_spawn_offset: float = 1.2
func shootFireball(damage):
	var camera = player.camera 
	var player_global_transform: Transform = player.global_transform
	var fireball_instance: KinematicBody
	var player_direction = player.direction
	var camera_transform: Transform = camera.global_transform
	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
	var player_forward: Vector3 = player_global_transform.basis.z.normalized()

	var camera_global_transform: Transform = camera.global_transform
	var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
	var shoot_position: Vector3 = player.global_transform.origin + camera_forward * 0.5
	shoot_position.y += vertical_spawn_offset 
	var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
	# Shoot the first bullet towards where the camera is looking at
	fireball_instance = fireball.instance()
	fireball_instance.direction = camera_forward
	fireball_instance.summoner = player
	fireball_instance.damage =  damage  
	Root.add_child(fireball_instance)
	fireball_instance.global_transform.origin = shoot_position
	# Orient to match player direction
	fireball_instance.look_at_from_position(shoot_position, shoot_position - player_direction, Vector3.UP)




var immolate_cooldown: float = 0.5
var last_immolate_time: float = 0.0 
var immolate_cost: float = 10
func immolateCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_immolate_time >= immolate_cooldown:
		last_immolate_time = current_time
		
var immolate: PackedScene = preload("res://Game/World/Player/Skill_Scenes/FireBreath.tscn")
func shootImmolate(damage):
	var camera = player.camera 
	var player_global_transform: Transform = player.global_transform
	var immolate_instance: KinematicBody
	var player_direction = player.direction
	var camera_transform: Transform = camera.global_transform
	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
	var player_forward: Vector3 = player_global_transform.basis.z.normalized()

	var camera_global_transform: Transform = camera.global_transform
	var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
	var shoot_position: Vector3 = player.global_transform.origin + camera_forward * 0.5
	shoot_position.y += 0.5
	var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
	# Shoot the first bullet towards where the camera is looking at
	immolate_instance = immolate.instance()
	immolate_instance.summoner = player
	immolate_instance.damage =  damage  
	Root.add_child(immolate_instance)
	immolate_instance.global_transform.origin = shoot_position
	# Orient to match player direction
	immolate_instance.look_at_from_position(shoot_position, shoot_position - player_direction, Vector3.UP)







		
func tripleFireballCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_triple_fireball_time >= triple_fireball_cooldown:
		last_triple_fireball_time = current_time
func shootTripleFireball(damage):
	var player_global_transform: Transform = player.global_transform
	var fireball_instance: KinematicBody
	var player_direction = player.direction
	var camera_transform: Transform = player.camera.global_transform
	var camera_rotation_x: float = camera_transform.basis.get_euler().x
	var strength_factor: float = 1.0
	var player_forward: Vector3 = player_global_transform.basis.z.normalized()
	
	var camera_global_transform: Transform = player.camera.global_transform
	var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized()
	var shoot_position: Vector3 = player.global_transform.origin + camera_forward * (0.5 + 1.5)
	shoot_position.y += vertical_spawn_offset
	var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
	
	# Shoot the first bullet towards where the camera is looking at
	fireball_instance = fireball.instance()
	fireball_instance.direction = camera_forward
	fireball_instance.summoner = player
	fireball_instance.damage = damage
	Root.add_child(fireball_instance)
	fireball_instance.look_at_from_position(shoot_position, shoot_position - player_direction, Vector3.UP)
	fireball_instance.global_transform.origin = shoot_position
	
	# Calculate spawn positions for diagonally shot bullets relative to shoot_position
	var spawn_position2: Vector3 = shoot_position + camera_right * 0.5
	var spawn_position3: Vector3 = shoot_position - camera_right * 0.5
	
	# Calculate the directions for the second and third bullets to be diagonally left and right
	var second_bullet_direction = (camera_forward + camera_right * 0.6).normalized()
	var third_bullet_direction = (camera_forward - camera_right * 0.6).normalized()
	
	# Shoot the second bullet
	fireball_instance = fireball.instance()
	fireball_instance.direction = second_bullet_direction
	fireball_instance.summoner = player
	fireball_instance.damage = damage
	Root.add_child(fireball_instance)
	fireball_instance.look_at_from_position(shoot_position, shoot_position - second_bullet_direction, Vector3.UP)
	fireball_instance.global_transform.origin = spawn_position2
	
	# Shoot the third bullet
	fireball_instance = fireball.instance()
	fireball_instance.direction = third_bullet_direction
	fireball_instance.summoner = player
	fireball_instance.damage = damage
	Root.add_child(fireball_instance)
	fireball_instance.look_at_from_position(shoot_position, shoot_position - third_bullet_direction, Vector3.UP)
	fireball_instance.global_transform.origin = spawn_position3

		
		
func ringOfFireCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_ring_of_fire_time >= ring_of_fire_cooldown:
		last_ring_of_fire_time = current_time

var ring_of_fire: PackedScene = preload("res://Game/World/Player/Skill_Scenes/FireRing.tscn")
func placeRingOfFire(ring_of_fire_damage):
	var player_transform: Transform = player.global_transform
	var camera_transform: Transform = player.camera.global_transform
	var camera_forward: Vector3 = -camera_transform.basis.z.normalized()
	var shoot_position: Vector3 = player_transform.origin + camera_forward * 10.0
	shoot_position.y = player_transform.origin.y
	
	var ring_of_fire_instance: Area = ring_of_fire.instance()
	ring_of_fire_instance.summoner = player
	ring_of_fire_instance.damage = ring_of_fire_damage 
	Root.add_child(ring_of_fire_instance)
	ring_of_fire_instance.global_transform.origin = shoot_position



func wallOfFireCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_wall_of_fire_time >= wall_of_fire_cooldown:
		last_wall_of_fire_time = current_time
var wall_of_fire: PackedScene = preload("res://Game/World/Player/Skill_Scenes/FireWall.tscn")
func placeWallOfFire(wall_of_fire_damage):
	var player_transform: Transform = player.global_transform
	var player_direction: Vector3 = player.direction.normalized()
	var shoot_position: Vector3 = player_transform.origin + player_direction * 10.0
	shoot_position.y = player_transform.origin.y
	
	var wall_of_fire_instance: Area = wall_of_fire.instance()
	wall_of_fire_instance.summoner = player
	wall_of_fire_instance.damage = wall_of_fire_damage 
	Root.add_child(wall_of_fire_instance)
	wall_of_fire_instance.global_transform.origin = shoot_position
	
	# Orient to match player direction
	wall_of_fire_instance.look_at_from_position(shoot_position, shoot_position - player_direction, Vector3.UP)





#___________________________________________________________________________________________________
#call this function and write in the string which skill to NOT  be cancelled, all the others 
#will go in cooldown if they are activated  as well as being turned off allowing for smooth skill cancelling 
func skillCancel(string:String)->void:
	if player.skill_cancelling == true:
		match string:
			"none":
				interruptBackstep()
				interruptBaseAtk()
				match player.previous_action:
					"silent stab":
						silentStabCD()
					"garrote":
						garroteCD()
					"fireball":
						fireballCD()
					"triple fireball":
						tripleFireballCD()
					"immolate":
						immolateCD()
					"ring of fire":
						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
			"silent stab":
				match player.previous_action:
#					"silent stab":
#						silentStabCD()
					"garrote":
						garroteCD()
					"fireball":
						fireballCD()
					"triple fireball":
						tripleFireballCD()
					"immolate":
						immolateCD()
					"ring of fire":
						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
			"garrote":
				match player.previous_action:
					"silent stab":
						silentStabCD()
#					"garrote":
#						garroteCD()
					"fireball":
						fireballCD()
					"triple fireball":
						tripleFireballCD()
					"immolate":
						immolateCD()
					"ring of fire":
						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
			"fireball":
				match player.previous_action:
					"silent stab":
						silentStabCD()
					"garrote":
						garroteCD()
#					"fireball":
#						fireballCD()
					"triple fireball":
						tripleFireballCD()
					"immolate":
						immolateCD()
					"ring of fire":
						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
			"triple fireball":
				match player.previous_action:
					"silent stab":
						silentStabCD()
					"garrote":
						garroteCD()
					"fireball":
						fireballCD()
#					"triple fireball":
#						tripleFireballCD()
					"immolate":
						immolateCD()
					"ring of fire":
						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
			"ring of fire":
				match player.previous_action:
					"silent stab":
						silentStabCD()
					"garrote":
						garroteCD()
					"fireball":
						fireballCD()
					"triple fireball":
						tripleFireballCD()
					"immolate":
						immolateCD()
#					"ring of fire":
#						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
			"wall of fire":
				match player.previous_action:
					"silent stab":
						silentStabCD()
					"garrote":
						garroteCD()
					"fireball":
						fireballCD()
					"triple fireball":
						tripleFireballCD()
					"immolate":
						immolateCD()
					"ring of fire":
						ringOfFireCD()
#					"wall of fire":
#						wallOfFireCD()
			"immolate":
				match player.previous_action:
					"silent stab":
						silentStabCD()
					"garrote":
						garroteCD()
					"fireball":
						fireballCD()
					"triple fireball":
						tripleFireballCD()
#					"immolate":
#						immolateCD()
					"ring of fire":
						ringOfFireCD()
					"wall of fire":
						wallOfFireCD()
						
						
func interruptBaseAtk():
	pass

func interruptBackstep()->void:
	pass
		
func getInterrupted()->void:#Universal stop, call this when I'm stunned, staggered, dead, knocked down and so on 
	player.active_action = "none"
	interruptBackstep()
	interruptBaseAtk()
	match player.previous_action:
		"garrote":
			garroteCD()
		"silent stab":
			silentStabCD()
		"ring of fire":
			ringOfFireCD()
