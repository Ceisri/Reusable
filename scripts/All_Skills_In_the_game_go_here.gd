extends Control

onready var player:Spatial = $"../../.."
onready var grid: GridContainer = $"../../../SkillBar/GridContainer"
var demon : PackedScene = preload("res://Classes/Necromant/Necromant Summonable Servants/Wraith.tscn")
var demon_distance: float = 10.0 
var summon_cooldown: float = 0.15 
var last_summon_time: float = 0.0 

var masochism : int = 1 


func updateCooldownLabel() -> void:
	var current_time = OS.get_ticks_msec() / 1000.0
	for child in $"../SkillBar/GridContainer".get_children():
		var icon = child.get_node("Icon")
		if icon != null and icon.texture != null and icon.texture.resource_path == autoload.summon_shadow.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateLabel(label,summon_cooldown, current_time,summon_cooldown)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.dominion.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateLabel(label,switch_cooldown, current_time,last_switch_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.tribute.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateLabel(label,tribute_cooldown, current_time,last_tribute_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.servitude.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				updateLabel(label,spell_cooldown, current_time,last_spell_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.arcane_blast.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateLabel(label, arcane_blast_cooldown, current_time, last_arcane_blast_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.necromant_switch.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateLabel(label,necro_switch_cooldown, current_time, last_necro_switch_time)
#___________________________________________Overhand and Underhand strike cooldowns_________________
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.overhead_slash.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateLabel2(label,overhead_slash_cooldown, current_time,last_overhead_slash_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.underhand_slash.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateUnderhand(label,underhand_slash_cooldown, current_time,last_underhand_slash_time)
#__________________________________________________Cyclone__________________________________________
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.cyclone.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateLabelCyclone(label,autoload.cyclone_cooldown, current_time,last_cyclone_time)
#__________________________________________________Whirlwind__________________________________________
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.whirlwind.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateWhirlwind(label,whirlwind_cooldown, current_time,last_whirlwind_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.counter_strike.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateLabelCounter(label,counter_cooldown, current_time,last_counter_time)
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.counter_strike.get_path():
			var label: Label = child.get_node("CD")
			if label != null:
				 updateLabelPotion(label,potion_cooldown, current_time,last_potion_time)
				
				
				
				
var can_overhead_slash: bool = false
func updateLabel2(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_overhead_slash = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_overhead_slash = true
		
		
var can_drink_potion: bool = true
func updateLabelPotion(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_drink_potion = false
		label.text = str(round(remaining_cooldown))
	else:
		label.text = ""
		can_drink_potion = true
var can_fury_strike: bool = false
func updateLabelFuryStrike(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	#print("remaining_cooldown:", remaining_cooldown)
	if remaining_cooldown!= 0:
		can_fury_strike = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_fury_strike = true
		
		
var can_cyclone: bool = false
func updateLabelCyclone(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	#print("remaining_cooldown:", remaining_cooldown)
	if remaining_cooldown!= 0:
		can_cyclone = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_cyclone = true
var can_counter: bool = false
func updateLabelCounter(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	#print("remaining_cooldown:", remaining_cooldown)
	if remaining_cooldown!= 0:
		can_counter = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_counter = true
		
		
		
		

func updateLabel(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	#print("remaining_cooldown:", remaining_cooldown)
	if remaining_cooldown!= 0:
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""



onready var camera: Camera = $"../../../../../Camroot/h/v/Camera"
var base_attack: PackedScene = preload("res://Classes/Necromant/Spells/ArcaneBlast.tscn")
var vertical_spawn_offset: float = 0.8
var forward_offset: float = 1
var base_damage: float = 5
var base_attack_damage: float  
var base_attack_cost = 0.5
func baseAttack():
	base_attack_damage = base_damage * (player.intelligence)
	var current_time: float = OS.get_ticks_msec() / 1000.0
	var player_global_transform: Transform = player.global_transform
	var arcane_blast_instance: KinematicBody
	var player_direction = player.direction
	var camera_transform: Transform = camera.global_transform
	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
	var player_forward: Vector3 = player_global_transform.basis.z.normalized()
	if player.nefis >= base_attack_cost:
		player.nefis -= base_attack_cost
		match player.aiming_mode:
			"directional":
				var shoot_position: Vector3 = player.global_transform.origin
				shoot_position += player_forward * (forward_offset)
				shoot_position.y += vertical_spawn_offset
				if camera_rotation_x > 0:
					strength_factor = 2
				else:
					strength_factor = 0.9
				# Calculate the modified direction using the rotation of the camera
				var modified_direction: Vector3 = player_direction + Vector3.UP * camera_rotation_x * strength_factor
				# Shoot the first bullet straight ahead from shoot_spawn_point
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = modified_direction.normalized()
				arcane_blast_instance.instigator = player
				arcane_blast_instance.summoner = player
				arcane_blast_instance.damage = damage
				get_tree().current_scene.add_child(arcane_blast_instance)
				arcane_blast_instance.global_transform.origin = shoot_position
			"camera":
				var camera_global_transform: Transform = camera.global_transform
				var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
				var shoot_position: Vector3 = player.global_transform.origin + camera_forward * (forward_offset + 1.5)
				shoot_position.y += vertical_spawn_offset
				var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
				# Shoot the first bullet towards where the camera is looking at
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = camera_forward
				arcane_blast_instance.instigator = player
				arcane_blast_instance.summoner = player
				arcane_blast_instance.damage = base_attack_damage
				get_tree().current_scene.add_child(arcane_blast_instance)
				arcane_blast_instance.global_transform.origin = shoot_position

var arcane_blast: PackedScene = preload("res://Classes/Necromant/Spells/ArcaneBlast.tscn")
var arcane_blast_cooldown: float = 3
var last_arcane_blast_time: float = 0.0 
var arcane_blast_cost: float = 0
var damage: float = 20
func arcaneBlast():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	var player_global_transform: Transform = player.global_transform
	var arcane_blast_instance: KinematicBody
	var player_direction = player.direction
	var camera_transform: Transform = camera.global_transform
	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
	var player_forward: Vector3 = player_global_transform.basis.z.normalized()
	if current_time - last_arcane_blast_time >= arcane_blast_cooldown:
		if player.nefis >= arcane_blast_cost:
			player.nefis -= arcane_blast_cost # skill cost
			last_arcane_blast_time = current_time
			match player.aiming_mode:
				"directional":
					var shoot_position: Vector3 = player.global_transform.origin
					shoot_position += player_forward * (forward_offset)
					shoot_position.y += vertical_spawn_offset
					if camera_rotation_x > 0:
						strength_factor = 2
					else:
						strength_factor = 0.9
					# Calculate the modified direction using the rotation of the camera
					var modified_direction: Vector3 = player_direction + Vector3.UP * camera_rotation_x * strength_factor
					# Shoot the first bullet straight ahead from shoot_spawn_point
					arcane_blast_instance = arcane_blast.instance()
					arcane_blast_instance.direction = modified_direction.normalized()
					arcane_blast_instance.instigator = player 
					arcane_blast_instance.summoner = player 
					arcane_blast_instance.damage = damage
					get_tree().current_scene.add_child(arcane_blast_instance)
					arcane_blast_instance.global_transform.origin = shoot_position
					# Calculate the spawn positions for diagonally shot bullets relative to shoot_spawn_point
					var spawn_position2: Vector3 = shoot_position + player_forward.rotated(Vector3.UP, deg2rad(-30)).normalized() 
					var spawn_position3: Vector3 = shoot_position + player_forward.rotated(Vector3.UP, deg2rad(30)).normalized() 
					# Adjust spawn positions vertically based on the camera's rotation
					spawn_position2 += Vector3.UP * camera_rotation_x * strength_factor
					spawn_position3 += Vector3.UP * camera_rotation_x * strength_factor
					# Shoot the second bullet diagonally to the right
					arcane_blast_instance = arcane_blast.instance()
					arcane_blast_instance.direction = (spawn_position2 - shoot_position).normalized()
					arcane_blast_instance.instigator = player
					arcane_blast_instance.summoner = player
					arcane_blast_instance.damage = damage
					get_tree().current_scene.add_child(arcane_blast_instance)
					arcane_blast_instance.global_transform.origin = shoot_position
					# Shoot the third bullet diagonally to the left
					arcane_blast_instance = arcane_blast.instance()
					arcane_blast_instance.direction = (spawn_position3 - shoot_position).normalized()
					arcane_blast_instance.instigator = player
					arcane_blast_instance.summoner = player
					arcane_blast_instance.damage = damage
					 # Use the same shoot_position
					get_tree().current_scene.add_child(arcane_blast_instance)
					arcane_blast_instance.global_transform.origin = shoot_position
				"camera":
					var camera_global_transform: Transform = camera.global_transform
					var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
					var shoot_position: Vector3 = player.global_transform.origin + camera_forward * (forward_offset + 1.5)
					shoot_position.y += vertical_spawn_offset
					var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
					# Shoot the first bullet towards where the camera is looking at
					arcane_blast_instance = arcane_blast.instance()
					arcane_blast_instance.direction = camera_forward
					arcane_blast_instance.instigator =player
					arcane_blast_instance.summoner =player
					arcane_blast_instance.damage = damage
					get_tree().current_scene.add_child(arcane_blast_instance)
					arcane_blast_instance.global_transform.origin = shoot_position
					# Calculate spawn positions for diagonally shot bullets relative to shoot_position
					var spawn_position2: Vector3 = shoot_position + camera_right * (forward_offset / 4) # Further reduce the offset
					var spawn_position3: Vector3 = shoot_position - camera_right * (forward_offset / 4) # Further reduce the offset
					# Calculate the directions for the second and third bullets to be closer to the first bullet
					var second_bullet_direction = (camera_forward + camera_right * 0.6).normalized()
					var third_bullet_direction = (camera_forward - camera_right * 0.6).normalized()
					# Shoot the second bullet towards where the camera is looking at, closer to the first bullet
					arcane_blast_instance = arcane_blast.instance()
					arcane_blast_instance.direction = second_bullet_direction
					arcane_blast_instance.instigator = player
					arcane_blast_instance.summoner = player
					arcane_blast_instance.damage = damage
					get_tree().current_scene.add_child(arcane_blast_instance)
					arcane_blast_instance.global_transform.origin = spawn_position2
					# Shoot the third bullet towards where the camera is looking at, closer to the first bullet
					arcane_blast_instance = arcane_blast.instance()
					arcane_blast_instance.direction = third_bullet_direction
					arcane_blast_instance.instigator =player
					arcane_blast_instance.summoner = player
					arcane_blast_instance.damage = damage
					get_tree().current_scene.add_child(arcane_blast_instance)
					arcane_blast_instance.global_transform.origin = spawn_position3

var summoned_demons: int = 0
func summonDemon() -> void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_summon_time >= summon_cooldown:
		var player_global_transform: Transform = player.global_transform
		var player_forward: Vector3 = player_global_transform.basis.z.normalized()
		var spawn_position: Vector3 = player_global_transform.origin + player_forward * demon_distance
		spawn_position.y += 1.0  # Adjust Y-coordinate to spawn slightly above the player
		var demon_instance: Node = demon.instance()
		demon_instance.summoner = player
		demon_instance.command = current_command
		demon_instance.global_transform.origin = spawn_position
		get_tree().current_scene.add_child(demon_instance)
		summoned_demons += 1 
		last_summon_time = current_time



func loadServants():
	var i = 0
	while i < summoned_demons:
		var player_global_transform: Transform = player.global_transform
		var player_forward: Vector3 = player_global_transform.basis.z.normalized()
		var spawn_position: Vector3 = player_global_transform.origin + player_forward * demon_distance
		spawn_position.y += 1.0  # Adjust Y-coordinate to spawn slightly above the player
		var demon_instance: Node = demon.instance()
		demon_instance.summoner = player 
		demon_instance.command = current_command
		demon_instance.global_transform.origin = spawn_position
		get_tree().current_scene.add_child(demon_instance)
		i += 1




var switch_cooldown: float = 0.5
var last_switch_time: float = 0.0 
var switchCount: int = 0 # Counter to keep track of the number of switches
var current_command = "follow"
func commandSwitch() -> void:
	var currentTime = OS.get_ticks_msec() / 1000.0
	if currentTime - last_switch_time >= switch_cooldown:
		var playerParent = player
		var servants = get_tree().get_nodes_in_group("Servant")
		
		for servant in servants:
			var servantSummoner = servant.summoner
			if servantSummoner == playerParent:
				if switchCount % 2 == 0:
					current_command= "attack"
					servant.command = current_command
				else:
					current_command = "follow"
					servant.command = current_command
		
		switchCount += 1
		last_switch_time = currentTime


var sacrifice_cooldown: float = 0.5
var last_sacrifice_time: float = 0.0 
func tribute():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_tribute_time >= tribute_cooldown:
		var servants = get_tree().get_nodes_in_group("Servant")
		
		if servants.size() > 0:
			var servant_index = randi() % servants.size()  # Randomly select an index
			var servant_to_delete = servants[servant_index]  # Get the servant at the selected index
			servant_to_delete.health -= 25
			
			# Heal the player
			var player_parent = player
			if player_parent != null:
				player_parent.health += 100
				
		last_tribute_time = current_time
		
		
var tribute_cooldown: float = 0.5
var last_tribute_time: float = 0.0 
func sacrifice():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_tribute_time >= tribute_cooldown:
		var servants = get_tree().get_nodes_in_group("Servant")
		
		if servants.size() > 0:
			var servant_index = randi() % servants.size()  # Randomly select an index
			var servant_to_delete = servants[servant_index]  # Get the servant at the selected index
			servant_to_delete.queue_free()  # Delete the selected servant
			
			# Heal the player
			var player_parent = player
			if player_parent != null:
				player_parent.health += 100
				player_parent.nefis += 100
				player_parent.resolve += 100
				player_parent.breath += 100
				
		last_tribute_time = current_time

var area_spell : PackedScene = preload("res://Classes/Necromant/Spells/AOE.tscn")
var spell_cooldown: float = 3
var last_spell_time: float = 0.0 
var spell_distance: float = 12

func areaSpell() -> void:
	var camera: Camera = $"../../../../../Camroot/h/v/Camera"
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_spell_time >= spell_cooldown:
		var player_global_transform: Transform = player.global_transform
		var player_forward: Vector3 = player_global_transform.basis.z.normalized()
		var camera_transform: Transform = camera.global_transform
		# Get the direction the camera is facing, only influencing the Y-axis
		var camera_forward_y: float = -camera_transform.basis.z.normalized().y
		# Calculate spawn position based on camera direction's Y-component
		var spawn_position: Vector3 = player_global_transform.origin + player_forward * spell_distance
		spawn_position.y += camera_forward_y * spell_distance
		spawn_position.y = max(spawn_position.y + 1, player_global_transform.origin.y +1)
		var area_spell_instance: Node = area_spell.instance()
		area_spell_instance.instigator = player
		area_spell_instance.summoner =player
		area_spell_instance.global_transform.origin = spawn_position
		var damage_partial: float = area_spell_instance.base_damage * (player.intelligence + player.instinct)
		area_spell_instance.damage = damage_partial + (player.max_nefis * 0.1)
		get_tree().current_scene.add_child(area_spell_instance)
		last_spell_time = current_time

var necro_switch: bool  = false
var necro_switch_cooldown: float = 5
var last_necro_switch_time: float = 0.0 
func switchStance():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_necro_switch_time >= necro_switch_cooldown:
		necro_switch = !necro_switch
		last_necro_switch_time = current_time




#testing overhead strike CD
var overhead_slash_cooldown: float = 3
var last_overhead_slash_time: float = 0.0 
var overhead_slash_cost: float = 7
func overheadSlashCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_overhead_slash_time >= overhead_slash_cooldown:
		if player.resolve >=overhead_slash_cost:
			last_overhead_slash_time = current_time

#___________________________________________________________________________________________________
var underhand_slash_cooldown: float = 3
var last_underhand_slash_time: float = 0.0 
var underhand_slash_cost: float = 7
func underhandSlashCD():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_underhand_slash_time >= underhand_slash_cooldown:
		if player.resolve >=underhand_slash_cost:
			last_underhand_slash_time = current_time
var can_underhand_slash: bool = false
func updateUnderhand(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_underhand_slash = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_underhand_slash = true
		
		
			

var last_cyclone_time: float = 0.0 
func cycloneCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_cyclone_time >= autoload.cyclone_cooldown:
		last_cyclone_time = current_time

#___________________________________________________________________________________________________
var whirlwind_cooldown: float = 3
var whirlwind_cost:float = 6
var last_whirlwind_time: float = 0.0 
func whirlwindCD()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_whirlwind_time >= whirlwind_cooldown:
		last_whirlwind_time = current_time
var can_whirlwind:bool = false
func updateWhirlwind(label: Label, cooldown: float, current_time: float, last_time: float) -> void:
	var elapsed_time: float = current_time - last_time
	var remaining_cooldown: float = max(0, cooldown - elapsed_time)
	if remaining_cooldown!= 0:
		can_whirlwind = false
		label.text = str(round(remaining_cooldown) )
	else:
		label.text = ""
		can_whirlwind = true
#___________________________________________________________________________________________________
var counter_cooldown: float = 3
var last_counter_time: float = 0.0 
var counter_cost: float = 5
func counterStrike()->void:
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_counter_time >= counter_cooldown:
		last_counter_time = current_time








var arrow: PackedScene = preload("res://Equipment/Arrows/Iron/Arrow_Iron.tscn")

func shootArrow(arrow_damage):
	var player_global_transform: Transform = player.global_transform
	var arrow_instance: KinematicBody
	var player_direction = player.direction
	var camera_transform: Transform = camera.global_transform
	var camera_rotation_x: float = camera_transform.basis.get_euler().x#Get the rotation degrees on the x-axis of the camera
	var strength_factor: float = 1.0#Calculate the strength factor based on the rotation of the camera
	var player_forward: Vector3 = player_global_transform.basis.z.normalized()

	var camera_global_transform: Transform = camera.global_transform
	var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() 
	var shoot_position: Vector3 = player.global_transform.origin + camera_forward * 0.5
	shoot_position.y += vertical_spawn_offset + 1
	var camera_right: Vector3 = camera_global_transform.basis.x.normalized()
	# Shoot the first bullet towards where the camera is looking at
	arrow_instance = arrow.instance()
	arrow_instance.direction = camera_forward
	arrow_instance.instigator = player
	arrow_instance.summoner = player
	arrow_instance.damage =  arrow_damage * player.strength 
	get_tree().current_scene.add_child(arrow_instance)
	arrow_instance.global_transform.origin = shoot_position



var potion_cooldown: float = 3
var last_potion_time: float = 0.0 

func potion():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_potion_time >= potion_cooldown:
		last_counter_time = current_time
