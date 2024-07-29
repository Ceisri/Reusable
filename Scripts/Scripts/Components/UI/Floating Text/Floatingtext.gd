extends Position2D

onready var label:Label = $Label
onready var status_label:Label = $Staggered
onready var tween:Tween = $Label/Tween
onready var texture:TextureRect = $PenHit
var player:KinematicBody = null
var amount:float = 0
var status:String = " "
var penetrating_hit:bool = false
var stay_time:float  = 0.3
var off1:float  = -20
var off2:float  = 20
var offset:Vector2 = Vector2(rand_range(-15, 15), rand_range(-15, 15))

var damage_type = Autoload.damage_type.slash
func _ready() -> void:
	if penetrating_hit:
		texture.visible = true
	match damage_type:
		Autoload.damage_type.slash:
			label.modulate = Color("#BFBFBF")
			if penetrating_hit:
				texture.modulate = Color("#BFBFBF")
		Autoload.damage_type.pierce:
			label.modulate = Color("#BFBFBF")
			if penetrating_hit:
				texture.modulate = Color("#BFBFBF")
		
		Autoload.damage_type.blunt:
			label.modulate = Color("#BFBFBF")
			if penetrating_hit:
				texture.modulate = Color("#BFBFBF")
		
		Autoload.damage_type.sonic:
			label.modulate = Color("#a9c9d3")
			if penetrating_hit:
				texture.modulate = Color("#a9c9d3")
		
		Autoload.damage_type.heat:
			label.modulate = Color("#d26045")
			if penetrating_hit:
				texture.modulate = Color("#d26045")
		
		Autoload.damage_type.cold:
			label.modulate = Color("#00d4f0")
			if penetrating_hit:
				texture.modulate = Color("#00d4f0")
		
		Autoload.damage_type.jolt:
			label.modulate = Color("#0072ff")
			if penetrating_hit:
				label.modulate = Color("#0072ff")
		
		Autoload.damage_type.toxic:
			label.modulate = Color("#831174")
			if penetrating_hit:
				texture.modulate = Color("#831174")
		
		Autoload.damage_type.acid:
			label.modulate = Color("#219a31")
			if penetrating_hit:
				texture.modulate = Color("#219a31")
		
		Autoload.damage_type.bleed:
			label.modulate = Color("#d83232")
			if penetrating_hit:
				texture.modulate = Color("#d83232")
		
		Autoload.damage_type.arcane:
			label.modulate = Color("#d47be0")
			if penetrating_hit:
				texture.modulate = Color("#d47be0")
		
		Autoload.damage_type.radiant:
			label.modulate = Color("#fffa85")
			if penetrating_hit:
				texture.modulate = Color("#fffa85")
				


	if amount >0:
		label.text = "-" + str(amount)
	else:
		label.visible = false
	status_label.text = status + "  "
		
	var screen_center = get_viewport_rect().size / 2
	self.position = calculateRandomPosition(screen_center)

	# Calculate the position adjustment based on the initial scale
	var initial_scale = self.scale
	var scale_factor = Vector2(1, 1) - Vector2(0.1, 0.1)
	var position_adjustment = (scale_factor * initial_scale) / 2

	# Move the object to the right before scaling down
	self.position.x += position_adjustment.x

	tween.interpolate_property(self, 'scale', scale, Vector2(1, 1), 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.interpolate_property(self, 'scale', Vector2(1, 1), Vector2(0.1, 0.1), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT, stay_time)
	tween.start()

	if is_instance_valid(player):
		player.popUIHit(player.health_label)

	

func calculateRandomPosition(center: Vector2) -> Vector2:
	offset = Vector2(rand_range(off1, off2), rand_range(off1, off2))
	return center + offset

func _on_Tween_tween_all_completed()->void:
	queue_free()
