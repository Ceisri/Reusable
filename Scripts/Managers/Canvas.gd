extends CanvasLayer

var resolutions = [
	Vector2(640, 480),
	Vector2(800, 600),
	Vector2(1024, 768),
	Vector2(1280, 720),
	Vector2(1366, 768),
	Vector2(1440, 900),
	Vector2(1600, 900),
	Vector2(1680, 1050),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3840, 2160),
	Vector2(720, 480),
	Vector2(960, 540),
	Vector2(1360, 768),
	Vector2(1600, 1200),
	Vector2(1920, 1200),
	Vector2(2048, 1152),
	Vector2(2560, 1600),
	Vector2(3440, 1440),
	Vector2(3840, 1600),
	Vector2(5120, 1440),
	Vector2(5120, 2160),
	Vector2(7680, 4320),
	Vector2(8192, 4320),
	Vector2(7680, 4800),
	Vector2(8192, 4680),
	Vector2(8192, 5120),
	Vector2(8192, 5400),
	Vector2(8192, 5460),
	Vector2(9600, 5400),
	Vector2(9600, 6000),
	Vector2(10240, 4320),
	Vector2(10240, 5760),
	Vector2(11520, 6480)
]


var current_resolution_index = 0
var base_resolution = Vector2(1920, 1080)  # Base resolution for design

func _physics_process(delta):
	if Input.is_action_just_pressed("test"):
		switch_resolution()

func switch_resolution():
	current_resolution_index = (current_resolution_index + 1) % resolutions.size()
	var new_resolution = resolutions[current_resolution_index]
	get_viewport().size = new_resolution
