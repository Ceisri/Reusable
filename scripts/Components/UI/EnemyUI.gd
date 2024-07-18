extends Control

var can_drag:bool = false
var dragging: bool = false
var offset: Vector2


func _on_DragUI_pressed():
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
				
