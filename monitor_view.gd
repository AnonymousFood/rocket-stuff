extends Camera3D

var is_active = false
var rotation_speed = 1.0
var height = 5.0

func _ready():
	# We'll add viewport setup here later when connecting to rocket scene
	pass

func _on_viewport_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_active = !is_active
			if is_active:
				print("Camera activated")
			else:
				print("Camera deactivated")

func _process(delta):
	if is_active:
		if Input.is_action_pressed("ui_right"):
			rotate_y(-delta * rotation_speed)
		if Input.is_action_pressed("ui_left"):
			rotate_y(delta * rotation_speed)
		if Input.is_action_pressed("ui_up"):
			height += delta * 5.0
		if Input.is_action_pressed("ui_down"):
			height -= delta * 5.0
		
		height = clamp(height, 2.0, 20.0)
		position.y = height

func rotate_around_target(angle):
	var current_pos = global_position
	var target_pos = Vector3.ZERO  # Assuming rocket is at origin
	
	var offset = current_pos - target_pos
	offset = offset.rotated(Vector3.UP, angle)
	
	global_position = target_pos + offset
	look_at(target_pos) 
