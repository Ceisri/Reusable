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
	player.flip_duration = false

func stepEnd()->void:
	player.skills.backstepCD()
	player.backstep_duration = false
	player.frontstep_duration = false
	player.leftstep_duration = false
	player.rightstep_duration = false

func dashEnd()->void:
	player.dash_active = false


func kickEnd()->void:
	player.skills.kickCD()
	player.kick_duration = false

func garroteEnd()->void:
	player.skills.garroteCD()
	player.garrote_active = false
	if player.garrote_victim != null:
	#	player.garrote_victim.knockeddown = true
		player.garrote_victim.garroted = false
		player.garrote_victim.set_collision_layer(1) 
		player.garrote_victim.set_collision_mask(1) 
		player.garrote_victim = null
		
func silentStabEnd()->void:
	player.skills.silentStabCD()
	player.silent_stab_active = false



	
	
func garroteDMG()->void:
	var dmg:float 
	var extr_pen_chance:float 
	if player.garrote_victim != null:
		if not player.garrote_victim.is_in_group("Boss"):
			dmg = player.garrote_victim.stats.max_health * 2
			extr_pen_chance = 100000
			player.garrote_victim.deadly_bleeding_duration = 10
		else:
			dmg = 100
			extr_pen_chance = 0
		
		player.garrote_victim.stats.getHit(player,dmg,Autoload.damage_type.slash,33,0)
