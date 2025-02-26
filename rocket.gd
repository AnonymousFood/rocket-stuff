extends Node3D

var launch_speed = 5.0
var is_launched = false

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):  # Space bar
		is_launched = true
	
	if is_launched:
		position.y += launch_speed * delta 
