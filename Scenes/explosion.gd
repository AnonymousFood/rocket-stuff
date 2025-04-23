extends Node3D

@onready var sparks = $Sparks
@onready var flash = $Flash
@onready var fire = $Fire
@onready var smoke = $Smoke

# Called when the node enters the scene tree for the first time.
func _ready():
	sparks.emitting = true
	flash.emitting = true
	fire.emitting = true
	smoke.emitting = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
