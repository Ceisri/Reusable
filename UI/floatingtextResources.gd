extends Position2D

onready var label = $Label
onready var tween = $Label/Tween
onready var texture_rect =$TextureRect

var amount = 0
var stay_time = 0.3

var off1 =-5 
var off2 = 5
var offset = Vector2(rand_range(-5, 5), rand_range(-5, 5))

var loot = "nothing"


func _ready():
	switchTexture()
	label.set_text(str(amount))
	var screen_center = get_viewport_rect().size / 2
	self.position = calculateRandomPosition(screen_center)
	# Scale from small to big
	tween.interpolate_property(self, 'scale', Vector2(0.1, 0.1), Vector2(1, 1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, stay_time)
	tween.start()

func switchTexture():
	match loot:
		"wood":
			texture_rect.texture = preload("res://resources/icons/wood.png")
		"branch":
			texture_rect.texture = preload("res://resources/icons/branch.png")
		"acorn":
			texture_rect.texture = preload("res://resources/icons/acorn.png")
		"resin":
			texture_rect.texture = preload("res://resources/icons/resin.png")
		"acorn_leaf":
			texture_rect.texture = preload("res://resources/icons/acornleaf.png")
		"crystal":
			texture_rect.texture = preload("res://resources/icons/crystal.png")
func calculateRandomPosition(center: Vector2) -> Vector2:
	offset = Vector2(rand_range(off1, off2), rand_range(off1, off2))
	return center + offset

func _on_Tween_tween_all_completed():
	self.queue_free()
