extends Position2D

onready var label = $Label
onready var status_label = $Staggered
onready var tween = $Label/Tween
var amount = 0
var status = " "
var stay_time = 0.3
var off1 = -20
var off2 = 20
var offset = Vector2(rand_range(-5, 5), rand_range(-5, 5))

var state = "cold"

func _ready():
	match state:
		"slash":
			label.add_color_override("font_color", Color("#BFBFBF")) 
		"pierce":
			label.add_color_override("font_color", Color("#BFBFBF"))  
		"blunt":
			label.add_color_override("font_color", Color("#BFBFBF")) 
		"sonic":
			label.add_color_override("font_color", Color("#a9c9d3"))  
		"heat":
			label.add_color_override("font_color", Color("d26045"))  
		"cold":
			label.add_color_override("font_color", Color("#00d4f0"))  
		"jolt":
			label.add_color_override("font_color", Color("#0072ff"))  
		"toxic":
			label.add_color_override("font_color", Color("#831174"))  
		"acid":
			label.add_color_override("font_color", Color("#219a31"))  
		"bleed":
			label.add_color_override("font_color", Color("#d83232")) 
		"neuro":
			label.add_color_override("font_color", Color("#d47be0")) 
		"radiant":
			label.add_color_override("font_color", Color("fffa85")) 
			label.add_color_override("font_outline", Color("fffa85")) 
		"healing":
			label.add_color_override("font_color", Color("a9f08f")) 
			label.add_color_override("font_outline", Color("000000")) 
	label.text = str(amount)
	status_label.text = status + "  "
	
	var screen_center = get_viewport_rect().size / 2
	self.position = calculateRandomPosition(screen_center)
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, stay_time)
	tween.start()

	# Set label color based on state


func calculateRandomPosition(center: Vector2) -> Vector2:
	offset = Vector2(rand_range(off1, off2), rand_range(off1, off2))
	return center + offset

func _on_Tween_tween_all_completed():
	self.queue_free()
