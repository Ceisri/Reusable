extends Node


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
#___________________________________________________________________________________________________
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
#___________________________________________________________________________________________________
var necro_switch: bool  = false
var necro_switch_cooldown: float = 5
var last_necro_switch_time: float = 0.0 
func switchStance():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_necro_switch_time >= necro_switch_cooldown:
		necro_switch = !necro_switch
		last_necro_switch_time = current_time