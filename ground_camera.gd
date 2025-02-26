extends Camera3D

@onready var rocket = $"../Rocket" # Replace with the correct path to your rocket

func _process(delta):
	# Update the camera to always look at the rocket
	look_at(rocket.global_transform.origin + Vector3(0, 3, 0), Vector3.UP)
