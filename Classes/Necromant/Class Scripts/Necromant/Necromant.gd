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



func  baseAttack():
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
var arcane_blast_cost = 7
onready var aim_ray: RayCast = $"../../../../../Camroot/h/v/Camera/Aim"
func arcaneBlast():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_arcane_blast_time >= arcane_blast_cooldown:
		if player.get_parent().nefis >= arcane_blast_cost:
			var player_global_transform: Transform = player.global_transform
			var player_forward: Vector3 = player_global_transform.basis.z.normalized()
			var spawn_position: Vector3 = player_global_transform.origin + player_forward * 1
			var player_direction = player.get_parent().direction # Assuming direction is a property of the player's parent node
			var arcane_blast_instance: KinematicBody = arcane_blast.instance()

			# Get the collision normal of the aim_ray
			var aim_collision_normal: Vector3 = aim_ray.get_collision_normal()
			var camera_forward_y: float = -aim_collision_normal.y
			
			var strength_factor: float = 1.0
			if camera_forward_y > 0:
				strength_factor = 2
			else:
				strength_factor = 0.5
			
			var modified_direction: Vector3 = player_direction + Vector3.UP * camera_forward_y * strength_factor
			arcane_blast_instance.direction = modified_direction.normalized()
			spawn_position.y = max(spawn_position.y + 1, player_global_transform.origin.y)
			arcane_blast_instance.instigator =  player.get_parent()
			arcane_blast_instance.summoner =  player.get_parent()
			
			arcane_blast_instance.damage = arcane_blast_instance.base_damage + (player.get_parent().max_nefis * 0.1)        
			
			arcane_blast_instance.global_transform.origin = spawn_position
			get_tree().current_scene.add_child(arcane_blast_instance)
			player.get_parent().nefis -= arcane_blast_cost
			last_arcane_blast_time = current_time



var necro_switch: bool  = false
var necro_switch_cooldown: float = 1
var last_necro_switch_time: float = 0.0 
func switchStance():
	var current_time: float = OS.get_ticks_msec() / 1000.0
	if current_time - last_necro_switch_time >= necro_switch_cooldown:
		necro_switch = !necro_switch
		last_necro_switch_time = current_time

#func arcaneBlast():
#	var current_time: float = OS.get_ticks_msec() / 1000.0
#	if current_time - last_arcane_blast_time >= arcane_blast_cooldown:
#		var camera: Camera = $"../../../../../Camroot/h/v/Camera"
#		var player_global_transform: Transform = player.global_transform
#		var player_forward: Vector3 = player_global_transform.basis.z.normalized()
#		var spawn_position: Vector3 = player_global_transform.origin + player_forward * 1
#		var player_direction = player.get_parent().direction # Assuming direction is a property of the player's parent node
#		var arcane_blast_instance: KinematicBody = arcane_blast.instance()
#		var camera_transform: Transform = camera.global_transform
#		var camera_forward_y: float = -camera_transform.basis.z.normalized().y
#		var modified_direction: Vector3 = player_direction + Vector3.UP * camera_forward_y
#		arcane_blast_instance.direction = modified_direction.normalized()
#		spawn_position.y = max(spawn_position.y + 1, player_global_transform.origin.y)
#		arcane_blast_instance.instigator =  player.get_parent()
#		arcane_blast_instance.summoner =  player.get_parent()
#		arcane_blast_instance.global_transform.origin = spawn_position
#		get_tree().current_scene.add_child(arcane_blast_instance)
#		last_arcane_blast_time = current_time
