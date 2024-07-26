extends KinematicBody
onready var threat_system = $"../../../../../../Threat"
export(NodePath) var entity_holder_path
var entity_holder = entity_holder_path
export(NodePath) var stats_path
onready var stats =  get_node("Stats")
onready var world = get_parent()
var experience_worth:int = 15
var state 


func _ready()-> void:
	add_to_group("BodyPart")

var deadly_bleeding_duration:float = 0
func _physics_process(delta: float) -> void:
	laserAttack()


export var entity_name: String = "Golem Eye"
export var species: String = "Golem"

func displayThreatInfo(label):
	threat_system.threat_info = threat_system.getBestFive()
	label.text = "\n".join(threat_system.threat_info)

var stored_attacker:KinematicBody 
var bleeding_duration:float = 0
var stunned_duration:float = 0
var berserk_duration:float = 0 


onready var ray = $RayCast
func laserAttack() -> void:
		if ray.is_colliding():
			var body = ray.get_collider()
			if body != null:
				if body != self:
					if body.is_in_group("Player"):
						body.stats.getHit(self,rand_range(5,15),Autoload.damage_type.cold,15,rand_range(0,5))
						if rand_range(0,1) > 0.5:
							body.get_node("Effects").bleed_duration  +=1
						else:
							body.get_node("Effects").stun_duration  +=1
