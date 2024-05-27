extends KinematicBody

var direction: Vector3 = Vector3.ZERO # Direction of the bullet
onready var area: Area = $Area
var summoner: KinematicBody
var entity_name: String = "Arrow"
var instigator: Node = self
var damage_type: String = "pierce"
var damage: float = 15.0
var aggro: float = 15.0
var stagger_chance: float = 0.5
var life_time: int = 200
var velocity: Vector3 = Vector3.ZERO # Initial velocity
var speed:float = 20
var time_to_rotate:float = 5



func _ready():
	speed += summoner.strength 
	hide()
	velocity = Vector3(0, 0, -10) # Adjust the direction and speed as needed
	
func rotateArrow():
	# Ensure summoner is defined and accessible
	if not summoner:
		return
		
	# Make $Eye look at the summoner
	$Eye.look_at(summoner.global_transform.origin, Vector3.UP)
	
	# Get the basis (rotation matrix) of the $Eye after looking at the target
	var eye_basis = $Eye.global_transform.basis
	
	# Apply the same rotation to the current object
	global_transform.basis = eye_basis

func moveArrow():
	move_and_collide(direction.normalized() * speed * get_physics_process_delta_time())

func _physics_process(delta: float) -> void:
	shot()
	moveArrow()
	speed += 1 * delta
	# Decrease lifetime
	life_time -= 1 * delta
	if life_time <= 0:
		queue_free()
	time_to_rotate -= 0.8
	if time_to_rotate > 0:
		rotateArrow()


func shot():
	var player = summoner
	var damage_type:String = "pierce"
	var damage_flank = damage + player.flank_dmg 
	var critical_damage : float  = damage * player.critical_strength
	var critical_flank_damage : float  = damage_flank * player.critical_strength
	var punishment_damage : float = 14 #extra damage for when the victim is trying to block but is facing the wrong way 
	var punishment_damage_type :String = "pierce"
	var aggro_power = damage * 0.95
	var enemies = $Area.get_overlapping_bodies()
	for victim in enemies:
		if victim.is_in_group("enemy"):
			if victim != self:
				player.pushEnemyAway(0.3, victim,0.25)
				if player.resolve < player.max_resolve:
					player.resolve += player.ferocity + 1.25
				if victim.has_method("takeDamage"):
					if player.is_on_floor():
						#insert sound effect here
						if randf() <= player.critical_chance:#critical hit
							if victim.state == "guard" or victim.state == "guard walk": #victim is guarding
								if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(critical_flank_damage + punishment_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
							else:#player is guarding
								if player.isFacingSelf(victim,0.30): #check if the victim is looking at me 
									victim.takeDamage(critical_damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks, extra damage
									victim.takeDamage(critical_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
						else: #normal hit
							if victim.state == "guard" or victim.state == "guard walk": #victim is guarding
								if player.isFacingSelf(victim,0.30): #the victim is looking face to face at self 
									victim.takeDamage(damage/victim.guard_dmg_absorbition,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks while guard, flank damage + punishment damage
									victim.takeDamage(damage_flank + punishment_damage,aggro_power,player,player.stagger_chance,punishment_damage_type)
							else:#victim is not guarding
								if player.isFacingSelf(victim,0.30):#the victim is looking face to face at self 
									victim.takeDamage(damage,aggro_power,player,player.stagger_chance,damage_type)
								else: #apparently the victim is showing his back or flanks, extra damage
									victim.takeDamage(damage_flank,aggro_power,player,player.stagger_chance,damage_type)
				queue_free()
		else:
			if victim != self:
				queue_free()





	


func _on_Timer_timeout():
	show()
