extends Position2D

onready var label = $Label
onready var tween = $Label/Tween
onready var texture_rect = $TextureRect

var amount = 0

var off1 = -5
var off2 = 5
var offset = Vector2(rand_range(-45, 45), rand_range(-25, 25))

func _ready():
	label.set_text(str(amount))
	var screen_center = get_viewport_rect().size / 2
	self.position = calculateRandomPosition(screen_center)
	# Scale from small to big
	tween.interpolate_property(self, 'scale', Vector2(0.1, 0.1), Vector2(1, 1), 1.5, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.5)
	# Fade out after scaling up
	tween.interpolate_property(self, 'modulate', Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.5, Tween.TRANS_LINEAR, Tween.EASE_IN, 2.0)
	tween.start()

func calculateRandomPosition(center: Vector2) -> Vector2:
	return center + offset

func _on_Tween_tween_all_completed():
	self.queue_free()

