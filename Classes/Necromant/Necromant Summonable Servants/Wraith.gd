extends KinematicBody

onready var eyes: Spatial = $Eyes
var summoner: KinematicBody

var turn_speed: float = 8
var maximum_enemy_range: float = 20
var summoner_distance_limit : float = 5
var enemy_distance_limit : float = 1
var command: String 
var speed: float = 4
var closestEnemy: KinematicBody = null


func _ready() -> void:
	add_to_group("Servant")
	


func _physics_process(delta: float) -> void:
	updateClosestEnemy()
	rotateTowardsSummoner(delta)
	listen(delta)

func listen(delta: float) -> void:
	match command:
		"follow":
			moveTowardsSummoner(delta)
		"attack":
			moveTowardsEnemy(delta)
			
func moveTowardsSummoner(delta: float) -> void:
	var direction = (summoner.global_transform.origin - global_transform.origin).normalized()
	var distance_to_summoner = global_transform.origin.distance_to(summoner.global_transform.origin)
	
	if distance_to_summoner > summoner_distance_limit:
		move_and_slide(direction * speed)
		rotateTowards(summoner)
		updateClosestEnemy()

func moveTowardsEnemy(delta: float) -> void:
	if not closestEnemy:
		return

	var direction = (closestEnemy.global_transform.origin - global_transform.origin).normalized()
	var distance_to_enemy = global_transform.origin.distance_to(closestEnemy.global_transform.origin)
	
	if distance_to_enemy > enemy_distance_limit:
		move_and_slide(direction * speed)
		eyes.look_at(closestEnemy.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * turn_speed))

func rotateTowardsSummoner(delta: float) -> void:
	if not checkEnemies(): # check if there are enemies in the area
		rotateTowards(summoner)
	else:
		if command != "follow":
			# rotate to look towards enemies
			rotateTowardsEnemies()

func updateClosestEnemy() -> void:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	closestEnemy = null
	var minDistance = maximum_enemy_range
	for enemy in enemies:
		var distance = enemy.global_transform.origin.distance_to(global_transform.origin)
		if distance < minDistance:
			minDistance = distance
			closestEnemy = enemy

func checkEnemies() -> bool:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		var distance = enemy.global_transform.origin.distance_to(global_transform.origin)
		if distance <= maximum_enemy_range:
			return true
	return false

func rotateTowardsEnemies() -> void:
	if closestEnemy:
		rotateTowards(closestEnemy)

func rotateTowards(node: Node) -> void:
	eyes.look_at(node.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad(eyes.rotation.y * turn_speed))
