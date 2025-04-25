extends Label


var rocket
var label 
var world_env
var prev_speed = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rocket = get_node("%Rocket") #assign rocket node to rocket var
	world_env = get_node("/root/Main/WorldEnvironment")
	label = world_env.get_node("Label")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = rocket.get_velocityY()
	var time = rocket.get_time()
	var distance = velocity * time
	var speed = 0
	var acceleration = 0
	if time != 0:
		speed = (distance/time)
		acceleration = -1 * round((speed - prev_speed) / time)
		if speed < 5:
			speed = round(speed)
			prev_speed = speed
		else:
			speed = round(speed) * 100 
			prev_speed = speed
	if speed != 0:
		label.text = "Speed: " + str(speed) + " km/h \n" + "Acceleration: " + str(acceleration) + " m/s \n"
