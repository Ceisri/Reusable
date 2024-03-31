extends MarginContainer

onready var player:Spatial = $"../../../../../Mesh"
onready var grid: GridContainer = $"../../../SkillBar/GridContainer"
var demon : PackedScene = preload("res://Classes/Necromant/Necromant Summonable Servants/Wraith.tscn")
var demon_distance: float = 10.0 # Distance in front of the player to summon the demon
var summon_cooldown: float = 0.15 # Cooldown time in seconds
var last_summon_time: float = 0.0 # Time when the demon was last summoned




func _physics_process(delta: float) -> void:
	updateCooldownLabel()

func updateCooldownLabel() -> void:
	var current_time = OS.get_ticks_msec() / 1000.0
	
	for child in grid.get_children():
		var icon = child.get_node("Icon")
		if icon != null and icon.texture != null and icon.texture.resource_path == autload.summon_shadow.get_path():
			var remaining_cooldown: float = max(0, summon_cooldown - (current_time - last_summon_time))
			var label: Label = child.get_node("CD")
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autload.dominion.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, switch_cooldown - (current_time - last_switch_time))
			if label != null:
				if remaining_cooldown >0:
					label.text = str(round(remaining_cooldown * 100)/ 100)
				else:
					label.text = ""
		elif icon != null and icon.texture != null and icon.texture.resource_path == autload.tribute.get_path():
			var label: Label = child.get_node("CD")
			var remaining_cooldown:float  = max(0, tribute_cooldown - (current_time - last_tribute_time))
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
		
		last_summon_time = current_time


		


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


var tribute_cooldown: float = 0.5
var last_tribute_time: float = 0.0 
func tribute():
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
				
		last_tribute_time = current_time

