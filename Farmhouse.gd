extends Node3D

@export var interaction_key := "ui_accept"  # Default key: "E" or "Enter"
@export var door: Node3D  # Assign the farmhouse door (if it moves)
var player_inside := false  # Track if player is near

func _ready():
	print("Farmhouse is ready!")

func _process(delta):
	if player_inside and Input.is_action_just_pressed(interaction_key):
		print("Player interacted with the farmhouse!")
		open_door()

func _on_body_entered(body):
	if body.is_in_group("player"):  # Ensure only the player can interact
		player_inside = true
		print("Player is near the farmhouse.")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		print("Player left the farmhouse area.")

func open_door():
	if door:
		door.rotation_degrees.y += 90  # Example: Rotate door 90 degrees
		print("The farmhouse door opens!")
	else:
		print("No door assigned! Add a door in the Inspector.")
