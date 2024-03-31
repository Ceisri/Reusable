extends MeshInstance


onready var area: Area = $Area
onready var timer: Timer = $Ticks
var summoner: KinematicBody
var entity_name: String = "fire"
var instigator: Node = self
var damage_type: String = "toxic"
var base_damage: float = 15.0
var damage: float = 15.0
var aggro: float = 15.0
var stagger_chance: float = 0.5
var life_time: int = 10

func _ready():
	timer.start(0.5)
	timer.connect("timeout", self, "tick")
	
func tick():
	increaseDamage()
	burn()
	die()
	
	
func burn():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body != summoner:
			if body.is_in_group("Servant"):
				if body.has_method("takeHealing"):
					if instigator.isFacingSelf(body,0.30):
						body.takeHealing(damage * 2,instigator)
					else:
						body.takeHealing(damage,instigator)
					if body.has_method("scaleUP"):
						body.scaleUP()
						
					
			elif body.is_in_group("Enemy"):
					if body.has_method("takeDamage"):
						if instigator.isFacingSelf(body,0.30):
							body.takeDamage(damage,aggro,instigator,stagger_chance,damage_type)
						else:
							body.takeDamage(damage * 2,aggro,instigator,stagger_chance,"acid")
		else:
			if body.has_method("takeHealing"):
					if instigator.isFacingSelf(body,0.30):
						body.takeHealing(damage * 2,instigator)
func die():
	life_time -= 1 
	if life_time <=0:
		queue_free()

func increaseDamage():
	damage += (damage * 0.1)
