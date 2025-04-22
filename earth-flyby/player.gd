extends CharacterBody3D

@export var mouse_sensitivity := 0.003
@export var move_speed := 5.0
@export var min_speed := 0.1
@export var max_speed := 160.0

var speed_multiplier := 1.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate player (yaw)
		rotate_y(-event.relative.x * mouse_sensitivity)

		# Rotate camera (pitch)
		var cam = $Camera3D
		cam.rotate_x(-event.relative.y * mouse_sensitivity)

		# Clamp pitch
		var pitch = cam.rotation_degrees.x
		pitch = clamp(pitch, -89, 89)
		cam.rotation_degrees.x = pitch

	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		var mode = Input.get_mouse_mode()
		if mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	elif event is InputEventMouseButton and event.pressed:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			speed_multiplier = min(speed_multiplier * 1.2, max_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			speed_multiplier = max(speed_multiplier / 1.2, min_speed)

			
	elif event is InputEventKey and event.pressed and event.keycode == KEY_F:
		var is_fullscreen := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _physics_process(delta):
	var dir = Vector3.ZERO
	var final_speed := move_speed * speed_multiplier  # ← Moved this up

	# Get yaw-only forward and right directions
	var cam_basis: Basis = $Camera3D.global_transform.basis
	var forward: Vector3 = -cam_basis.z
	var right: Vector3 = cam_basis.x

	# WASD movement
	if Input.is_action_pressed("move_forward"):
		dir += forward
	if Input.is_action_pressed("move_back"):
		dir -= forward
	if Input.is_action_pressed("move_left"):
		dir -= right
	if Input.is_action_pressed("move_right"):
		dir += right

	# Vertical movement
	if Input.is_action_pressed("move_up"):
		dir += cam_basis.y
	if Input.is_action_pressed("move_down"):
		dir -= cam_basis.y

	velocity = dir.normalized() * final_speed
	move_and_slide()
	
	var speed = velocity.length()
	var label = get_node("/root/World/HUD/SpeedLabel")
	label.text = "Speed: " + str(round(speed))
