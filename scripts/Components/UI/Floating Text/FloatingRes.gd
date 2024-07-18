extends Position2D

onready var label = $Label
onready var item_name_label = $ItemNameLabel
onready var tween = $Label/Tween
onready var texture_rect =$TextureRect

var player:KinematicBody = null
var item_name:String 
var amount:int = 0
var stay_time:float = 0.45
var item_rarity:float = 0 

var off1:float =-5 
var off2:float = 5
var offset:Vector2 = Vector2(rand_range(-5, 5), rand_range(-5, 5))

func _ready()->void:
	label.text = "+" +str(amount)
	item_name_label.text = item_name
	var screen_center = get_viewport_rect().size / 2
	self.position = calculateRandomPosition(screen_center)
	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, stay_time)
	tween.start()

func calculateRandomPosition(center: Vector2) -> Vector2:
	offset = Vector2(rand_range(off1, off2), rand_range(off1, off2))
	return center + offset

func _on_Tween_tween_all_completed()->void:
	if is_instance_valid(player):
		player.popUI(player.inv_button_holder,player.ui_tween)
	self.queue_free()
