extends Control

onready var player:Spatial = $"../../../../../Mesh"
onready var grid: GridContainer = $"../../../SkillBar/GridContainer"
var demon : PackedScene = preload("res://Classes/Necromant/Necromant Summonable Servants/Wraith.tscn")
var demon_distance: float = 10.0 
var summon_cooldown: float = 0.15 
var last_summon_time: float = 0.0 

var masochism : int = 1 

func _ready():
	loadServants()

func _physics_process(delta: float) -> void:
	updateCooldownLabel()

func updateCooldownLabel() -> void:
	var current_time = OS.get_ticks_msec() / 1000.0
	
	for child in grid.get_children():
		var icon = child.get_node("Icon")
		if icon != null and icon.texture != null and icon.texture.resource_path == autoload.summon_shadow.get_path():
			var remaining_cooldown: float = max(0, summon_cooldown - (current_time - last_summon_time))
			var label: Label = child.get_node("CD")
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.dominion.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, switch_cooldown - (current_time - last_switch_time))
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.tribute.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, tribute_cooldown - (current_time - last_tribute_time))
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.servitude.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, spell_cooldown - (current_time - last_spell_time))
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.arcane_blast.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, arcane_blast_cooldown - (current_time - last_arcane_blast_time))
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autoload.necromant_switch.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, necro_switch_cooldown - (current_time - last_necro_switch_time))
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
					
		else:
			var label: Label = child.get_node("CD")
			label.text = ""
			
			


func findLabelsInGrid(node):
	var foundLabels = []

	if node.has_node("CD"):
		foundLabels.append(node.get_node("CD"))

	for child in node.get_children():
		var childLabels = findLabelsInGrid(child)
		foundLabels += childLabels  # Concatenate arrays using the + operator

	return foundLabels



func findIconInGrid(node):
	if node.has_node("Icon"):
		return node.get_node("Icon")
	else:
		for child in node.get_children():
			var icon = findIconInGrid(child)
			if icon != null:
				return icon
	return null



func baseAttack():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if player.get_parent().nefis >= 0.5:
			var camera: Camera = $"../../../../../Camroot/h/v/Camera"
			var player_global_transform: Transform = player.global_transform
			var player_forward: Vector3 = player_global_transform.basis.z.normalized()
			var spawn_position: Vector3 = player_global_transform.origin + player_forward * 1
			var player_direction = player.get_parent().direction # Assuming direction is a property of the player's parent node
			var arcane_blast_instance: KinematicBody = arcane_blast.instance()
			var camera_transform: Transform = camera.global_transform

			var camera_forward_y: float = -camera_transform.basis.z.normalized().y
			var strength_factor: float = 1.0
			if camera_forward_y > 0:
				strength_factor = 1.8
			else:
				strength_factor = 0.9
			var modified_direction: Vector3 = player_direction + Vector3.UP * camera_forward_y * strength_factor
			arcane_blast_instance.direction = modified_direction.normalized()
			spawn_position.y = max(spawn_position.y + 1, player_global_transform.origin.y)
			arcane_blast_instance.instigator =  player.get_parent()
			arcane_blast_instance.summoner =  player.get_parent()
			
			arcane_blast_instance.damage = 0 #placeholder
			
			arcane_blast_instance.global_transform.origin = spawn_position
			get_tree().current_scene.add_child(arcane_blast_instance)
			player.get_parent().nefis -= 0.5


var summoned_demons: int = 0
func summonDemon() -> void:

	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_summon_time >= summon_cooldown:
		var player_global_transform: Transform = player.global_transform
		var player_forward: Vector3 = player_global_transform.basis.z.normalized()
		var spawn_position: Vector3 = player_global_transform.origin + player_forward * demon_distance
		spawn_position.y += 1.0  # Adjust Y-coordinate to spawn slightly above the player
		var demon_instance: Node = demon.instance()
		demon_instance.summoner = player.get_parent()
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
		demon_instance.summoner = player.get_parent()
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
		
		var playerParent = player.get_parent()
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
			var player_parent = player.get_parent()
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
			var player_parent = player.get_parent()
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
		area_spell_instance.instigator = player.get_parent()
		area_spell_instance.summoner = player.get_parent()
		area_spell_instance.global_transform.origin = spawn_position
		var damage_partial: float = area_spell_instance.base_damage * (player.get_parent().intelligence + player.get_parent().instinct)
		area_spell_instance.damage = damage_partial + (player.get_parent().max_nefis * 0.1)
		get_tree().current_scene.add_child(area_spell_instance)
		last_spell_time = current_time



var arcane_blast: PackedScene = preload("res://Classes/Necromant/Spells/ArcaneBlast.tscn")
var arcane_blast_cooldown: float = 1
var last_arcane_blast_time: float = 0.0 
var arcane_blast_cost: float = 0
var vertical_spawn_offset: float = 0.8
var forward_offset: float = 1
var aiming_mode: String = "camera"
var damage: float = 20
func arcaneBlast():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if player.get_parent().nefis >= arcane_blast_cost:
		# Deduct the resource (nefis) of the player
		player.get_parent().nefis -= arcane_blast_cost
		match aiming_mode:
			"directional":
				var camera: Camera = $"../../../../../Camroot/h/v/Camera"
				var player_global_transform: Transform = player.global_transform
				var player_forward: Vector3 = player_global_transform.basis.z.normalized()
				var shoot_position: Vector3 = player.global_transform.origin
				shoot_position += player_forward * forward_offset
				shoot_position.y += vertical_spawn_offset
				var player_direction = player.get_parent().direction
				var arcane_blast_instance: KinematicBody
				var camera_transform: Transform = camera.global_transform
				# Get the rotation degrees on the x-axis of the camera
				var camera_rotation_x: float = camera_transform.basis.get_euler().x
				# Calculate the strength factor based on the rotation of the camera
				var strength_factor: float = 1.0
				if camera_rotation_x > 0:
					strength_factor = 2
				else:
					strength_factor = 0.9
				# Calculate the modified direction using the rotation of the camera
				var modified_direction: Vector3 = player_direction + Vector3.UP * camera_rotation_x * strength_factor
				# Shoot the first bullet straight ahead from shoot_spawn_point
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = modified_direction.normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = shoot_position
				get_tree().current_scene.add_child(arcane_blast_instance)
				# Calculate the rotation of the player in the world
				var player_rotation = player_global_transform.basis.get_euler()
				# Calculate spawn positions for diagonally shot bullets relative to shoot_spawn_point
				var spawn_position2: Vector3 = shoot_position + player_forward.rotated(Vector3.UP, deg2rad(-30)).normalized() * 2
				var spawn_position3: Vector3 = shoot_position + player_forward.rotated(Vector3.UP, deg2rad(30)).normalized() * 2
				# Adjust spawn positions vertically based on the camera's rotation
				spawn_position2 += Vector3.UP * camera_rotation_x * strength_factor
				spawn_position3 += Vector3.UP * camera_rotation_x * strength_factor
				# Shoot the second bullet diagonally to the right
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = (spawn_position2 - shoot_position).normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = spawn_position2
				get_tree().current_scene.add_child(arcane_blast_instance)
				# Shoot the third bullet diagonally to the left
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = (spawn_position3 - shoot_position).normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = spawn_position3
				get_tree().current_scene.add_child(arcane_blast_instance)
			"camera reverse":
				var camera: Camera = $"../../../../../Camroot/h/v/Camera"
				var player_global_transform: Transform = player.global_transform
				var camera_global_transform: Transform = camera.global_transform
				var shoot_position: Vector3 = player.global_transform.origin
				shoot_position.y += vertical_spawn_offset
				var player_direction = player.get_parent().direction
				var arcane_blast_instance: KinematicBody
				var camera_forward: Vector3 = camera_global_transform.basis.z.normalized()
				var camera_up: Vector3 = camera_global_transform.basis.y.normalized()
				var camera_right: Vector3 = camera_global_transform.basis.x.normalized()

				# Shoot the first bullet towards where the camera is looking at
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = camera_forward
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = shoot_position
				get_tree().current_scene.add_child(arcane_blast_instance)

				# Calculate spawn positions for diagonally shot bullets relative to shoot_position
				var spawn_position2: Vector3 = shoot_position + camera_right * forward_offset
				var spawn_position3: Vector3 = shoot_position - camera_right * forward_offset

				# Shoot the second bullet diagonally to the right
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = (spawn_position2 - shoot_position).normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = spawn_position2
				get_tree().current_scene.add_child(arcane_blast_instance)

				# Shoot the third bullet diagonally to the left
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = (spawn_position3 - shoot_position).normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = spawn_position3
				get_tree().current_scene.add_child(arcane_blast_instance)
			"camera":
				var camera: Camera = $"../../../../../Camroot/h/v/Camera"
				var player_global_transform: Transform = player.global_transform
				var camera_global_transform: Transform = camera.global_transform
				var shoot_position: Vector3 = player.global_transform.origin
				shoot_position.y += vertical_spawn_offset
				var player_direction = player.get_parent().direction
				var arcane_blast_instance: KinematicBody
				var camera_forward: Vector3 = -camera_global_transform.basis.z.normalized() # Invert the direction
				var camera_right: Vector3 = camera_global_transform.basis.x.normalized()

				# Shoot the first bullet towards where the camera is looking at
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = camera_forward
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = shoot_position
				get_tree().current_scene.add_child(arcane_blast_instance)

				# Calculate spawn positions for diagonally shot bullets relative to shoot_position
				var spawn_position2: Vector3 = shoot_position + camera_right * (forward_offset / 4) # Further reduce the offset
				var spawn_position3: Vector3 = shoot_position - camera_right * (forward_offset / 4) # Further reduce the offset

				# Calculate directions for the second and third bullets with opposite and reduced offset
				var deviation_angle: float = 0 
				var deviation_left: Vector3 = -camera_right.rotated(Vector3.UP, deg2rad(0))  # No deviation
				var deviation_right: Vector3 = camera_right.rotated(Vector3.UP, deg2rad(0))  # No deviation

				# Shoot the second bullet towards where the camera is looking at, deviated slightly to the left
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = (camera_forward + deviation_left).normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = spawn_position2
				get_tree().current_scene.add_child(arcane_blast_instance)

				# Shoot the third bullet towards where the camera is looking at, deviated slightly to the right
				arcane_blast_instance = arcane_blast.instance()
				arcane_blast_instance.direction = (camera_forward + deviation_right).normalized()
				arcane_blast_instance.instigator = player.get_parent()
				arcane_blast_instance.summoner = player.get_parent()
				arcane_blast_instance.damage = damage
				arcane_blast_instance.global_transform.origin = spawn_position3
				get_tree().current_scene.add_child(arcane_blast_instance)



var necro_switch: bool  = false
var necro_switch_cooldown: float = 1
var last_necro_switch_time: float = 0.0 
func switchStance():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_necro_switch_time >= necro_switch_cooldown:
		necro_switch = !necro_switch
		last_necro_switch_time = current_time


