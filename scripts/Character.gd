extends Spatial

onready var player = get_parent().get_parent()

func _ready()->void:
	player.character = self
	player.skeleton = $Armature/Skeleton

func startMoving()->void:
	player.can_move = true
	
func stopMoving()->void:
	player.can_move = false

func flipEnd()->void:
	player.active_action = "none"

func stepEnd()->void:
	player.skills.backstepCD()
	player.active_action = "none"


func endAction()->void:
	player.skills.skillCancel("none")
	player.active_action = "none"

func placeOrShoot()->void:
	match player.active_action:
		"lighting":
			player.skills.placeLighting(1.25)
		"fireball":
			player.skills.shootFireball(5)
		"ring of fire":
			player.skills.placeRingOfFire(12)
		"wall of fire":
			player.skills.placeWallOfFire(7.5)

		"triple fireball":
			player.skills.shootTripleFireball(3.75)
		"immolate":
			player.skills.shootImmolate(33)




func garroteEnd()->void:
	player.skills.garroteCD()
	player.active_action = "none"
	if player.garrote_victim != null:
		player.garrote_victim.garroted = false
		player.garrote_victim.set_collision_layer(1) 
		player.garrote_victim.set_collision_mask(1) 
		player.garrote_victim = null
		
func silentStabEnd()->void:
	player.skills.silentStabCD()
	player.active_action = "none"



	
	
func garroteDMG()->void:
	var dmg:float 
	var extr_pen_chance:float 
	if player.garrote_victim != null:
		if player.garrote_victim.is_boss == true:
			player.garrote_victim.stats.getHit(player,100,Autoload.damage_type.slash,0,0)
		else:
			dmg = player.garrote_victim.stats.max_health * 99999999999
			extr_pen_chance = 100000
			player.garrote_victim.deadly_bleeding_duration = 10
		
			player.garrote_victim.stats.getHit(player,dmg,Autoload.damage_type.slash,extr_pen_chance,0)
