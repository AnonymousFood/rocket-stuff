extends WorldEnvironment

var day = true
var skyDay = preload("res://Day_Sky.tres")
var skyNight = preload("res://Night_Sky.tres")
@onready var lightSource : DirectionalLight3D = $"../Sun"
var randomizer = randi() % 2

#default funcs not needed for the swap

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randomizer == 0:
		setSkyBox(skyDay)
		lightSource.light_energy = 1
	else:
		day = !day
		setSkyBox(skyNight)
		lightSource.light_energy = 0.3
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func setSkyBox(sky : Sky):
	if environment:
		environment.sky = sky

func _input(event):
	if event.is_action_pressed("toggleSky"):
		day = !day
		if day:
			setSkyBox(skyDay)
			lightSource.light_energy = 1
		else:
			setSkyBox(skyNight)
			lightSource.light_energy = 0.2
