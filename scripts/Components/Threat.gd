extends Node

class ThreatManagement:
	var player : Node
	var threat : int
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
const max_int = 2147483647  # The maximum possible integer value (2^31 - 1)
func findLowestThreat() -> ThreatManagement:
	var lowest_threat = max_int  # Set the initial lowest threat to maximum possible integer value
	var target : ThreatManagement = null
	for assailant in targets:
		if assailant.threat < lowest_threat:
			target = assailant
			lowest_threat = assailant.threat
	return target	
	
func findHighestThreat() -> ThreatManagement:
	var highest_threat = -1
	var target : ThreatManagement = null
	for assailant in targets:
		if assailant.threat > highest_threat:
			target = assailant
			highest_threat = assailant.threat
	return target

func findSecondThreat() -> ThreatManagement:
	var highest_threat = -1
	var second_highest_threat = -1
	var target : ThreatManagement = null
	var second_target : ThreatManagement = null
	for assailant in targets:
		if assailant.threat > highest_threat:
			second_target = target
			second_highest_threat = highest_threat
			target = assailant
			highest_threat = assailant.threat
		elif assailant.threat > second_highest_threat:
			second_target = assailant
			second_highest_threat = assailant.threat
	return second_target

func findThirdThreat() -> ThreatManagement:
	var highest_threat = -1
	var second_highest_threat = -1
	var third_highest_threat = -1
	var target : ThreatManagement = null
	var second_target : ThreatManagement = null
	var third_target : ThreatManagement = null
	
	for assailant in targets:
		if assailant.threat > highest_threat:
			third_target = second_target
			third_highest_threat = second_highest_threat
			second_target = target
			second_highest_threat = highest_threat
			target = assailant
			highest_threat = assailant.threat
		elif assailant.threat > second_highest_threat:
			third_target = second_target
			third_highest_threat = second_highest_threat
			second_target = assailant
			second_highest_threat = assailant.threat
		elif assailant.threat > third_highest_threat:
			third_target = assailant
			third_highest_threat = assailant.threat
	
	return third_target

func findFourthThreat() -> ThreatManagement:
	var highest_threat = -1
	var second_highest_threat = -1
	var third_highest_threat = -1
	var fourth_highest_threat = -1
	var target : ThreatManagement = null
	var second_target : ThreatManagement = null
	var third_target : ThreatManagement = null
	var fourth_target : ThreatManagement = null
	
	for assailant in targets:
		if assailant.threat > highest_threat:
			fourth_target = third_target
			fourth_highest_threat = third_highest_threat
			third_target = second_target
			third_highest_threat = second_highest_threat
			second_target = target
			second_highest_threat = highest_threat
			target = assailant
			highest_threat = assailant.threat
		elif assailant.threat > second_highest_threat:
			fourth_target = third_target
			fourth_highest_threat = third_highest_threat
			third_target = second_target
			third_highest_threat = second_highest_threat
			second_target = assailant
			second_highest_threat = assailant.threat
		elif assailant.threat > third_highest_threat:
			fourth_target = third_target
			fourth_highest_threat = third_highest_threat
			third_target = assailant
			third_highest_threat = assailant.threat
		elif assailant.threat > fourth_highest_threat:
			fourth_target = assailant
			fourth_highest_threat = assailant.threat
	
	return fourth_target

func findFifthThreat() -> ThreatManagement:
	var highest_threat = -1
	var second_highest_threat = -1
	var third_highest_threat = -1
	var fourth_highest_threat = -1
	var fifth_highest_threat = -1
	var target : ThreatManagement = null
	var second_target : ThreatManagement = null
	var third_target : ThreatManagement = null
	var fourth_target : ThreatManagement = null
	var fifth_target : ThreatManagement = null
	for assailant in targets:
		if assailant.threat > highest_threat:
			fifth_target = fourth_target
			fifth_highest_threat = fourth_highest_threat
			fourth_target = third_target
			fourth_highest_threat = third_highest_threat
			third_target = second_target
			third_highest_threat = second_highest_threat
			second_target = target
			second_highest_threat = highest_threat
			target = assailant
			highest_threat = assailant.threat
		elif assailant.threat > second_highest_threat:
			fifth_target = fourth_target
			fifth_highest_threat = fourth_highest_threat
			fourth_target = third_target
			fourth_highest_threat = third_highest_threat
			third_target = second_target
			third_highest_threat = second_highest_threat
			second_target = assailant
			second_highest_threat = assailant.threat
		elif assailant.threat > third_highest_threat:
			fifth_target = fourth_target
			fifth_highest_threat = fourth_highest_threat
			fourth_target = third_target
			fourth_highest_threat = third_highest_threat
			third_target = assailant
			third_highest_threat = assailant.threat
		elif assailant.threat > fourth_highest_threat:
			fifth_target = fourth_target
			fifth_highest_threat = fourth_highest_threat
			fourth_target = assailant
			fourth_highest_threat = assailant.threat
		elif assailant.threat > fifth_highest_threat:
			fifth_target = assailant
			fifth_highest_threat = assailant.threat
	
	return fifth_target


func getBestFive():
	var first = findHighestThreat()
	var second = findSecondThreat()
	var third = findThirdThreat()
	var fourth = findFourthThreat()
	var fifth = findFifthThreat()
	var threat_info = []  # Array to store player threat information
	for assailant in [first, second, third, fourth, fifth]:# Append the threat information of the first, second, third, fourth, and fifth assailants
		if is_instance_valid(assailant):
			if assailant != null and assailant.player != null:
				var player = assailant.player
				# Check if player instance is valid by verifying its instance ID
				if is_instance_valid(player):
					if player.get_instance_id() != 0:
						var player_name = player.entity_name
						var player_id = player.get_instance_id()
						threat_info.append(player_name + " ID: " + str(player_id) + " threat: " + str(assailant.threat))
	return threat_info

func getThreatInfo() -> Array:#use this for displaying data in labels
	var threat_info = []  # Array to store player threat information
	for assailant in targets:
		if assailant != null and assailant.player != null:
			var player = assailant.player
			var player_name = player.entity_name
			var player_id = player.get_instance_id()
			threat_info.append(player_name + " ID: " + str(player_id) + " threat: " + str(assailant.threat))
	return threat_info
	
func loseThreat()->void: #call this function every few ticks to lose threat from entities that are too far away
	# Get the position of the parent node
	var parent_position = get_parent().global_transform.origin
	var close_range:float = 10.0 
	var middle_range:float = 35.0  
	for assailant in targets:
		if assailant != null and assailant.player != null:
			# Calculate distance between assailant and parent node
			if is_instance_valid(assailant):
				if assailant != null:
					if assailant.player != null:
						var distance = assailant.player.global_transform.origin.distance_to(parent_position)
						# Calculate reduction based on distance range
						var reduction:int = 0#Decrease the aggro of all targets based on distance to parent
						if distance <= close_range:
							reduction = 0
						elif distance >= middle_range:
							reduction = 1
						elif distance > middle_range * 1.5:
							reduction = 25
						# Ensure the reduction doesn't exceed the current threat
						assailant.threat = max(0, assailant.threat - reduction)
	var all_zero_threat = true
	for assailant in targets:
		if assailant.threat > 0:#Check if all targets have zero threat
			all_zero_threat = false
			break
	if get_parent().health > 0:
		if get_parent().state != autoload.state_list.staggered:
			if all_zero_threat: #if no player or entity  has any threat towards the parent of this node, return to a harmless state
				get_parent().state = autoload.state_list.wander
			else: #else engage the threatening player or entity 
				get_parent().state = autoload.state_list.engage
