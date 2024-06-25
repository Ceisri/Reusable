extends KinematicBody

export var health: float = 100
export var size: float = 1
export var grow_speed: float = 0.01  # The amount by which the tree grows each tick
export var regrow_time: float = 10   # Time the tree stays invisible before regrowing
export var grow_interval: float = 0.1  # Interval for each grow tick

onready var timer: Timer = $Timer
var growing: bool = false

func _ready() -> void:
	timer.connect("timeout", self, "on_timer_timeout")
	timer.wait_time = regrow_time

func getChopped(value, instigator) -> void:
	if health > 0:
		instigator.receiveDrops(autoload.steak, value)
		instigator.receiveDrops(autoload.ribs, value)
		health -= value  # Reduce health by the value of the chop
		if health <= 0:
			hide()
			size = 0.1  # Set initial regrow size
			set_scale(Vector3(size, size, size))
			growing = false
			timer.wait_time = regrow_time
			timer.start()
	else:
		hide()
		timer.wait_time = regrow_time
		timer.start()

func on_timer_timeout() -> void:
	if growing:
		grow()
	else:
		start_growing()

func start_growing() -> void:
	health = 10  # Initial health when regrowing
	set_visible(true)
	growing = true
	timer.wait_time = grow_interval  # Adjust this to control how often the tree grows
	timer.start()

func grow() -> void:
	size += grow_speed
	set_scale(Vector3(size, size, size))
	health += grow_speed * 10  # Increase health as the tree grows

	if size >= 1:
		size = 1
		set_scale(Vector3(size, size, size))
		growing = false
		timer.stop()  # Stop growing when size is back to normal
