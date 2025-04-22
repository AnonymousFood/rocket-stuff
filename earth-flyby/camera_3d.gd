extends Node3D

@export var mouse_sensitivity := 0.003
@export var move_speed := 5.0

var rotation_x := 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_x = clamp(rotation_x, deg_to_rad(-89), deg_to_rad(89))
		rotation.y -= event.relative.x * mouse_sensitivity

		$Camera3D.rotation.x = rotation_x

func _process(delta):
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += transform.basis.x
	if Input.is_action_pressed("move_up"):
		input_dir += transform.basis.y
	if Input.is_action_pressed("move_down"):
		input_dir -= transform.basis.y

	if input_dir != Vector3.ZERO:
		translate(input_dir.normalized() * move_speed * delta)
