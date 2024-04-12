extends Node

class ThreatManagement:
	var player : Node
	var threat : int
onready var eyes = self 
var targets : Array = []
var speed = 4
var velocity = Vector3()
var max_distance = 30.1
var threat_info

func createFindThreat(player: Node) -> ThreatManagement:
	for existing_target in targets:
		if existing_target.player == player:
			return existing_target
	var new_target = ThreatManagement.new()
	new_target.player = player
	targets.append(new_target)
	return new_target
	
func findHighestThreat() -> ThreatManagement:
	var highest_threat = -1
	var target : ThreatManagement = null
	for assailant in targets:
		if assailant.threat > highest_threat:
			target = assailant
			highest_threat = assailant.threat
	return target
	
func getThreatInfo() -> Array:
	var threat_info = []  # Array to store player threat information
	for assailant in targets:
		if assailant != null and assailant.player != null:
			var player = assailant.player
			var player_name = player.entity_name
			var player_id = player.get_instance_id()
			threat_info.append(player_name + " ID: " + str(player_id) + " threat: " + str(assailant.threat))
	return threat_info
	
	
