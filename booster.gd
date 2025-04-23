extends RigidBody3D
@export var explosion_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if "Ground" in body.name:
		print(body.name + " Booster touched ground!")
		var explosion_instance = explosion_scene.instantiate()
		get_tree().current_scene.add_child(explosion_instance)
		explosion_instance.global_transform.origin = global_transform.origin
		#explosion_instance.get_node_or_null("$Sparks").emitting = true
