extends KinematicBody
onready var world = get_parent()
var experience_worth:int = 15
onready var threat_system: Node = $Threat
onready var entity_holder = $Mesh/EntityHolder
onready var stats = $Stats
var state 

var deadly_bleeding_duration:float = 0
func _physics_process(delta: float) -> void:
	if Engine.get_physics_frames() % 48 == 0:
			if stats.health >0:
				threat_system.loseThreat()
			else:
				queue_free()
				$"../../armL".visible = false


export var entity_name: String = "Golem Eye"
export var species: String = "Golem"


func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)


var stored_attacker:KinematicBody 
var bleeding_duration:float = 0
var stunned_duration:float = 0
var berserk_duration:float = 0 
