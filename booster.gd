extends RigidBody3D
@export var explosion_scene: PackedScene
@onready var booster_collision = $BoosterCollision
@onready var booster_model = $BoosterModel

var time_elapsed: float = 0.0
var engine_lit: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	if time_elapsed > 5.0 and not engine_lit:
		pass

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if "Ground" in body.name:
		var explosion_instance = explosion_scene.instantiate()
		add_child(explosion_instance)
		explosion_instance.global_transform.origin = booster_collision.global_transform.origin
		booster_model.visible = false
