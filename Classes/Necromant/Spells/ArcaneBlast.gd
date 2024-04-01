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
var speed:float = 0.1

func _ready():
	# Set up initial velocity (for example, moving forward)
	velocity = Vector3(0, 0, -10) # Adjust the direction and speed as needed

func _physics_process(delta: float) -> void:
	burn()
	# Move the bullet using direction
	move_and_collide(direction.normalized() * speed * delta)
	
	speed += 2
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
					pushEnemyAway(4,body,0.25)
					if instigator.isFacingSelf(body,0.30):
						body.takeDamage(damage,aggro,instigator,stagger_chance,damage_type)
					else:
						body.takeDamage(damage,aggro,instigator,stagger_chance,"acid")
				queue_free()

onready var tween: Tween = $Tween
func pushEnemyAway(push_distance, enemy, push_speed):
	var direction_to_enemy = enemy.global_transform.origin - summoner.global_transform.origin
	direction_to_enemy.y = 1  # No vertical push
	direction_to_enemy = direction_to_enemy.normalized()
	
	var motion = direction_to_enemy * push_speed
	var acceleration_time = push_speed / 2.0
	var deceleration_distance = motion.length() * acceleration_time * 0.5
	var collision = enemy.move_and_collide(motion)
	if collision: #this checks the dipshit hits a wall after you punch him 
		#the dipshit takes damage from being pushed into something
		#afterwards he is pushed back...like ball bouncing back but made of meat
		enemy.takeDamage(10, 100, self, 1, "bleed")
		# Calculate bounce-back direction
		var normal = collision.normal
		var bounce_motion = -4 * normal * normal.dot(motion) + motion
		# Move the enemy slightly away from the wall to avoid sticking
		enemy.translation += normal * 0.1 * collision.travel
		# Tween the bounce-back motion
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + bounce_motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
	else:
		# Tween the movement over time with initial acceleration followed by instant stop
		tween.interpolate_property(enemy, "translation", enemy.translation, enemy.translation + motion * push_distance, acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(enemy, "translation", enemy.translation + motion * push_distance, enemy.translation + motion * (push_distance - deceleration_distance), acceleration_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, acceleration_time)
		tween.start()
