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
		if assailant != null and assailant.player != null:
			var player = assailant.player
			# Check if player instance is valid by verifying its instance ID
			if player.get_instance_id() != 0:
				var player_name = player.entity_name
				var player_id = player.get_instance_id()
				threat_info.append(player_name + " ID: " + str(player_id) + " threat: " + str(assailant.threat))
			else:
				pass
	return threat_info

func getThreatInfo() -> Array:
	var threat_info = []  # Array to store player threat information
	for assailant in targets:
		if assailant != null and assailant.player != null:
			var player = assailant.player
			var player_name = player.entity_name
			var player_id = player.get_instance_id()
			threat_info.append(player_name + " ID: " + str(player_id) + " threat: " + str(assailant.threat))
	return threat_info
	
func loseThreat():
	# Get the position of the parent node
	var parent_position = get_parent().global_transform.origin

	# Define distance ranges and their corresponding aggro reduction values
	var close_range = 10.0  # Adjust as needed
	var middle_range = 20.0  # Adjust as needed

	# Decrease the aggro of all targets based on distance to parent
	for assailant in targets:
		if assailant != null and assailant.player != null:
			# Calculate distance between assailant and parent node
			if is_instance_valid(assailant):
				if assailant != null:
					var distance = assailant.player.global_transform.origin.distance_to(parent_position)
					# Calculate reduction based on distance range
					var reduction = 0
					if distance <= close_range:
						reduction = 0
					elif distance <= middle_range:
						reduction = 1
					else:
						reduction = 3
					# Ensure the reduction doesn't exceed the current threat
					assailant.threat = max(0, assailant.threat - reduction)

