extends Node

onready var parent = get_parent()
onready var direction_change_timer = $DirectionChangeTimer
onready var idle_timer = $IdleTimer
export (NodePath) var eyes
var originalOrientation = Quat()
var active = true
var velocity = Vector3()
var is_walking = true
var ch_dir_min = 3
var ch_dir_max = 30
var id_ti_min = 0.5
var id_ti_max = 5
func _ready():
	originalOrientation = parent.rotation  # Store the original orientation
	direction_change_timer.connect("timeout", self, "changeDirection")
	idle_timer.connect("timeout", self, "switchIdleWander")
	# Start the timer when the object is ready
	direction_change_timer.wait_time = rand_range(ch_dir_min, ch_dir_max)
	direction_change_timer.start()
	# Start the timer when the object is ready
	startIdleTimer()
	
func startIdleTimer():
	var timeout = rand_range(id_ti_min, id_ti_max)
	idle_timer.start(timeout)
func switchIdleWander():
	is_walking = !is_walking
func idle():
	is_walking = !is_walking
	
	if is_walking:
		wander()
	else:
		print ("nt mov")
		idle()
		startIdleTimer()
func wander():#move the entity in the forward direction
	if is_walking == true:
		var velocity = getSlideVelocity(parent.walk_speed)
		parent.move_and_slide(velocity)

func getSlideVelocity(speed: float) -> Vector3:# Get the forward direction
	var forward_vector = parent.transform.basis.z
	return forward_vector * speed

onready var tween = $Tween

func changeDirection():
	if parent.stats.health >0:
		if parent.state == Autoload.state_list.wander:
			var target_rotation = rand_range(-360, 360)
			tween.interpolate_property(parent, "rotation_degrees:y", parent.rotation_degrees.y, target_rotation, 0.5, Tween.TRANS_LINEAR, Tween.EASE_OUT) # Adjust the duration (0.5) and easing as needed
			tween.start()
			direction_change_timer.wait_time = rand_range(ch_dir_min, ch_dir_max)
			direction_change_timer.start()
