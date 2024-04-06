extends KinematicBody

var direction: Vector3= Vector3.ZERO
var speed: float = 4
var attack_range: float= 2.0
var state: String = "chase"
onready var animation_player: AnimationPlayer= $AnimationPlayer
onready var state_label: Label3D= $Label3D
var player: Node 
var player_index: int 
var player_pos: Vector3
var attack_cooldown: float = 2.0 # Cooldown period for attack1 in seconds
var attack_timer: float = 0.0 # Timer to track cooldown



func _ready():
	# Connect the timer timeout signal to the script
	$Timer.connect("timeout", self, "directionTimer")
	# Start the direction timer
	directionTimer()

func _physics_process(delta: float) -> void:
	matchState(delta)
	showState()
	distanceCheck()
	updateCooldown(delta)
	drawAggroFromPlayers()
	# Update the direction change timer
	directionChangeTimer += delta
func matchState(delta):
	match state:
		"run":
			pass
		"walk":
			if attack_timer <= 0.0:
				moveRandomDirection()
				move_and_slide(getSlideVelocity(speed))
				animation_player.play("walk", 0.4)
		"idle":
			animation_player.play("idle", 0.4)
		"chase":
			if attack_timer <= 0.0:
				chase()
				animation_player.play("walk", 0.4)
		"staggered":
			pass
		"attack1":
			if attack_timer <= 0.0:
				var rand_num = randi() % 10 # Generate a random number between 0 and 9
				if rand_num == 0:
					animation_player.play("slash", 0.5)
					animation_player.queue("scream")
					attack_timer = attack_cooldown
				elif rand_num >= 8:
					animation_player.play("slash", 0.5)
					animation_player.queue("tpose")
					attack_timer = attack_cooldown
				else:
					animation_player.play("slash", 0.5)
					animation_player.queue("dash") # change this so this animation can't repeat 
					attack_timer = 0.9
func distanceCheck():
	if state != "walk" and state != "idle":
		var target = findPlayerWithHighestAggro()  # Get the player with the highest aggro
		if target:
			var distance_to_player = (target.player.global_transform.origin - global_transform.origin).length()
			print("Distance to player:", distance_to_player)
			if distance_to_player < attack_range and state != "attack1":
				state = "attack1"
				print("State changed to attack1")
			elif distance_to_player >= attack_range and state == "attack1":
				state = "chase"

func showState():
	state_label.text = str(state)
func updateCooldown(delta: float) -> void:
	if attack_timer > 0.0:
		attack_timer -= delta
#_________________________________section about moving towards players______________________________
class PlayerAggro:
	var player: Node
	var aggro: int

onready var players: Array = get_tree().get_nodes_in_group("Player")
onready var eyes: Spatial = $Eyes
var max_distance: float = 30.1
var turn_speed: float = 3.0
var playerAggros: Array = []

func drawAggroFromPlayers():
	for player in players:
		var distance = global_transform.origin.distance_to(player.global_transform.origin)
		var aggroChange = calculateAggroChange(distance)
		var playerAggro = PlayerAggro.new()
		playerAggro.player = player
		playerAggro.aggro = aggroChange
		playerAggros.append(playerAggro) 
func getOrCreatePlayerAggro(player: Node) -> PlayerAggro:
	for playerAggro in playerAggros:
		if playerAggro.player == player:
			return playerAggro
	
	# If the playerAggro doesn't exist, create a new one
	var playerAggro = PlayerAggro.new()
	playerAggro.player = player
	playerAggros.append(playerAggro)
	return playerAggro

func findPlayerWithHighestAggro():
	var highestAggro = -1
	var target: PlayerAggro = null
	for playerAggro in playerAggros:
		if playerAggro.aggro > highestAggro:
			highestAggro = playerAggro.aggro
			target = playerAggro
	return target

func calculateAggroChange(distance):
	if distance <= 1:
		return 6
	elif distance <= 5:
		return 5
	elif distance <= 7:
		return 4
	elif distance <= 12:
		return 3
	elif distance <= 23:
		playerAggros.clear()
		return -2
	else:
		
		return -50000
func rotateTowardsHighestAggroPlayer():
	var target = findPlayerWithHighestAggro()
	eyes.look_at(target.player.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad(eyes.rotation.y * turn_speed))
func chase():
	var target = findPlayerWithHighestAggro()
	if target:
		rotateTowardsHighestAggroPlayer()
		var direction = (target.player.global_transform.origin - global_transform.origin).normalized()
		move_and_slide(direction * speed)
	else:
		# If no player has aggro, revert back to "walk" state
		state = "walk"
#________________________________________combat section_________________________
var floatingtext_damage = preload("res://UI/floatingtext.tscn")
onready var take_damage_audio = $TakeHit
onready var take_damage_view  = $TakeDamageView/Viewport

func takeDamage(damage:float , aggro_power:float, instigator:Node, stagger_chance:float, damage_type: String):
	state = "chase"
	var damage_to_take = damage
	var text = floatingtext_damage.instance()
	var attacker = getOrCreatePlayerAggro(instigator)#do something like this 
	attacker.aggro += damage_to_take + aggro_power
	health -= damage_to_take	
	text.amount =round(damage_to_take * 100)/ 100
	text.state = damage_type
	take_damage_view.add_child(text)
	if health < 0:
		queue_free()

#____________________________________section about moving randomly__________________________________
# Random movement variables
var minChangeInterval: float = 3
var maxChangeInterval: float = 12
var directionChangeTimer: float = 0.0
var directionChangeInterval: float = 3.0  # Interval for changing direction
var idle_chance: float = 0.5  # Chance of going idle
var idle_min_duration: float = 1.0  # Minimum duration of idle
var idle_max_duration: float = 3.0  # Maximum duration of idle
var targetRotation: Quat  # Target rotation for random movement
func moveRandomDirection():
	if directionChangeTimer >= directionChangeInterval:
		directionChangeTimer = 0.0
		var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
		var lookRotation = Vector3.FORWARD.angle_to(randomDirection)
		targetRotation = Quat(Vector3.UP, lookRotation)
		changeRandomDirection()
func changeRandomDirection():
	var randomDirection = Vector3(rand_range(-1, 1), 0, rand_range(-1, 1)).normalized()
	var lookRotation = randomDirection.angle_to(Vector3.FORWARD)
	rotate_y(lookRotation)
func getSlideVelocity(speed: float) -> Vector3:
	var forwardVector = -transform.basis.z
	return forwardVector * speed
func directionTimer():
	if state != "chase":
		if state != "attack1":
			if randf() < idle_chance:
				# Enemy goes idle
				var idle_duration = rand_range(idle_min_duration, idle_max_duration)
				set_process(true)  # Enable _process so we can track idle duration
				yield(get_tree().create_timer(idle_duration), "timeout")
				state = "idle"
				# print("Idle for:", idle_duration, "seconds")
			else:
				moveRandomDirection()
				# Set a new random interval for the timer
				directionChangeInterval = rand_range(minChangeInterval, maxChangeInterval)
				# print("Moving, next change in:", directionChangeInterval)
				state = "walk"



#stats______________________________________________________________________________________________
var entity_name = "Demon"
var level: int = 100

const base_weight = 60
var weight = 60
const base_walk_speed = 6
var walk_speed = 3
const base_run_speed = 7
var run_speed = 7
const base_crouch_speed = 2
var crouch_speed = 2
const base_jumping_power = 20
var jumping_power = 20
const base_dash_power = 20
var dash_power = 20
var attribute = 1000

var defense =  10
const base_defense = 0

#magic energy systems 
const base_max_aefis = 100
var max_aefis = 100 
var aefis = 100 
#______________________
const base_max_nefis = 100
var max_nefis = 100 
var nefis = 100 
#_______________________
const base_max_vifis = 100
var max_vifis = 100 
var vifis = 100 

#health system 
const base_max_health = 100
var max_health = 100
var health = 100
#________________________


#additional combat energy systems
const base_max_resolve = 100
var max_resolve = 100
var resolve = 100
#__________________________
const base_max_breath = 100
var max_breath = 100
var breath = 100


var scale_factor = 1
#attributes 
#leveling
var skill_points = 0

var sanity: float  = 1
var wisdom: float = 1
var memory: float = 1
var intelligence: float = 1
var instinct: float = 1

var force: float = 1
var strength: float = 1
var impact: float = 1
var ferocity: float  = 1 
var fury: float = 1 

var accuracy: float = 1
var dexterity: float = 1
var poise: float = 1
var balance: float = 1
var focus: float = 1

var haste: float = 1
var agility: float = 1
var celerity: float = 1
var flexibility: float = 1
var deflection: float = 1

var endurance: float = 1
var stamina: float = 1
var vitality: float = 1
var resistance: float = 1
var tenacity: float = 1

const base_charisma = 1 
var charisma: float = 1
var charisma_multiplier: float = 1 
var loyalty: float = 1 
var diplomacy: float = 1
var authority: float = 1
var courage: float = 1 


const base_melee_atk_speed: int = 1 
var melee_atk_speed: float = 1 
const base_ranged_atk_speed: int = 1 
var ranged_atk_speed: float = 1 
const base_casting_speed: int  = 1 
var critical_chance: float = 0.00
var critical_strength: float = 2.0
var stagger_chance: float = 0.00
var life_steal: float = 0
#resistances
var slash_resistance: int = 0 #50 equals 33.333% damage reduction 100 equals 50% damage reduction, 200 equals 66.666% damage reduction
var pierce_resistance: int = 0
var blunt_resistance: int = 0
var sonic_resistance: int = 0
var heat_resistance: int = 0
var cold_resistance: int = 0
var jolt_resistance: int = 0
var toxic_resistance: int = 0
var acid_resistance: int = 0
var bleed_resistance: int = 0
var neuro_resistance: int = 0
var radiant_resistance: int = 0


var stagger_resistance: float = 0.5
var deflection_chance : float = 0.33


var guard_dmg_absorbition: float = 2 #total damage taken will be divided by this when guarding


var base_flank_dmg : float = 10.0
var flank_dmg: float = 10.0 #extra damage to add to backstabs 

var extra_melee_atk_speed : float = 0


var slash_dmg: int = 0 
var pierce_dmg: int = 0
var blunt_dmg: int = 10
var sonic_dmg: int = 0
var heat_dmg: int = 0
var cold_dmg: int = 0
var jolt_dmg: int = 0
var toxic_dmg: int = 0
var acid_dmg: int = 0
var bleed_dmg: int = 0
var neuro_dmg: int = 0
var radiant_dmg: int = 0

var casting_speed: float = 1 

#equipment variables
var extra_sanity: float  = 0
var extra_wisdom: float = 0
var extra_memory: float = 0
var extra_intelligence: float = 0
var extra_instinct: float = 0

var extra_force: float = 0
var extra_strength: float = 0
var extra_impact: float = 0
var extra_ferocity: float  = 0
var extra_fury: float = 0

var extra_accuracy: float = 0
var extra_dexterity: float = 0
var extra_poise: float = 0
var extra_balance: float = 0
var extra_focus: float = 0

var extra_haste: float = 0
var extra_agility: float = 0
var extra_celerity: float = 0
var extra_flexibility: float = 0
var extra_deflection: float = 0

var extra_endurance: float = 0
var extra_stamina: float = 0
var extra_vitality: float = 0
var extra_resistance: float = 0
var extra_tenacity: float = 0


var extra_charisma : float = 0
var extra_loyalty : float = 0
var extra_diplomacy : float = 0
var extra_authority : float = 0
var extra_courage : float = 0


var total_sanity: float = 0
var total_wisdom: float = 0
var total_memory: float = 0
var total_intelligence: float = 0
var total_instinct: float = 0

var total_force: float = 0
var total_strength: float = 0
var total_impact: float = 0
var total_ferocity: float = 0
var total_fury: float = 0

var total_accuracy: float = 0
var total_dexterity: float = 0
var total_poise: float = 0
var total_balance: float = 0
var total_focus: float = 0

var total_haste: float = 0
var total_agility: float = 0
var total_celerity: float = 0
var total_flexibility: float = 0
var total_deflection: float = 0

var total_endurance: float = 0
var total_stamina: float = 0
var total_vitality: float = 0
var total_resistance: float = 0
var total_tenacity: float = 0

var total_charisma: float = 0
var total_loyalty: float = 0
var total_diplomacy: float = 0
var total_authority: float = 0
var total_courage: float = 0
