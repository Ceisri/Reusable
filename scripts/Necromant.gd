extends MarginContainer

onready var player:Spatial = $"../../../../../Mesh"
onready var grid: GridContainer = $"../../../SkillBar/GridContainer"
var demon : PackedScene = preload("res://Classes/Necromant/Necromant Summonable Servants/Wraith.tscn")
var demonDistance: float = 10.0 # Distance in front of the player to summon the demon
var summon_cooldown: float = 3.0 # Cooldown time in seconds
var last_summon_time: float = 0.0 # Time when the demon was last summoned

var switch_cooldown: float = 0.5
var last_switch_time: float = 0.0 


func _physics_process(delta: float) -> void:
	updateCooldownLabel()

func updateCooldownLabel():
	var current_time = OS.get_ticks_msec() / 1000.0
	var remaining_cooldown = max(0, summon_cooldown - (current_time - last_summon_time))
	
	for child in grid.get_children():
		var icon = child.get_node("Icon")
		if icon != null and icon.texture != null and icon.texture.resource_path == "res://Classes/Necromant/Class Icons/SummonShadow.png":
			var label = child.get_node("CD")
			if label != null:
				label.text = str(remaining_cooldown)




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







func summonDemon():
	var currentTime = OS.get_ticks_msec() / 1000.0
	if currentTime - last_summon_time >= summon_cooldown:
		var playerGlobalTransform = player.global_transform
		var playerForward = playerGlobalTransform.basis.z.normalized()
		var spawnPosition = playerGlobalTransform.origin + playerForward * demonDistance
		
		var demonInstance = demon.instance()
		demonInstance.summoner = player.get_parent()
		demonInstance.command = current_command
		demonInstance.global_transform.origin = spawnPosition
		get_tree().current_scene.add_child(demonInstance)
		
		last_summon_time = currentTime
		


var switchCooldown = 0.25 # Cooldown time for command switch in seconds
var lastSwitchTime = 0.0 # Time when the command switch was last used
var switchCount = 0 # Counter to keep track of the number of switches
var current_command = "follow"

func commandSwitch() -> void:
	var currentTime = OS.get_ticks_msec() / 1000.0
	if currentTime - lastSwitchTime >= switchCooldown:
		
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
		lastSwitchTime = currentTime
