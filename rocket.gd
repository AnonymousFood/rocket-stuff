extends CharacterBody3D

@export var thrust_power: float = 10.0
var velocity_y: float = 0.0
var gravity: float = -9.8

func _physics_process(delta):
	velocity_y += thrust_power * delta  # Apply thrust
	velocity_y += gravity * delta  # Apply gravity

	velocity = Vector3(0, velocity_y, 0)
	move_and_slide()
