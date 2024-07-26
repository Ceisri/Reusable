extends Control

var can_drag:bool = false
var dragging: bool = false
var offset: Vector2

onready var left_right_button:TextureButton = $LeftRightButtonHolder/button
onready var drag_ui_button:TextureButton = $DragUItButtonHolder/button
onready var intel_button:TextureButton =$IntelButtonButtonHolder/button

func _ready()-> void:
	left_right_button.connect("pressed", self, "leftRightPressed")
	drag_ui_button.connect("pressed", self, "dragUIPressed")
	intel_button.connect("pressed", self, "intelPressed")
	extra_intel.visible = false
	extra_intel2.visible = false
	
onready var right_side_up:Control = $Up
onready var left_side_up:Control = $UpL
onready var right_side_down:Control = $Down
onready var left_side_down:Control = $DownL 
func leftRightPressed() -> void:
	var nodes = [left_side_up, right_side_up, left_side_down, right_side_down]
	for node in nodes:
		node.visible = !node.visible
onready var extra_intel:Control = $Down/ExtraIntel
onready var extra_intel2:Control = $DownL/ExtraIntel
func intelPressed() -> void:
	extra_intel.visible =  !extra_intel.visible
	extra_intel2.visible =  !extra_intel2.visible 
	

func dragUIPressed()-> void:
	can_drag = !can_drag
	print("ok")

func _physics_process(delta: float)-> void:
	if Engine.get_physics_frames() % 2 == 0:
		if can_drag ==true:
			dragUI()

func dragUI()-> void:
	if dragging:
		rect_position = get_global_mouse_position() + offset


func _input(event)->void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				# Check if the mouse is over the Control node
				if get_global_rect().has_point(event.position):
					dragging = true
					offset = rect_position - event.position
			else:
				dragging = false
				
