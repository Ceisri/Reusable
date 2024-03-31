extends KinematicBody

var direction: Vector3 = Vector3.ZERO # Direction of the bullet
onready var area: Area = $Area
var summoner: KinematicBody
var entity_name: String = "fire"
var instigator: Node = self
var damage_type: String = "toxic"
var base_damage: float = 15.0
var damage: float = 15.0
var aggro: float = 15.0
var stagger_chance: float = 0.5
var life_time: int = 200
var velocity: Vector3 = Vector3.ZERO # Initial velocity
var speed:float = 8.00

func _ready():
	# Set up initial velocity (for example, moving forward)
	velocity = Vector3(0, 0, -10) # Adjust the direction and speed as needed

func _physics_process(delta: float) -> void:
	burn()
	# Move the bullet using direction
	move_and_collide(direction.normalized() * speed * delta)

	# Decrease lifetime
	life_time -= 1
	if life_time <= 0:
		queue_free()


func burn():
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body != summoner:
			if body.is_in_group("Enemy"):
				if body.has_method("takeDamage"):
					if instigator.isFacingSelf(body,0.30):
						body.takeDamage(damage,aggro,instigator,stagger_chance,damage_type)
					else:
						body.takeDamage(damage,aggro,instigator,stagger_chance,"acid")
				queue_free()
