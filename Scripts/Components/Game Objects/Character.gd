extends Spatial

onready var player = get_parent().get_parent()

func _ready()->void:
	$AnimationPlayer.add_animation("APose", load("res://Game/World/Player/Animations/TPose.anim"))
	
	
	if player != null:
		if player.is_in_group("Player"):
			player.character = self
			player.skeleton = $Armature/Skeleton
			player.animation = $AnimationPlayer

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
		"fireball":
			var damage:float = 10
			var projectile_scene:PackedScene = player.skills.fireball
			var damage_type:int = Autoload.damage_type.heat
			var can_pentrate_wall:bool = false
			var does_slow_down:bool = false
			var is_lingering:bool = false
			var speed:float = 20
			var life_time:int = 5
			player.skills.shootProjectile(damage, 
			projectile_scene,
			damage_type,
			can_pentrate_wall,
			does_slow_down,
			is_lingering,
			speed,
			life_time)
		"arcane bolt":
			var damage:float = 3
			var projectile_scene:PackedScene = player.skills.arcane_bolt
			var damage_type:int = Autoload.damage_type.arcane
			var can_pentrate_wall:bool = true
			var does_slow_down:bool = true
			var is_lingering:bool = true
			var speed:float = 10
			var life_time:int = 15
			player.skills.shootProjectile(damage, 
			projectile_scene,
			damage_type,
			can_pentrate_wall,
			does_slow_down,
			is_lingering,
			speed,
			life_time)



		"lighting":
			player.skills.placeLighting(1)

		"icicle scatter shot":
			player.skills.shootIcicle(1)

			
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
