extends MarginContainer

onready var player = $"../../../../../Mesh"
var demon : PackedScene = preload("res://Classes/Necromant/Necromant Summonable Servants/Wraith.tscn")
var demonDistance = 10.0 # Distance in front of the player to summon the demon
var summonCooldown = 3.0 # Cooldown time in seconds
var lastSummonTime = 0.0 # Time when the demon was last summoned

var switch_cooldown = 0.5
var last_switch_time = 0.0 

onready var label_cd = $"../../../SkillBar/GridContainer/Slot1/CD"

func _ready():
	updateCooldownLabel()

func _process(delta):
	updateCooldownLabel()

func updateCooldownLabel():
	var grid = $"../../../SkillBar/GridContainer"
	var currentTime = OS.get_ticks_msec() / 1000.0
	var remainingCooldown = max(0, summonCooldown - (currentTime - lastSummonTime))
	
	for child in grid.get_children():
		var icon = child.get_node("Icon")
		if icon != null and icon.texture != null and icon.texture.resource_path == "res://Classes/Necromant/Class Icons/SummonShadow.png":
			var label = child.get_node("CD")
			if label != null:
				label.text = str(remainingCooldown)




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
	if currentTime - lastSummonTime >= summonCooldown:
		var playerGlobalTransform = player.global_transform
		var playerForward = playerGlobalTransform.basis.z.normalized()
		var spawnPosition = playerGlobalTransform.origin + playerForward * demonDistance
		
		var demonInstance = demon.instance()
		demonInstance.summoner = player.get_parent()
		demonInstance.global_transform.origin = spawnPosition
		get_tree().current_scene.add_child(demonInstance)
		
		lastSummonTime = currentTime
		
func commandSwitch() -> void:
	var currentTime = OS.get_ticks_msec() / 1000.0
	if currentTime - last_switch_time >= switch_cooldown:
		
		var playerParent = player.get_parent()
		var servants = get_tree().get_nodes_in_group("Servant")
		
		for servant in servants:
			var servantSummoner = servant.summoner
			if servantSummoner == playerParent:
				if servant.command == "follow":
					servant.command = "attack"
				else:
					servant.command = "follow"
		
		last_switch_time = currentTime
